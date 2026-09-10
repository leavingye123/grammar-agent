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
import 'package:grammar_agent/features/lesson/presentation/lesson_session.dart';
import 'package:grammar_agent/features/tutor/data/tutor_repository.dart';
import 'package:grammar_agent/features/tutor/data/tutor_stream.dart';
import 'package:grammar_agent/features/tutor/presentation/tutor_sheet.dart';
import 'package:grammar_agent/features/tutor/tutor_session.dart';

void main() {
  // Real renderer actions -> repository result -> shared feedback -> real TutorSheet.
  // The fake backend supplies correctness; the UI never evaluates these answers.
  for (final style in <InteractionStyle?>[...InteractionStyle.values, null]) {
    testWidgets('correct $style: feedback waits, Tutor preserves scope, and Continue clears it', (tester) async {
      final repo = _Lessons([_question(style), _nextQuestion]);
      final tutor = _Tutor();
      final container = await _pump(tester, repo, tutor);
      expect(find.byType(GrammarTutorButton), findsNothing);
      await _answer(tester, style);
      expect(repo.submits, 1);
      await tester.pump(const Duration(seconds: 5));
      expect(container.read(lessonSessionProvider(99)).currentIndex, 0);
      expect(find.text('继续'), findsOneWidget);
      final entry = find.byType(GrammarTutorButton);
      expect(entry.hitTestable(), findsOneWidget);
      expect(tester.widget<GrammarTutorButton>(entry).wrongAnswer, isFalse);
      expect(find.text('🐱 还有疑问？问 Grammar Cat'), findsOneWidget);
      await tester.tap(entry);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2)); // Beyond the old timer.
      expect(container.read(lessonSessionProvider(99)).currentIndex, 0);
      expect(container.read(tutorSessionProvider).scopeKey, 'question:Q1');
      expect(tutor.scenes, ['answered']);
      final input = find.descendant(of: find.byType(GrammarTutorSheet), matching: find.byType(TextField));
      await tester.enterText(input, '为什么这样用？');
      await tester.tap(find.text('发送'));
      await tester.pumpAndSettle();
      expect(tutor.questionCodes, ['Q1']);
      expect(container.read(tutorSessionProvider).messages.last.content, '这是当前题的解释。');

      await tester.tap(find.byTooltip('关闭'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      expect(container.read(lessonSessionProvider(99)).currentIndex, 0);
      expect(container.read(lessonSessionProvider(99)).feedback?.correct, isTrue);
      expect(find.text('继续'), findsOneWidget);
      await tester.tap(find.byType(GrammarTutorButton));
      await tester.pumpAndSettle();
      expect(container.read(tutorSessionProvider).messages, hasLength(2));
      expect(tutor.scenes, ['answered']); // Reopen does not reset the session.
      await tester.tap(find.byTooltip('关闭'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('继续'));
      await tester.pumpAndSettle();
      expect(find.text('2 / 2'), findsOneWidget);
      expect(container.read(tutorSessionProvider).messages, isEmpty);
      expect(container.read(tutorSessionProvider).scopeKey, isNull);
      expect(repo.completes, 0);
      expect(find.byType(GrammarTutorButton), findsNothing);

      await tester.tap(find.text('Next answer'));
      await tester.pump();
      await tester.tap(find.byType(GrammarTutorButton));
      await tester.pumpAndSettle();
      expect(container.read(tutorSessionProvider).scopeKey, 'question:Q2');
      expect(container.read(tutorSessionProvider).messages, isEmpty);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('correct without opening Tutor waits indefinitely for Continue and makes no AI request', (tester) async {
    final repo = _Lessons([_question(InteractionStyle.sentenceSpotlight), _nextQuestion]);
    final tutor = _Tutor();
    final container = await _pump(tester, repo, tutor);
    await _answer(tester, InteractionStyle.sentenceSpotlight);
    expect(find.byType(GrammarTutorButton).hitTestable(), findsOneWidget);
    await tester.pump(const Duration(seconds: 30));
    expect(container.read(lessonSessionProvider(99)).currentIndex, 0);
    expect(tutor.scenes, isEmpty);
    expect(tutor.questionCodes, isEmpty);
    await tester.tap(find.text('继续'));
    await tester.pumpAndSettle();
    expect(container.read(lessonSessionProvider(99)).currentIndex, 1);
  });

  testWidgets('wrong answer still opens Tutor and only continues manually', (tester) async {
    final repo = _Lessons([_question(InteractionStyle.quickChoice), _nextQuestion], correct: false);
    final tutor = _Tutor();
    final container = await _pump(tester, repo, tutor);
    await _answer(tester, InteractionStyle.quickChoice);
    await tester.pump(const Duration(seconds: 2));
    expect(container.read(lessonSessionProvider(99)).currentIndex, 0);
    expect(find.text('🐱 不明白为什么？问 Grammar Cat'), findsOneWidget);
    await tester.tap(find.byType(GrammarTutorButton));
    await tester.pumpAndSettle();
    expect(tutor.scenes, ['wrong']);
    await tester.tap(find.byTooltip('关闭'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('继续'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 2'), findsOneWidget);
  });

  testWidgets('Tutor can still open long after the correct answer was submitted', (tester) async {
    final repo = _Lessons([_question(InteractionStyle.sentenceSpotlight), _nextQuestion]);
    final container = await _pump(tester, repo, _Tutor());
    await _answer(tester, InteractionStyle.sentenceSpotlight);
    await tester.pump(const Duration(seconds: 30));
    await tester.tap(find.byType(GrammarTutorButton));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(GrammarTutorSheet), findsOneWidget);
    expect(container.read(lessonSessionProvider(99)).currentIndex, 0);
    expect(container.read(tutorSessionProvider).scopeKey, 'question:Q1');
  });

  testWidgets('last correct question keeps Tutor, then completion reaches Result exactly once', (tester) async {
    final repo = _Lessons([_question(InteractionStyle.sentenceSpotlight)]);
    final container = await _pump(tester, repo, _Tutor());
    await _answer(tester, InteractionStyle.sentenceSpotlight);
    await tester.pump(const Duration(seconds: 2));
    expect(repo.completes, 0);
    await tester.tap(find.byType(GrammarTutorButton));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    expect(repo.completes, 0);
    await tester.tap(find.byTooltip('关闭'));
    await tester.pumpAndSettle();
    expect(find.text('完成 Lesson'), findsOneWidget);
    await tester.tap(find.text('完成 Lesson'));
    await tester.pumpAndSettle();
    expect(find.text('RESULT_PAGE'), findsOneWidget);
    expect(repo.completes, 1);
    expect(container.read(tutorSessionProvider).scopeKey, isNull);
  });
}

Future<void> _answer(WidgetTester tester, InteractionStyle? style) async {
  final keys = switch (style) {
    InteractionStyle.sentenceSpotlight => ['token-t1'],
    InteractionStyle.grammarPaint => ['labels-subject', 'token-t1'],
    InteractionStyle.slotPuzzle => ['token-t1', 'slots-subject'],
    InteractionStyle.sentenceSurgery || InteractionStyle.sentenceTransform => ['token-t1', 'replacement-r1'],
    InteractionStyle.sentenceKnockout => ['card-c1'],
    InteractionStyle.patternComplete || InteractionStyle.contextApplication => ['token-t1'],
    _ => <String>[],
  };
  for (final key in keys) {
    await tester.tap(find.byKey(ValueKey(key)));
    await tester.pump();
  }
  if (style == null) {
    await tester.enterText(find.byType(TextField), 'I');
    await tester.tap(find.text('提交答案'));
  } else if (style == InteractionStyle.quickChoice) {
    await tester.tap(find.text('Yes'));
  } else if (style == InteractionStyle.tapToBuild) {
    await tester.tap(find.text('I'));
  }
  await tester.pump();
}

Future<ProviderContainer> _pump(WidgetTester tester, _Lessons repo, _Tutor tutor) async {
  final router = GoRouter(initialLocation: '/lesson/99', routes: [
    GoRoute(path: '/lesson/:id', builder: (_, _) => const QuestionScreen(lessonId: 99)),
    GoRoute(path: '/lesson/:id/result', builder: (_, state) {
      expect(state.extra, isA<LessonResultData>());
      return const Scaffold(body: Text('RESULT_PAGE'));
    }),
  ]);
  addTearDown(router.dispose);
  await tester.pumpWidget(ProviderScope(overrides: [
    lessonRepositoryProvider.overrideWithValue(repo),
    courseRepositoryProvider.overrideWithValue(_Course()),
    tutorRepositoryProvider.overrideWithValue(tutor),
  ], child: MaterialApp.router(routerConfig: router)));
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(QuestionScreen)));
}

const _tokens = [{'id': 't1', 'text': 'I'}];
Question _question(InteractionStyle? style) => Question(
  id: 1, questionCode: 'Q1', interactionStyle: style,
  questionType: switch (style) {
    InteractionStyle.sentenceSpotlight => QuestionType.tokenSelect,
    InteractionStyle.grammarPaint => QuestionType.tokenLabel,
    InteractionStyle.slotPuzzle || InteractionStyle.patternComplete => QuestionType.slotAssignment,
    InteractionStyle.sentenceSurgery || InteractionStyle.sentenceTransform => QuestionType.transform,
    InteractionStyle.contextApplication || InteractionStyle.tapToBuild => QuestionType.sentenceOrder,
    null => QuestionType.fillBlank,
    _ => QuestionType.singleChoice,
  },
  questionContent: '当前活动', difficulty: 1, sortOrder: 1,
  options: switch (style) {
    null => null,
    InteractionStyle.quickChoice => const [{'id': 'A', 'text': 'Yes'}],
    InteractionStyle.tapToBuild => const ['I'],
    _ => const {
      'tokens': _tokens,
      'labels': [{'id': 'subject', 'text': '主语'}],
      'slots': [{'id': 'subject', 'text': '主语'}],
      'replacements': [{'id': 'r1', 'text': 'We'}],
      'cards': [{'id': 'c1', 'text': 'I am here.'}],
      'patternRows': [['You'], [null]],
      'scene': {'speaker': 'Cat', 'line': 'Hello', 'targetMeaning': '我'},
    },
  },
);
const _nextQuestion = Question(id: 2, questionCode: 'Q2', questionType: QuestionType.singleChoice,
    questionContent: '下一题', options: [{'id': 'A', 'text': 'Next answer'}], difficulty: 1, sortOrder: 2);

class _Course extends CourseRepository {
  _Course() : super(ApiClient(Dio()));
  @override
  Future<LessonDetail> lesson(int id) async => LessonDetail(id: id, grammarPointId: 9,
      title: 'Grammar', lessonType: 'PRACTICE', xpReward: 10, sortOrder: 1, questionCount: 2, contentStatus: 'READY');
}

class _Lessons extends LessonRepository {
  _Lessons(this.items, {this.correct = true}) : super(ApiClient(Dio()));
  final List<Question> items;
  final bool correct;
  int submits = 0;
  int completes = 0;
  @override
  Future<List<Question>> questions(int id) async => items;
  @override
  Future<SubmitAnswerResult> submit(int id, QuestionType type, Object answer, int durationMs) async {
    submits++;
    return SubmitAnswerResult(questionId: id, correct: correct, correctAnswer: const {'optionId': 'A'},
        explanation: '简短解释', xpEarned: 1, grammarPointMastery: 30);
  }
  @override
  Future<LessonCompletion> complete(int id) async {
    completes++;
    return LessonCompletion(lessonId: id, status: 'COMPLETED', totalCount: items.length,
        correctCount: items.length, score: 100, xpEarned: 10, lessonAttemptId: 7);
  }
}

class _Tutor extends TutorRepository {
  _Tutor() : super(ApiClient(Dio()));
  final scenes = <String>[];
  final questionCodes = <String?>[];
  @override
  Future<TutorStatus> status(String scene, {int? lessonAttemptId}) async {
    scenes.add(scene);
    return const TutorStatus(true, ['解释一下', '再举例', '怎么记', '注意什么']);
  }
  @override
  Stream<TutorStreamEvent> streamChat({int? grammarPointId, int? lessonAttemptId,
    required String message, String? questionCode, List<TutorMessage> history = const [], CancelToken? cancelToken,
  }) async* {
    questionCodes.add(questionCode);
    yield const TutorStreamEvent.delta('这是当前题的解释。');
    yield const TutorStreamEvent.done([]);
  }
}
