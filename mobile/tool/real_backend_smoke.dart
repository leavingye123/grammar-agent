import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grammar_agent/core/network/api_client.dart';
import 'package:grammar_agent/core/network/api_endpoints.dart';
import 'package:grammar_agent/core/network/auth_interceptor.dart';
import 'package:grammar_agent/core/storage/token_storage.dart';
import 'package:grammar_agent/features/auth/data/auth_repository.dart';
import 'package:grammar_agent/features/auth/domain/auth_models.dart';
import 'package:grammar_agent/features/course/data/course_repository.dart';
import 'package:grammar_agent/features/course/domain/grammar_tree.dart';
import 'package:grammar_agent/features/home/data/home_repository.dart';
import 'package:grammar_agent/features/lesson/data/lesson_repository.dart';
import 'package:grammar_agent/features/lesson/domain/lesson_models.dart';
import 'package:grammar_agent/features/review/data/review_repository.dart';

void main() {
  test('real backend mobile learning and review smoke', _run);
}

Future<void> _run() async {
  final password = Platform.environment['SMOKE_PASSWORD'];
  if (password == null || password.isEmpty) {
    throw StateError('Set SMOKE_PASSWORD to a disposable test password.');
  }
  final baseUrl =
      Platform.environment['API_BASE_URL'] ?? 'http://localhost:18080';
  final email =
      'mobile-smoke-${DateTime.now().microsecondsSinceEpoch}@example.com';
  final storage = MemoryTokenStorage();
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
  var expired = false;
  late final AuthInterceptor interceptor;
  interceptor = AuthInterceptor(
    dio: dio,
    storage: storage,
    onSessionExpired: () => expired = true,
  );
  dio.interceptors.add(interceptor);
  final client = ApiClient(dio);
  final auth = RemoteAuthRepository(client, storage);
  final course = CourseRepository(client);
  final home = HomeRepository(client);
  final lessonRepo = LessonRepository(client);
  final review = ReviewRepository(client);

  stdout.writeln('SMOKE register');
  final registered = await auth.register(email, 'mobile-smoke', password);
  stdout.writeln('SMOKE login');
  await auth.logout();
  final loggedIn = await auth.login(email, password);
  _expect(registered.id == loggedIn.id, 'register/login user mismatch');
  final restored = await auth.restore();
  _expect(restored?.email == email, '/users/me failed');

  stdout.writeln('SMOKE automatic refresh');
  storage.accessToken = 'intentionally-invalid-access-token';
  final refreshedUser = await client.get(
    ApiEndpoints.me,
    (j) => UserProfile.fromJson(Map<String, dynamic>.from(j! as Map)),
  );
  _expect(
    refreshedUser.id == loggedIn.id && interceptor.refreshRequestCount == 1,
    'automatic refresh/retry failed',
  );

  stdout.writeln('SMOKE concurrent refresh');
  storage.accessToken = 'intentionally-invalid-access-token';
  final beforeConcurrent = interceptor.refreshRequestCount;
  await Future.wait([auth.restore(), review.summary(), review.wrong()]);
  _expect(
    interceptor.refreshRequestCount - beforeConcurrent == 1,
    'concurrent 401 did not share one refresh',
  );

  stdout.writeln('SMOKE learning path');
  final path = await course.learningPath();
  _expect(
    path.levels.expand(pointsInLevel).length == 45 &&
        path.levels.first.chapters.length == 7,
    'public learning path does not contain the complete A1 tree',
  );
  final initialPersonalPath = await course.myLearningPath();
  _expect(
    initialPersonalPath.levels.expand(pointsInLevel).length == 45 &&
        initialPersonalPath.levels
            .expand(pointsInLevel)
            .every((point) => point.status == 'NOT_STARTED'),
    'personal learning path initial state mismatch',
  );
  final firstLesson =
      path.levels.first.chapters.first.grammarPoints.first.lessons.first;
  final detail = await course.lesson(firstLesson.id);
  final questions = await lessonRepo.questions(detail.id);
  _expect(
    questions.length == 2,
    'expected two authored questions in the first lesson',
  );
  stdout.writeln('SMOKE answer questions');
  for (final q in questions) {
    final answer = switch (q.questionType) {
      QuestionType.singleChoice => 'A', // Deliberately wrong once.
      QuestionType.multipleChoice => q.optionItems.map((e) => e.id).toList(),
      QuestionType.fillBlank => 'is',
      QuestionType.sentenceOrder => ['They', 'are', 'friends', '.'],
      QuestionType.trueFalse => true,
      QuestionType.correction => 'She is my teacher.',
    };
    await lessonRepo.submit(q.id, q.questionType, answer, 1000);
  }
  final completion = await lessonRepo.complete(detail.id);
  _expect(
    completion.totalCount == 2 &&
        completion.correctCount == 1 &&
        completion.score == 50,
    'lesson completion mismatch',
  );
  final updatedPersonalPath = await course.myLearningPath();
  final updatedPoint = findPoint(
    updatedPersonalPath,
    path.levels.first.chapters.first.grammarPoints.first.id,
  );
  _expect(
    updatedPoint?.status == 'IN_PROGRESS' &&
        updatedPoint?.completedLessons == 1,
    'personal learning path progress overlay mismatch',
  );
  final dashboard = await home.dashboard();
  _expect(
    dashboard.progress.totalLessons == 135 &&
        dashboard.progress.completedLessons == 1 &&
        dashboard.continueLearning?.lessonId ==
            path.levels.first.chapters.first.grammarPoints.first.lessons[1].id,
    'dashboard totals or continue-learning selection mismatch',
  );
  stdout.writeln('SMOKE review');
  final wrong = await review.wrong();
  _expect(wrong.isNotEmpty, 'deliberate wrong answer was not added to review');
  final target = wrong.firstWhere(
    (e) => e.question.questionType == QuestionType.singleChoice,
  );
  final reviewResult = await review.submit(
    target.question.id,
    target.question.questionType,
    'B',
    1000,
  );
  _expect(
    reviewResult.correct && reviewResult.mastered,
    'active review did not master item',
  );
  final after = await review.summary();
  await auth.logout();
  _expect(
    !expired && await storage.getAccessToken() == null,
    'logout/session state failed',
  );

  stdout.writeln(
    'REAL_SMOKE_OK user=${loggedIn.id} questions=${questions.length} score=${completion.score} mastered=${reviewResult.mastered} refreshes=${interceptor.refreshRequestCount} remainingUnmastered=${after.unmasteredCount}',
  );
}

void _expect(bool condition, String message) {
  if (!condition) throw StateError(message);
}
