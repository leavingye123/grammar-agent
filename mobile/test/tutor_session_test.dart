import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grammar_agent/core/network/api_client.dart';
import 'package:grammar_agent/features/auth/data/auth_repository.dart';
import 'package:grammar_agent/features/auth/domain/auth_models.dart';
import 'package:grammar_agent/features/auth/presentation/auth_controller.dart';
import 'package:grammar_agent/core/storage/token_storage.dart';
import 'package:grammar_agent/core/network/network_providers.dart';
import 'package:grammar_agent/features/tutor/data/tutor_repository.dart';
import 'package:grammar_agent/features/tutor/data/tutor_stream.dart';
import 'package:grammar_agent/features/tutor/tutor_session.dart';

const suggestions = ['为什么要这样用？', '能再简单解释一下吗？', '能再给我两个例子吗？', '这个知识点最容易错在哪里？'];

void main() {
  late _FakeTutor repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeTutor();
    container = ProviderContainer(overrides: [
      tutorRepositoryProvider.overrideWithValue(repository),
      authRepositoryProvider.overrideWithValue(_FakeAuth()),
      tokenStorageProvider.overrideWithValue(MemoryTokenStorage()),
    ]);
    addTearDown(container.dispose);
    addTearDown(repository.dispose);
  });

  TutorSessionController ctrl() => container.read(tutorSessionProvider.notifier);
  TutorSessionState cur() => container.read(tutorSessionProvider);

  TutorScope question(String code, {int grammarPointId = 16, String scene = 'answered'}) =>
      TutorScope(key: 'question:$code', scene: scene,
          grammarPointId: grammarPointId, questionCode: code);
  TutorScope review(String code, {int grammarPointId = 16}) =>
      TutorScope(key: 'review:$code', scene: 'wrong',
          grammarPointId: grammarPointId, questionCode: code);
  TutorScope teaching(int pointId) =>
      TutorScope(key: 'teaching:$pointId', scene: 'teaching', grammarPointId: pointId);
  TutorScope result(int attemptId) => TutorScope(
      key: 'result:$attemptId', scene: 'result', lessonAttemptId: attemptId,
      initialMessage: '帮我总结这次练习');

  Future<void> open(TutorScope scope) async {
    ctrl().setScope(scope);
    await _settle();
  }

  Future<void> completeCurrent(String text) async {
    repository.current.add(TutorStreamEvent.delta(text));
    repository.current.add(const TutorStreamEvent.done(suggestions));
    unawaited(repository.current.close());
    await _settle();
  }

  Future<void> round(String text) async {
    expect(ctrl().send(text), isTrue);
    await _settle();
    await completeCurrent('回答:$text');
  }

  test('formal question: closing and reopening the same question keeps both user and assistant turns', () async {
    await open(question('A1-001-Q003'));
    await round('为什么这里用 are？');
    await round('再给我一个例子。');
    expect(cur().messages.map((m) => m.role), ['user', 'assistant', 'user', 'assistant']);
    final statusCalls = repository.statusCalls;

    ctrl().setScope(question('A1-001-Q003')); // reopen same context
    await _settle();
    expect(cur().scopeKey, 'question:A1-001-Q003');
    expect(cur().messages.map((m) => m.content),
        ['为什么这里用 are？', '回答:为什么这里用 are？', '再给我一个例子。', '回答:再给我一个例子。']);
    expect(repository.statusCalls, statusCalls); // no redundant status request
    expect(repository.calls, hasLength(2)); // no duplicate chat request
  });

  test('formal question: entering the next question clears the session', () async {
    await open(question('A1-001-Q003'));
    await round('为什么？');
    ctrl().setScope(question('A1-001-Q004'));
    await _settle();
    expect(cur().scopeKey, 'question:A1-001-Q004');
    expect(cur().messages, isEmpty);
    expect(cur().sending, isFalse);
  });

  test('teaching: page 1 and page 2 of the same grammar point share one session', () async {
    await open(teaching(9));
    await round('这个知识点怎么理解？');
    ctrl().setScope(teaching(9)); // page 2 re-enters the same scope
    await _settle();
    expect(cur().messages, hasLength(2));
    expect(cur().messages.first.content, '这个知识点怎么理解？');
  });

  test('teaching to formal question: teaching session is cleared', () async {
    await open(teaching(9));
    await round('这个知识点怎么理解？');
    ctrl().setScope(question('A1-009-Q001', grammarPointId: 9));
    await _settle();
    expect(cur().scopeKey, 'question:A1-009-Q001');
    expect(cur().messages, isEmpty);
  });

  test('review: reopening the same review question keeps the chat', () async {
    await open(review('A1-016-Q001'));
    await round('为什么错？');
    ctrl().setScope(review('A1-016-Q001'));
    await _settle();
    expect(cur().messages.map((m) => m.content), ['为什么错？', '回答:为什么错？']);
  });

  test('review: moving to the next review question clears the chat', () async {
    await open(review('A1-016-Q001'));
    await round('为什么错？');
    ctrl().setScope(review('A1-016-Q002'));
    await _settle();
    expect(cur().scopeKey, 'review:A1-016-Q002');
    expect(cur().messages, isEmpty);
  });

  test('result: closing and reopening the same lesson attempt keeps the chat', () async {
    await open(result(99));
    await completeCurrent('回答:帮我总结这次练习'); // initial summary turn
    await round('我主要错在哪？');
    ctrl().setScope(result(99));
    await _settle();
    expect(cur().messages.map((m) => m.content),
        ['帮我总结这次练习', '回答:帮我总结这次练习', '我主要错在哪？', '回答:我主要错在哪？']);
  });

  test('result: entering the next lesson clears the chat', () async {
    await open(result(99));
    await completeCurrent('回答:帮我总结这次练习');
    ctrl().setScope(result(100));
    await _settle();
    expect(cur().scopeKey, 'result:100');
    expect(cur().messages, hasLength(2)); // fresh auto-summary turn only
    expect(cur().messages.first.content, '帮我总结这次练习');
  });

  test('logout clears the tutor session and account switch cannot see the previous chat', () async {
    final auth = container.read(authProvider.notifier);
    await _settle(); // bootstrap
    await open(question('A1-001-Q003'));
    await round('为什么？');
    expect(cur().messages, hasLength(2));

    await auth.logout();
    expect(container.read(tutorSessionProvider).messages, isEmpty);
    expect(container.read(tutorSessionProvider).scopeKey, isNull);

    // Logging in as another account still starts from a blank session.
    await auth.login('b@example.com', 'password');
    await open(question('A1-001-Q003'));
    await round('新的问题');
    expect(cur().messages.map((m) => m.content), ['新的问题', '回答:新的问题']);
  });

  test('scope change cancels an in-flight stream without a second request', () async {
    await open(question('A1-001-Q003'));
    expect(ctrl().send('正在回答的问题'), isTrue);
    await _settle();
    repository.current.add(const TutorStreamEvent.delta('部分'));
    await _settle();
    expect(cur().messages.last.content, '部分');

    final token = repository.token!;
    ctrl().setScope(question('A1-001-Q004'));
    await _settle();
    expect(token.isCancelled, isTrue);
    expect(repository.calls, hasLength(1));
    expect(cur().messages, isEmpty);

    // Late tokens from the old stream are ignored.
    repository.current.add(const TutorStreamEvent.delta('late'));
    await _settle();
    expect(cur().messages, isEmpty);
  });
}

Future<void> _settle() async {
  for (var i = 0; i < 4; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class _FakeAuth implements AuthRepository {
  @override
  Future<void> logout() async {}

  @override
  Future<UserProfile> login(String email, String password) async => _user(email);

  @override
  Future<UserProfile> register(String email, String username, String password) async => _user(email);

  @override
  Future<UserProfile?> restore() async => null;

  UserProfile _user(String email) => UserProfile(
    id: 1, email: email, username: 'user', status: 'ACTIVE', createdAt: DateTime(2026),
  );
}

class _FakeTutor extends TutorRepository {
  _FakeTutor() : super(ApiClient(Dio()));
  final calls = <({String message, List<TutorMessage> history})>[];
  final streams = <StreamController<TutorStreamEvent>>[];
  int statusCalls = 0;
  CancelToken? token;

  StreamController<TutorStreamEvent> get current => streams.last;
  void dispose() {
    for (final controller in streams) {
      unawaited(controller.close());
    }
  }

  @override
  Future<TutorStatus> status(String scene, {int? lessonAttemptId}) async {
    statusCalls++;
    return const TutorStatus(true, suggestions);
  }

  @override
  Stream<TutorStreamEvent> streamChat({
    int? grammarPointId, int? lessonAttemptId, required String message,
    String? questionCode, List<TutorMessage> history = const [], CancelToken? cancelToken,
  }) {
    calls.add((message: message, history: history));
    token = cancelToken;
    final controller = StreamController<TutorStreamEvent>();
    streams.add(controller);
    return controller.stream;
  }
}
