import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grammar_agent/app.dart';
import 'package:grammar_agent/core/network/api_client.dart';
import 'package:grammar_agent/core/routing/app_router.dart';
import 'package:grammar_agent/features/auth/domain/auth_models.dart';
import 'package:grammar_agent/features/auth/presentation/auth_controller.dart';
import 'package:grammar_agent/features/course/domain/course_models.dart';
import 'package:grammar_agent/features/course/presentation/course_providers.dart';
import 'package:grammar_agent/features/course/presentation/course_screens.dart';
import 'package:grammar_agent/features/course/presentation/learning_entry.dart';
import 'package:grammar_agent/features/home/domain/home_models.dart';
import 'package:grammar_agent/features/home/presentation/home_providers.dart';
import 'package:grammar_agent/features/home/presentation/home_screen.dart';
import 'package:grammar_agent/features/lesson/data/lesson_repository.dart';
import 'package:grammar_agent/features/lesson/domain/lesson_models.dart';
import 'package:grammar_agent/features/lesson/presentation/lesson_screens.dart';
import 'package:grammar_agent/features/lesson/presentation/lesson_session.dart';

void main() {
  test('Home and Grammar Tree share first-learning routing policy', () {
    expect(
      grammarLearningRoute(
        grammarPointId: 9,
        lessonId: 90,
        grammarPointStatus: 'NOT_STARTED',
        lessonStatus: 'NOT_STARTED',
        hasMicroLesson: true,
        lessonReady: true,
      ),
      '/grammar-point/9/micro-lesson?lessonId=90',
    );
    for (final status in ['IN_PROGRESS', 'COMPLETED']) {
      expect(
        grammarLearningRoute(
          grammarPointId: 9,
          lessonId: 90,
          grammarPointStatus: status,
          lessonStatus: status,
          hasMicroLesson: true,
          lessonReady: true,
        ),
        '/lesson/90',
      );
    }
    expect(
      grammarLearningRoute(
        grammarPointId: 9,
        lessonId: 90,
        grammarPointStatus: 'NOT_STARTED',
        lessonStatus: 'NOT_STARTED',
        hasMicroLesson: false,
        lessonReady: true,
      ),
      isNull,
    );
    expect(
      grammarLearningRoute(
        grammarPointId: 9,
        lessonId: 90,
        grammarPointStatus: 'NOT_STARTED',
        lessonStatus: 'NOT_STARTED',
        hasMicroLesson: true,
        lessonReady: false,
      ),
      isNull,
    );
  });

  testWidgets(
    'Home NOT_STARTED opens two teaching pages, Quick Check, then practice',
    (tester) async {
      final repo = _CountingLessonRepository();
      final container = _container(status: 'NOT_STARTED', repo: repo);
      addTearDown(container.dispose);
      await _pumpApp(tester, container);

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('约 2 分钟讲解 · 然后练习'), findsOneWidget);
      await _tapVisible(
        tester,
        find.byKey(const ValueKey('home-start-learning')),
      );

      expect(find.byType(MicroLessonScreen), findsOneWidget);
      expect(find.text('根据主语选择正确的 be 动词。'), findsOneWidget);
      expect(find.text('核心规则'), findsOneWidget);
      expect(find.byType(QuestionScreen), findsNothing);

      await tester.tap(find.byKey(const ValueKey('teaching-page-1-continue')));
      await tester.pumpAndSettle();
      expect(find.text('常见错误'), findsOneWidget);
      expect(find.textContaining('Grammar Cat 提示'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('teaching-page-2-continue')));
      await tester.pumpAndSettle();
      expect(find.text('We ___ ready.'), findsOneWidget);
      expect(repo.submitCalls, 0);

      await tester.tap(find.text('are'));
      await tester.pumpAndSettle();
      await _tapVisible(tester, find.text('下一题'));
      expect(find.text('My dog ___ here.'), findsOneWidget);
      await tester.tap(find.text('is'));
      await tester.pumpAndSettle();
      expect(find.text('Quick Check 不计入 Mastery。'), findsOneWidget);
      expect(repo.submitCalls, 0);

      await _tapVisible(tester, find.text('进入正式练习'));
      expect(find.byType(LessonScreen), findsOneWidget);
      expect(find.byType(QuestionScreen), findsNothing);
      expect(repo.submitCalls, 0);
    },
  );

  testWidgets('Home IN_PROGRESS continues formal practice directly', (
    tester,
  ) async {
    final container = _container(
      status: 'IN_PROGRESS',
      repo: _CountingLessonRepository(),
    );
    addTearDown(container.dispose);
    await _pumpApp(tester, container);

    expect(find.text('继续学习'), findsOneWidget);
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('home-start-learning')),
    );
    expect(find.byType(LessonScreen), findsOneWidget);
    expect(find.byType(MicroLessonScreen), findsNothing);
  });

  testWidgets('Grammar Tree lesson uses the same NOT_STARTED teaching entry', (
    tester,
  ) async {
    final container = _container(
      status: 'NOT_STARTED',
      repo: _CountingLessonRepository(),
    );
    addTearDown(container.dispose);
    await _pumpApp(tester, container);
    container.read(routerProvider).go('/grammar-point/9');
    await tester.pumpAndSettle();
    expect(find.byType(GrammarPointScreen), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('认识主语与 be 动词'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await _tapVisible(tester, find.text('认识主语与 be 动词'));
    expect(find.byType(MicroLessonScreen), findsOneWidget);
    expect(find.byType(QuestionScreen), findsNothing);
  });
}

Future<void> _pumpApp(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const GrammarAgentApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  final viewportHeight = tester.getSize(find.byType(Scaffold).first).height;
  for (var i = 0; i < 20; i++) {
    final y = tester.getCenter(finder.first).dy;
    if (y >= 0 && y <= viewportHeight - 16) break;
    await tester.drag(
      find.byType(ListView).first,
      Offset(0, y > viewportHeight ? -180 : 180),
    );
    await tester.pumpAndSettle();
  }
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

ProviderContainer _container({
  required String status,
  required _CountingLessonRepository repo,
}) => ProviderContainer(
  overrides: [
    authProvider.overrideWith(_Authenticated.new),
    dashboardProvider.overrideWith((_) async => _dashboard),
    myLearningPathProvider.overrideWith((_) async => _path(status)),
    grammarPointProvider(9).overrideWith((_) async => _detail),
    grammarPointLessonsProvider(9).overrideWith(
      (_) async =>
          _path(status).levels.first.chapters.first.grammarPoints.first.lessons,
    ),
    lessonProvider(90).overrideWith((_) async => _lesson),
    lessonRepositoryProvider.overrideWithValue(repo),
  ],
);

LearningPath _path(String status) => LearningPath(
  language: const LanguageModel(
    id: 1,
    code: 'en',
    name: 'English',
    nativeName: 'English',
  ),
  levels: [
    LevelModel(
      id: 1,
      code: 'A1',
      name: 'A1',
      sortOrder: 1,
      chapters: [
        ChapterModel(
          id: 1,
          title: '基础语法',
          sortOrder: 1,
          grammarPoints: [
            GrammarPointSummary(
              id: 9,
              code: 'A1-009',
              title: '主格与宾格代词',
              difficulty: 1,
              sortOrder: 9,
              status: status,
              completedLessons: status == 'COMPLETED' ? 1 : 0,
              totalLessons: 1,
              lessons: [
                LessonSummary(
                  id: 90,
                  title: '认识主语与 be 动词',
                  lessonType: 'LEARNING',
                  xpReward: 8,
                  sortOrder: 1,
                  questionCount: 1,
                  contentStatus: 'READY',
                  status: status,
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

const _dashboard = Dashboard(
  user: DashboardUser(
    username: 'new-learner',
    currentLanguage: 'en',
    currentLevel: 'A1',
  ),
  continueLearning: ContinueLearning(
    grammarPointId: 9,
    grammarPointTitle: '主格与宾格代词',
    lessonId: 90,
    lessonTitle: '认识主语与 be 动词',
  ),
  today: DashboardToday(completedLessons: 0, xpEarned: 0, goalXp: 30),
  review: DashboardReview(dueCount: 0),
  progress: DashboardProgress(
    completedLessons: 0,
    totalLessons: 135,
    averageMastery: 0,
  ),
  statistics: DashboardStatistics(
    totalAnsweredQuestions: 0,
    correctAnswers: 0,
    accuracy: 0,
    totalXp: 0,
  ),
  streak: DashboardStreak(currentStreak: 0, maxStreak: 0),
);

const _micro = MicroLesson(
  learningObjective: '根据主语选择正确的 be 动词。',
  shortIntroduction: '先找到句子的主角，再选择 be 动词。',
  coreRule: 'I 搭配 am，单数搭配 is，you 和复数搭配 are。',
  structure: 'Subject + am / is / are + Complement',
  examples: [MicroLessonExample(sentence: 'I am ready.', note: 'I 搭配 am。')],
  commonMistakes: [
    MicroLessonMistake(
      incorrect: 'She are happy.',
      correct: 'She is happy.',
      reason: 'She 是单数。',
    ),
  ],
  memoryTip: 'I am，单数 is，复数 are。',
  quickCheck: [
    MicroQuickCheck(
      checkCode: 'A1-009-MQ01',
      prompt: 'We ___ ready.',
      options: [
        MicroQuickCheckOption(id: 'A', text: 'is'),
        MicroQuickCheckOption(id: 'B', text: 'are'),
      ],
      correctOptionId: 'B',
      explanation: 'We 搭配 are。',
    ),
    MicroQuickCheck(
      checkCode: 'A1-009-MQ02',
      prompt: 'My dog ___ here.',
      options: [
        MicroQuickCheckOption(id: 'A', text: 'is'),
        MicroQuickCheckOption(id: 'B', text: 'are'),
      ],
      correctOptionId: 'A',
      explanation: 'My dog 是单数。',
    ),
  ],
);

const _detail = GrammarPointDetail(
  id: 9,
  chapterId: 1,
  code: 'A1-009',
  title: '主格与宾格代词',
  description: '理解代词在句子中的位置。',
  grammarRule: '主语放在动作前。',
  microLesson: _micro,
  difficulty: 1,
  sortOrder: 9,
  prerequisites: [],
);

const _lesson = LessonDetail(
  id: 90,
  grammarPointId: 9,
  title: '认识主语与 be 动词',
  description: '正式练习',
  lessonType: 'LEARNING',
  xpReward: 8,
  sortOrder: 1,
  questionCount: 1,
  contentStatus: 'READY',
);

class _Authenticated extends AuthController {
  @override
  AuthState build() => AuthState(
    AuthStatus.authenticated,
    user: UserProfile(
      id: 1,
      email: 'new@example.com',
      username: 'new-learner',
      status: 'ACTIVE',
      createdAt: DateTime.utc(2026),
    ),
  );
}

class _CountingLessonRepository extends LessonRepository {
  _CountingLessonRepository() : super(ApiClient(Dio()));

  int submitCalls = 0;

  @override
  Future<List<Question>> questions(int id) async => [
    const Question(
      id: 900,
      questionCode: 'A1-009-Q001',
      questionType: QuestionType.singleChoice,
      questionContent: 'She ___ ready.',
      options: [
        {'id': 'A', 'text': 'is'},
        {'id': 'B', 'text': 'are'},
      ],
      difficulty: 1,
      sortOrder: 1,
    ),
  ];

  @override
  Future<SubmitAnswerResult> submit(
    int id,
    QuestionType type,
    Object answer,
    int durationMs,
  ) async {
    submitCalls++;
    return const SubmitAnswerResult(
      questionId: 900,
      correct: true,
      correctAnswer: {'optionId': 'A'},
      explanation: '单数主语使用 is。',
      xpEarned: 0,
      grammarPointMastery: 0,
    );
  }
}
