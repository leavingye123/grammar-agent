import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/async_views.dart';
import '../../../core/widgets/grammar_cat.dart';
import '../../../core/widgets/learning_widgets.dart';
import 'home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(dashboardProvider);
    return RefreshIndicator(
      onRefresh: () => ref.refresh(dashboardProvider.future),
      child: value.when(
        loading: () => const PageBody(children: [LoadingView()]),
        error: (e, _) => PageBody(
          children: [
            ErrorView(
              error: e,
              onRetry: () => ref.invalidate(dashboardProvider),
            ),
          ],
        ),
        data: (d) => PageBody(
          children: [
            Row(
              children: [
                const Icon(Icons.spa, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'GrammarAgent',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '你好，${d.user.username}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text('今天也让语法树长一点吧。'),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const GrammarCat(size: 72),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.language, size: 18),
                  label: Text(
                    '${languageLabel(d.user.currentLanguage)} · ${d.user.currentLevel ?? '学习中'}',
                  ),
                ),
                Chip(
                  avatar: const Icon(
                    Icons.local_fire_department_outlined,
                    size: 18,
                  ),
                  label: Text('连续学习 ${d.streak.currentStreak} 天'),
                ),
              ],
            ),
            ProgressCard(
              title: '今日目标',
              value: '${d.today.xpEarned} / ${d.today.goalXp} XP',
              fraction: d.today.goalXp == 0
                  ? 0
                  : d.today.xpEarned / d.today.goalXp,
              caption: '今日完成 ${d.today.completedLessons} 节课程',
            ),
            const SectionHeader('今日计划', subtitle: '一点新知识，一点复习，每天都有收获'),
            if (d.continueLearning case final next?)
              GrammarCard(
                color: AppColors.mint,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '01 / 新知识',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      next.grammarPointTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(next.lessonTitle),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton.icon(
                      onPressed: () => context.push('/lesson/${next.lessonId}'),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('继续学习'),
                    ),
                  ],
                ),
              )
            else
              const GrammarCard(
                color: AppColors.mint,
                child: CatMessage(
                  '当前课程都完成了！回到树上巩固知识，或看看今天的复习。',
                  celebrating: true,
                ),
              ),
            LessonCard(
              title: '今日复习',
              showStatus: false,
              subtitle: '${d.review.dueCount} 道到期错题',
              onTap: () => context.go('/review'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/learning-path'),
              icon: const Icon(Icons.account_tree_outlined),
              label: const Text('探索语法树'),
            ),
            const SectionHeader('我的学习概况'),
            StatGrid(
              items: [
                StatCard(
                  label: '当前平均 Mastery',
                  value: '${d.progress.averageMastery}%',
                ),
                StatCard(
                  label: '累计 XP',
                  value: '${d.statistics.totalXp}',
                  icon: Icons.bolt,
                ),
                StatCard(
                  label: '答题正确率',
                  value: '${d.statistics.accuracy}%',
                  icon: Icons.track_changes,
                ),
              ],
            ),
            Text(
              '已完成 ${d.progress.completedLessons}/${d.progress.totalLessons} 节课程 · 累计答题 ${d.statistics.totalAnsweredQuestions} 次',
            ),
            const SectionHeader('下一片生长的可能', subtitle: '未来功能预览'),
            const FutureFeature(
              title: 'Grammar Health',
              description: '未来结合掌握度、复习和记忆新鲜度，观察语法的长期状态。',
              icon: Icons.eco_outlined,
            ),
            const FutureFeature(
              title: 'AI Grammar Coach',
              description: 'Grammar Cat 陪你解释错题、追问与举例。',
            ),
            const FutureFeature(
              title: '混合挑战',
              description: '对比易混规则，在不同语境中灵活运用。',
              icon: Icons.shuffle,
            ),
            const FutureFeature(
              title: '每日表达',
              description: '用今天的语法，描述自己的生活。',
              icon: Icons.edit_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
