import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_views.dart';
import '../../../core/widgets/grammar_cat.dart';
import '../../../core/widgets/learning_widgets.dart';
import '../../../core/theme/design_tokens.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../home/presentation/home_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final dashboard = ref.watch(dashboardProvider);
    return PageBody(
      children: [
        Text('我的成长', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xl),
        const Center(child: GrammarCat(size: 88)),
        const SizedBox(height: AppSpacing.md),
        Text(
          user?.username ?? '学习伙伴',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(user?.email ?? '', textAlign: TextAlign.center),
        const CatMessage('小小语法，大大可能。每一次理解，都值得被记住。'),
        dashboard.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorView(
            error: e,
            onRetry: () => ref.invalidate(dashboardProvider),
          ),
          data: (d) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '学习阶段 · ${languageLabel(d.user.currentLanguage)} ${d.user.currentLevel ?? '学习中'}',
              ),
              StatGrid(
                items: [
                  StatCard(
                    label: '累计 XP',
                    value: '${d.statistics.totalXp}',
                    icon: Icons.bolt,
                  ),
                  StatCard(
                    label: '连续学习天数',
                    value: '${d.streak.currentStreak}',
                    icon: Icons.local_fire_department_outlined,
                  ),
                  StatCard(
                    label: '当前 Mastery',
                    value: '${d.progress.averageMastery}%',
                  ),
                ],
              ),
              ProgressCard(
                title: '语法学习概况',
                value:
                    '${d.progress.completedLessons}/${d.progress.totalLessons} 课程已完成',
                fraction: d.progress.totalLessons == 0
                    ? 0
                    : d.progress.completedLessons / d.progress.totalLessons,
                caption:
                    '答题 ${d.statistics.totalAnsweredQuestions} 次 · 正确率 ${d.statistics.accuracy}%',
              ),
            ],
          ),
        ),
        const SectionHeader('成就预览'),
        const FutureFeature(
          title: 'Grammar Explorer',
          description: '探索第一个语法点。成就系统上线后开放。',
          icon: Icons.explore_outlined,
        ),
        const FutureFeature(
          title: 'Tree Keeper',
          description: '让复习成为习惯，守护你的语法树。',
          icon: Icons.park_outlined,
        ),
        const FutureFeature(
          title: 'Grammar Master',
          description: '持续巩固，向更高掌握度成长。',
          icon: Icons.workspace_premium_outlined,
        ),
        const SectionHeader('更多陪伴'),
        const FutureFeature(
          title: 'GrammarAgent Plus',
          description: '更多个性化学习能力正在准备中。',
          icon: Icons.stars_outlined,
        ),
        const SectionHeader('账号设置'),
        GrammarCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('母语：${user?.nativeLanguage ?? '未设置'}'),
              if (user != null)
                Text(
                  '加入时间：${user.createdAt.toLocal().toString().split(' ').first}',
                ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: auth.loading
              ? null
              : () => ref.read(authProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
          label: const Text('退出登录'),
        ),
      ],
    );
  }
}
