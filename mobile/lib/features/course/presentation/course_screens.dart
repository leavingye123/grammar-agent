import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_views.dart';
import '../domain/course_models.dart';
import 'course_providers.dart';

class LearningPathScreen extends ConsumerWidget {
  const LearningPathScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(learningPathProvider);
    return RefreshIndicator(
      onRefresh: () => ref.refresh(learningPathProvider.future),
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(floating: true, title: Text('English 学习路径')),
          value.when(
            loading: () => const SliverFillRemaining(child: LoadingView()),
            error: (e, _) => SliverFillRemaining(
              child: ErrorView(
                error: e,
                onRetry: () => ref.invalidate(learningPathProvider),
              ),
            ),
            data: (path) {
              if (path.levels.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyView(message: '暂无课程'),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                sliver: SliverList.list(
                  children: [
                    Text(
                      '${path.language.name} · ${path.language.nativeName}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    for (final level in path.levels) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 8),
                        child: Row(
                          children: [
                            CircleAvatar(child: Text(level.code)),
                            const SizedBox(width: 12),
                            Text(
                              level.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                      for (final chapter in level.chapters)
                        _ChapterCard(chapter: chapter),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({required this.chapter});
  final ChapterModel chapter;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(chapter.title, style: Theme.of(context).textTheme.titleMedium),
          const Divider(height: 24),
          for (final point in chapter.grammarPoints) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(point.title),
              subtitle: Text('难度 ${point.difficulty}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/grammar-point/${point.id}'),
            ),
            for (final lesson in point.lessons)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: ListTile(
                  leading: const Icon(Icons.play_circle_outline),
                  title: Text(lesson.title),
                  subtitle: Text('+${lesson.xpReward} XP'),
                  onTap: () => context.push('/lesson/${lesson.id}'),
                ),
              ),
          ],
        ],
      ),
    ),
  );
}

class GrammarPointScreen extends ConsumerWidget {
  const GrammarPointScreen({super.key, required this.id});
  final int id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(grammarPointProvider(id));
    final lessons = ref.watch(grammarPointLessonsProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('语法点')),
      body: detail.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(grammarPointProvider(id)),
        ),
        data: (point) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(point.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text('难度 ${point.difficulty} · ${point.code}'),
            if (point.description?.isNotEmpty == true)
              _InfoCard(title: '简介', content: point.description!),
            if (point.grammarRule?.isNotEmpty == true)
              _InfoCard(title: '语法规则', content: point.grammarRule!),
            if (point.examples != null)
              _InfoCard(title: '例句', content: _pretty(point.examples)),
            if (point.commonErrors != null)
              _InfoCard(title: '常见错误', content: _pretty(point.commonErrors)),
            if (point.prerequisites.isNotEmpty)
              _InfoCard(
                title: '前置语法',
                content: point.prerequisites.map((e) => e.title).join('、'),
              ),
            const SizedBox(height: 18),
            Text('Lessons', style: Theme.of(context).textTheme.titleLarge),
            lessons.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text(e.toString()),
              data: (items) => items.isEmpty
                  ? const Text('暂无 Lesson')
                  : Column(
                      children: [
                        for (final lesson in items)
                          Card(
                            child: ListTile(
                              title: Text(lesson.title),
                              subtitle: Text(
                                '${lesson.lessonType} · +${lesson.xpReward} XP',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push('/lesson/${lesson.id}'),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static String _pretty(Object? value) =>
      const JsonEncoder.withIndent('  ').convert(value);
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.content});
  final String title;
  final String content;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SelectableText(content),
        ],
      ),
    ),
  );
}
