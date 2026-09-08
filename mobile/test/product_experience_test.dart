import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grammar_agent/app.dart';
import 'package:grammar_agent/core/network/api_client.dart';
import 'package:grammar_agent/core/routing/app_router.dart';
import 'package:grammar_agent/core/theme/app_theme.dart';
import 'package:grammar_agent/core/widgets/grammar_tree_widgets.dart';
import 'package:grammar_agent/core/widgets/option_card.dart';
import 'package:grammar_agent/features/auth/domain/auth_models.dart';
import 'package:grammar_agent/features/auth/presentation/auth_controller.dart';
import 'package:grammar_agent/features/course/domain/course_models.dart';
import 'package:grammar_agent/features/course/domain/grammar_tree.dart';
import 'package:grammar_agent/features/course/presentation/course_providers.dart';
import 'package:grammar_agent/features/course/presentation/course_screens.dart';
import 'package:grammar_agent/features/home/presentation/home_providers.dart';
import 'package:grammar_agent/features/home/presentation/home_screen.dart';
import 'package:grammar_agent/features/lesson/data/lesson_repository.dart';
import 'package:grammar_agent/features/lesson/domain/lesson_models.dart';
import 'package:grammar_agent/features/lesson/presentation/lesson_screens.dart';
import 'package:grammar_agent/features/lesson/presentation/lesson_session.dart';
import 'package:grammar_agent/features/lesson/presentation/question_widgets.dart';
import 'package:grammar_agent/features/profile/presentation/profile_screen.dart';
import 'package:grammar_agent/features/review/domain/review_models.dart';
import 'package:grammar_agent/features/review/presentation/review_providers.dart';
import 'package:grammar_agent/features/review/presentation/review_screens.dart';

import 'widget_test.dart' as fixtures;

const _micro = MicroLesson(
  learningObjective: '根据主语选择正确的 be 动词。',
  shortIntroduction: 'be 动词帮助我们说明身份、状态和位置。',
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
      checkCode: 'A1-003-MQ01',
      prompt: 'We ___ ready.',
      options: [
        MicroQuickCheckOption(id: 'A', text: 'is'),
        MicroQuickCheckOption(id: 'B', text: 'are'),
      ],
      correctOptionId: 'B',
      explanation: 'We 搭配 are。',
    ),
    MicroQuickCheck(
      checkCode: 'A1-003-MQ02',
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
  id: 1,
  chapterId: 1,
  code: 'BE',
  title: 'be 动词基础',
  difficulty: 1,
  sortOrder: 1,
  description: '理解 am、is、are',
  grammarRule: 'I 搭配 am',
  examples: [
    {'sentence': 'I am a student.', 'translation': '我是一名学生。'},
  ],
  commonErrors: [
    {'incorrect': 'I is a student.', 'correct': 'I am a student.'},
  ],
  microLesson: _micro,
  prerequisites: [],
);
const _lesson = LessonDetail(
  id: 1,
  grammarPointId: 1,
  title: 'Lesson 1',
  description: '学习 am、is、are',
  lessonType: 'LEARNING',
  xpReward: 10,
  sortOrder: 1,
  questionCount: 1,
  contentStatus: 'READY',
);
const _completion = LessonCompletion(
  lessonId: 1,
  status: 'COMPLETED',
  totalCount: 5,
  correctCount: 4,
  score: 80,
  xpEarned: 8,
);
final _point =
    fixtures.samplePath.levels.first.chapters.first.grammarPoints.first;

class _Auth extends AuthController {
  @override
  AuthState build() => AuthState(
    AuthStatus.authenticated,
    user: UserProfile(
      id: 1,
      email: 'preview@example.com',
      username: '学习伙伴',
      status: 'ACTIVE',
      createdAt: DateTime.utc(2026),
    ),
  );
}

ProviderContainer _container() => ProviderContainer(
  overrides: [
    authProvider.overrideWith(_Auth.new),
    myLearningPathProvider.overrideWith((_) async => fixtures.samplePath),
    dashboardProvider.overrideWith((_) async => fixtures.sampleDashboard),
    grammarPointProvider(1).overrideWith((_) async => _detail),
    grammarPointLessonsProvider(1).overrideWith((_) async => _point.lessons),
    lessonProvider(1).overrideWith((_) async => _lesson),
    lessonRepositoryProvider.overrideWithValue(_Repo()),
    reviewSummaryProvider.overrideWith(
      (_) async => const ReviewSummary(
        dueCount: 0,
        unmasteredCount: 0,
        masteredCount: 1,
      ),
    ),
    reviewDueProvider.overrideWith((_) async => []),
  ],
);

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double scale = 1,
}) async {
  final c = _container();
  addTearDown(c.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Tenses branch supports multiple real-shaped nodes without unlock rules',
    (tester) async {
      final c = ProviderContainer(
        overrides: [
          myLearningPathProvider.overrideWith(
            (_) async => LearningPath(
              language: fixtures.samplePath.language,
              levels: [
                LevelModel(
                  id: 1,
                  code: 'A1',
                  name: 'A1',
                  sortOrder: 1,
                  chapters: [
                    ChapterModel(
                      id: 1,
                      title: '时态',
                      sortOrder: 1,
                      grammarPoints: [
                        GrammarPointSummary(
                          id: 2,
                          code: 'EN_A1_SIMPLE_PRESENT_001',
                          title: '一般现在时',
                          difficulty: 1,
                          sortOrder: 1,
                          lessons: _point.lessons,
                          masteryScore: 60,
                          status: 'IN_PROGRESS',
                          completedLessons: 0,
                          totalLessons: 1,
                        ),
                        GrammarPointSummary(
                          id: 3,
                          code: 'EN_A1_PRESENT_CONTINUOUS_001',
                          title: '现在进行时',
                          difficulty: 1,
                          sortOrder: 2,
                          lessons: _point.lessons,
                          masteryScore: 0,
                          status: 'NOT_STARTED',
                          completedLessons: 0,
                          totalLessons: 1,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(c.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const GrammarBranchScreen(domainId: 'tenses'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GrammarNode), findsNWidgets(2));
      expect(
        tester.widget<GrammarNode>(find.byKey(const ValueKey('point-2'))).stage,
        GrowthStage.learning,
      );
      expect(
        tester.widget<GrammarNode>(find.byKey(const ValueKey('point-3'))).onTap,
        isNotNull,
      );
      expect(find.textContaining('LOCKED'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  test('Server answer payloads are readable for all six question types', () {
    expect(
      formatCorrectAnswer({'optionId': 'A'}, question: _question),
      'A · is',
    );
    expect(
      formatCorrectAnswer({
        'optionIds': ['A', 'B'],
      }, question: _question),
      'A · is、B · are',
    );
    expect(
      formatCorrectAnswer({
        'answers': ['is'],
      }),
      'is',
    );
    expect(
      formatCorrectAnswer({
        'acceptedAnswers': ['She is happy.'],
      }),
      'She is happy.',
    );
    expect(
      formatCorrectAnswer({
        'tokens': ['They', 'are', 'friends', '.'],
      }),
      'They are friends.',
    );
    expect(formatCorrectAnswer({'value': true}), '正确');
  });
  test('growth keeps completion separate from mastery; unknown codes remain reachable', () {
    expect(growthFor(_point), GrowthStage.practicing);
    expect(domainFor('en', _point), GrammarDomain.foundations);
    expect(domainFor('ja', _point), GrammarDomain.other);
    expect(TreeProgress([_point]).fraction, 1);
    expect(TreeProgress([]).fraction, 0);
    expect(GrammarDomain.fromId('missing'), isNull);
  });

  testWidgets('Tree → Branch → Grammar Point → Lesson navigation', (
    tester,
  ) async {
    final c = _container();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: c, child: const GrammarAgentApp()),
    );
    await tester.pumpAndSettle();
    c.read(routerProvider).go('/learning-path');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('chapter-999')), findsNothing);
    expect(find.text('即将推出'), findsNothing);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('chapter-1')),
      250,
    );
    await tester.tap(find.byKey(const ValueKey('chapter-1')));
    await tester.pumpAndSettle();
    expect(find.byType(GrammarBranchScreen), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('point-1')));
    await tester.pumpAndSettle();
    expect(find.byType(GrammarPointScreen), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Lesson 1'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Lesson 1'));
    await tester.pumpAndSettle();
    expect(find.byType(MicroLessonScreen), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('开始 Quick Check'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('开始 Quick Check'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('are'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('下一题'));
    await tester.tap(find.text('下一题'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('is'));
    await tester.pumpAndSettle();
    expect(find.text('Quick Check 不计入 Mastery。'), findsOneWidget);
    await tester.ensureVisible(find.text('进入正式练习'));
    await tester.tap(find.text('进入正式练习'));
    await tester.pumpAndSettle();
    expect(find.byType(LessonScreen), findsOneWidget);
    await tester.scrollUntilVisible(find.text('开始学习'), 200);
    await tester.tap(find.text('开始学习'));
    await tester.pumpAndSettle();
    expect(find.byType(QuestionScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Grammar Point renders examples as readable content, not JSON', (
    tester,
  ) async {
    await _pump(tester, const GrammarPointScreen(id: 1));
    await tester.scrollUntilVisible(
      find.text('I am a student.'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('我是一名学生。'), findsOneWidget);
    expect(find.textContaining('"sentence"'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Branch reflects new server progress after invalidation', (
    tester,
  ) async {
    var completed = false;
    final c = ProviderContainer(
      overrides: [
        myLearningPathProvider.overrideWith(
          (_) async => LearningPath(
            language: fixtures.samplePath.language,
            levels: [
              LevelModel(
                id: 1,
                code: 'A1',
                name: 'A1',
                sortOrder: 1,
                chapters: [
                  ChapterModel(
                    id: 1,
                    title: '基础',
                    sortOrder: 1,
                    grammarPoints: [
                      GrammarPointSummary(
                        id: 1,
                        code: 'BE',
                        title: 'be 动词基础',
                        difficulty: 1,
                        sortOrder: 1,
                        lessons: _point.lessons,
                        masteryScore: completed ? 100 : 0,
                        completedLessons: completed ? 1 : 0,
                        totalLessons: 1,
                        status: completed ? 'COMPLETED' : 'NOT_STARTED',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(c.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const GrammarBranchScreen(domainId: 'foundations'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<GrammarNode>(find.byKey(const ValueKey('point-1'))).stage,
      GrowthStage.seed,
    );
    completed = true;
    c.invalidate(myLearningPathProvider);
    await tester.pumpAndSettle();
    expect(
      tester.widget<GrammarNode>(find.byKey(const ValueKey('point-1'))).stage,
      GrowthStage.mastered,
    );
  });

  testWidgets(
    'Selection is highlighted; correct and incorrect feedback retain answers',
    (tester) async {
      await _pump(
        tester,
        QuestionInput(question: _question, enabled: true, onChanged: (_) {}),
      );
      await tester.tap(find.text('is'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<OptionCard>(find.byType(OptionCard).first).selected,
        isTrue,
      );
      for (final correct in [true, false]) {
        await _pump(
          tester,
          SingleChildScrollView(
            child: FeedbackPanel(
              correct: correct,
              correctAnswer: 'is',
              explanation: '单数主语使用 is',
            ),
          ),
        );
        expect(find.text('正确答案：is'), findsOneWidget);
        expect(find.text('单数主语使用 is'), findsOneWidget);
      }
    },
  );

  testWidgets(
    'Unknown branch and missing result payload have recoverable destinations',
    (tester) async {
      await _pump(tester, const GrammarBranchScreen(domainId: 'unknown'));
      expect(find.text('没有找到这个语法分支'), findsOneWidget);
      final c = _container();
      addTearDown(c.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(container: c, child: const GrammarAgentApp()),
      );
      await tester.pumpAndSettle();
      c.read(routerProvider).go('/lesson/1/result');
      await tester.pumpAndSettle();
      expect(find.byType(LessonScreen), findsOneWidget);
    },
  );

  final pages = <String, Widget>{
    'Home': const HomeScreen(),
    'Tree': const LearningPathScreen(),
    'Branch': const GrammarBranchScreen(domainId: 'foundations'),
    'Grammar Point': const GrammarPointScreen(id: 1),
    'Micro Lesson': const MicroLessonScreen(grammarPointId: 1, lessonId: 1),
    'Lesson': const LessonScreen(id: 1),
    'Question': const QuestionScreen(lessonId: 1),
    'Result': const LessonResultScreen(
      lessonId: 1,
      completion: _completion,
      durationMs: 83000,
    ),
    'Review': const ReviewScreen(),
    'Profile': const ProfileScreen(),
  };
  for (final entry in pages.entries) {
    testWidgets('${entry.key} 320px / 2x text has no overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _pump(tester, entry.value, scale: 2);
      for (var i = 0; i < 14; i++) {
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Long node titles remain bounded in the organic tree', (
    tester,
  ) async {
    var tapped = false;
    await _pump(
      tester,
      SingleChildScrollView(
        child: OrganicGrammarTree(
          locateCurrent: false,
          nodes: [
            TreeVisualNode(
              id: 'long',
              title: '这是一个非常长的语法领域标题用于验证换行行为',
              progress: '10/10',
              icon: Icons.eco,
              stage: GrowthStage.mastered,
              onTap: () => tapped = true,
            ),
            TreeVisualNode(
              id: 'next',
              title: '下一知识点',
              progress: '0/2',
              icon: Icons.spa,
              stage: GrowthStage.seed,
              onTap: () {},
            ),
          ],
        ),
      ),
      scale: 2,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.textContaining('这是一个非常长'));
    expect(tapped, isTrue);
  });

  test(
    'Completion double-tap sends one request and refreshes shared read models',
    () async {
      final repo = _Repo();
      var dashboards = 0;
      final c = ProviderContainer(
        overrides: [
          lessonRepositoryProvider.overrideWithValue(repo),
          dashboardProvider.overrideWith((_) async {
            dashboards++;
            return fixtures.sampleDashboard;
          }),
        ],
      );
      addTearDown(c.dispose);
      c.listen(lessonSessionProvider(1), (_, _) {});
      c.listen(dashboardProvider, (_, _) {});
      await c.read(dashboardProvider.future);
      await Future<void>.delayed(Duration.zero);
      final controller = c.read(lessonSessionProvider(1).notifier);
      controller.setAnswer('A');
      await controller.submit();
      final pending = controller.continueNext();
      expect(await controller.continueNext(), isNull);
      expect(repo.completes, 1);
      repo.completion.complete(_completion);
      expect(await pending, _completion);
      await c.read(dashboardProvider.future);
      expect(dashboards, greaterThan(1));
    },
  );
}

const _question = Question(
  id: 1,
  questionType: QuestionType.singleChoice,
  questionContent: 'She ___ happy.',
  options: [
    {'id': 'A', 'text': 'is'},
    {'id': 'B', 'text': 'are'},
  ],
  difficulty: 1,
  sortOrder: 1,
);

class _Repo extends LessonRepository {
  _Repo() : super(ApiClient(Dio()));
  int completes = 0;
  final completion = Completer<LessonCompletion>();
  @override
  Future<List<Question>> questions(int id) async => [_question];
  @override
  Future<SubmitAnswerResult> submit(
    int id,
    QuestionType t,
    Object a,
    int d,
  ) async => const SubmitAnswerResult(
    questionId: 1,
    correct: true,
    correctAnswer: 'is',
    explanation: '单数主语使用 is',
    xpEarned: 0,
    grammarPointMastery: 100,
  );
  @override
  Future<LessonCompletion> complete(int id) {
    completes++;
    return completion.future;
  }
}
