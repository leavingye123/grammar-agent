import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/async_views.dart';
import '../../core/widgets/learning_widgets.dart';
import '../../core/theme/design_tokens.dart';
import 'book_repository.dart';

class GrammarBooksScreen extends ConsumerWidget {
  const GrammarBooksScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('语法书')),
    body: ref.watch(grammarBooksProvider).when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(error: error, onRetry: () => ref.invalidate(grammarBooksProvider)),
      data: (books) => RefreshIndicator(
        onRefresh: () async { ref.invalidate(grammarBooksProvider); await ref.read(grammarBooksProvider.future); },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Grammar Books', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('选择适合自己的语法书，查看章节与相关知识点。'),
            const SizedBox(height: 16),
            if (books.isEmpty) const EmptyView(message: '语法书正在准备中'),
            for (final book in books) Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GrammarCard(child: ListTile(
                key: ValueKey('grammar-book-${book.id}'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.menu_book_rounded, color: AppColors.primary),
                title: Text(book.title),
                subtitle: Text('${book.subtitle}\n${book.levelMin} → ${book.levelMax}\n'
                    '已学 ${book.studied} / ${book.mapped} 个关联语法点'
                    '${book.selected ? "\n✓ 当前语法书" : ""}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/grammar-books/${book.id}'),
              )),
            ),
          ],
        ),
      ),
    ),
  );
}

class GrammarBookDetailScreen extends ConsumerStatefulWidget {
  const GrammarBookDetailScreen({super.key, required this.id});
  final int id;
  @override
  ConsumerState<GrammarBookDetailScreen> createState() => _GrammarBookDetailState();
}

class _GrammarBookDetailState extends ConsumerState<GrammarBookDetailScreen> {
  bool saving = false;
  String? error;
  Future<void> select(GrammarBook book) async {
    setState(() { saving = true; error = null; });
    try {
      await ref.read(grammarBookRepositoryProvider).select(book);
      if (!mounted) return;
      ref.invalidate(grammarBooksProvider);
      ref.invalidate(grammarBookProvider(widget.id));
    } catch (_) {
      if (mounted) setState(() => error = '暂时无法保存选择，请重试。');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('语法书详情')),
    body: ref.watch(grammarBookProvider(widget.id)).when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(error: error, onRetry: () => ref.invalidate(grammarBookProvider(widget.id))),
      data: (book) => RefreshIndicator(
        onRefresh: () async { ref.invalidate(grammarBookProvider(widget.id)); await ref.read(grammarBookProvider(widget.id).future); },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Text(book.title, style: Theme.of(context).textTheme.headlineSmall),
            Text(book.authors),
            Text('${book.publisher} · ${book.edition}'),
            Text('${book.levelMin} → ${book.levelMax}'),
            const SizedBox(height: 12),
            Text(book.description),
            const SizedBox(height: 12),
            Text('已学 ${book.studied} / ${book.mapped} 个关联语法点'),
            FilledButton.icon(
              onPressed: saving || book.selected ? null : () => select(book),
              icon: Icon(book.selected ? Icons.check_circle : Icons.menu_book),
              label: Text(saving ? '正在保存…' : book.selected ? '✓ 当前语法书' : '使用这本语法书'),
            ),
            if (error != null) Text(error!, style: const TextStyle(color: AppColors.orange)),
            const SectionHeader('章节'),
            for (final section in book.sections) Padding(
              padding: EdgeInsets.only(left: section.parentId == null ? 0 : 12, bottom: 12),
              child: GrammarCard(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(section.parentId == null ? section.title : '${section.order}. ${section.title}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (section.description.isNotEmpty) Text(section.description),
                  for (final mapping in section.mappings)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(mapping.title),
                      subtitle: Text(mapping.approved ? mapping.code : '${mapping.code} · 对应关系待审核'),
                      trailing: mapping.approved ? const Icon(Icons.chevron_right) : null,
                      onTap: mapping.approved ? () => context.push('/grammar-point/${mapping.id}') : null,
                    ),
                ],
              )),
            ),
            ExpansionTile(title: Text('来源与授权 · ${book.license}'), children: [
              Padding(padding: const EdgeInsets.all(12), child: SelectableText(
                '${book.attribution}\n\n${book.sourceUrl}\n${book.licenseUrl}',
              )),
            ]),
          ],
        ),
      ),
    ),
  );
}
