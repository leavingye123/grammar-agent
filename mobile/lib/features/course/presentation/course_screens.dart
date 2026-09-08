import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/async_views.dart';
import '../../../core/widgets/grammar_tree_widgets.dart';
import '../../../core/widgets/grammar_cat.dart';
import '../../../core/widgets/learning_widgets.dart';
import '../domain/course_models.dart';
import '../domain/grammar_tree.dart';
import 'course_providers.dart';
import 'learning_entry.dart';

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
            final chapters =
                level.chapters
                    .where((chapter) => chapter.grammarPoints.isNotEmpty)
                    .toList()
                  ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
            if (chapters.isEmpty) {
              return const PageBody(
                children: [EmptyView(message: '新的语法种子正在准备中')],
              );
            }
            final currentChapter = chapters.firstWhere(
              (chapter) => chapter.grammarPoints.any(
                (point) => point.status == 'IN_PROGRESS',
              ),
              orElse: () => chapters.firstWhere(
                (chapter) => chapter.grammarPoints.any(
                  (point) => point.status != 'COMPLETED',
                ),
                orElse: () => chapters.last,
              ),
            );
            TreeVisualNode node(ChapterModel chapter) {
              final points = chapter.grammarPoints;
              final stats = TreeProgress(points);
              final stage =
                  points.every((p) => growthFor(p) == GrowthStage.mastered)
                  ? GrowthStage.mastered
                  : points.any((p) => growthFor(p) != GrowthStage.seed)
                  ? GrowthStage.learning
                  : GrowthStage.seed;
              return TreeVisualNode(
                id: 'chapter-${chapter.id}',
                title: chapter.title,
                progress: '${stats.completed}/${stats.total}',
                icon: _chapterIcon(chapter.sortOrder),
                stage: stage,
                current: chapter.id == currentChapter.id,
                masteryScore: points.isEmpty
                    ? 0
                    : points.fold<int>(
                            0,
                            (sum, point) => sum + (point.masteryScore ?? 0),
                          ) ~/
                          points.length,
                widgetKey: ValueKey('chapter-${chapter.id}'),
                onTap: () => context.push(
                  '/learning-path/branch/chapter-${chapter.id}?level=${level.id}',
                ),
              );
            }

            return PageBody(
              children: [
                _TreePageHeader(
                  title: '语法花园',
                  subtitle: '从一棵树开始，长出更大的自己',
                  trailing: DropdownButton<int>(
                    value: level.id,
                    borderRadius: AppRadius.small,
                    underline: const SizedBox.shrink(),
                    items: [
                      for (final l in path.levels)
                        DropdownMenuItem(
                          value: l.id,
                          child: Text('${path.language.name} ${l.code}'),
                        ),
                    ],
                    onChanged: (id) => setState(() => levelId = id),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  '每一个语法点，都是新叶的开始！',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                OrganicGrammarTree(nodes: chapters.map(node).toList()),
                ProgressCard(
                  title: '当前进度',
                  value: '${progress.completed}/${progress.total} 个语法点',
                  fraction: progress.fraction,
                  caption:
                      '${progress.lessonCompleted}/${progress.lessonTotal} 节课程已完成',
                ),
                const Text(
                  '语法不是规则，而是打开表达世界的钥匙。',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.secondaryText),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

IconData _chapterIcon(int sortOrder) => switch (sortOrder) {
  1 => Icons.spa_outlined,
  2 => Icons.people_alt_outlined,
  3 => Icons.category_outlined,
  4 => Icons.schedule,
  5 => Icons.help_outline,
  6 => Icons.forum_outlined,
  _ => Icons.auto_stories_outlined,
};

class _TreePageHeader extends StatelessWidget {
  const _TreePageHeader({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact =
          constraints.maxWidth < 420 ||
          MediaQuery.textScalerOf(context).scale(14) > 20;
      final heading = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineLarge),
          Text(subtitle),
        ],
      );
      if (compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading,
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: constraints.maxWidth,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(fit: BoxFit.scaleDown, child: trailing),
              ),
            ),
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: heading),
          const SizedBox(width: AppSpacing.md),
          trailing,
        ],
      );
    },
  );
}

class GrammarBranchScreen extends ConsumerWidget {
  const GrammarBranchScreen({super.key, required this.domainId, this.levelId});
  final String domainId;
  final int? levelId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domain = GrammarDomain.fromId(domainId);
    final value = ref.watch(myLearningPathProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('语法分支')),
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
          final chapterId = domainId.startsWith('chapter-')
              ? int.tryParse(domainId.substring('chapter-'.length))
              : null;
          final chapter = level?.chapters
              .where((item) => item.id == chapterId)
              .firstOrNull;
          if (level == null || (chapter == null && domain == null)) {
            return const EmptyView(message: '没有找到这个语法分支');
          }
          final points =
              chapter?.grammarPoints ?? pointsInDomain(path, level, domain!);
          if (points.isEmpty) {
            return const PageBody(children: [CatMessage('这根树枝还在生长，课程即将推出。')]);
          }
          final branchTitle = chapter?.title ?? domain!.title;
          final progress = TreeProgress(points);
          final ordered = [...points]
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          final currentPoint = ordered.firstWhere(
            (point) => point.status == 'IN_PROGRESS',
            orElse: () => ordered.firstWhere(
              (point) => point.status != 'COMPLETED',
              orElse: () => ordered.last,
            ),
          );
          TreeVisualNode node(GrammarPointSummary p) => TreeVisualNode(
            id: p.code,
            title: p.title,
            progress:
                '${p.completedLessons ?? 0}/${p.totalLessons ?? p.lessons.length}',
            icon: growthFor(p) == GrowthStage.mastered
                ? Icons.eco
                : Icons.menu_book_outlined,
            stage: growthFor(p),
            masteryScore: p.masteryScore,
            current: p.id == currentPoint.id,
            prerequisiteIds: p.prerequisiteCodes,
            widgetKey: ValueKey('point-${p.id}'),
            onTap: () => context.push('/grammar-point/${p.id}'),
          );
          return RefreshIndicator(
            onRefresh: () => ref.refresh(myLearningPathProvider.future),
            child: PageBody(
              children: [
                _TreePageHeader(
                  title: branchTitle,
                  subtitle: '掌握$branchTitle，让表达更准确',
                  trailing: Chip(
                    label: Text('${path.language.name} ${level.code}'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                OrganicGrammarTree(nodes: ordered.map(node).toList()),
                ProgressCard(
                  title: branchTitle,
                  value: '${progress.completed}/${progress.total} 知识点已完成',
                  fraction: progress.fraction,
                  caption: '一步一步来，你可以的！点击知识节点继续学习。',
                ),
                const Text(
                  '掌握语法，就是掌握用语言记录生活的能力。',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.secondaryText),
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
                        if (point.microLesson != null &&
                            items.any((lesson) => lesson.contentAvailable))
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: OutlinedButton.icon(
                              onPressed: () {
                                final lesson = items.firstWhere(
                                  (item) => item.contentAvailable,
                                );
                                final route = grammarLearningRoute(
                                  grammarPointId: id,
                                  lessonId: lesson.id,
                                  grammarPointStatus: summary?.status,
                                  lessonStatus: summary?.lessons
                                      .where((item) => item.id == lesson.id)
                                      .firstOrNull
                                      ?.status,
                                  hasMicroLesson: true,
                                  lessonReady: true,
                                  relearn: true,
                                );
                                if (route != null) context.push(route);
                              },
                              icon: const Icon(Icons.menu_book_outlined),
                              label: const Text('重新学习知识点'),
                            ),
                          ),
                        for (final lesson in items)
                          LessonCard(
                            title: lesson.title,
                            subtitle: lesson.contentAvailable
                                ? '${lesson.questionCount} 道练习 · 最高 ${lesson.xpReward} XP'
                                : point.microLesson == null
                                ? '内容准备中'
                                : '先学习 1–2 分钟知识讲解 · 正式练习准备中',
                            status: summary?.lessons
                                .where((l) => l.id == lesson.id)
                                .firstOrNull
                                ?.status,
                            onTap: switch (grammarLearningRoute(
                              grammarPointId: id,
                              lessonId: lesson.id,
                              grammarPointStatus: summary?.status,
                              lessonStatus: summary?.lessons
                                  .where((item) => item.id == lesson.id)
                                  .firstOrNull
                                  ?.status,
                              hasMicroLesson: point.microLesson != null,
                              lessonReady: lesson.contentAvailable,
                            )) {
                              final route? => () => context.push(route),
                              null => null,
                            },
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

class MicroLessonScreen extends ConsumerStatefulWidget {
  const MicroLessonScreen({
    super.key,
    required this.grammarPointId,
    required this.lessonId,
  });

  final int grammarPointId;
  final int lessonId;

  @override
  ConsumerState<MicroLessonScreen> createState() => _MicroLessonScreenState();
}

class _MicroLessonScreenState extends ConsumerState<MicroLessonScreen> {
  int teachingPage = 0;
  bool checking = false;
  int checkIndex = 0;
  String? selectedOptionId;
  bool? answerCorrect;

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(grammarPointProvider(widget.grammarPointId));
    final lessons = ref.watch(
      grammarPointLessonsProvider(widget.grammarPointId),
    );
    final micro = detail.asData?.value.microLesson;
    final selectedLesson = lessons.asData?.value
        .where((lesson) => lesson.id == widget.lessonId)
        .firstOrNull;
    final practiceReady = selectedLesson?.contentAvailable == true;
    return Scaffold(
      appBar: AppBar(title: const Text('1–2 分钟知识课')),
      body: detail.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () =>
              ref.invalidate(grammarPointProvider(widget.grammarPointId)),
        ),
        data: (point) {
          final micro = point.microLesson;
          if (micro == null) {
            return const EmptyView(message: '这节知识讲解正在准备中');
          }
          return checking
              ? _quickCheckView(context, micro, practiceReady)
              : teachingPage == 0
              ? _understandView(context, point.title, micro)
              : _rememberView(context, point.title, micro);
        },
      ),
      bottomNavigationBar: micro == null || checking
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: FilledButton.icon(
                key: ValueKey('teaching-page-${teachingPage + 1}-continue'),
                onPressed: _teachingAction(context, micro, practiceReady),
                icon: Icon(
                  teachingPage == 0 && _hasRememberPage(micro)
                      ? Icons.arrow_forward
                      : micro.quickCheck.isNotEmpty
                      ? Icons.quiz_outlined
                      : practiceReady
                      ? Icons.play_arrow_rounded
                      : Icons.hourglass_empty,
                ),
                label: Text(_teachingActionLabel(micro, practiceReady)),
              ),
            ),
    );
  }

  bool _hasRememberPage(MicroLesson micro) =>
      micro.commonMistakes.isNotEmpty || micro.memoryTip?.isNotEmpty == true;

  VoidCallback? _teachingAction(
    BuildContext context,
    MicroLesson micro,
    bool practiceReady,
  ) {
    if (teachingPage == 0 && _hasRememberPage(micro)) {
      return () => setState(() => teachingPage = 1);
    }
    if (micro.quickCheck.isNotEmpty) {
      return () => setState(() => checking = true);
    }
    if (practiceReady) {
      return () => context.go('/lesson/${widget.lessonId}');
    }
    return null;
  }

  String _teachingActionLabel(MicroLesson micro, bool practiceReady) {
    if (teachingPage == 0 && _hasRememberPage(micro)) return '继续';
    if (micro.quickCheck.isNotEmpty) return '开始 Quick Check';
    return practiceReady ? '开始练习' : '正式练习内容准备中';
  }

  Widget _understandView(
    BuildContext context,
    String grammarPointTitle,
    MicroLesson micro,
  ) => PageBody(
    children: [
      const Center(child: GrammarCat(size: 88)),
      Text(
        grammarPointTitle,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      CatMessage(micro.shortIntroduction),
      _MicroSection(
        icon: Icons.flag_outlined,
        title: '学习目标',
        child: Text(micro.learningObjective),
      ),
      _MicroSection(
        icon: Icons.auto_stories_outlined,
        title: '核心规则',
        child: Text(micro.coreRule),
      ),
      _MicroSection(
        icon: Icons.account_tree_outlined,
        title: '句型结构',
        child: SelectableText(micro.structure),
      ),
      _MicroSection(
        icon: Icons.lightbulb_outline,
        title: '看例句',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final example in micro.examples) ...[
              Text(
                example.sentence,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(example.note),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    ],
  );

  Widget _rememberView(
    BuildContext context,
    String grammarPointTitle,
    MicroLesson micro,
  ) => PageBody(
    children: [
      Row(
        children: [
          const GrammarCat(size: 68),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grammarPointTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Text('记住容易混淆的地方'),
              ],
            ),
          ),
        ],
      ),
      if (micro.commonMistakes.isNotEmpty)
        _MicroSection(
          icon: Icons.warning_amber_rounded,
          title: '常见错误',
          color: AppColors.softOrange,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final mistake in micro.commonMistakes) ...[
                Text('✕ ${mistake.incorrect}'),
                Text(
                  '✓ ${mistake.correct}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(mistake.reason),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
      if (micro.memoryTip?.isNotEmpty == true)
        CatMessage('Grammar Cat 提示：${micro.memoryTip}'),
    ],
  );

  Widget _quickCheckView(
    BuildContext context,
    MicroLesson micro,
    bool practiceReady,
  ) {
    final check = micro.quickCheck[checkIndex];
    final last = checkIndex == micro.quickCheck.length - 1;
    return PageBody(
      children: [
        Text(
          'Quick Check ${checkIndex + 1}/${micro.quickCheck.length}',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(check.prompt, style: Theme.of(context).textTheme.headlineSmall),
        for (final option in check.options)
          Card(
            color: selectedOptionId == option.id ? AppColors.mint : null,
            child: ListTile(
              title: Text(option.text),
              leading: CircleAvatar(child: Text(option.id)),
              onTap: answerCorrect == null
                  ? () => setState(() {
                      selectedOptionId = option.id;
                      answerCorrect = option.id == check.correctOptionId;
                    })
                  : null,
            ),
          ),
        if (answerCorrect != null)
          GrammarCard(
            color: answerCorrect! ? AppColors.mint : AppColors.softOrange,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  answerCorrect! ? '理解正确' : '再看一下这个规则',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(check.explanation),
                const SizedBox(height: AppSpacing.sm),
                const Text('Quick Check 不计入 Mastery。'),
              ],
            ),
          ),
        if (answerCorrect != null && !last)
          FilledButton(
            onPressed: () => setState(() {
              checkIndex++;
              selectedOptionId = null;
              answerCorrect = null;
            }),
            child: const Text('下一题'),
          ),
        if (answerCorrect != null && last) ...[
          FilledButton.icon(
            key: const ValueKey('enter-practice'),
            onPressed: practiceReady
                ? () => context.go('/lesson/${widget.lessonId}')
                : null,
            icon: Icon(
              practiceReady ? Icons.play_arrow_rounded : Icons.hourglass_empty,
            ),
            label: Text(practiceReady ? '进入正式练习' : '正式练习内容准备中'),
          ),
          TextButton(
            onPressed: () => setState(() {
              checking = false;
              checkIndex = 0;
              selectedOptionId = null;
              answerCorrect = null;
            }),
            child: const Text('重新阅读知识讲解'),
          ),
        ],
      ],
    );
  }
}

class _MicroSection extends StatelessWidget {
  const _MicroSection({
    required this.icon,
    required this.title,
    required this.child,
    this.color,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) => GrammarCard(
    color: color ?? AppColors.surface,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    ),
  );
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
