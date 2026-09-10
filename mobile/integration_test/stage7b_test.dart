import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:grammar_agent/app.dart';
import 'package:grammar_agent/core/network/network_providers.dart';
import 'package:grammar_agent/core/routing/app_router.dart';
import 'package:grammar_agent/core/storage/token_storage.dart';
import 'package:grammar_agent/features/auth/presentation/auth_controller.dart';
import 'package:grammar_agent/features/course/presentation/course_providers.dart';
import 'package:grammar_agent/features/course/presentation/course_screens.dart';
import 'package:grammar_agent/features/course/domain/grammar_tree.dart';
import 'package:grammar_agent/features/home/presentation/home_screen.dart';
import 'package:grammar_agent/features/lesson/presentation/lesson_screens.dart';
import 'package:grammar_agent/features/lesson/presentation/lesson_session.dart';
import 'package:grammar_agent/features/lesson/presentation/practice_activities.dart';
import 'package:grammar_agent/features/lesson/presentation/question_widgets.dart';
import 'package:grammar_agent/features/profile/presentation/profile_screen.dart';
import 'package:grammar_agent/features/review/presentation/review_screens.dart';
import 'package:grammar_agent/features/tutor/presentation/tutor_sheet.dart';
import 'package:grammar_agent/features/tutor/tutor_session.dart';

// Uses a disposable account against the real local backend. Only token storage
// is isolated so the emulator owner's existing login is left intact.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('7B real Android learning journey', (tester) async {
    final c = ProviderContainer(
      overrides: [tokenStorageProvider.overrideWithValue(MemoryTokenStorage())],
    );
    addTearDown(c.dispose);
    final random = Random.secure();
    final email =
        'stage7b-${DateTime.now().microsecondsSinceEpoch}@example.com';
    final password =
        'Ga7b${List.generate(20, (_) => random.nextInt(10)).join()}';
    final auth = c.read(authRepositoryProvider);
    await auth.register(email, '语法探索者', password);
    await auth.logout();
    await tester.pumpWidget(
      UncontrolledProviderScope(container: c, child: const GrammarAgentApp()),
    );
    await _wait(tester, find.byKey(const Key('login-email')));
    await tester.enterText(find.byKey(const Key('login-email')), email);
    await tester.enterText(find.byKey(const Key('login-password')), password);
    await _tap(tester, find.byKey(const Key('login-submit')));
    await _wait(tester, find.byType(HomeScreen));
    await _wait(tester, find.text('今日目标'));
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('01-home');
    final path = await c.read(myLearningPathProvider.future);
    final firstChapter = path.levels.first.chapters.first;
    final point = firstChapter.grammarPoints.first;
    final lesson = point.lessons.first;
    await _scroll(tester, find.byKey(const ValueKey('home-start-learning')));
    await _tap(tester, find.byKey(const ValueKey('home-start-learning')));
    await _wait(tester, find.byType(MicroLessonScreen));
    expect(find.byType(QuestionScreen), findsNothing);
    await _wait(tester, find.byKey(const ValueKey('teaching-page-1-continue')));
    await _askTutor(tester);
    await binding.takeScreenshot('02-teaching-understand');
    await _tap(tester, find.byKey(const ValueKey('teaching-page-1-continue')));
    await _wait(tester, find.text('常见错误'));
    await binding.takeScreenshot('03-teaching-remember');
    await _tap(tester, find.byKey(const ValueKey('teaching-page-2-continue')));
    await _wait(tester, find.text('Tom'));
    await _tap(tester, find.text('Tom'));
    await _scroll(tester, find.text('下一题'));
    await _tap(tester, find.text('下一题'));
    await _wait(tester, find.text('My sister sings.'));
    await _tap(tester, find.text('My sister sings.'));
    await _wait(tester, find.text('Quick Check 不计入 Mastery。'));
    await _scroll(tester, find.text('进入正式练习'));
    await binding.takeScreenshot('04-quick-check');
    await _tap(tester, find.text('进入正式练习'));
    await _wait(tester, find.byType(LessonScreen));
    await _scroll(tester, find.text('开始学习'));
    await binding.takeScreenshot('05-lesson');
    await _tap(tester, find.text('开始学习'));
    await _wait(tester, find.byType(QuestionScreen));
    final questions = c.read(lessonSessionProvider(lesson.id)).questions;
    for (var i = 0; i < questions.length; i++) {
      final q = questions[i];
      final style = resolveInteractionStyle(q);
      await _wait(tester, find.byKey(ValueKey('activity-${q.id}')));
      switch (style) {
        // Tap-first activities submit themselves; the first activity is
        // answered deliberately wrong to verify orange feedback and review.
        case PracticeInteractionStyle.quickChoice ||
            PracticeInteractionStyle.dialogue ||
            PracticeInteractionStyle.ruleMatch ||
            PracticeInteractionStyle.tokenTap:
          await _tap(
            tester,
            find.text(
              q.optionItems
                  .firstWhere(
                    (o) =>
                        o.id == (q.questionCode == 'A1-001-Q014' ? 'B' : 'A'),
                  )
                  .text,
            ),
          );
        case PracticeInteractionStyle.wordSlot ||
            PracticeInteractionStyle.fixIt:
          await _tap(tester, find.text(q.optionItems.first.text));
        case PracticeInteractionStyle.trueFalse:
          await _tap(tester, find.text('✓ 正确'));
        case PracticeInteractionStyle.tapToBuild:
          for (final option in q.optionItems) {
            await _scroll(tester, find.text(option.text));
            await _tap(tester, find.text(option.text));
          }
        case PracticeInteractionStyle.pairMatch ||
            PracticeInteractionStyle.categorySort:
          final lefts = q.optionItems
              .map((option) => option.text.split(' → ').first)
              .toSet()
              .toList();
          final rights = q.optionItems
              .map((option) => option.text.split(' → ').last)
              .toSet()
              .toList();
          for (var j = 0; j < lefts.length; j++) {
            await _tap(tester, find.text(lefts[j]));
            await _tap(tester, find.text(rights[j % rights.length]));
          }
        case PracticeInteractionStyle.multipleSelect:
          for (final option in q.optionItems) {
            await _tap(tester, find.text(option.text));
          }
        case PracticeInteractionStyle.legacyText:
          await tester.enterText(
            find.byType(TextField).first,
            'She is my teacher.',
          );
        case PracticeInteractionStyle.sentenceSpotlight:
          await _tap(tester, find.byKey(const ValueKey('token-t2')));
        case PracticeInteractionStyle.grammarPaint:
          for (final pair in [
            ('subject', 't1'),
            ('verb', 't2'),
            ('object', 't3'),
          ]) {
            await _tap(tester, find.byKey(ValueKey('labels-${pair.$1}')));
            await _tap(tester, find.byKey(ValueKey('token-${pair.$2}')));
          }
        case PracticeInteractionStyle.slotPuzzle:
          for (final pair in [
            ('t1', 'subject'),
            ('t2', 'verb'),
            ('t3', 'object'),
          ]) {
            await _tap(tester, find.byKey(ValueKey('token-${pair.$1}')));
            await _tap(tester, find.byKey(ValueKey('slots-${pair.$2}')));
          }
        case PracticeInteractionStyle.sentenceSurgery:
          await _tap(tester, find.byKey(const ValueKey('token-t1')));
          await _tap(
            tester,
            find.byKey(const ValueKey('replacement-after-verb')),
          );
        case PracticeInteractionStyle.sentenceTransform:
          await _tap(tester, find.byKey(const ValueKey('token-t3')));
          await _tap(tester, find.byKey(const ValueKey('replacement-r1')));
        case PracticeInteractionStyle.sentenceKnockout:
          await _tap(tester, find.byKey(const ValueKey('card-c4')));
        case PracticeInteractionStyle.patternComplete:
          await _tap(tester, find.byKey(const ValueKey('token-t1')));
        case PracticeInteractionStyle.contextApplication:
          for (final id in ['t1', 't2', 't3', 't4']) {
            await _tap(tester, find.byKey(ValueKey('token-$id')));
          }
      }
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      if (!autoSubmits(style)) {
        await _scroll(tester, find.text('提交答案'));
        await _tap(tester, find.text('提交答案'));
      }
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();
      if (i == 0) {
        await _wait(tester, find.byType(FeedbackPanel));
        await _askTutor(tester);
        await binding.takeScreenshot('06-answer-feedback');
      }
      // Both correct and incorrect feedback stay on this question until Continue.
      expect(find.byKey(ValueKey('activity-${questions[i].id}')), findsOneWidget);
      final next = find.text(i == questions.length - 1 ? '完成 Lesson' : '继续');
      await _wait(tester, next);
      await _scroll(tester, next);
      await _tap(tester, next);
      if (i < questions.length - 1) {
        await _wait(
          tester,
          find.byKey(ValueKey('activity-${questions[i + 1].id}')),
        );
      }
    }
    await _wait(tester, find.byType(LessonResultScreen));
    await _wait(tester, find.text('Lesson 完成'));
    expect(
      tester
          .widget<LessonResultScreen>(find.byType(LessonResultScreen))
          .completion
          .score,
      // The journey deliberately misses only the first native spotlight.
      90,
    );
    await binding.takeScreenshot('07-result');
    await _askTutor(tester, automaticMessage: true);
    await _scroll(tester, find.text('返回语法树'));
    await _tap(tester, find.text('返回语法树'));
    await _wait(tester, find.byType(LearningPathScreen));
    final updated = await c.read(myLearningPathProvider.future);
    expect(findPoint(updated, point.id)?.status, 'IN_PROGRESS');
    expect(findPoint(updated, point.id)?.completedLessons, 1);
    c.read(routerProvider).go('/home');
    await _wait(tester, find.byType(HomeScreen));
    await _wait(tester, find.byKey(const ValueKey('home-start-learning')));
    await _scroll(tester, find.byKey(const ValueKey('home-start-learning')));
    await _tap(tester, find.byKey(const ValueKey('home-start-learning')));
    await _wait(tester, find.byType(LessonScreen));
    expect(find.byType(MicroLessonScreen), findsNothing);
    c.read(routerProvider).go('/review');
    await _wait(tester, find.byType(ReviewScreen));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('08-review');
    await _scroll(tester, find.text('全部未掌握错题'));
    await _tap(tester, find.text('全部未掌握错题'));
    await _wait(tester, find.byType(WrongQuestionsScreen));
    await _wait(tester, find.byType(ListTile));
    await _tap(tester, find.byType(ListTile).first);
    await _wait(tester, find.byType(ReviewPracticeScreen));
    await _tap(tester, find.byKey(const ValueKey('token-t1')));
    await _scroll(tester, find.text('提交答案'));
    await _tap(tester, find.text('提交答案'));
    await _wait(tester, find.byType(FeedbackPanel));
    await _askTutor(tester);
    await _scroll(tester, find.text('完成复习'));
    await _tap(tester, find.text('完成复习'));
    await _wait(tester, find.byType(WrongQuestionsScreen));
    await tester.pageBack();
    await tester.pumpAndSettle();
    await _tap(tester, find.text('我的'));
    await _wait(tester, find.byType(ProfileScreen));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('09-profile');
    expect(tester.takeException(), isNull);
    await auth.logout();
  }, timeout: const Timeout(Duration(minutes: 8)));
}

Future<void> _askTutor(
  WidgetTester tester, {
  bool automaticMessage = false,
}) async {
  await _scroll(tester, find.byType(GrammarTutorButton));
  await _tap(tester, find.byType(GrammarTutorButton));
  await _wait(tester, find.byType(GrammarTutorSheet));
  if (!automaticMessage) {
    await _wait(tester, find.byType(TextField));
    await tester.enterText(find.byType(TextField), '请简单解释一下。');
    await _tap(tester, find.text('发送'));
  }
  // The real LLM reply content is not deterministic; wait for the streamed
  // answer to finish rather than for any specific wording.
  await _wait(
    tester,
    find.byWidgetPredicate(
      (widget) =>
          widget is TutorChatBubble &&
          widget.message.role == 'assistant' &&
          widget.message.status == TutorMessageStatus.complete,
    ),
  );
  expect(
    find.descendant(
      of: find.byType(GrammarTutorSheet),
      matching: find.byType(ActionChip),
    ),
    findsNWidgets(4),
  );
  await _tap(tester, find.byTooltip('关闭'));
  await tester.pumpAndSettle();
  expect(find.byType(GrammarTutorSheet), findsNothing);
}

Future<void> _wait(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 150; i++) {
    if (finder.evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 300));
      return;
    }
    await tester.pump(const Duration(milliseconds: 200));
  }
  expect(finder, findsWidgets, reason: 'Timed out waiting for real backend/UI');
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.tap(finder.first);
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _scroll(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      230,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 40,
    );
  } else {
    await tester.ensureVisible(finder.first);
  }
  await tester.pumpAndSettle();
}
