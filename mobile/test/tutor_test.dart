import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grammar_agent/core/error/app_exception.dart';
import 'package:grammar_agent/core/network/api_client.dart';
import 'package:grammar_agent/features/tutor/data/tutor_repository.dart';
import 'package:grammar_agent/features/tutor/data/tutor_stream.dart';
import 'package:grammar_agent/features/tutor/presentation/tutor_sheet.dart';

const suggestions = ['为什么要这样用？', '能再简单解释一下吗？', '能再给我两个例子吗？', '这个知识点最容易错在哪里？'];
final send = find.byKey(const ValueKey('tutor-send'));

void main() {
  for (final streaming in [false, true]) {
    test('repository bounds history and sends only allowed fields: stream=$streaming', () async {
      final adapter = _TutorAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:18080'))..httpClientAdapter = adapter;
      addTearDown(dio.close);
      final repository = TutorRepository(ApiClient(dio));
      expect((await repository.status('teaching')).suggestedQuestions, hasLength(4));
      final history = List.generate(12, (i) => TutorMessage(i.isEven ? 'user' : 'assistant', 'x' * 2100));
      if (streaming) {
        final events = await repository.streamChat(grammarPointId: 16, questionCode: 'A1-016-Q001',
            message: '为什么？', history: history).toList();
        expect(events.first.content, '因为 apple 以元音音素开头。');
        expect(events.last.done, isTrue);
      } else {
        final reply = await repository.chat(grammarPointId: 16, questionCode: 'A1-016-Q001',
            message: '为什么？', history: history);
        expect(reply.answer, '因为 apple 以元音音素开头。');
      }
      final sent = adapter.requests.last;
      expect(sent.path, streaming ? '/api/v1/ai/tutor/chat/stream' : '/api/v1/ai/tutor/chat');
      expect(sent.receiveTimeout, const Duration(seconds: 90));
      final data = sent.data as Map;
      expect(data.keys, unorderedEquals(['grammarPointId', 'questionCode', 'message', 'history']));
      expect(data['history'], hasLength(8));
      expect(((data['history'] as List).first as Map)['content'], hasLength(2000));
    });
  }

  test('only a missing stream route falls back to the legacy endpoint', () async {
    final adapter = _TutorAdapter()..streamStatus = 404;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))..httpClientAdapter = adapter;
    addTearDown(dio.close);
    final repository = TutorRepository(ApiClient(dio));
    final events = await repository.streamChat(grammarPointId: 16, message: 'why').toList();
    expect(events.last.done, isTrue);
    expect(adapter.requests.map((r) => r.path), ['/api/v1/ai/tutor/chat/stream', '/api/v1/ai/tutor/chat']);
    adapter.requests.clear();
    adapter.streamStatus = 503;
    await expectLater(repository.streamChat(grammarPointId: 16, message: 'why'), emitsError(isA<AppException>()));
    expect(adapter.requests, hasLength(1));
  });

  testWidgets('disabled AI preserves the learning exit and makes no chat request', (tester) async {
    final repository = _FakeTutor()..available = false;
    await _pump(tester, repository);
    expect(find.text('Grammar Cat AI 暂未开启，你可以继续学习。'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    expect(tester.widget<FilledButton>(send).onPressed, isNull);
    expect(repository.calls, isEmpty);
    expect(find.byTooltip('关闭'), findsOneWidget);
  });

  testWidgets('optimistic user bubble and empty input precede the first provider token', (tester) async {
    final repository = _FakeTutor();
    await _pump(tester, repository);
    await tester.enterText(find.byType(TextField), '再给我一个例子');
    await tester.tap(send);
    await tester.pump();
    expect(_messages(tester).first.content, '再给我一个例子');
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
    expect(find.text('Grammar Cat 正在思考…'), findsOneWidget);
    expect(tester.widget<FilledButton>(send).onPressed, isNull);
    expect(repository.calls, hasLength(1));
    expect(repository.calls.single.history, isEmpty);
    expect(tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus, isTrue);

    repository.current.add(const TutorStreamEvent.delta('A'));
    await tester.pump();
    expect(_messages(tester).last.content, 'A');
    expect(find.text('Grammar Cat 正在思考…'), findsNothing);
    repository.current.add(const TutorStreamEvent.delta('B'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(_messages(tester).last.content, 'AB');
    repository.current.add(const TutorStreamEvent.delta('C'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(_messages(tester).last.content, 'ABC');
    repository.current.add(const TutorStreamEvent.done(suggestions));
    unawaited(repository.current.close());
    await tester.pumpAndSettle();
    expect(_messages(tester).last.status, TutorMessageStatus.complete);
    expect(tester.widget<FilledButton>(send).onPressed, isNotNull);

    await tester.enterText(find.byType(TextField), '再解释一下');
    await tester.tap(send);
    await tester.pump();
    expect(repository.calls.last.history.map((m) => m.content), ['再给我一个例子', 'ABC']);
    expect(repository.calls.last.grammarPointId, 16);
    expect(repository.calls.last.questionCode, 'A1-016-Q001');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('four chips directly send a user message and are disabled while streaming', (tester) async {
    final repository = _FakeTutor();
    await _pump(tester, repository);
    expect(find.byType(ActionChip), findsNWidgets(4));
    await tester.tap(find.text(suggestions.first));
    await tester.pump();
    expect(_messages(tester).first.content, suggestions.first);
    expect(repository.calls.single.message, suggestions.first);
    expect(tester.widget<ActionChip>(find.byType(ActionChip).first).onPressed, isNull);
    expect(tester.widget<FilledButton>(send).onPressed, isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('partial failure preserves both messages and retry reuses the same user turn', (tester) async {
    final repository = _FakeTutor();
    await _pump(tester, repository);
    await tester.enterText(find.byType(TextField), '为什么这里用 an？');
    await tester.tap(send);
    await tester.pump();
    repository.current.add(const TutorStreamEvent.delta('元音'));
    await tester.pump();
    repository.current.addError(const AppException('secret', code: 50410));
    await tester.pumpAndSettle();
    expect(_messages(tester), hasLength(2));
    expect(_messages(tester).last.content, '元音');
    expect(_messages(tester).last.status, TutorMessageStatus.error);
    expect(find.text('回复中断，请重试'), findsOneWidget);
    expect(find.textContaining('secret'), findsNothing);
    await tester.tap(find.text('重新生成'));
    await tester.pump();
    expect(_messages(tester), hasLength(2));
    expect(repository.calls, hasLength(2));
    expect(repository.calls.last.message, '为什么这里用 an？');
    expect(repository.calls.last.history, isEmpty);
    repository.current.add(const TutorStreamEvent.delta('重试成功'));
    repository.current.add(const TutorStreamEvent.done(suggestions));
    unawaited(repository.current.close());
    await tester.pumpAndSettle();
    expect(_messages(tester).last.content, '重试成功');
    expect(find.text('重新生成'), findsNothing);
  });

  testWidgets('closing during streaming cancels subscription and request', (tester) async {
    final repository = _FakeTutor();
    await _pump(tester, repository);
    await tester.tap(find.text(suggestions.first));
    await tester.pump();
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    expect(repository.token!.isCancelled, isTrue);
    expect(repository.cancelled, isTrue);
    repository.current.add(const TutorStreamEvent.delta('late token'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('stream follows the bottom but respects manual scrolling through a long answer', (tester) async {
    final repository = _FakeTutor();
    await _pump(tester, repository);
    await tester.tap(find.text(suggestions.first));
    await tester.pump();
    repository.current.add(TutorStreamEvent.delta(List.generate(60, (i) => 'Example $i').join('\n\n')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    final list = find.byKey(const ValueKey('tutor-messages'));
    final scroll = tester.widget<ListView>(list).controller!;
    expect(scroll.position.extentAfter, lessThan(2));
    await tester.drag(list, const Offset(0, 220));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(scroll.position.extentAfter, greaterThan(80));
    final before = scroll.offset;
    repository.current.add(const TutorStreamEvent.delta('\n\nNew example'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump();
    expect(scroll.offset, closeTo(before, 1));
    await tester.drag(list, const Offset(0, -1000));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    repository.current.add(const TutorStreamEvent.delta('\n\nFollowing again'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump();
    expect(scroll.position.extentAfter, lessThan(2));
    expect(tester.getRect(send).bottom, lessThanOrEqualTo(600));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('modal input stays above a simulated keyboard', (tester) async {
    final repository = _FakeTutor();
    addTearDown(repository.dispose);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(ProviderScope(
      overrides: [tutorRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: Scaffold(body: GrammarTutorButton(grammarPointId: 16))),
    ));
    await tester.tap(find.byType(GrammarTutorButton));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 200);
    await tester.pumpAndSettle();
    expect(tester.getRect(send).bottom, lessThanOrEqualTo(400));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Markdown renders bold text without raw stars and tolerates incomplete tokens', (tester) async {
    final message = TutorChatMessage('assistant', '**', TutorMessageStatus.streaming);
    Future<void> render() => tester.pumpWidget(MaterialApp(home: Scaffold(
      body: TutorChatBubble(message: message),
    )));
    await render();
    expect(tester.takeException(), isNull);
    message.content = '**are**\n\n- *you*\n- `are`\n\n1. English example\n\n中文解释';
    message.status = TutorMessageStatus.complete;
    await render();
    expect(find.byType(MarkdownBody), findsOneWidget);
    final textSpans = tester.widgetList<SelectableText>(find.byType(SelectableText))
        .map((w) => w.textSpan).whereType<TextSpan>().expand(_spans).toList();
    expect(textSpans.any((s) => s.text == 'are' && s.style?.fontWeight == FontWeight.bold), isTrue);
    expect(textSpans.map((s) => s.text ?? '').join(), isNot(contains('**')));
    expect(tester.takeException(), isNull);
  });
}

Iterable<TextSpan> _spans(TextSpan span) sync* {
  yield span;
  for (final child in span.children ?? <InlineSpan>[]) {
    if (child is TextSpan) yield* _spans(child);
  }
}

List<TutorChatMessage> _messages(WidgetTester tester) => tester
    .widgetList<TutorChatBubble>(find.byType(TutorChatBubble)).map((w) => w.message).toList();

Future<void> _pump(WidgetTester tester, _FakeTutor repository) async {
  addTearDown(repository.dispose);
  await tester.pumpWidget(ProviderScope(
    overrides: [tutorRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: Scaffold(body: GrammarTutorSheet(
      grammarPointId: 16, questionCode: 'A1-016-Q001', scene: 'wrong',
    ))),
  ));
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
  bool cancelled = false;
  CancelToken? token;
  final calls = <_Call>[];
  final streams = <StreamController<TutorStreamEvent>>[];
  StreamController<TutorStreamEvent> get current => streams.last;
  void dispose() {
    for (final controller in streams) {
      unawaited(controller.close());
    }
  }

  @override
  Future<TutorStatus> status(String scene, {int? lessonAttemptId}) async => TutorStatus(available, suggestions);

  @override
  Stream<TutorStreamEvent> streamChat({
    int? grammarPointId, int? lessonAttemptId, required String message,
    String? questionCode, List<TutorMessage> history = const [], CancelToken? cancelToken,
  }) {
    calls.add(_Call(grammarPointId, questionCode, message, history));
    token = cancelToken;
    final controller = StreamController<TutorStreamEvent>(onCancel: () { cancelled = true; });
    streams.add(controller);
    return controller.stream;
  }
}

class _TutorAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  int streamStatus = 200;
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    if (options.path.endsWith('/stream')) {
      return ResponseBody.fromString(streamStatus == 200
          ? 'event: delta\ndata: ${jsonEncode({'content': '因为 apple 以元音音素开头。'})}\n\nevent: done\ndata: {}\n\n'
          : jsonEncode({'code': 50310, 'message': 'unavailable'}), streamStatus,
          headers: {Headers.contentTypeHeader: [streamStatus == 200 ? 'text/event-stream' : Headers.jsonContentType]});
    }
    return ResponseBody.fromString(jsonEncode({
      'code': 0, 'message': 'success', 'data': {
        'available': true, 'answer': '因为 apple 以元音音素开头。',
        'suggestedQuestions': [for (final text in suggestions) {'text': text}],
      },
    }), 200, headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
  }
  @override
  void close({bool force = false}) {}
}
