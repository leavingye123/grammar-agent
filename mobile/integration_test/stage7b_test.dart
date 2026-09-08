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
import 'package:grammar_agent/features/lesson/domain/lesson_models.dart';
import 'package:grammar_agent/features/lesson/presentation/lesson_screens.dart';
import 'package:grammar_agent/features/lesson/presentation/lesson_session.dart';
import 'package:grammar_agent/features/lesson/presentation/question_widgets.dart';
import 'package:grammar_agent/features/profile/presentation/profile_screen.dart';
import 'package:grammar_agent/features/review/presentation/review_screens.dart';

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
    await _wait(tester, find.byType(QuestionInput));
    final questions = c.read(lessonSessionProvider(lesson.id)).questions;
    for (var i = 0; i < questions.length; i++) {
      final q = questions[i];
      switch (q.questionType) {
        case QuestionType.singleChoice:
          // Deliberately wrong once, to verify orange feedback and review.
          await _tap(
            tester,
            find.text(q.optionItems.firstWhere((o) => o.id == 'A').text),
          );
        case QuestionType.multipleChoice:
          for (final option in q.optionItems) {
            await _tap(tester, find.text(option.text));
          }
        case QuestionType.fillBlank:
          await tester.enterText(find.byType(TextField).first, 'is');
        case QuestionType.sentenceOrder:
          for (final word in ['They', 'are', 'friends', '.']) {
            await _scroll(tester, find.widgetWithText(ActionChip, word));
            await _tap(tester, find.widgetWithText(ActionChip, word));
          }
        case QuestionType.trueFalse:
          await _tap(tester, find.text('正确'));
        case QuestionType.correction:
          await tester.enterText(
            find.byType(TextField).first,
            'She is my teacher.',
          );
      }
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await _scroll(tester, find.text('提交答案'));
      await _tap(tester, find.text('提交答案'));
      await _wait(tester, find.byType(FeedbackPanel));
      await _scroll(tester, find.byType(FeedbackPanel));
      expect(
        tester.widget<FeedbackPanel>(find.byType(FeedbackPanel)).explanation,
        isNotEmpty,
      );
      if (i == 0) await binding.takeScreenshot('06-answer-feedback');
      await _scroll(
        tester,
        find.text(i == questions.length - 1 ? '完成 Lesson' : '继续'),
      );
      await _tap(
        tester,
        find.text(i == questions.length - 1 ? '完成 Lesson' : '继续'),
      );
      if (i < questions.length - 1) {
        await _wait(tester, find.byKey(ValueKey(questions[i + 1].id)));
        await tester.drag(find.byType(Scrollable).first, const Offset(0, 900));
        await tester.pumpAndSettle();
      }
    }
    await _wait(tester, find.byType(LessonResultScreen));
    await _wait(tester, find.text('Lesson 完成'));
    expect(
      tester
          .widget<LessonResultScreen>(find.byType(LessonResultScreen))
          .completion
          .score,
      50,
    );
    await binding.takeScreenshot('07-result');
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
    final first = questions.first;
    await _tap(
      tester,
      find.text(first.optionItems.firstWhere((o) => o.id == 'B').text),
    );
    await _scroll(tester, find.text('提交答案'));
    await _tap(tester, find.text('提交答案'));
    await _wait(tester, find.byType(FeedbackPanel));
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
