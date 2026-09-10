import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:grammar_agent/core/network/api_client.dart';
import 'package:grammar_agent/features/course/data/course_repository.dart';
import 'package:grammar_agent/features/course/domain/course_models.dart';
import 'package:grammar_agent/features/course/presentation/course_providers.dart';
import 'package:grammar_agent/features/lesson/data/lesson_repository.dart';
import 'package:grammar_agent/features/lesson/domain/lesson_models.dart';
import 'package:grammar_agent/features/lesson/presentation/lesson_screens.dart';
import 'package:grammar_agent/features/lesson/presentation/question_widgets.dart';
import 'package:grammar_agent/features/lesson/presentation/lesson_session.dart';
import 'package:grammar_agent/features/lesson/presentation/practice_activities.dart';
import 'package:grammar_agent/features/tutor/presentation/tutor_sheet.dart';

void main() {
  test('resolver maps pilot question shapes to tap-first interaction styles', () {
    expect(
      resolveInteractionStyle(_questions[0]),
      PracticeInteractionStyle.quickChoice,
    );
    expect(
      resolveInteractionStyle(_questions[1]),
      PracticeInteractionStyle.trueFalse,
    );
    expect(
      resolveInteractionStyle(_questions[2]),
      PracticeInteractionStyle.tokenTap,
    );
    expect(
      resolveInteractionStyle(_questions[4]),
      PracticeInteractionStyle.wordSlot,
    );
    expect(
      resolveInteractionStyle(_questions[5]),
      PracticeInteractionStyle.dialogue,
    );
    expect(
      resolveInteractionStyle(_questions[6]),
      PracticeInteractionStyle.ruleMatch,
    );
    expect(
      resolveInteractionStyle(_questions[7]),
      PracticeInteractionStyle.tapToBuild,
    );
    expect(
      resolveInteractionStyle(_questions[8]),
      PracticeInteractionStyle.pairMatch,
    );
    expect(
      resolveInteractionStyle(_questions[9]),
      PracticeInteractionStyle.categorySort,
    );
    expect(
      resolveInteractionStyle(_fixItQuestion),
      PracticeInteractionStyle.fixIt,
    );
    // Legacy questions without authored word banks keep the keyboard fallback.
    expect(
      resolveInteractionStyle(
        const Question(
          id: 99,
          questionType: QuestionType.fillBlank,
          questionContent: 'Fill in the blank: She ___ happy.',
          difficulty: 1,
          sortOrder: 1,
        ),
      ),
      PracticeInteractionStyle.legacyText,
    );
    expect(
      resolveInteractionStyle(
        const Question(
          id: 98,
          questionType: QuestionType.correction,
          questionContent: 'Correct the sentence: Me am from China.',
          difficulty: 1,
          sortOrder: 1,
        ),
      ),
      PracticeInteractionStyle.legacyText,
    );
    for (final style in PracticeInteractionStyle.values) {
      final manual =
          style == PracticeInteractionStyle.multipleSelect ||
          style == PracticeInteractionStyle.legacyText;
      expect(autoSubmits(style), manual ? isFalse : isTrue);
    }
  });

  testWidgets('session shows the target activity count and dot progress', (
    tester,
  ) async {
    final repo = _PilotRepo();
    await _pump(tester, repo);
    expect(find.text('1 / 10'), findsOneWidget);
    expect(find.byKey(const ValueKey('practice-dot-9')), findsOneWidget);
    expect(find.byKey(const ValueKey('practice-dot-10')), findsNothing);
    expect(
      find.byType(TextField),
      findsNothing,
    ); // No keyboard anywhere in the pilot.
  });

  testWidgets('token tap (error hunt) submits the tapped token option', (
    tester,
  ) async {
    final repo = _PilotRepo();
    await _pump(tester, repo, startAt: 2);
    expect(find.text('点击句子中的主语。'), findsOneWidget);
    await tester.tap(find.text('drinks')); // deliberately wrong token
    await tester.pumpAndSettle();
    expect(repo.submits.single.id, _questions[2].id);
    expect(repo.submits.single.answer, 'B');
    expect(
      find.textContaining('正确答案'),
      findsOneWidget,
    ); // wrong feedback stays for reading
    expect(find.text('继续'), findsOneWidget);
  });

  testWidgets('word slot fills from a word bank without any keyboard', (
    tester,
  ) async {
    final repo = _PilotRepo();
    await _pump(tester, repo, startAt: 4);
    expect(find.textContaining('Tom'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.text('plays'));
    await tester.pump();
    expect(repo.submits.single.answer, 'plays');
    await tester.pumpAndSettle();
    expect(find.text('✓ 正确'), findsOneWidget);
  });

  testWidgets(
    'fix it replaces the marked token and submits the corrected sentence',
    (tester) async {
      final repo = _PilotRepo(fixItOnly: true);
      await _pump(tester, repo);
      expect(find.textContaining('She'), findsOneWidget);
      await tester.tap(find.text('is'));
      await tester.pump();
      expect(repo.submits.single.answer, 'She is happy.');
      await tester.pumpAndSettle();
      expect(find.text('✓ 正确'), findsOneWidget);
    },
  );

  testWidgets(
    'dialogue choice renders the scene and submits through the evaluator',
    (tester) async {
      final repo = _PilotRepo();
      await _pump(tester, repo, startAt: 5);
      expect(find.text('Hi! I am Tom.'), findsOneWidget);
      expect(find.textContaining('＿＿＿'), findsOneWidget);
      await tester.tap(find.text('I am Mia.'));
      await tester.pump();
      expect(repo.submits.single.answer, 'A');
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('✓ 正确'),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('✓ 正确'), findsOneWidget);
    },
  );

  testWidgets(
    'pair match pairs left with right and auto-submits the option set',
    (tester) async {
      final repo = _PilotRepo();
      await _pump(tester, repo, startAt: 8);
      await tester.tap(find.text('Tom'));
      await tester.pump();
      await tester.tap(find.text('主语'));
      await tester.pump();
      // A wrong pairing is still expressible and submits a wrong set.
      await tester.tap(find.text('plays'));
      await tester.pump();
      await tester.tap(find.text('主语'));
      await tester.pump();
      await tester.tap(find.text('football'));
      await tester.pump();
      await tester.tap(find.text('宾语'));
      await tester.pump();
      expect(repo.submits, hasLength(1));
      expect(repo.submits.single.answer, isA<List<String>>());
      expect((repo.submits.single.answer as List).toSet(), {'A', 'D', 'I'});
      await tester.pumpAndSettle();
      expect(find.textContaining('正确答案'), findsOneWidget);
      expect(find.text('继续'), findsOneWidget);
    },
  );

  testWidgets('category sort assigns every word and auto-submits', (
    tester,
  ) async {
    final repo = _PilotRepo();
    await _pump(tester, repo, startAt: 9);
    Future<void> sort(String word, String zone) async {
      await tester.tap(find.text(word));
      await tester.pump();
      await tester.tap(find.text(zone));
      await tester.pump();
    }

    await sort('sing', '动词');
    // A mis-sorted word can be pulled back out and re-sorted before the set completes.
    await sort('book', '动词');
    await tester.tap(
      find.text('book'),
    ); // the zone chip — unassign and reselect
    await tester.pump();
    await sort('book', '名词');
    await sort('dance', '动词');
    await sort('pen', '名词');
    expect(repo.submits, hasLength(1));
    expect((repo.submits.single.answer as List).toSet(), {'A', 'D', 'E', 'H'});
    await tester.pumpAndSettle();
    expect(find.text('✓ 正确'), findsOneWidget);
  });

  testWidgets('tap-to-build composes the sentence and supports undo', (
    tester,
  ) async {
    final repo = _PilotRepo();
    await _pump(tester, repo, startAt: 7);
    await tester.tap(find.text('reads'));
    await tester.pump();
    // Undo the wrongly placed token; it returns to the bank.
    await tester.tap(find.text('reads'));
    await tester.pump();
    expect(find.text('按顺序点击下方词块'), findsOneWidget);
    for (final word in ['Lina', 'reads', 'books', '.']) {
      await tester.tap(find.text(word));
      await tester.pump();
    }
    expect(repo.submits.single.answer, ['Lina', 'reads', 'books', '.']);
    await tester.pumpAndSettle();
    expect(find.text('✓ 正确'), findsOneWidget);
  });

  testWidgets(
    'wrong answers keep feedback, tutor entry, and the continue button',
    (tester) async {
      final repo = _PilotRepo();
      await _pump(tester, repo);
      await tester.tap(find.text('Reads books.'));
      await tester.pumpAndSettle();
      expect(find.byType(FeedbackPanel), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byType(GrammarTutorButton),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byType(GrammarTutorButton), findsOneWidget);
      expect(find.text('继续'), findsOneWidget);
      await tester.tap(find.text('继续'));
      await tester.pumpAndSettle();
      expect(find.text('2 / 10'), findsOneWidget);
      expect(repo.submits, hasLength(1));
    },
  );

  testWidgets(
    'a full ten-activity practice completes once and shows the result',
    (tester) async {
      final repo = _PilotRepo();
      await _pump(tester, repo);
      // Every answer keeps feedback until the learner explicitly continues.
      Future<void> continueAfterFeedback() async {
        await tester.pumpAndSettle();
        expect(find.text('继续'), findsOneWidget);
        await tester.tap(find.text('继续'));
        await tester.pumpAndSettle();
      }

      Future<void> correct(Finder finder) async {
        await tester.tap(finder);
        await tester.pump();
        await continueAfterFeedback();
      }

      await correct(find.text('Lina reads books.')); // 1 quick choice
      await correct(find.text('✓ 正确')); // 2 true/false
      expect(find.text('3 / 10'), findsOneWidget);
      await correct(find.text('Noah')); // 3 token tap
      await correct(find.text('sings')); // 4 token tap
      await correct(find.text('plays')); // 5 word slot
      await correct(find.text('I am Mia.')); // 6 dialogue
      await correct(find.text('主语')); // 7 rule match
      for (final word in ['Lina', 'reads', 'books', '.']) {
        await tester.tap(find.text(word)); // 8 tap-to-build
        await tester.pump();
      }
      await continueAfterFeedback();
      for (final pair in [('Tom', '主语'), ('plays', '动词'), ('football', '宾语')]) {
        await tester.tap(find.text(pair.$1)); // 9 pair match
        await tester.pump();
        await tester.tap(find.text(pair.$2));
        await tester.pump();
      }
      await continueAfterFeedback();
      for (final pair in [
        ('sing', '动词'),
        ('book', '名词'),
        ('dance', '动词'),
        ('pen', '名词'),
      ]) {
        await tester.tap(
          find.text(pair.$1),
        ); // 10 category sort (last activity)
        await tester.pump();
        await tester.tap(find.text(pair.$2));
        await tester.pump();
      }
      await tester.pumpAndSettle();
      expect(find.text('10 / 10'), findsOneWidget);
      expect(find.text('完成 Lesson'), findsOneWidget);
      await tester.tap(find.text('完成 Lesson'));
      await tester.pumpAndSettle();
      expect(find.text('RESULT_PAGE'), findsOneWidget);
      expect(repo.submits, hasLength(10));
      expect(
        repo.completes,
        1,
      ); // One attempt, one completion, XP/mastery from the server.
      expect(repo.submits.map((s) => s.id), _questions.map((q) => q.id));
    },
  );
}

Future<void> _pump(
  WidgetTester tester,
  LessonRepository repo, {
  int startAt = 0,
}) async {
  final router = GoRouter(
    initialLocation: '/lesson/99',
    routes: [
      GoRoute(
        path: '/lesson/:id',
        builder: (_, _) => const QuestionScreen(lessonId: 99),
      ),
      GoRoute(
        path: '/lesson/:id/result',
        builder: (_, _) => const Scaffold(body: Text('RESULT_PAGE')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        lessonRepositoryProvider.overrideWithValue(repo),
        courseRepositoryProvider.overrideWithValue(_FakeCourseRepo()),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  if (startAt > 0) {
    final container = ProviderScope.containerOf(
      tester.element(find.byType(QuestionScreen)),
    );
    final controller = container.read(lessonSessionProvider(99).notifier);
    controller.state = controller.state.copyWith(currentIndex: startAt);
    await tester.pumpAndSettle();
  }
}

Question _q(
  int id,
  QuestionType type,
  String content,
  Object? options,
  Object expected,
) => Question(
  id: id,
  questionCode: 'A1-001-Q$id',
  questionType: type,
  questionContent: content,
  options: options,
  difficulty: 1,
  sortOrder: id,
);

final _questions = [
  _q(
    1,
    QuestionType.singleChoice,
    'Choose the complete sentence.',
    [
      {'id': 'A', 'text': 'Reads books.'},
      {'id': 'B', 'text': 'Lina reads books.'},
      {'id': 'C', 'text': 'Lina books.'},
    ],
    const {'optionId': 'B'},
  ),
  _q(
    2,
    QuestionType.trueFalse,
    'True or false: In "Birds fly", "Birds" is the subject.',
    [
      {'value': true, 'text': 'True'},
      {'value': false, 'text': 'False'},
    ],
    const {'value': true},
  ),
  _q(
    3,
    QuestionType.singleChoice,
    '点击句子中的主语。Noah drinks coffee.',
    [
      {'id': 'A', 'text': 'Noah'},
      {'id': 'B', 'text': 'drinks'},
      {'id': 'C', 'text': 'coffee'},
    ],
    const {'optionId': 'A'},
  ),
  _q(
    4,
    QuestionType.singleChoice,
    '点击句子中的动词。Mia sings songs.',
    [
      {'id': 'A', 'text': 'Mia'},
      {'id': 'B', 'text': 'sings'},
      {'id': 'C', 'text': 'songs'},
    ],
    const {'optionId': 'B'},
  ),
  _q(
    5,
    QuestionType.fillBlank,
    '把正确的词点进空格。Tom ___ football every day.',
    [
      {'id': 'A', 'text': 'plays'},
      {'id': 'B', 'text': 'football'},
      {'id': 'C', 'text': 'day'},
    ],
    const {
      'answers': ['plays'],
    },
  ),
  _q(
    6,
    QuestionType.singleChoice,
    'Tom: Hi! I am Tom.\nMia: ___',
    [
      {'id': 'A', 'text': 'I am Mia.'},
      {'id': 'B', 'text': 'Mia am I.'},
      {'id': 'C', 'text': 'Am Mia.'},
    ],
    const {'optionId': 'A'},
  ),
  _q(
    7,
    QuestionType.singleChoice,
    '根据规则选择：英语陈述句通常先说___，再说动作。',
    [
      {'id': 'A', 'text': '主语'},
      {'id': 'B', 'text': '动词'},
      {'id': 'C', 'text': '宾语'},
    ],
    const {'optionId': 'A'},
  ),
  _q(
    8,
    QuestionType.sentenceOrder,
    '按顺序点击词块，组成正确的句子。',
    ['reads', 'Lina', 'books', '.'],
    const {
      'tokens': ['Lina', 'reads', 'books', '.'],
    },
  ),
  _q(
    9,
    QuestionType.multipleChoice,
    '把句子 “Tom plays football.” 中的词和它扮演的角色配对。',
    [
      {'id': 'A', 'text': 'Tom → 主语'},
      {'id': 'B', 'text': 'Tom → 动词'},
      {'id': 'C', 'text': 'Tom → 宾语'},
      {'id': 'D', 'text': 'plays → 主语'},
      {'id': 'E', 'text': 'plays → 动词'},
      {'id': 'F', 'text': 'plays → 宾语'},
      {'id': 'G', 'text': 'football → 主语'},
      {'id': 'H', 'text': 'football → 动词'},
      {'id': 'I', 'text': 'football → 宾语'},
    ],
    const {
      'optionIds': ['A', 'E', 'I'],
    },
  ),
  _q(
    10,
    QuestionType.multipleChoice,
    '把单词放进正确的类别：动词还是名词。',
    [
      {'id': 'A', 'text': 'sing → 动词'},
      {'id': 'B', 'text': 'sing → 名词'},
      {'id': 'C', 'text': 'book → 动词'},
      {'id': 'D', 'text': 'book → 名词'},
      {'id': 'E', 'text': 'dance → 动词'},
      {'id': 'F', 'text': 'dance → 名词'},
      {'id': 'G', 'text': 'pen → 动词'},
      {'id': 'H', 'text': 'pen → 名词'},
    ],
    const {
      'optionIds': ['A', 'D', 'E', 'H'],
    },
  ),
];

final _fixItQuestion = _q(
  11,
  QuestionType.correction,
  '把错误的词换成正确的词。She *are* happy.',
  [
    {'id': 'A', 'text': 'is'},
    {'id': 'B', 'text': 'am'},
    {'id': 'C', 'text': 'be'},
  ],
  const {
    'acceptedAnswers': ['She is happy.'],
  },
);

class _FakeCourseRepo extends CourseRepository {
  _FakeCourseRepo() : super(ApiClient(Dio()));
  @override
  Future<LessonDetail> lesson(int id) async => LessonDetail(
    id: id,
    grammarPointId: 9,
    title: '找到句子的主角和动作',
    lessonType: 'PRACTICE',
    xpReward: 10,
    sortOrder: 1,
    questionCount: 10,
    contentStatus: 'READY',
  );
}

class _PilotRepo extends LessonRepository {
  _PilotRepo({bool fixItOnly = false})
    : items = fixItOnly ? [_fixItQuestion] : _questions,
      super(ApiClient(Dio()));
  final List<Question> items;
  final submits = <({int id, Object answer})>[];
  int completes = 0;

  @override
  Future<List<Question>> questions(int id) async => items;

  @override
  Future<SubmitAnswerResult> submit(
    int id,
    QuestionType type,
    Object answer,
    int durationMs,
  ) async {
    submits.add((id: id, answer: answer));
    final question = items.firstWhere((q) => q.id == id);
    return SubmitAnswerResult(
      questionId: id,
      correct: _isCorrect(type, question, answer),
      correctAnswer: _expectedOf(question),
      explanation: '解析 $id',
      xpEarned: 1,
      grammarPointMastery: 30,
    );
  }

  @override
  Future<LessonCompletion> complete(int id) async {
    completes++;
    return const LessonCompletion(
      lessonId: 99,
      status: 'COMPLETED',
      totalCount: 10,
      correctCount: 10,
      score: 100,
      xpEarned: 10,
      lessonAttemptId: 7,
    );
  }

  // The wire shape the backend already returns for each pilot question.
  Object _expectedOf(Question question) => switch (question.id) {
    1 || 4 => const {'optionId': 'B'},
    2 => const {'value': true},
    5 => const {
      'answers': ['plays'],
    },
    8 => const {
      'tokens': ['Lina', 'reads', 'books', '.'],
    },
    9 => const {
      'optionIds': ['A', 'E', 'I'],
    },
    10 => const {
      'optionIds': ['A', 'D', 'E', 'H'],
    },
    11 => const {
      'acceptedAnswers': ['She is happy.'],
    },
    _ => const {'optionId': _correctOptionId},
  };

  static const _correctOptionId = 'A';

  // Mini evaluator mirroring the backend QuestionAnswerEvaluator rules.
  bool _isCorrect(QuestionType type, Question question, Object answer) {
    final expected = _expectedOf(question);
    switch (type) {
      case QuestionType.singleChoice:
        return (expected as Map)['optionId'] == answer;
      case QuestionType.trueFalse:
        return (expected as Map)['value'] == answer;
      case QuestionType.multipleChoice:
        final expectedIds = ((expected as Map)['optionIds'] as List).toSet();
        final submitted = (answer as List).whereType<String>().toSet();
        return expectedIds.length == submitted.length &&
            expectedIds.containsAll(submitted);
      case QuestionType.sentenceOrder:
        return ((expected as Map)['tokens'] as List).join('\u0001') ==
            (answer as List).join('\u0001');
      case QuestionType.fillBlank:
        return ((expected as Map)['answers'] as List).contains(answer);
      case QuestionType.correction:
        return ((expected as Map)['acceptedAnswers'] as List).contains(answer);
      case QuestionType.tokenSelect:
        return ((expected as Map)['tokenIds'] as List).toSet().containsAll(
          ((answer as Map)['tokenIds'] as List).toSet(),
        );
      case QuestionType.tokenLabel || QuestionType.slotAssignment:
        return (expected as Map)['assignments'].toString() ==
            (answer as Map)['assignments'].toString();
      case QuestionType.transform:
        return expected.toString() == answer.toString();
    }
  }
}
