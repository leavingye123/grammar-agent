import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/async_views.dart';
import '../../../core/widgets/grammar_tree_widgets.dart';
import '../../../core/widgets/learning_widgets.dart';
import '../domain/course_models.dart';
import '../domain/grammar_tree.dart';
import 'course_providers.dart';

class LearningPathScreen extends ConsumerStatefulWidget {
  const LearningPathScreen({super.key});
  @override
  ConsumerState<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends ConsumerState<LearningPathScreen> {
  int? levelId;
  @override
  Widget build(BuildContext context) {
    final value = ref.watch(myLearningPathProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('GrammarAgent')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(myLearningPathProvider.future),
        child: value.when(
          loading: () => const PageBody(children: [LoadingView()]),
          error: (e, _) => PageBody(
            children: [
              ErrorView(
                error: e,
                onRetry: () => ref.invalidate(myLearningPathProvider),
              ),
            ],
          ),
          data: (path) {
            if (path.levels.isEmpty) {
              return const PageBody(
                children: [EmptyView(message: '新的语法种子正在准备中')],
              );
            }
            final level =
                path.levels.where((l) => l.id == levelId).firstOrNull ??
                path.levels.first;
            final progress = TreeProgress(pointsInLevel(level));
            Widget node(GrammarDomain domain) {
              final points = pointsInDomain(path, level, domain);
              final stats = TreeProgress(points);
              final stage = points.isEmpty
                  ? GrowthStage.seed
                  : points.every((p) => growthFor(p) == GrowthStage.mastered)
                  ? GrowthStage.mastered
                  : points.any((p) => growthFor(p) != GrowthStage.seed)
                  ? GrowthStage.learning
                  : GrowthStage.seed;
              return GrammarNode(
                key: ValueKey('domain-${domain.id}'),
                title: domain.title,
                subtitle:
                    '${stats.completed}/${stats.total} 知识点\n${domain.subtitle}',
                icon: _domainIcon(domain),
                stage: stage,
                preview: points.isEmpty,
                onTap: () => context.push(
                  '/learning-path/branch/${domain.id}?level=${level.id}',
                ),
              );
            }

            return PageBody(
              children: [
                Text('语法花园', style: Theme.of(context).textTheme.headlineLarge),
                const Text('从一棵树开始，长出更大的自己。'),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: level.id,
                  decoration: const InputDecoration(labelText: '学习语言与阶段'),
                  items: [
                    for (final l in path.levels)
                      DropdownMenuItem(
                        value: l.id,
                        child: Text(
                          '${path.language.name} · ${l.code}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (id) => setState(() => levelId = id),
                ),
                const CatMessage('每一个语法点，都是新的开始。选择一根树枝，一起探索吧。'),
                TreeRow(left: node(GrammarDomain.advanced)),
                TreeRow(
                  left: node(GrammarDomain.clauses),
                  right: node(GrammarDomain.structure),
                ),
                TreeRow(left: node(GrammarDomain.tenses)),
                TreeRow(
                  left: node(GrammarDomain.parts),
                  right: node(GrammarDomain.voice),
                ),
                TreeRow(left: node(GrammarDomain.foundations), root: true),
                if (pointsInDomain(path, level, GrammarDomain.other).isNotEmpty)
                  TreeRow(left: node(GrammarDomain.other)),
                ProgressCard(
                  title: '当前进度',
                  value: '${progress.completed}/${progress.total} 语法点已完成',
                  fraction: progress.fraction,
                  caption:
                      '${progress.lessonCompleted}/${progress.lessonTotal} 节课程已完成',
                ),
                const Text(
                  '树枝表示主题分组，不限制学习顺序。灰绿节点代表未探索；标注“即将推出”的领域尚无课程。',
                  style: TextStyle(color: AppColors.secondaryText),
                ),
                const SectionHeader('成长图例'),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('未探索')),
                    Chip(label: Text('正在学习')),
                    Chip(label: Text('继续巩固')),
                    Chip(label: Text('熟练掌握')),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

IconData _domainIcon(GrammarDomain domain) => switch (domain) {
  GrammarDomain.foundations => Icons.spa_outlined,
  GrammarDomain.parts => Icons.bubble_chart_outlined,
  GrammarDomain.tenses => Icons.schedule,
  GrammarDomain.voice => Icons.record_voice_over_outlined,
  GrammarDomain.clauses => Icons.account_tree_outlined,
  GrammarDomain.structure => Icons.view_quilt_outlined,
  GrammarDomain.advanced => Icons.workspace_premium_outlined,
  GrammarDomain.other => Icons.auto_stories_outlined,
};

class GrammarBranchScreen extends ConsumerWidget {
  const GrammarBranchScreen({super.key, required this.domainId, this.levelId});
  final String domainId;
  final int? levelId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domain = GrammarDomain.fromId(domainId);
    final value = ref.watch(myLearningPathProvider);
    return Scaffold(
      appBar: AppBar(title: Text(domain?.title ?? '语法分支')),
      body: value.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(myLearningPathProvider),
        ),
        data: (path) {
          final level = levelId == null
              ? path.levels.firstOrNull
              : path.levels.where((l) => l.id == levelId).firstOrNull;
          if (domain == null || level == null) {
            return const EmptyView(message: '没有找到这个语法分支');
          }
          final points = pointsInDomain(path, level, domain);
          if (points.isEmpty) {
            return const PageBody(children: [CatMessage('这根树枝还在生长，课程即将推出。')]);
          }
          final progress = TreeProgress(points);
          Widget node(GrammarPointSummary p) => GrammarNode(
            key: ValueKey('point-${p.id}'),
            title: p.title,
            subtitle:
                '${p.completedLessons ?? 0}/${p.totalLessons ?? p.lessons.length} 课程 · Mastery ${p.masteryScore ?? 0}%\n${growthFor(p).label}',
            icon: growthFor(p) == GrowthStage.mastered
                ? Icons.eco
                : Icons.menu_book_outlined,
            stage: growthFor(p),
            onTap: () => context.push('/grammar-point/${p.id}'),
          );
          final branches = points.reversed.toList();
          return RefreshIndicator(
            onRefresh: () => ref.refresh(myLearningPathProvider.future),
            child: PageBody(
              children: [
                Text(
                  domain.subtitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text('${path.language.name} · ${level.code}'),
                const CatMessage('一步一步来，你可以的！先理解，再练习，让知识扎下根。'),
                for (var i = 0; i < branches.length; i += 2)
                  TreeRow(
                    left: node(branches[i]),
                    right: i + 1 < branches.length
                        ? node(branches[i + 1])
                        : null,
                    root: i + 2 >= branches.length,
                  ),
                ProgressCard(
                  title: domain.title,
                  value: '${progress.completed}/${progress.total} 知识点已完成',
                  fraction: progress.fraction,
                  caption: '点击知识节点，查看概念、规则和学习课程。',
                ),
                const Text(
                  '按课程顺序排列，树枝表示同一主题。具体前置知识请查看语法点。',
                  style: TextStyle(color: AppColors.secondaryText),
                ),
                const FutureFeature(
                  title: '混合练习',
                  description: '把同一分支中的规则放在一起运用。',
                ),
                const FutureFeature(
                  title: '学习笔记',
                  description: '留下你自己的理解与例句。',
                  icon: Icons.edit_note,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class GrammarPointScreen extends ConsumerWidget {
  const GrammarPointScreen({super.key, required this.id});
  final int id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(grammarPointProvider(id));
    final lessons = ref.watch(grammarPointLessonsProvider(id));
    final path = ref.watch(myLearningPathProvider);
    final summary = findPoint(path.asData?.value, id);
    return Scaffold(
      appBar: AppBar(title: const Text('知识卡片')),
      body: detail.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(grammarPointProvider(id)),
        ),
        data: (point) => PageBody(
          children: [
            Text(point.title, style: Theme.of(context).textTheme.headlineLarge),
            Text('难度 ${point.difficulty} · 理解一个规则，多一种表达'),
            if (summary != null)
              ProgressCard(
                title: '当前 Mastery',
                value: '${summary.masteryScore ?? 0}%',
                fraction: (summary.masteryScore ?? 0) / 100,
                caption:
                    '${growthFor(summary).label} · ${lessonStatusLabel(summary.status)}',
              ),
            if (path.hasError)
              ErrorView(
                error: '掌握度暂时无法加载',
                onRetry: () => ref.invalidate(myLearningPathProvider),
              ),
            if (point.description?.isNotEmpty == true)
              _InfoCard(title: '核心概念', content: point.description!),
            if (point.grammarRule?.isNotEmpty == true)
              _InfoCard(title: '规则解释', content: point.grammarRule!),
            if (point.examples is List &&
                (point.examples as List).isNotEmpty) ...[
              const SectionHeader('例句', subtitle: '把规则放回真实表达里'),
              for (final example in point.examples as List)
                GrammarCard(child: _ExampleContent(value: example)),
            ],
            if (point.commonErrors is List &&
                (point.commonErrors as List).isNotEmpty) ...[
              const SectionHeader('常见错误'),
              for (final example in point.commonErrors as List)
                GrammarCard(
                  color: AppColors.softOrange,
                  child: _ExampleContent(value: example, error: true),
                ),
            ],
            if (point.prerequisites.isNotEmpty) ...[
              const SectionHeader('前置知识'),
              for (final p in point.prerequisites)
                Card(
                  child: ListTile(
                    title: Text(p.title),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/grammar-point/${p.id}'),
                  ),
                ),
            ],
            const SectionHeader('学习路径', subtitle: '理解 → 练习 → 巩固'),
            lessons.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(
                error: e,
                onRetry: () => ref.invalidate(grammarPointLessonsProvider(id)),
              ),
              data: (items) => items.isEmpty
                  ? const EmptyView(message: '这片知识的新课程正在准备中')
                  : Column(
                      children: [
                        for (final lesson in items)
                          LessonCard(
                            title: lesson.title,
                            subtitle: '本课最高 ${lesson.xpReward} XP',
                            status: summary?.lessons
                                .where((l) => l.id == lesson.id)
                                .firstOrNull
                                ?.status,
                            onTap: () => context.push('/lesson/${lesson.id}'),
                          ),
                      ],
                    ),
            ),
            const FutureFeature(
              title: 'AI Grammar Coach',
              description: '和语法小猫追问规则、举例、解释错题。',
            ),
            const FutureFeature(
              title: '表达练习',
              description: '用这个语法点，写下属于你的句子。',
              icon: Icons.edit_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.content});
  final String title, content;
  @override
  Widget build(BuildContext context) => GrammarCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        SelectableText(content),
      ],
    ),
  );
}

class _ExampleContent extends StatelessWidget {
  const _ExampleContent({required this.value, this.error = false});
  final Object? value;
  final bool error;
  @override
  Widget build(BuildContext context) {
    if (value is! Map) return Text('$value');
    final item = value as Map;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (error && item['incorrect'] != null)
          Text(
            '易混：${item['incorrect']}',
            style: const TextStyle(color: AppColors.orange),
          ),
        Text(
          '${item[error ? 'correct' : 'sentence'] ?? ''}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (item['translation'] != null) Text('${item['translation']}'),
        if (item['explanation'] != null) Text('${item['explanation']}'),
      ],
    );
  }
}
