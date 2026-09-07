import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_views.dart';
import '../../../core/widgets/learning_widgets.dart';
import '../../../core/theme/design_tokens.dart';
import '../../home/presentation/home_providers.dart';
import '../../course/presentation/course_providers.dart';
import '../../lesson/presentation/question_widgets.dart';
import '../domain/review_models.dart';
import 'review_providers.dart';

String formatLocalTime(DateTime? time) {
  if (time == null) return '暂无计划';
  final t = time.toLocal();
  String p(int v) => v.toString().padLeft(2, '0');
  return '${t.year}-${p(t.month)}-${p(t.day)} ${p(t.hour)}:${p(t.minute)}';
}

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(reviewSummaryProvider);
    final due = ref.watch(reviewDueProvider);
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(reviewSummaryProvider);
        ref.invalidate(reviewDueProvider);
        await ref.read(reviewSummaryProvider.future);
      },
      child: PageBody(
        children: [
          Text('语法记忆', style: Theme.of(context).textTheme.headlineLarge),
          const Text('Grammar Memory · 让理解留下来'),
          const CatMessage('复习不是从头再来，而是让已经长出的叶子更有活力。'),
          summary.when(
            loading: () => const LoadingView(),
            error: (e, _) => ErrorView(
              error: e,
              onRetry: () => ref.invalidate(reviewSummaryProvider),
            ),
            data: (s) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatGrid(
                  items: [
                    StatCard(
                      label: '待复习',
                      value: '${s.dueCount}',
                      icon: Icons.replay,
                    ),
                    StatCard(
                      label: '未掌握',
                      value: '${s.unmasteredCount}',
                      icon: Icons.edit_note,
                    ),
                    StatCard(
                      label: '已掌握',
                      value: '${s.masteredCount}',
                      icon: Icons.task_alt,
                    ),
                  ],
                ),
                if (s.dueCount == 0)
                  GrammarCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('当前没有到期错题'),
                        Text('下次复习：${formatLocalTime(s.nextReviewAt)}'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SectionHeader('今日复习', subtitle: '到期的错题，值得再看一次'),
          due.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => ErrorView(
              error: e,
              onRetry: () => ref.invalidate(reviewDueProvider),
            ),
            data: (items) => items.isEmpty
                ? const GrammarCard(child: Text('今天暂时没有到期任务，也可以主动巩固未掌握错题。'))
                : FilledButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: Text('开始复习（${items.length}）'),
                    onPressed: () => _openPractice(context, ref, items),
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WrongQuestionsScreen()),
            ),
            icon: const Icon(Icons.list_alt),
            label: const Text('全部未掌握错题'),
          ),
          const GrammarCard(
            child: Text('当前复习来源：答错的题目与到期复习计划。复习会更新掌握度，不获得 XP。'),
          ),
          const FutureFeature(
            title: '更懂你的复习',
            description: '未来覆盖易混语法、低掌握度和长期未练习的知识。',
            icon: Icons.eco_outlined,
          ),
        ],
      ),
    );
  }

  static Future<void> _openPractice(
    BuildContext context,
    WidgetRef ref,
    List<ReviewQuestion> items,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReviewPracticeScreen(items: items)),
    );
    if (!context.mounted) return;
    ref.invalidate(reviewSummaryProvider);
    ref.invalidate(reviewDueProvider);
    ref.invalidate(wrongQuestionsProvider);
  }
}

class WrongQuestionsScreen extends ConsumerWidget {
  const WrongQuestionsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(wrongQuestionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('未掌握错题')),
      body: value.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(wrongQuestionsProvider),
        ),
        data: (items) => items.isEmpty
            ? const EmptyView(message: '暂无未掌握错题，继续保持！', icon: Icons.task_alt)
            : RefreshIndicator(
                onRefresh: () => ref.refresh(wrongQuestionsProvider.future),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      child: ListTile(
                        title: Text(item.question.questionContent),
                        subtitle: Text(
                          '错误 ${item.wrongCount} 次 · 下次 ${formatLocalTime(item.nextReviewAt)}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ReviewPracticeScreen(items: [item]),
                            ),
                          );
                          ref.invalidate(wrongQuestionsProvider);
                          ref.invalidate(reviewSummaryProvider);
                        },
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class ReviewPracticeScreen extends ConsumerStatefulWidget {
  const ReviewPracticeScreen({super.key, required this.items});
  final List<ReviewQuestion> items;
  @override
  ConsumerState<ReviewPracticeScreen> createState() =>
      _ReviewPracticeScreenState();
}

class _ReviewPracticeScreenState extends ConsumerState<ReviewPracticeScreen> {
  int index = 0;
  Object? answer;
  ReviewAnswerResult? result;
  bool submitting = false;
  String? error;
  final Stopwatch stopwatch = Stopwatch()..start();
  Future<void> submit() async {
    if (answer == null || submitting || result != null) return;
    setState(() {
      submitting = true;
      error = null;
    });
    stopwatch.stop();
    final q = widget.items[index].question;
    try {
      final value = await ref
          .read(reviewRepositoryProvider)
          .submit(q.id, q.questionType, answer!, stopwatch.elapsedMilliseconds);
      if (mounted) {
        ref.invalidate(dashboardProvider);
        ref.invalidate(myLearningPathProvider);
        ref.invalidate(reviewSummaryProvider);
        ref.invalidate(reviewDueProvider);
        ref.invalidate(wrongQuestionsProvider);
        setState(() {
          result = value;
          submitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          submitting = false;
          stopwatch.start();
        });
      }
    }
  }

  void next() {
    if (index == widget.items.length - 1) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      index++;
      answer = null;
      result = null;
      error = null;
      stopwatch
        ..reset()
        ..start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.items[index].question;
    return Scaffold(
      appBar: AppBar(title: Text('复习 ${index + 1}/${widget.items.length}')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              q.questionContent,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            QuestionInput(
              key: ValueKey(q.id),
              question: q,
              enabled: result == null && !submitting,
              onChanged: (v) => setState(() => answer = v),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (result != null) ...[
              const SizedBox(height: 20),
              FeedbackPanel(
                question: q,
                correct: result!.correct,
                correctAnswer: result!.correctAnswer,
                explanation: result!.explanation,
                extra: result!.mastered
                    ? '已掌握 ✓'
                    : '仍需复习 · 下次 ${formatLocalTime(result!.nextReviewAt)}',
              ),
            ],
            const SizedBox(height: 24),
            result == null
                ? FilledButton(
                    onPressed: answer == null || submitting ? null : submit,
                    child: submitting
                        ? const CircularProgressIndicator()
                        : const Text('提交答案'),
                  )
                : FilledButton(
                    onPressed: next,
                    child: Text(
                      index == widget.items.length - 1 ? '完成复习' : '继续',
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
