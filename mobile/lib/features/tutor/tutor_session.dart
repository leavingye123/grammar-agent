import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/app_exception.dart';
import 'data/tutor_repository.dart';
import 'data/tutor_stream.dart';

enum TutorMessageStatus { complete, streaming, error }

class TutorChatMessage {
  TutorChatMessage(this.role, this.content, this.status);
  final String role;
  String content;
  TutorMessageStatus status;
  String? error;
}

/// A tutor conversation lives as long as its learning context. The sheet that
/// renders it may open and close freely; only a scope change or logout clears it.
class TutorScope {
  const TutorScope({
    required this.key,
    required this.scene,
    this.grammarPointId,
    this.lessonAttemptId,
    this.questionCode,
    this.initialMessage,
  });

  final String key;
  final String scene;
  final int? grammarPointId;
  final int? lessonAttemptId;
  final String? questionCode;
  final String? initialMessage;
}

String tutorScopeKey({
  int? grammarPointId,
  int? lessonAttemptId,
  String? questionCode,
  bool review = false,
}) => lessonAttemptId != null
    ? 'result:$lessonAttemptId'
    : questionCode != null
    ? '${review ? 'review' : 'question'}:$questionCode'
    : 'teaching:$grammarPointId';

class TutorSessionState {
  const TutorSessionState({
    this.scopeKey,
    this.messages = const [],
    this.suggestions = const [],
    this.loading = false,
    this.available = false,
    this.sending = false,
    this.error,
    this.statusLoaded = false,
    this.initialMessageStarted = false,
    this.revision = 0,
  });

  final String? scopeKey;
  final List<TutorChatMessage> messages;
  final List<String> suggestions;
  final bool loading;
  final bool available;
  final bool sending;
  final String? error;
  final bool statusLoaded;
  final bool initialMessageStarted;

  /// Bumped on every message/content change so views can react to stream ticks.
  final int revision;

  TutorSessionState copyWith({
    List<TutorChatMessage>? messages,
    List<String>? suggestions,
    bool? loading,
    bool? available,
    bool? sending,
    String? error,
    bool? statusLoaded,
    bool? initialMessageStarted,
    int? revision,
    bool clearError = false,
  }) => TutorSessionState(
    scopeKey: scopeKey,
    messages: messages ?? this.messages,
    suggestions: suggestions ?? this.suggestions,
    loading: loading ?? this.loading,
    available: available ?? this.available,
    sending: sending ?? this.sending,
    error: clearError ? null : error ?? this.error,
    statusLoaded: statusLoaded ?? this.statusLoaded,
    initialMessageStarted: initialMessageStarted ?? this.initialMessageStarted,
    revision: revision ?? this.revision,
  );
}

final tutorSessionProvider =
    NotifierProvider<TutorSessionController, TutorSessionState>(
      TutorSessionController.new,
    );

class TutorSessionController extends Notifier<TutorSessionState> {
  TutorScope? _scope;
  StreamSubscription<TutorStreamEvent>? _subscription;
  CancelToken? _cancelToken;
  Timer? _paintTimer;
  final _pending = StringBuffer();
  TutorChatMessage? _active;
  List<TutorMessage> _requestHistory = [];
  String _requestText = '';
  List<TutorChatMessage> _messages = [];

  @override
  TutorSessionState build() {
    ref.onDispose(_cancelStream);
    return const TutorSessionState();
  }

  /// Re-entering the same learning context keeps the whole session (including
  /// an in-flight stream); entering a new context starts a fresh one.
  void setScope(TutorScope scope) {
    if (scope.key == state.scopeKey && (state.statusLoaded || state.loading)) {
      return;
    }
    _cancelStream();
    _scope = scope;
    _messages = [];
    _requestHistory = [];
    _requestText = '';
    _pending.clear();
    state = TutorSessionState(scopeKey: scope.key, loading: true);
    _loadStatus();
  }

  /// Logout / account switch: discard the session of the previous account.
  void clear() {
    _cancelStream();
    _scope = null;
    _messages = [];
    _requestHistory = [];
    _requestText = '';
    _pending.clear();
    state = const TutorSessionState();
  }

  void retryStatus() {
    if (_scope == null || state.loading || state.sending) return;
    state = state.copyWith(loading: true, clearError: true);
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final scope = _scope!;
    try {
      final status = await ref
          .read(tutorRepositoryProvider)
          .status(scope.scene, lessonAttemptId: scope.lessonAttemptId);
      if (!ref.mounted || !identical(scope, _scope)) return;
      state = state.copyWith(
        available: status.available,
        suggestions: status.suggestedQuestions,
        loading: false,
        statusLoaded: true,
      );
      if (status.available &&
          !state.initialMessageStarted &&
          scope.initialMessage != null) {
        state = state.copyWith(initialMessageStarted: true);
        send(scope.initialMessage!);
      }
    } catch (error) {
      if (!ref.mounted || !identical(scope, _scope)) return;
      state = state.copyWith(
        loading: false,
        available: false,
        error: error is AppException && error.code == 40311
            ? '只能总结你自己已完成的这次练习。'
            : 'Grammar Cat 暂时无法连接，请稍后重试。',
      );
    }
  }

  List<TutorMessage> _completedHistory() {
    final history = <TutorMessage>[];
    for (var i = 0; i + 1 < _messages.length; i += 2) {
      final user = _messages[i];
      final assistant = _messages[i + 1];
      if (assistant.status == TutorMessageStatus.complete) {
        history.addAll([
          TutorMessage('user', user.content),
          TutorMessage('assistant', assistant.content),
        ]);
      }
    }
    return history;
  }

  bool send(String text, {bool retry = false}) {
    if (state.sending || !state.available || _scope == null) return false;
    final message = retry ? _requestText : text.trim();
    if (message.isEmpty) return false;
    if (message.length > 2000) {
      state = state.copyWith(error: '请将问题控制在 2000 字以内。');
      return false;
    }
    if (!retry) {
      _requestHistory = _completedHistory(); // Snapshot before optimistic append.
      _requestText = message;
    }
    _pending.clear();
    if (retry) {
      _active!
        ..content = ''
        ..status = TutorMessageStatus.streaming
        ..error = null;
    } else {
      _messages.add(TutorChatMessage('user', message, TutorMessageStatus.complete));
      _active = TutorChatMessage('assistant', '', TutorMessageStatus.streaming);
      _messages.add(_active!);
    }
    final token = CancelToken();
    _cancelToken = token;
    state = state.copyWith(
      sending: true,
      clearError: true,
      messages: List.of(_messages),
      revision: state.revision + 1,
    );
    // Render the optimistic bubble before starting the request, even with a synchronous test provider.
    scheduleMicrotask(() {
      if (!ref.mounted || token.isCancelled || !state.sending) return;
      _subscription = ref
          .read(tutorRepositoryProvider)
          .streamChat(
            grammarPointId: _scope!.grammarPointId,
            lessonAttemptId: _scope!.lessonAttemptId,
            questionCode: _scope!.questionCode,
            message: message,
            history: _requestHistory,
            cancelToken: token,
          )
          .listen(_onEvent, onError: _onStreamError, onDone: () {
            if (ref.mounted && state.sending) {
              _onStreamError(const AppException('回复中断，请重试。'));
            }
          });
    });
    return true;
  }

  void _onEvent(TutorStreamEvent event) {
    if (!ref.mounted || !state.sending) return;
    if (event.done) {
      _flush();
      _active!.status = TutorMessageStatus.complete;
      state = state.copyWith(
        sending: false,
        messages: List.of(_messages),
        suggestions: event.suggestedQuestions.isNotEmpty
            ? event.suggestedQuestions
            : state.suggestions,
        revision: state.revision + 1,
      );
    } else {
      _pending.write(event.content);
      // Show the first text immediately; throttle only subsequent state updates.
      if (_active!.content.isEmpty) {
        _flush();
      } else {
        _paintTimer ??= Timer(const Duration(milliseconds: 50), _flush);
      }
    }
  }

  void _flush() {
    _paintTimer?.cancel();
    _paintTimer = null;
    if (!ref.mounted || _pending.isEmpty || _active == null) return;
    _active!.content += _pending.toString();
    _pending.clear();
    state = state.copyWith(
      messages: List.of(_messages),
      revision: state.revision + 1,
    );
  }

  void _onStreamError(Object error) {
    if (!ref.mounted || !state.sending) return;
    _flush();
    _active!.status = TutorMessageStatus.error;
    _active!.error = _active!.content.isNotEmpty
        ? '回复中断，请重试'
        : switch (error is AppException ? error.code : null) {
            50310 => 'Grammar Cat AI 暂未开启或暂时不可用。',
            50410 => 'Grammar Cat 回答超时，请重试。',
            42910 => 'Grammar Cat 正忙，请稍后重试。',
            40310 => '请先提交这道题，再询问解析。',
            40311 => '只能总结你自己已完成的这次练习。',
            _ => 'Grammar Cat 回复失败',
          };
    state = state.copyWith(
      sending: false,
      messages: List.of(_messages),
      revision: state.revision + 1,
    );
    unawaited(_subscription?.cancel());
    _cancelToken?.cancel('stream failed');
  }

  void _cancelStream() {
    _paintTimer?.cancel();
    _paintTimer = null;
    unawaited(_subscription?.cancel());
    _subscription = null;
    _cancelToken?.cancel('session ended');
    _cancelToken = null;
    _active = null;
  }
}
