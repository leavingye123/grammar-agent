import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grammar_agent/core/network/api_client.dart';
import 'package:grammar_agent/core/network/api_endpoints.dart';
import 'package:grammar_agent/core/network/api_response.dart';
import 'package:grammar_agent/core/network/auth_interceptor.dart';
import 'package:grammar_agent/core/network/network_providers.dart';
import 'package:grammar_agent/core/storage/token_storage.dart';
import 'package:grammar_agent/features/auth/data/auth_repository.dart';
import 'package:grammar_agent/features/auth/domain/auth_models.dart';
import 'package:grammar_agent/features/auth/presentation/auth_controller.dart';
import 'package:grammar_agent/features/auth/presentation/auth_screens.dart';
import 'package:grammar_agent/features/course/domain/course_models.dart';
import 'package:grammar_agent/features/lesson/data/lesson_repository.dart';
import 'package:grammar_agent/features/lesson/domain/lesson_models.dart';
import 'package:grammar_agent/features/lesson/presentation/lesson_session.dart';
import 'package:grammar_agent/features/review/domain/review_models.dart';

const userJson = {
  'id': 1,
  'email': 'test@example.com',
  'username': 'tester',
  'avatarUrl': null,
  'nativeLanguage': 'zh',
  'status': 'ACTIVE',
  'createdAt': '2026-01-01T00:00:00Z',
};
const tokenJson = {
  'accessToken': 'access',
  'refreshToken': 'refresh',
  'tokenType': 'Bearer',
  'accessExpiresIn': 900,
  'refreshExpiresIn': 604800,
};
const questionJson = {
  'id': 10,
  'questionType': 'SINGLE_CHOICE',
  'questionContent': 'Choose',
  'options': [
    {'id': 'A', 'text': 'is'},
    {'id': 'B', 'text': 'are'},
  ],
  'difficulty': 1,
  'sortOrder': 1,
};

void main() {
  test('1 ApiResponse 成功解析', () {
    final value = ApiResponse<int>.fromJson({
      'code': 0,
      'message': 'success',
      'data': 7,
      'timestamp': 'now',
    }, (j) => j as int);
    expect(value.data, 7);
    expect(value.code, 0);
  });
  test('2 API Error envelope 解析', () {
    final value = ApiResponse<Object?>.fromJson({
      'code': 40901,
      'message': 'Email already exists',
      'data': null,
    }, (j) => j);
    expect(value.code, 40901);
    expect(value.message, contains('Email'));
  });
  test('3 TokenStorage 保存及清理', () async {
    final storage = MemoryTokenStorage();
    final pair = TokenPair.fromJson(tokenJson);
    await storage.saveTokens(pair);
    expect(await storage.getAccessToken(), 'access');
    await storage.clearTokens();
    expect(await storage.getRefreshToken(), isNull);
  });
  test('4 Auth 状态初始化', () async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        tokenStorageProvider.overrideWithValue(MemoryTokenStorage()),
      ],
    );
    addTearDown(container.dispose);
    expect(container.read(authProvider).status, AuthStatus.bootstrapping);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(authProvider).status, AuthStatus.authenticated);
  });
  test('5 Login 表单基础校验', () {
    expect(validateEmail('bad'), isNotNull);
    expect(validateEmail('a@b.com'), isNull);
    expect(validatePassword(''), isNotNull);
  });
  test('6 Auth Repository 登录成功解析', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://test'));
    dio.httpClientAdapter = _JsonAdapter(
      (_) => _ok({'user': userJson, 'tokens': tokenJson}),
    );
    final storage = MemoryTokenStorage();
    final user = await RemoteAuthRepository(
      ApiClient(dio),
      storage,
    ).login('test@example.com', 'Password1');
    expect(user.username, 'tester');
    expect(await storage.getRefreshToken(), 'refresh');
  });
  test('7 LearningPath JSON 解析', () {
    final path = LearningPath.fromJson({
      'language': {
        'id': 1,
        'code': 'en',
        'name': 'English',
        'nativeName': 'English',
      },
      'levels': [
        {
          'id': 1,
          'code': 'A1',
          'name': 'Beginner',
          'sortOrder': 1,
          'chapters': [],
        },
      ],
    });
    expect(path.levels.single.code, 'A1');
  });
  test('8 QuestionResponse 不依赖 correctAnswer', () {
    final q = Question.fromJson({
      ...questionJson,
      'correctAnswer': {'optionId': 'A'},
    });
    expect(q.toJson().containsKey('correctAnswer'), isFalse);
  });
  test('9 六种题型 Answer Request 序列化', () {
    expect(answerRequest(QuestionType.singleChoice, 'A', 1)['answer'], {
      'optionId': 'A',
    });
    expect(
      answerRequest(QuestionType.multipleChoice, ['A', 'B'], 1)['answer'],
      {
        'optionIds': ['A', 'B'],
      },
    );
    expect(answerRequest(QuestionType.fillBlank, 'is', 1)['answer'], 'is');
    expect(
      answerRequest(QuestionType.sentenceOrder, ['I', 'am'], 1)['answer'],
      {
        'tokens': ['I', 'am'],
      },
    );
    expect(answerRequest(QuestionType.trueFalse, true, 1)['answer'], isTrue);
    expect(
      answerRequest(QuestionType.correction, 'She is.', 1)['answer'],
      'She is.',
    );
  });
  test('10 Lesson Session 当前题推进', () async {
    final fake = _FakeLessonRepository();
    final container = ProviderContainer(
      overrides: [lessonRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);
    final provider = lessonSessionProvider(1);
    container.listen(provider, (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 10));
    container.read(provider.notifier).setAnswer('A');
    await container.read(provider.notifier).submit();
    await container.read(provider.notifier).continueNext();
    expect(container.read(provider).currentIndex, 1);
  });
  test('11 Submit 后不能重复提交同一题', () async {
    final fake = _FakeLessonRepository();
    final container = ProviderContainer(
      overrides: [lessonRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);
    final provider = lessonSessionProvider(1);
    container.listen(provider, (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 10));
    container.read(provider.notifier).setAnswer('A');
    expect(await container.read(provider.notifier).submit(), isTrue);
    expect(await container.read(provider.notifier).submit(), isFalse);
    expect(fake.submitCalls, 1);
  });
  test('12 Lesson Completion Response 解析', () {
    final v = LessonCompletion.fromJson({
      'lessonId': 1,
      'status': 'COMPLETED',
      'totalCount': 5,
      'correctCount': 4,
      'score': 80,
      'xpEarned': 8,
    });
    expect(v.score, 80);
  });
  test('13 ReviewSummary 解析', () {
    final v = ReviewSummary.fromJson({
      'dueCount': 2,
      'unmasteredCount': 3,
      'masteredCount': 4,
      'nextReviewAt': '2026-01-02T00:00:00Z',
    });
    expect(v.unmasteredCount, 3);
  });
  test('14 ReviewQuestion 解析', () {
    final v = ReviewQuestion.fromJson({
      'wrongQuestionId': 2,
      'question': questionJson,
      'wrongCount': 1,
      'lastWrongAt': '2026-01-01T00:00:00Z',
      'nextReviewAt': '2026-01-02T00:00:00Z',
    });
    expect(v.question.id, 10);
  });
  test('15 ReviewAnswer mastered 状态解析', () {
    final v = ReviewAnswerResult.fromJson({
      'questionId': 10,
      'correct': true,
      'correctAnswer': {'optionId': 'A'},
      'explanation': 'ok',
      'mastered': true,
      'wrongCount': 1,
      'nextReviewAt': '2026-01-02T00:00:00Z',
      'grammarPointMastery': 100,
    });
    expect(v.mastered, isTrue);
  });
  test('16 401 refresh 逻辑', () async {
    final storage = MemoryTokenStorage()
      ..accessToken = 'old'
      ..refreshToken = 'valid';
    final adapter = _RefreshAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://test'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(
      AuthInterceptor(dio: dio, storage: storage, onSessionExpired: () {}),
    );
    final response = await dio.get('/secure');
    expect(response.statusCode, 200);
    expect(adapter.refreshes, 1);
    expect(await storage.getAccessToken(), 'fresh');
  });
  test('17 并发多个 401 只触发一次 refresh', () async {
    final storage = MemoryTokenStorage()
      ..accessToken = 'old'
      ..refreshToken = 'valid';
    final adapter = _RefreshAdapter(delay: true);
    final dio = Dio(BaseOptions(baseUrl: 'http://test'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(
      AuthInterceptor(dio: dio, storage: storage, onSessionExpired: () {}),
    );
    await Future.wait([
      dio.get('/secure/a'),
      dio.get('/secure/b'),
      dio.get('/secure/c'),
    ]);
    expect(adapter.refreshes, 1);
  });
  test('18 refresh 失败清空 auth', () async {
    var expired = false;
    final storage = MemoryTokenStorage()
      ..accessToken = 'old'
      ..refreshToken = 'bad';
    final adapter = _RefreshAdapter(fail: true);
    final dio = Dio(BaseOptions(baseUrl: 'http://test'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        storage: storage,
        onSessionExpired: () => expired = true,
      ),
    );
    await expectLater(dio.get('/secure'), throwsA(isA<DioException>()));
    expect(await storage.getAccessToken(), isNull);
    expect(expired, isTrue);
  });
}

ResponseBody _ok(Object? data) => ResponseBody.fromString(
  jsonEncode({
    'code': 0,
    'message': 'success',
    'data': data,
    'timestamp': 'now',
  }),
  200,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this.handler);
  final ResponseBody Function(RequestOptions) handler;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => handler(options);
  @override
  void close({bool force = false}) {}
}

class _RefreshAdapter implements HttpClientAdapter {
  _RefreshAdapter({this.fail = false, this.delay = false});
  final bool fail, delay;
  int refreshes = 0;
  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<Uint8List>? stream,
    Future<void>? cancel,
  ) async {
    if (o.path == ApiEndpoints.refresh) {
      refreshes++;
      if (delay) await Future<void>.delayed(const Duration(milliseconds: 40));
      if (fail) {
        return ResponseBody.fromString(
          jsonEncode({'code': 40106, 'message': 'invalid', 'data': null}),
          401,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      }
      return _ok({
        ...tokenJson,
        'accessToken': 'fresh',
        'refreshToken': 'rotated',
      });
    }
    if (o.headers['Authorization'] == 'Bearer fresh') return _ok({'ok': true});
    return ResponseBody.fromString(
      jsonEncode({'code': 40100, 'message': 'expired', 'data': null}),
      401,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FakeAuthRepository implements AuthRepository {
  final user = UserProfile.fromJson(userJson);
  @override
  Future<UserProfile?> restore() async => user;
  @override
  Future<UserProfile> login(String e, String p) async => user;
  @override
  Future<UserProfile> register(String e, String u, String p) async => user;
  @override
  Future<void> logout() async {}
}

class _FakeLessonRepository extends LessonRepository {
  _FakeLessonRepository() : super(ApiClient(Dio()));
  int submitCalls = 0;
  final qs = [
    Question.fromJson(questionJson),
    Question.fromJson({...questionJson, 'id': 11, 'sortOrder': 2}),
  ];
  @override
  Future<List<Question>> questions(int id) async => qs;
  @override
  Future<SubmitAnswerResult> submit(
    int id,
    QuestionType type,
    Object answer,
    int duration,
  ) async {
    submitCalls++;
    return SubmitAnswerResult(
      questionId: id,
      correct: true,
      correctAnswer: const {'optionId': 'A'},
      explanation: 'Because',
      xpEarned: 1,
      grammarPointMastery: 20,
    );
  }

  @override
  Future<LessonCompletion> complete(int id) async => const LessonCompletion(
    lessonId: 1,
    status: 'COMPLETED',
    totalCount: 2,
    correctCount: 2,
    score: 100,
    xpEarned: 2,
  );
}
