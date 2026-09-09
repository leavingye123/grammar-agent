import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../data/tutor_repository.dart';
import '../data/tutor_stream.dart';
import '../../../core/theme/design_tokens.dart';

class GrammarTutorButton extends StatelessWidget {
  const GrammarTutorButton({
    super.key,
    this.grammarPointId,
    this.lessonAttemptId,
    this.questionCode,
    this.wrongAnswer = false,
    this.reviewFeedback = false,
  }) : assert((grammarPointId == null) != (lessonAttemptId == null));

  final int? grammarPointId;
  final int? lessonAttemptId;
  final String? questionCode;
  final bool wrongAnswer;
  final bool reviewFeedback;

  @override
  Widget build(BuildContext context) {
    void openTutor() {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => GrammarTutorSheet(
          grammarPointId: grammarPointId,
          lessonAttemptId: lessonAttemptId,
          initialMessage: lessonAttemptId == null ? null : '帮我总结这次练习',
          questionCode: questionCode,
          scene: lessonAttemptId != null
              ? 'result'
              : questionCode == null
              ? 'teaching'
              : wrongAnswer
              ? 'wrong'
              : 'answered',
        ),
      );
    }

    if (reviewFeedback && wrongAnswer) {
      return OutlinedButton(
        onPressed: openTutor,
        child: const Text(
          '🐱 还是没弄懂？\n问 Grammar Cat',
          textAlign: TextAlign.center,
        ),
      );
    }
    return TextButton(
      onPressed: openTutor,
      child: Text(
        lessonAttemptId != null
            ? '帮我总结这次练习'
            : questionCode == null
            ? '🐱 问 Grammar Cat'
            : wrongAnswer
            ? '🐱 不明白为什么？问 Grammar Cat'
            : '还有疑问？问 Grammar Cat',
      ),
    );
  }
}

class GrammarTutorSheet extends ConsumerStatefulWidget {
  const GrammarTutorSheet({
    super.key,
    this.grammarPointId,
    this.lessonAttemptId,
    this.initialMessage,
    this.questionCode,
    this.scene = 'teaching',
  }) : assert((grammarPointId == null) != (lessonAttemptId == null));

  final int? grammarPointId;
  final int? lessonAttemptId;
  final String? initialMessage;
  final String? questionCode;
  final String scene;

  @override
  ConsumerState<GrammarTutorSheet> createState() => _GrammarTutorSheetState();
}

enum TutorMessageStatus { complete, streaming, error }

class TutorChatMessage {
  TutorChatMessage(this.role, this.content, this.status);
  final String role;
  String content;
  TutorMessageStatus status;
  String? error;
}

class _GrammarTutorSheetState extends ConsumerState<GrammarTutorSheet> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();
  final List<TutorChatMessage> _messages = [];
  List<String> _suggestions = [];
  bool _loading = true;
  bool _available = false;
  bool _sending = false;
  bool _initialMessageStarted = false;
  bool _follow = true;
  bool _scrollScheduled = false;
  String? _error;
  StreamSubscription<TutorStreamEvent>? _subscription;
  CancelToken? _cancelToken;
  Timer? _paintTimer;
  final _pending = StringBuffer();
  TutorChatMessage? _active;
  List<TutorMessage> _requestHistory = [];
  String _requestText = '';

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() { _loading = true; _error = null; });
    try {
      final status = await ref.read(tutorRepositoryProvider).status(
        widget.scene, lessonAttemptId: widget.lessonAttemptId,
      );
      if (!mounted) return;
      setState(() {
        _available = status.available;
        _suggestions = status.suggestedQuestions;
        _loading = false;
      });
      if (_available && !_initialMessageStarted && widget.initialMessage != null) {
        _initialMessageStarted = true;
        _send(widget.initialMessage);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _available = false;
        _error = error is AppException && error.code == 40311
            ? '只能总结你自己已完成的这次练习。'
            : 'Grammar Cat 暂时无法连接，请稍后重试。';
      });
    }
  }

  List<TutorMessage> _completedHistory() {
    final history = <TutorMessage>[];
    for (var i = 0; i + 1 < _messages.length; i += 2) {
      final user = _messages[i];
      final assistant = _messages[i + 1];
      if (assistant.status == TutorMessageStatus.complete) {
        history.addAll([TutorMessage('user', user.content), TutorMessage('assistant', assistant.content)]);
      }
    }
    return history;
  }

  void _send([String? suggested, bool retry = false]) {
    if (_sending || !_available) return;
    final text = retry ? _requestText : (suggested ?? _input.text).trim();
    if (text.isEmpty) return;
    if (text.length > 2000) {
      setState(() => _error = '请将问题控制在 2000 字以内。');
      return;
    }
    if (!retry) {
      _requestHistory = _completedHistory(); // Snapshot before optimistic append.
      _requestText = text;
    }
    _pending.clear();
    setState(() {
      _sending = true;
      _error = null;
      if (retry) {
        _active!
          ..content = ''
          ..status = TutorMessageStatus.streaming
          ..error = null;
      } else {
        _input.clear();
        _messages.add(TutorChatMessage('user', text, TutorMessageStatus.complete));
        _active = TutorChatMessage('assistant', '', TutorMessageStatus.streaming);
        _messages.add(_active!);
        if (_messages.length > 8) _messages.removeRange(0, _messages.length - 8);
      }
    });
    _follow = true;
    _scrollToBottom(force: true);
    _cancelToken = CancelToken();
    // Render the optimistic bubble before starting the HTTP request, even with a synchronous test provider.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_sending) return;
      _subscription = ref.read(tutorRepositoryProvider).streamChat(
        grammarPointId: widget.grammarPointId,
        lessonAttemptId: widget.lessonAttemptId,
        questionCode: widget.questionCode,
        message: text,
        history: _requestHistory,
        cancelToken: _cancelToken,
      ).listen(_onEvent, onError: _onStreamError, onDone: () {
        if (mounted && _sending) _onStreamError(const AppException('回复中断，请重试。'));
      });
    });
  }

  void _onEvent(TutorStreamEvent event) {
    if (!mounted || !_sending) return;
    if (event.done) {
      _flush();
      setState(() {
        _sending = false;
        _active!.status = TutorMessageStatus.complete;
        if (event.suggestedQuestions.isNotEmpty) _suggestions = event.suggestedQuestions;
      });
      _scrollToBottom();
    } else {
      _pending.write(event.content);
      // Show the first text immediately; throttle only subsequent rebuilds.
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
    if (!mounted || _pending.isEmpty) return;
    setState(() { _active!.content += _pending.toString(); _pending.clear(); });
    _scrollToBottom();
  }

  void _onStreamError(Object error) {
    if (!mounted || !_sending) return;
    _flush();
    setState(() {
      _sending = false;
      _active!.status = TutorMessageStatus.error;
      _active!.error = _active!.content.isNotEmpty ? '回复中断，请重试' : switch (error is AppException ? error.code : null) {
        50310 => 'Grammar Cat AI 暂未开启或暂时不可用。',
        50410 => 'Grammar Cat 回答超时，请重试。',
        42910 => 'Grammar Cat 正忙，请稍后重试。',
        40310 => '请先提交这道题，再询问解析。',
        40311 => '只能总结你自己已完成的这次练习。',
        _ => 'Grammar Cat 回复失败',
      };
    });
    unawaited(_subscription?.cancel());
    _cancelToken?.cancel('stream failed');
    _scrollToBottom();
  }

  void _scrollToBottom({bool force = false}) {
    if ((!force && !_follow) || _scrollScheduled) return;
    _scrollScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollScheduled = false;
      if (mounted && _scroll.hasClients && (force || _follow)) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _paintTimer?.cancel();
    _cancelToken?.cancel('sheet closed');
    unawaited(_subscription?.cancel());
    _input.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.90,
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: const CircleAvatar(backgroundColor: AppColors.mint, child: Text('🐱')),
              title: const Text('Grammar Cat', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('一起把语法弄明白', style: TextStyle(fontSize: 12)),
              trailing: IconButton(tooltip: '关闭', onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
            ),
            const Divider(height: 1),
            if (_loading) const LinearProgressIndicator(),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notice) {
                  // Only user scrolling changes follow mode; new layout height must not turn following off.
                  if (notice is UserScrollNotification ||
                      (notice is ScrollUpdateNotification && notice.dragDetails != null)) {
                    _follow = notice.metrics.extentAfter < 80;
                  }
                  return false;
                },
                child: ListView(
                  key: const ValueKey('tutor-messages'),
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    if (_messages.isEmpty && _available)
                      const Padding(padding: EdgeInsets.all(12), child: Text('哪里还不太明白？选一个问题，或直接问我。', style: TextStyle(color: AppColors.secondaryText))),
                    if (!_loading && !_available) ...[
                      if (_error == null) const Text('Grammar Cat AI 暂未开启，你可以继续学习。'),
                      TextButton(onPressed: _loadStatus, child: const Text('重新检查')),
                    ],
                    if (_error != null) Text(_error!),
                    for (final message in _messages)
                      TutorChatBubble(
                        message: message,
                        onRetry: !_sending && identical(message, _active) && message.status == TutorMessageStatus.error
                            ? () => _send(null, true) : null,
                      ),
                  ],
                ),
              ),
            ),
            if (_available && _suggestions.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 116),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Wrap(spacing: 6, runSpacing: 2, children: [
                    for (final question in _suggestions)
                      ActionChip(
                        label: Text(question, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppColors.mint,
                        side: BorderSide.none,
                        onPressed: _sending ? null : () => _send(question),
                      ),
                  ]),
                ),
              ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: TextField(
                    controller: _input,
                    focusNode: _focus,
                    enabled: _available, // Keep the keyboard/focus while a reply streams.
                    maxLength: 2000, minLines: 1, maxLines: 3,
                    decoration: InputDecoration(
                      hintText: '输入你的问题…', counterText: '',
                      filled: true, fillColor: AppColors.surfaceGreen,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                  )),
                  const SizedBox(width: 8),
                  FilledButton(
                    key: const ValueKey('tutor-send'),
                    onPressed: _available && !_sending ? () => _send() : null,
                    child: _sending
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('发送'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class TutorChatBubble extends StatelessWidget {
  const TutorChatBubble({super.key, required this.message, this.onRetry});
  final TutorChatMessage message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final user = message.role == 'user';
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: user ? 0.82 : 0.96,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!user) const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 6),
                child: Text('🐱 Grammar Cat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: user ? AppColors.softGreen : AppColors.surfaceGreen,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: user
                    ? SelectableText(message.content)
                    : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (message.content.isEmpty && message.status == TutorMessageStatus.streaming)
                          const Text('Grammar Cat 正在思考…'),
                        if (message.content.isNotEmpty)
                          MarkdownBody(
                            data: message.content, selectable: true, softLineBreak: true,
                            // Model text cannot initiate image network requests or open external links.
                            imageBuilder: (_, _, _) => const SizedBox.shrink(),
                            onTapLink: (_, _, _) {},
                            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                              p: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
                              code: const TextStyle(fontFamily: 'monospace', backgroundColor: AppColors.mint),
                            ),
                          ),
                        if (message.content.isNotEmpty && message.status == TutorMessageStatus.streaming)
                          const Text('▍', style: TextStyle(color: AppColors.primary)),
                        if (message.status == TutorMessageStatus.error) ...[
                          Text(message.error ?? 'Grammar Cat 回复失败', style: const TextStyle(color: AppColors.orange)),
                          if (onRetry != null) TextButton.icon(
                            onPressed: onRetry, icon: const Icon(Icons.refresh, size: 16), label: const Text('重新生成'),
                          ),
                        ],
                      ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
