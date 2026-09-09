import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grammar_agent/core/error/app_exception.dart';
import 'package:grammar_agent/core/network/api_client.dart';
import 'package:grammar_agent/features/tutor/data/tutor_repository.dart';
import 'package:grammar_agent/features/tutor/presentation/tutor_sheet.dart';

const suggestions = ['为什么要这样用？', '能再简单解释一下吗？', '能再给我两个例子吗？', '这个知识点最容易错在哪里？'];

void main() {
  test(
    'repository sends only allowed fields and bounded history to backend',
    () async {
      final adapter = _TutorAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:18080'))
        ..httpClientAdapter = adapter;
      final repository = TutorRepository(ApiClient(dio));
      final status = await repository.status('teaching');
      expect(status.suggestedQuestions, hasLength(4));
      expect(adapter.last!.path, '/api/v1/ai/tutor/status');
      final reply = await repository.chat(
        grammarPointId: 16,
        questionCode: 'A1-016-Q001',
        message: '为什么？',
        history: List.generate(
          12,
          (i) => TutorMessage(i.isEven ? 'user' : 'assistant', 'x' * 2100),
        ),
      );
      expect(reply.answer, '因为 apple 以元音音素开头。');
      final sent = adapter.last!;
      expect(sent.path, '/api/v1/ai/tutor/chat');
      expect(sent.receiveTimeout, const Duration(seconds: 90));
      final data = sent.data as Map;
      expect(
        data.keys,
        unorderedEquals([
          'grammarPointId',
          'questionCode',
          'message',
          'history',
        ]),
      );
      expect(data['history'], hasLength(8));
      expect(
        ((data['history'] as List).first as Map)['content'],
        hasLength(2000),
      );
      await repository.chat(grammarPointId: 16, message: '再解释一下');
      expect((adapter.last!.data as Map).containsKey('questionCode'), isFalse);
      dio.close();
    },
  );

  testWidgets('disabled AI keeps chat safe and lets learner close it', (
    tester,
  ) async {
    final repository = _FakeTutor()..available = false;
    await _pump(tester, repository);
    expect(find.text('Grammar Cat AI 暂未开启，你可以继续学习。'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(repository.calls, isEmpty);
    expect(find.byTooltip('关闭'), findsOneWidget);
  });

  testWidgets(
    'four suggestions, custom question, history, and duplicate-send guard',
    (tester) async {
      final repository = _FakeTutor();
      await _pump(tester, repository);
      for (final text in suggestions) {
        expect(find.text(text), findsOneWidget);
      }
      repository.pending = Completer<TutorReply>();
      await tester.tap(find.text(suggestions.first));
      await tester.pump();
      expect(repository.calls, hasLength(1));
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      repository.pending!.complete(
        const TutorReply('因为 apple 以元音音素开头。', suggestions),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Grammar Cat：因为 apple'), findsOneWidget);
      repository.pending = null;
      await tester.enterText(find.byType(TextField), '再给我一个例子');
      await tester.tap(find.text('发送'));
      await tester.pumpAndSettle();
      expect(repository.calls.last.message, '再给我一个例子');
      expect(repository.calls.last.history, hasLength(2));
      expect(repository.calls.last.grammarPointId, 16);
      expect(repository.calls.last.questionCode, 'A1-016-Q001');
    },
  );

  testWidgets('provider failure preserves input and allows retry', (
    tester,
  ) async {
    final repository = _FakeTutor()
      ..failure = const AppException('timeout', code: 50410);
    await _pump(tester, repository);
    await tester.enterText(find.byType(TextField), '为什么这里用 an？');
    await tester.tap(find.text('发送'));
    await tester.pumpAndSettle();
    expect(find.text('Grammar Cat 回答超时，请重试。'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '为什么这里用 an？',
    );
    repository.failure = null;
    await tester.tap(find.text('发送'));
    await tester.pumpAndSettle();
    expect(repository.calls, hasLength(2));
    expect(repository.calls.last.history, isEmpty);
  });

  testWidgets('closing during request never updates a disposed widget', (
    tester,
  ) async {
    final repository = _FakeTutor()..pending = Completer<TutorReply>();
    await _pump(tester, repository);
    await tester.tap(find.text(suggestions.first));
    await tester.pump();
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    repository.pending!.complete(const TutorReply('answer', suggestions));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pump(WidgetTester tester, _FakeTutor repository) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [tutorRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(
        home: Scaffold(
          body: GrammarTutorSheet(
            grammarPointId: 16,
            questionCode: 'A1-016-Q001',
            scene: 'wrong',
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _Call {
  _Call(this.grammarPointId, this.questionCode, this.message, this.history);
  final int? grammarPointId;
  final String? questionCode;
  final String message;
  final List<TutorMessage> history;
}

class _FakeTutor extends TutorRepository {
  _FakeTutor() : super(ApiClient(Dio()));
  bool available = true;
  AppException? failure;
  Completer<TutorReply>? pending;
  final calls = <_Call>[];

  @override
  Future<TutorStatus> status(String scene, {int? lessonAttemptId}) async =>
      TutorStatus(available, suggestions);

  @override
  Future<TutorReply> chat({
    int? grammarPointId,
    int? lessonAttemptId,
    required String message,
    String? questionCode,
    List<TutorMessage> history = const [],
  }) async {
    calls.add(_Call(grammarPointId, questionCode, message, history));
    if (failure != null) throw failure!;
    if (pending != null) return pending!.future;
    return const TutorReply('因为 apple 以元音音素开头。', suggestions);
  }
}

class _TutorAdapter implements HttpClientAdapter {
  RequestOptions? last;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      jsonEncode({
        'code': 0,
        'message': 'success',
        'data': {
          if (options.path.endsWith('/status')) 'available': true,
          if (options.path.endsWith('/chat')) 'answer': '因为 apple 以元音音素开头。',
          'suggestedQuestions': [
            for (final text in suggestions) {'text': text},
          ],
        },
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
