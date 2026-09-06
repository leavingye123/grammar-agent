import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grammar_agent/app.dart';
import 'package:grammar_agent/core/network/api_client.dart';
import 'package:grammar_agent/core/routing/app_router.dart';
import 'package:grammar_agent/features/auth/presentation/auth_controller.dart';
import 'package:grammar_agent/features/auth/presentation/auth_screens.dart';
import 'package:grammar_agent/features/auth/domain/auth_models.dart';
import 'package:grammar_agent/features/course/domain/course_models.dart';
import 'package:grammar_agent/features/course/presentation/course_providers.dart';
import 'package:grammar_agent/features/course/presentation/course_screens.dart';
import 'package:grammar_agent/features/home/domain/home_models.dart';
import 'package:grammar_agent/features/home/presentation/home_providers.dart';
import 'package:grammar_agent/features/home/presentation/home_screen.dart';
import 'package:grammar_agent/features/lesson/data/lesson_repository.dart';
import 'package:grammar_agent/features/lesson/domain/lesson_models.dart';
import 'package:grammar_agent/features/lesson/presentation/lesson_screens.dart';
import 'package:grammar_agent/features/lesson/presentation/lesson_session.dart';
import 'package:grammar_agent/features/review/domain/review_models.dart';
import 'package:grammar_agent/features/review/presentation/review_providers.dart';
import 'package:grammar_agent/features/review/presentation/review_screens.dart';

void main() {
  testWidgets('19 Router 未登录保护跳转 Login', (tester) async {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(
          () =>
              _FixedAuthController(const AuthState(AuthStatus.unauthenticated)),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const GrammarAgentApp(),
      ),
    );
    await tester.pumpAndSettle();
    container.read(routerProvider).go('/profile');
    await tester.pumpAndSettle();
    expect(find.text('欢迎回到 GrammarAgent'), findsOneWidget);
  });
  testWidgets('20 Router 已登录访问入口自动跳学习首页', (tester) async {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(
          () => _FixedAuthController(
            AuthState(AuthStatus.authenticated, user: _user),
          ),
        ),
        dashboardProvider.overrideWith((_) async => sampleDashboard),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const GrammarAgentApp(),
      ),
    );
    await tester.pumpAndSettle();
    container.read(routerProvider).go('/login');
    await tester.pumpAndSettle();
    expect(find.text('今日目标'), findsOneWidget);
    expect(find.text('学习'), findsOneWidget);
  });
  testWidgets('LoginScreen 校验与按钮交互', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(
            () => _FixedAuthController(
              const AuthState(AuthStatus.unauthenticated),
            ),
          ),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();
    expect(find.text('请输入邮箱'), findsOneWidget);
  });
  testWidgets('LearningPathScreen Error 状态和 Retry', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myLearningPathProvider.overrideWith((_) => Future.error('network')),
        ],
        child: const MaterialApp(home: LearningPathScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('重试'), findsOneWidget);
  });

  testWidgets('HomeScreen 展示今日目标与学习进度', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardProvider.overrideWith((_) async => sampleDashboard),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('今日目标'), findsOneWidget);
    expect(find.text('16 / 30 XP'), findsOneWidget);
    expect(find.text('继续学习'), findsOneWidget);
    expect(find.text('be 动词基础'), findsOneWidget);
    expect(find.text('3 道'), findsOneWidget);
  });

  testWidgets('LearningPathScreen 展示 Lesson 状态', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myLearningPathProvider.overrideWith((_) async => samplePath),
        ],
        child: const MaterialApp(home: LearningPathScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('be 动词基础'), findsOneWidget);
    expect(find.text('已完成'), findsWidgets);
  });
  testWidgets('QuestionScreen 成功交互及反馈', (tester) async {
    final fake = _WidgetLessonRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [lessonRepositoryProvider.overrideWithValue(fake)],
        child: const MaterialApp(home: QuestionScreen(lessonId: 1)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('is'));
    await tester.pump();
    await tester.tap(find.text('提交答案'));
    await tester.pumpAndSettle();
    expect(find.text('✓ 正确'), findsOneWidget);
    expect(find.text('完成 Lesson'), findsOneWidget);
  });
  testWidgets('LessonResultScreen 展示成绩', (tester) async {
    const completion = LessonCompletion(
      lessonId: 1,
      status: 'COMPLETED',
      totalCount: 5,
      correctCount: 4,
      score: 80,
      xpEarned: 8,
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: LessonResultScreen(lessonId: 1, completion: completion),
      ),
    );
    expect(find.text('4 / 5'), findsOneWidget);
    expect(find.text('+8'), findsOneWidget);
  });
  testWidgets('ReviewScreen 空状态', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reviewSummaryProvider.overrideWith(
            (_) async => const ReviewSummary(
              dueCount: 0,
              unmasteredCount: 0,
              masteredCount: 2,
            ),
          ),
          reviewDueProvider.overrideWith((_) async => []),
        ],
        child: const MaterialApp(home: ReviewScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('当前没有到期错题'), findsOneWidget);
    expect(find.text('已掌握'), findsOneWidget);
  });
}

final samplePath = LearningPath(
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
      name: 'Beginner',
      sortOrder: 1,
      chapters: [
        ChapterModel(
          id: 1,
          title: '基础句子',
          sortOrder: 1,
          grammarPoints: [
            GrammarPointSummary(
              id: 1,
              code: 'BE',
              title: 'be 动词基础',
              difficulty: 1,
              sortOrder: 1,
              masteryScore: 72,
              completedLessons: 1,
              totalLessons: 1,
              status: 'COMPLETED',
              lessons: [
                const LessonSummary(
                  id: 1,
                  title: 'Lesson 1',
                  lessonType: 'PRACTICE',
                  xpReward: 10,
                  sortOrder: 1,
                  status: 'COMPLETED',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

final sampleDashboard = Dashboard(
  user: const DashboardUser(
    username: 'tester',
    currentLanguage: 'en',
    currentLevel: 'A1',
  ),
  continueLearning: const ContinueLearning(
    grammarPointId: 1,
    grammarPointTitle: 'be 动词基础',
    lessonId: 10,
    lessonTitle: 'Lesson 1',
  ),
  today: const DashboardToday(completedLessons: 1, xpEarned: 16, goalXp: 30),
  review: const DashboardReview(dueCount: 3),
  progress: const DashboardProgress(
    completedLessons: 2,
    totalLessons: 30,
    averageMastery: 68,
  ),
  statistics: const DashboardStatistics(
    totalAnsweredQuestions: 10,
    correctAnswers: 6,
    accuracy: 60,
    totalXp: 16,
  ),
  streak: const DashboardStreak(currentStreak: 0, maxStreak: 0),
);
final _user = UserProfile(
  id: 1,
  email: 'a@b.com',
  username: 'tester',
  status: 'ACTIVE',
  createdAt: DateTime.utc(2026),
);

class _FixedAuthController extends AuthController {
  _FixedAuthController(this.value);
  final AuthState value;
  @override
  AuthState build() => value;
}

class _WidgetLessonRepository extends LessonRepository {
  _WidgetLessonRepository() : super(ApiClient(Dio()));
  @override
  Future<List<Question>> questions(int id) async => [
    const Question(
      id: 1,
      questionType: QuestionType.singleChoice,
      questionContent: 'Choose be',
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
    QuestionType t,
    Object a,
    int d,
  ) async => const SubmitAnswerResult(
    questionId: 1,
    correct: true,
    correctAnswer: {'optionId': 'A'},
    explanation: '正确解析',
    xpEarned: 1,
    grammarPointMastery: 20,
  );
}
