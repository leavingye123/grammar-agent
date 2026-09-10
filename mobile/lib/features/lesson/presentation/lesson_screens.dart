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
import '../../tutor/presentation/tutor_sheet.dart';
import '../../tutor/tutor_session.dart';
import '../domain/lesson_models.dart';
import 'lesson_session.dart';
import 'practice_activities.dart';
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
                '点一点完成一个个小活动 → 自动判分 → 立即反馈\n\n查看解析，有疑问可以问语法小猫，准备好后点击“继续”。答题会更新语法掌握度，完成本课后结算 XP。',
              ),
            ),
            const CatMessage('这节很重要，我们慢慢来。遇到容易混的地方，我陪你一起看解析。'),
            if (!item.contentAvailable)
              const CatMessage('正式练习还在准备中，可以先返回知识卡片学习 Micro Lesson。'),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: item.contentAvailable
                  ? () => setState(() => started = true)
                  : null,
              icon: Icon(
                item.contentAvailable
                    ? Icons.arrow_forward
                    : Icons.hourglass_empty,
              ),
              label: Text(item.contentAvailable ? '开始学习' : '内容准备中'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionScreen extends ConsumerStatefulWidget {
  const QuestionScreen({super.key, required this.lessonId});
  final int lessonId;
  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends ConsumerState<QuestionScreen> {
  bool _canOpenTutor(int questionId) {
    final state = ref.read(lessonSessionProvider(widget.lessonId));
    if (state.current?.id != questionId || state.feedback == null || state.submitting) {
      return false;
    }
    return true;
  }

  void _clearQuestionTutor(String? questionCode) {
    if (questionCode != null &&
        ref.read(tutorSessionProvider).scopeKey == 'question:$questionCode') {
      ref.read(tutorSessionProvider.notifier).clear();
    }
  }

  Future<void> _continueNext() async {
    final controller = ref.read(lessonSessionProvider(widget.lessonId).notifier);
    final question = ref.read(lessonSessionProvider(widget.lessonId)).current;
    try {
      final completion = await controller.continueNext();
      if (!mounted) return;
      if (completion != null ||
          ref.read(lessonSessionProvider(widget.lessonId)).current?.id != question?.id) {
        _clearQuestionTutor(question?.questionCode);
      }
      if (completion != null && mounted) {
        context.go(
          '/lesson/${widget.lessonId}/result',
          extra: LessonResultData(
            completion,
            controller.sessionWatch.elapsedMilliseconds,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lessonSessionProvider(widget.lessonId));
    final controller = ref.read(lessonSessionProvider(widget.lessonId).notifier);
    final tutorGrammarPointId = ref
        .watch(lessonProvider(widget.lessonId))
        .asData
        ?.value
        .grammarPointId;
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
    final style = resolveInteractionStyle(question);
    final prompt = activityPrompt(question, style);
    final isLast = state.currentIndex == state.questions.length - 1;
    final feedback = state.feedback;
    return Scaffold(
      appBar: AppBar(
        title: Text('${state.currentIndex + 1} / ${state.questions.length}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(26),
          child: _PracticeProgressDots(
            current: state.currentIndex,
            total: state.questions.length,
            results: state.results,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                children: [
                  Text(
                    interactionLabel(style),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (prompt.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      prompt,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  PracticeActivityInput(
                    key: ValueKey('activity-${question.id}'),
                    question: question,
                    style: style,
                    enabled: feedback == null && !state.submitting,
                    onChanged: controller.setAnswer,
                    onAutoSubmit: controller.submit,
                  ),
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        state.error!,
                        style: const TextStyle(color: AppColors.orange),
                      ),
                    ),
                  if (feedback != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    if (feedback.correct)
                      _CorrectBanner(explanation: feedback.explanation)
                    else ...[
                      FeedbackPanel(
                        question: question,
                        correct: false,
                        correctAnswer: feedback.correctAnswer,
                        explanation: feedback.explanation,
                      ),
                    ],
                  ],
                ],
              ),
            ),
            // Shared by every activity renderer and visible without scrolling,
            // so the learner can ask about even a long activity's feedback.
            if (feedback != null && tutorGrammarPointId != null && question.questionCode != null)
              GrammarTutorButton(
                grammarPointId: tutorGrammarPointId,
                questionCode: question.questionCode,
                wrongAnswer: !feedback.correct,
                onBeforeOpen: () => _canOpenTutor(question.id),
              ),
            if (feedback == null && !autoSubmits(style))
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: state.answer == null || state.submitting
                        ? null
                        : controller.submit,
                    child: Text(state.submitting ? '正在检查…' : '提交答案'),
                  ),
                ),
              )
            else if (feedback != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: state.submitting ? null : _continueNext,
                    child: Text(
                      state.submitting
                          ? '正在结算…'
                          : isLast
                          ? '完成 Lesson'
                          : '继续',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PracticeProgressDots extends StatelessWidget {
  const _PracticeProgressDots({
    required this.current,
    required this.total,
    required this.results,
  });
  final int current;
  final int total;
  final List<SubmitAnswerResult> results;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            Container(
              key: ValueKey('practice-dot-$i'),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < results.length
                    ? (results[i].correct ? AppColors.primary : AppColors.orange)
                    : Colors.transparent,
                border: i >= results.length
                    ? Border.all(
                        color: i == current ? AppColors.primary : AppColors.border,
                        width: 2,
                      )
                    : null,
              ),
            ),
            if (i != total - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _CorrectBanner extends StatelessWidget {
  const _CorrectBanner({required this.explanation});
  final String? explanation;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: AppColors.mint,
      borderRadius: AppRadius.card,
      border: Border.all(color: AppColors.primary),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '✓ 正确',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        if (explanation?.isNotEmpty == true) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(explanation!, style: const TextStyle(color: AppColors.secondaryText)),
        ],
      ],
    ),
  );
}

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
            if (completion.lessonAttemptId != null) ...[
              const SizedBox(height: AppSpacing.md),
              GrammarCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🐱 Grammar Cat'),
                    Text(completion.correctCount == completion.totalCount
                        ? '这次全部答对了。可以让 Grammar Cat 帮你总结规则或提醒容易混淆的地方。'
                        : '想看看这次哪里需要注意吗？'),
                    GrammarTutorButton(lessonAttemptId: completion.lessonAttemptId),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
