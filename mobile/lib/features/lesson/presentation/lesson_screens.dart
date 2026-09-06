import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_views.dart';
import '../../course/presentation/course_providers.dart';
import '../domain/lesson_models.dart';
import 'lesson_session.dart';
import 'question_widgets.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.id});
  final int id;
  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  bool started = false;
  @override
  Widget build(BuildContext context) {
    if (started) return QuestionScreen(lessonId: widget.id);
    final lesson = ref.watch(lessonProvider(widget.id));
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson')),
      body: lesson.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(lessonProvider(widget.id)),
        ),
        data: (item) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.auto_stories_rounded,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                item.description ?? '准备好开始语法练习了吗？',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '${item.lessonType} · +${item.xpReward} XP',
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => setState(() => started = true),
                child: const Text('开始学习'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionScreen extends ConsumerWidget {
  const QuestionScreen({super.key, required this.lessonId});
  final int lessonId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonSessionProvider(lessonId));
    final controller = ref.read(lessonSessionProvider(lessonId).notifier);
    if (state.loading) return const Scaffold(body: LoadingView(label: '加载题目…'));
    if (state.error != null && state.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(error: state.error!, onRetry: controller.load),
      );
    }
    final question = state.current;
    if (question == null) {
      return const Scaffold(body: EmptyView(message: '本 Lesson 暂无题目'));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('${state.currentIndex + 1} / ${state.questions.length}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (state.currentIndex + 1) / state.questions.length,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              question.questionContent,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 22),
            QuestionInput(
              key: ValueKey(question.id),
              question: question,
              enabled: state.feedback == null && !state.submitting,
              onChanged: controller.setAnswer,
            ),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  state.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (state.feedback != null) ...[
              const SizedBox(height: 20),
              FeedbackPanel(
                correct: state.feedback!.correct,
                correctAnswer: state.feedback!.correctAnswer,
                explanation: state.feedback!.explanation,
              ),
            ],
            const SizedBox(height: 24),
            if (state.feedback == null)
              FilledButton(
                onPressed: state.answer == null || state.submitting
                    ? null
                    : controller.submit,
                child: state.submitting
                    ? const CircularProgressIndicator()
                    : const Text('提交答案'),
              )
            else
              FilledButton(
                onPressed: () async {
                  try {
                    final completion = await controller.continueNext();
                    if (completion != null && context.mounted) {
                      context.go('/lesson/$lessonId/result', extra: completion);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                },
                child: Text(
                  state.currentIndex == state.questions.length - 1
                      ? '完成 Lesson'
                      : '继续',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class LessonResultScreen extends StatelessWidget {
  const LessonResultScreen({
    super.key,
    required this.lessonId,
    required this.completion,
  });
  final int lessonId;
  final LessonCompletion completion;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(automaticallyImplyLeading: false, title: const Text('学习结果')),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            const Text(
              '🎉',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 72),
            ),
            Text(
              'Lesson 完成',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Metric(
                  label: '正确',
                  value:
                      '${completion.correctCount} / ${completion.totalCount}',
                ),
                _Metric(label: 'Score', value: '${completion.score}'),
                _Metric(label: 'XP', value: '+${completion.xpEarned}'),
              ],
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => context.go('/learning-path'),
              child: const Text('返回课程'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => context.go('/review/wrong'),
              child: const Text('查看错题'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: Theme.of(context).textTheme.headlineSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      Text(label),
    ],
  );
}
