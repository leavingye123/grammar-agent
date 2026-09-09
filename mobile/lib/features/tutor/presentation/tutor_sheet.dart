import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/design_tokens.dart';
import '../tutor_session.dart';

class GrammarTutorButton extends ConsumerWidget {
  const GrammarTutorButton({
    super.key,
    this.grammarPointId,
    this.lessonAttemptId,
    this.questionCode,
    this.wrongAnswer = false,
    this.reviewFeedback = false,
  }) : assert((grammarPointId == null) != (lessonAttemptId == null));

  final int? grammarPointId;
  final int? lessonAttemptId;
  final String? questionCode;
  final bool wrongAnswer;
  final bool reviewFeedback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void openTutor() {
      final scope = TutorScope(
        key: tutorScopeKey(
          grammarPointId: grammarPointId,
          lessonAttemptId: lessonAttemptId,
          questionCode: questionCode,
          review: reviewFeedback,
        ),
        scene: lessonAttemptId != null
            ? 'result'
            : questionCode == null
            ? 'teaching'
            : wrongAnswer
            ? 'wrong'
            : 'answered',
        grammarPointId: grammarPointId,
        lessonAttemptId: lessonAttemptId,
        questionCode: questionCode,
        initialMessage: lessonAttemptId == null ? null : '帮我总结这次练习',
      );
      // Bind the conversation to the learning context, not to this sheet.
      ref.read(tutorSessionProvider.notifier).setScope(scope);
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => GrammarTutorSheet(
          grammarPointId: grammarPointId,
          lessonAttemptId: lessonAttemptId,
          questionCode: questionCode,
          review: reviewFeedback,
          wrongAnswer: wrongAnswer,
        ),
      );
    }

    if (reviewFeedback && wrongAnswer) {
      return OutlinedButton(
        onPressed: openTutor,
        child: const Text(
          '🐱 还是没弄懂？\n问 Grammar Cat',
          textAlign: TextAlign.center,
        ),
      );
    }
    return TextButton(
      onPressed: openTutor,
      child: Text(
        lessonAttemptId != null
            ? '帮我总结这次练习'
            : questionCode == null
            ? '🐱 问 Grammar Cat'
            : wrongAnswer
            ? '🐱 不明白为什么？问 Grammar Cat'
            : '还有疑问？问 Grammar Cat',
      ),
    );
  }
}

/// Pure view over [tutorSessionProvider]; closing the sheet never discards
/// the conversation — only a scope change or logout does.
class GrammarTutorSheet extends ConsumerStatefulWidget {
  const GrammarTutorSheet({
    super.key,
    this.grammarPointId,
    this.lessonAttemptId,
    this.questionCode,
    this.review = false,
    this.wrongAnswer = false,
  }) : assert((grammarPointId == null) != (lessonAttemptId == null));

  final int? grammarPointId;
  final int? lessonAttemptId;
  final String? questionCode;
  final bool review;
  final bool wrongAnswer;

  @override
  ConsumerState<GrammarTutorSheet> createState() => _GrammarTutorSheetState();
}

class _GrammarTutorSheetState extends ConsumerState<GrammarTutorSheet> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();
  bool _follow = true;
  bool _scrollScheduled = false;

  @override
  void initState() {
    super.initState();
    // Idempotent when the button already entered the same scope; deferred one
    // microtask because Riverpod forbids modifying providers during initState.
    Future.microtask(() {
      if (!mounted) return;
      ref.read(tutorSessionProvider.notifier).setScope(TutorScope(
      key: tutorScopeKey(
        grammarPointId: widget.grammarPointId,
        lessonAttemptId: widget.lessonAttemptId,
        questionCode: widget.questionCode,
        review: widget.review,
      ),
      scene: widget.lessonAttemptId != null
          ? 'result'
          : widget.questionCode == null
          ? 'teaching'
          : widget.wrongAnswer
          ? 'wrong'
          : 'answered',
      grammarPointId: widget.grammarPointId,
      lessonAttemptId: widget.lessonAttemptId,
      questionCode: widget.questionCode,
      initialMessage: widget.lessonAttemptId == null ? null : '帮我总结这次练习',
      ));
    });
  }

  void _submit([String? suggested]) {
    final text = suggested ?? _input.text;
    if (ref.read(tutorSessionProvider.notifier).send(text)) {
      if (suggested == null) _input.clear();
    }
  }

  void _scrollToBottom({bool force = false}) {
    if ((!force && !_follow) || _scrollScheduled) return;
    _scrollScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollScheduled = false;
      if (mounted && _scroll.hasClients && (force || _follow)) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    // Only view resources die with the sheet; the session keeps streaming.
    _input.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(tutorSessionProvider);
    // A newly appended turn re-enables following; stream ticks scroll only if following.
    ref.listen(tutorSessionProvider.select((s) => s.messages.length), (prev, next) {
      if (next > (prev ?? 0)) {
        _follow = true;
        _scrollToBottom(force: true);
      }
    });
    ref.listen(tutorSessionProvider.select((s) => s.revision), (_, _) {
      _scrollToBottom();
    });
    final messages = session.messages;
    final last = messages.isNotEmpty ? messages.last : null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.90,
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                leading: const CircleAvatar(backgroundColor: AppColors.mint, child: Text('🐱')),
                title: const Text('Grammar Cat', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('一起把语法弄明白', style: TextStyle(fontSize: 12)),
                trailing: IconButton(tooltip: '关闭', onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
              ),
              const Divider(height: 1),
              if (session.loading) const LinearProgressIndicator(),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notice) {
                    // Only user scrolling changes follow mode; new layout height must not turn following off.
                    if (notice is UserScrollNotification ||
                        (notice is ScrollUpdateNotification && notice.dragDetails != null)) {
                      _follow = notice.metrics.extentAfter < 80;
                    }
                    return false;
                  },
                  child: ListView(
                    key: const ValueKey('tutor-messages'),
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      if (messages.isEmpty && session.available)
                        const Padding(padding: EdgeInsets.all(12), child: Text('哪里还不太明白？选一个问题，或直接问我。', style: TextStyle(color: AppColors.secondaryText))),
                      if (!session.loading && !session.available) ...[
                        if (session.error == null) const Text('Grammar Cat AI 暂未开启，你可以继续学习。'),
                        TextButton(onPressed: () => ref.read(tutorSessionProvider.notifier).retryStatus(), child: const Text('重新检查')),
                      ],
                      if (session.error != null) Text(session.error!),
                      for (final message in messages)
                        TutorChatBubble(
                          message: message,
                          onRetry: !session.sending && identical(message, last) && message.status == TutorMessageStatus.error
                              ? () => ref.read(tutorSessionProvider.notifier).send('', retry: true) : null,
                        ),
                    ],
                  ),
                ),
              ),
              if (session.available && session.suggestions.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 116),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Wrap(spacing: 6, runSpacing: 2, children: [
                      for (final question in session.suggestions)
                        ActionChip(
                          label: Text(question, style: const TextStyle(fontSize: 12)),
                          backgroundColor: AppColors.mint,
                          side: BorderSide.none,
                          onPressed: session.sending ? null : () => _submit(question),
                        ),
                    ]),
                  ),
                ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: TextField(
                      controller: _input,
                      focusNode: _focus,
                      enabled: session.available, // Keep the keyboard/focus while a reply streams.
                      maxLength: 2000, minLines: 1, maxLines: 3,
                      decoration: InputDecoration(
                        hintText: '输入你的问题…', counterText: '',
                        filled: true, fillColor: AppColors.surfaceGreen,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      ),
                    )),
                    const SizedBox(width: 8),
                    FilledButton(
                      key: const ValueKey('tutor-send'),
                      onPressed: session.available && !session.sending ? () => _submit() : null,
                      child: session.sending
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('发送'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TutorChatBubble extends StatelessWidget {
  const TutorChatBubble({super.key, required this.message, this.onRetry});
  final TutorChatMessage message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final user = message.role == 'user';
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: user ? 0.82 : 0.96,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!user) const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 6),
                child: Text('🐱 Grammar Cat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: user ? AppColors.softGreen : AppColors.surfaceGreen,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: user
                    ? SelectableText(message.content)
                    : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (message.content.isEmpty && message.status == TutorMessageStatus.streaming)
                          const Text('Grammar Cat 正在思考…'),
                        if (message.content.isNotEmpty)
                          MarkdownBody(
                            data: message.content, selectable: true, softLineBreak: true,
                            // Model text cannot initiate image network requests or open external links.
                            imageBuilder: (_, _, _) => const SizedBox.shrink(),
                            onTapLink: (_, _, _) {},
                            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                              p: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
                              code: const TextStyle(fontFamily: 'monospace', backgroundColor: AppColors.mint),
                            ),
                          ),
                        if (message.content.isNotEmpty && message.status == TutorMessageStatus.streaming)
                          const Text('▍', style: TextStyle(color: AppColors.primary)),
                        if (message.status == TutorMessageStatus.error) ...[
                          Text(message.error ?? 'Grammar Cat 回复失败', style: const TextStyle(color: AppColors.orange)),
                          if (onRetry != null) TextButton.icon(
                            onPressed: onRetry, icon: const Icon(Icons.refresh, size: 16), label: const Text('重新生成'),
                          ),
                        ],
                      ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
