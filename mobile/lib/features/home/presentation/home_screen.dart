import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_views.dart';
import '../domain/home_models.dart';
import 'home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(dashboardProvider);
    return RefreshIndicator(
      onRefresh: () => ref.refresh(dashboardProvider.future),
      child: value.when(
        loading: () => ListView(
          children: const [SizedBox(height: 200, child: LoadingView())],
        ),
        error: (e, _) => ListView(
          children: [
            SizedBox(
              height: 400,
              child: ErrorView(
                error: e,
                onRetry: () => ref.invalidate(dashboardProvider),
              ),
            ),
          ],
        ),
        data: (dashboard) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            _Greeting(username: dashboard.user.username),
            const SizedBox(height: 16),
            _TodayGoalCard(today: dashboard.today),
            const SizedBox(height: 12),
            if (dashboard.continueLearning != null)
              _ContinueLearningCard(item: dashboard.continueLearning!),
            _ReviewCard(dueCount: dashboard.review.dueCount),
            _ProgressCard(
              progress: dashboard.progress,
              statistics: dashboard.statistics,
              streak: dashboard.streak,
            ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: () => context.push('/learning-path'),
              icon: const Icon(Icons.route_outlined),
              label: const Text('查看学习路径'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.username});
  final String username;
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? '早上好'
        : hour < 18
        ? '下午好'
        : '晚上好';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GrammarAgent',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$greeting，$username',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }
}

class _TodayGoalCard extends StatelessWidget {
  const _TodayGoalCard({required this.today});
  final DashboardToday today;
  @override
  Widget build(BuildContext context) {
    final progress = today.goalXp <= 0
        ? 0.0
        : (today.xpEarned / today.goalXp).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('今日目标', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Text(
              '${today.xpEarned} / ${today.goalXp} XP',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text('今日完成 ${today.completedLessons} 个 Lesson'),
          ],
        ),
      ),
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({required this.item});
  final ContinueLearning item;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: const Icon(Icons.play_circle_fill, size: 40),
      title: Text(item.lessonTitle),
      subtitle: Text(item.grammarPointTitle),
      trailing: FilledButton.tonal(
        style: FilledButton.styleFrom(
          minimumSize: const Size(96, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: () => context.push('/lesson/${item.lessonId}'),
        child: const Text('继续学习'),
      ),
      onTap: () => context.push('/lesson/${item.lessonId}'),
    ),
  );
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.dueCount});
  final int dueCount;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: const Icon(Icons.replay, size: 32),
      title: Text('待复习'),
      subtitle: Text('$dueCount 道'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/review'),
    ),
  );
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.progress,
    required this.statistics,
    required this.streak,
  });
  final DashboardProgress progress;
  final DashboardStatistics statistics;
  final DashboardStreak streak;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('学习进度', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: '总进度',
                  value: '${progress.completedLessons} / ${progress.totalLessons}',
                ),
              ),
              Expanded(
                child: _Metric(
                  label: '平均 Mastery',
                  value: '${progress.averageMastery}%',
                ),
              ),
              Expanded(
                child: _Metric(
                  label: '连续学习',
                  value: '${streak.currentStreak} 天',
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: '累计 XP',
                  value: '${statistics.totalXp}',
                ),
              ),
              Expanded(
                child: _Metric(
                  label: '正确率',
                  value: '${statistics.accuracy}%',
                ),
              ),
              Expanded(
                child: _Metric(
                  label: '答题数',
                  value: '${statistics.totalAnsweredQuestions}',
                ),
              ),
            ],
          ),
        ],
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
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}
