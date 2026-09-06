import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_views.dart';
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
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              '复习中心',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          summary.when(
            loading: () => const SizedBox(height: 180, child: LoadingView()),
            error: (e, _) => SizedBox(
              height: 200,
              child: ErrorView(
                error: e,
                onRetry: () => ref.invalidate(reviewSummaryProvider),
              ),
            ),
            data: (s) => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(label: '待复习', value: s.dueCount),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCard(
                        label: '未掌握',
                        value: s.unmasteredCount,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCard(label: '已掌握', value: s.masteredCount),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (s.dueCount == 0)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: const Text('当前没有到期错题'),
                      subtitle: Text('下次复习：${formatLocalTime(s.nextReviewAt)}'),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          due.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text(e.toString()),
            data: (items) => items.isEmpty
                ? const SizedBox.shrink()
                : FilledButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: Text('开始复习（${items.length}）'),
                    onPressed: () => _openPractice(context, ref, items),
                  ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WrongQuestionsScreen()),
            ),
            icon: const Icon(Icons.list_alt),
            label: const Text('全部未掌握错题'),
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
    ref.invalidate(reviewSummaryProvider);
    ref.invalidate(reviewDueProvider);
    ref.invalidate(wrongQuestionsProvider);
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      child: Column(
        children: [
          Text(
            '$value',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(label),
        ],
      ),
    ),
  );
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
