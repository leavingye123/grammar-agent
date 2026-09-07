import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/async_views.dart';
import '../../../core/widgets/grammar_cat.dart';
import '../../../core/widgets/learning_widgets.dart';
import '../../course/domain/grammar_tree.dart';
import '../../course/presentation/course_providers.dart';
import '../../home/presentation/home_providers.dart';
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
      appBar: AppBar(title: const Text('准备学习')),
      body: lesson.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(lessonProvider(widget.id)),
        ),
        data: (item) => PageBody(
          children: [
            const SizedBox(height: AppSpacing.xl),
            const Icon(
              Icons.auto_stories_rounded,
              size: 56,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(item.title, style: Theme.of(context).textTheme.headlineMedium),
            const SectionHeader('本课目标'),
            GrammarCard(
              child: Text(item.description ?? '理解语法规则，并通过练习检查自己的掌握情况。'),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.bolt, size: 18),
                  label: Text('最高 ${item.xpReward} XP'),
                ),
                const Chip(
                  avatar: Icon(Icons.schedule, size: 18),
                  label: Text('按自己的节奏学习'),
                ),
              ],
            ),
            const SectionHeader('你会如何学习'),
            const GrammarCard(
              child: Text(
                '阅读题目 → 提交答案 → 查看解析 → 再试着理解\n\n答题会更新语法掌握度；完成本课后，根据本次成绩结算 XP。',
              ),
            ),
            const CatMessage('这节很重要，我们慢慢来。遇到容易混的地方，我陪你一起看解析。'),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: () => setState(() => started = true),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('开始学习'),
            ),
          ],
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
    if (state.loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const LoadingView(label: '加载题目…'),
      );
    }
    if (state.error != null && state.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(error: state.error!, onRetry: controller.load),
      );
    }
    final question = state.current;
    if (question == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyView(message: '本 Lesson 暂无题目'),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('${state.currentIndex + 1} / ${state.questions.length}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: LinearProgressIndicator(
            value:
                (state.currentIndex + (state.feedback == null ? 0 : 1)) /
                state.questions.length,
          ),
        ),
      ),
      body: SafeArea(
        child: PageBody(
          children: [
            Text(
              _questionLabel(question.questionType),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              question.questionContent,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xl),
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
                  style: const TextStyle(color: AppColors.orange),
                ),
              ),
            if (state.feedback != null) ...[
              const SizedBox(height: AppSpacing.xl),
              FeedbackPanel(
                question: question,
                correct: state.feedback!.correct,
                correctAnswer: state.feedback!.correctAnswer,
                explanation: state.feedback!.explanation,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            if (state.feedback == null)
              FilledButton(
                onPressed: state.answer == null || state.submitting
                    ? null
                    : controller.submit,
                child: Text(state.submitting ? '正在检查…' : '提交答案'),
              )
            else
              FilledButton(
                onPressed: state.submitting
                    ? null
                    : () async {
                        try {
                          final completion = await controller.continueNext();
                          if (completion != null && context.mounted) {
                            context.go(
                              '/lesson/$lessonId/result',
                              extra: LessonResultData(
                                completion,
                                controller.sessionWatch.elapsedMilliseconds,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      },
                child: Text(
                  state.submitting
                      ? '正在结算…'
                      : state.currentIndex == state.questions.length - 1
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

String _questionLabel(QuestionType type) => switch (type) {
  QuestionType.singleChoice => '选择最合适的答案',
  QuestionType.multipleChoice => '选择所有正确答案',
  QuestionType.fillBlank => '补全句子',
  QuestionType.sentenceOrder => '把词块组成一句话',
  QuestionType.trueFalse => '判断句子是否正确',
  QuestionType.correction => '修改句子中的错误',
};

class LessonResultData {
  const LessonResultData(this.completion, this.durationMs);
  final LessonCompletion completion;
  final int durationMs;
}

class LessonResultScreen extends ConsumerWidget {
  const LessonResultScreen({
    super.key,
    required this.lessonId,
    required this.completion,
    this.durationMs,
  });
  final int lessonId;
  final LessonCompletion completion;
  final int? durationMs;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = ref.watch(myLearningPathProvider);
    final dashboard = ref.watch(dashboardProvider);
    final point = path.asData?.value.levels
        .expand(pointsInLevel)
        .where((p) => p.lessons.any((l) => l.id == lessonId))
        .firstOrNull;
    final next = dashboard.asData?.value.continueLearning;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('学习结果'),
      ),
      body: SafeArea(
        child: PageBody(
          children: [
            const Center(child: GrammarCat(size: 104, celebrating: true)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '又长出一片新叶',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text('Lesson 完成', textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            StatGrid(
              items: [
                StatCard(
                  label: '答对题数',
                  value:
                      '${completion.correctCount} / ${completion.totalCount}',
                  icon: Icons.check_circle_outline,
                ),
                StatCard(
                  label: 'Score',
                  value: '${completion.score}',
                  icon: Icons.track_changes,
                ),
                StatCard(
                  label: '本次 XP',
                  value: '+${completion.xpEarned}',
                  icon: Icons.bolt,
                ),
              ],
            ),
            Text(
              '正确率 ${completion.totalCount == 0 ? 0 : (completion.correctCount / completion.totalCount * 100).round()}%',
            ),
            if (durationMs != null)
              Text(
                '本次设备学习用时 ${durationMs! ~/ 60000} 分 ${(durationMs! ~/ 1000) % 60} 秒',
              ),
            if (point != null)
              ProgressCard(
                title: '${point.title} · 当前 Mastery',
                value: '${point.masteryScore ?? 0}%',
                fraction: (point.masteryScore ?? 0) / 100,
                caption: '继续练习，让理解更牢固。',
              ),
            if (path.isLoading || dashboard.isLoading)
              const LinearProgressIndicator(),
            if (path.hasError)
              ErrorView(
                error: '掌握度暂时无法加载',
                onRetry: () => ref.invalidate(myLearningPathProvider),
              ),
            if (dashboard.hasError)
              ErrorView(
                error: '下一课推荐暂时无法加载',
                onRetry: () => ref.invalidate(dashboardProvider),
              ),
            const CatMessage('今天的每一次练习，都在帮你扎下更深的根。', celebrating: true),
            if (next != null && next.lessonId != lessonId)
              FilledButton(
                onPressed: () => context.go('/lesson/${next.lessonId}'),
                child: Text('继续学习 · ${next.lessonTitle}'),
              ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              onPressed: () => context.go('/learning-path'),
              child: const Text('返回语法树'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () => context.go('/review/wrong'),
              child: const Text('复习错题'),
            ),
          ],
        ),
      ),
    );
  }
}
