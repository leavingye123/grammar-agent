import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../domain/lesson_models.dart';

typedef NativeAnswerCallback = void Function(Object answer);

class NativePracticeActivity extends StatelessWidget {
  const NativePracticeActivity({
    super.key,
    required this.question,
    required this.enabled,
    required this.onComplete,
  });

  final Question question;
  final bool enabled;
  final NativeAnswerCallback onComplete;

  @override
  Widget build(BuildContext context) => switch (question.interactionStyle) {
    InteractionStyle.sentenceSpotlight => _SentenceSpotlight(
      question: question,
      enabled: enabled,
      onComplete: onComplete,
    ),
    InteractionStyle.grammarPaint => _AssignmentBoard(
      key: const ValueKey('native-grammar-paint'),
      question: question,
      targetField: 'labels',
      enabled: enabled,
      onComplete: onComplete,
      instruction: '先选一个语法角色，再点句子中的词',
    ),
    InteractionStyle.slotPuzzle => _AssignmentBoard(
      key: const ValueKey('native-slot-puzzle'),
      question: question,
      targetField: 'slots',
      enabled: enabled,
      onComplete: onComplete,
      instruction: '先选词块，再点它属于的槽位',
      tokenFirst: true,
    ),
    InteractionStyle.sentenceSurgery => _SentenceTransform(
      key: const ValueKey('native-sentence-surgery'),
      question: question,
      enabled: enabled,
      onComplete: onComplete,
      surgery: true,
    ),
    InteractionStyle.sentenceTransform => _SentenceTransform(
      key: const ValueKey('native-sentence-transform'),
      question: question,
      enabled: enabled,
      onComplete: onComplete,
    ),
    InteractionStyle.sentenceKnockout => _SentenceKnockout(
      question: question,
      enabled: enabled,
      onComplete: onComplete,
    ),
    InteractionStyle.patternComplete => _PatternComplete(
      question: question,
      enabled: enabled,
      onComplete: onComplete,
    ),
    InteractionStyle.contextApplication => _ContextApplication(
      question: question,
      enabled: enabled,
      onComplete: onComplete,
    ),
    _ => const SizedBox.shrink(),
  };
}

class _SentenceSpotlight extends StatefulWidget {
  const _SentenceSpotlight({
    required this.question,
    required this.enabled,
    required this.onComplete,
  });
  final Question question;
  final bool enabled;
  final NativeAnswerCallback onComplete;

  @override
  State<_SentenceSpotlight> createState() => _SentenceSpotlightState();
}

class _SentenceSpotlightState extends State<_SentenceSpotlight> {
  String? selected;

  @override
  Widget build(BuildContext context) => _NativePanel(
    key: const ValueKey('native-sentence-spotlight'),
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.md,
      children: [
        for (final token in widget.question.items('tokens'))
          _NativeChip(
            key: ValueKey('token-${token.id}'),
            label: token.text,
            selected: selected == token.id,
            onTap: widget.enabled
                ? () {
                    setState(() => selected = token.id);
                    widget.onComplete({
                      'tokenIds': [token.id],
                    });
                  }
                : null,
          ),
      ],
    ),
  );
}

class _AssignmentBoard extends StatefulWidget {
  const _AssignmentBoard({
    super.key,
    required this.question,
    required this.targetField,
    required this.enabled,
    required this.onComplete,
    required this.instruction,
    this.tokenFirst = false,
  });
  final Question question;
  final String targetField;
  final bool enabled;
  final NativeAnswerCallback onComplete;
  final String instruction;
  final bool tokenFirst;

  @override
  State<_AssignmentBoard> createState() => _AssignmentBoardState();
}

class _AssignmentBoardState extends State<_AssignmentBoard> {
  String? activeTarget;
  String? activeToken;
  final Map<String, String> assignments = {};

  void assign(String targetId, String tokenId) {
    final next = Map<String, String>.of(assignments)..[targetId] = tokenId;
    setState(() {
      assignments
        ..clear()
        ..addAll(next);
      activeTarget = null;
      activeToken = null;
    });
    if (next.length == widget.question.items(widget.targetField).length) {
      widget.onComplete({'assignments': next});
    }
  }

  void tapTarget(String targetId) {
    if (activeToken != null) {
      assign(targetId, activeToken!);
    } else {
      setState(() => activeTarget = targetId);
    }
  }

  void tapToken(String tokenId) {
    if (activeTarget != null) {
      assign(activeTarget!, tokenId);
    } else {
      setState(() => activeToken = tokenId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.question.items('tokens');
    final targets = widget.question.items(widget.targetField);
    final tokenById = {for (final token in tokens) token.id: token.text};
    final targetByToken = {
      for (final entry in assignments.entries) entry.value: entry.key,
    };
    final tokenRow = Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.md,
      children: [
        for (final token in tokens)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NativeChip(
                key: ValueKey('token-${token.id}'),
                label: token.text,
                selected:
                    activeToken == token.id ||
                    targetByToken.containsKey(token.id),
                onTap: widget.enabled ? () => tapToken(token.id) : null,
              ),
              if (targetByToken[token.id] case final targetId?)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    targets
                            .where((item) => item.id == targetId)
                            .firstOrNull
                            ?.text ??
                        targetId,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
    final targetRow = Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final target in targets)
          _TargetCard(
            key: ValueKey('${widget.targetField}-${target.id}'),
            label: target.text,
            value: tokenById[assignments[target.id]],
            selected: activeTarget == target.id,
            onTap: widget.enabled ? () => tapTarget(target.id) : null,
          ),
      ],
    );
    return _NativePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.instruction,
            style: const TextStyle(color: AppColors.secondaryText),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (widget.tokenFirst) ...[
            tokenRow,
            const SizedBox(height: AppSpacing.xl),
            targetRow,
          ] else ...[
            targetRow,
            const SizedBox(height: AppSpacing.xl),
            tokenRow,
          ],
        ],
      ),
    );
  }
}

class _SentenceTransform extends StatefulWidget {
  const _SentenceTransform({
    super.key,
    required this.question,
    required this.enabled,
    required this.onComplete,
    this.surgery = false,
  });
  final Question question;
  final bool enabled;
  final NativeAnswerCallback onComplete;
  final bool surgery;

  @override
  State<_SentenceTransform> createState() => _SentenceTransformState();
}

class _SentenceTransformState extends State<_SentenceTransform> {
  String? target;
  String? replacement;

  @override
  Widget build(BuildContext context) {
    final tokens = widget.question.items('tokens');
    final replacements = widget.question.items('replacements');
    final replacementText = replacements
        .where((item) => item.id == replacement)
        .firstOrNull
        ?.text;
    return _NativePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.surgery ? '① 找到位置不对的词' : '① 点要替换的句子成分',
            style: const TextStyle(color: AppColors.secondaryText),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final token in tokens)
                _NativeChip(
                  key: ValueKey('token-${token.id}'),
                  label:
                      token.id == target &&
                          replacementText != null &&
                          !widget.surgery
                      ? replacementText
                      : token.text,
                  selected: token.id == target,
                  warning: widget.surgery && token.id == target,
                  onTap: widget.enabled
                      ? () => setState(() => target = token.id)
                      : null,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            widget.surgery ? '② 选择正确的位置' : '② 选择新的词块',
            style: const TextStyle(color: AppColors.secondaryText),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              for (final item in replacements)
                _NativeChip(
                  key: ValueKey('replacement-${item.id}'),
                  label: item.text,
                  selected: replacement == item.id,
                  onTap: widget.enabled && target != null
                      ? () {
                          setState(() => replacement = item.id);
                          widget.onComplete({
                            'targetTokenId': target!,
                            'replacementTokenId': item.id,
                          });
                        }
                      : null,
                ),
            ],
          ),
          if (widget.surgery &&
              replacement != null &&
              widget.question.structuredOptions['resultSentence'] != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              '修复后：${widget.question.structuredOptions['resultSentence']}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SentenceKnockout extends StatefulWidget {
  const _SentenceKnockout({
    required this.question,
    required this.enabled,
    required this.onComplete,
  });
  final Question question;
  final bool enabled;
  final NativeAnswerCallback onComplete;
  @override
  State<_SentenceKnockout> createState() => _SentenceKnockoutState();
}

class _SentenceKnockoutState extends State<_SentenceKnockout> {
  String? selected;
  @override
  Widget build(BuildContext context) => Column(
    key: const ValueKey('native-sentence-knockout'),
    children: [
      for (final card in widget.question.items('cards'))
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _SentenceCard(
            key: ValueKey('card-${card.id}'),
            text: card.text,
            selected: selected == card.id,
            onTap: widget.enabled
                ? () {
                    setState(() => selected = card.id);
                    widget.onComplete(card.id);
                  }
                : null,
          ),
        ),
    ],
  );
}

class _PatternComplete extends StatelessWidget {
  const _PatternComplete({
    required this.question,
    required this.enabled,
    required this.onComplete,
  });
  final Question question;
  final bool enabled;
  final NativeAnswerCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final rows = question.structuredOptions['patternRows'];
    final slot = question.items('slots').firstOrNull;
    return _NativePanel(
      key: const ValueKey('native-pattern-complete'),
      child: Column(
        children: [
          if (rows is List)
            for (final rawRow in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    for (final value in (rawRow as List))
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: value == null
                                ? AppColors.surfaceGreen
                                : AppColors.surface,
                            borderRadius: AppRadius.small,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            value == null ? '?' : '$value',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            children: [
              for (final token in question.items('tokens'))
                _NativeChip(
                  key: ValueKey('token-${token.id}'),
                  label: token.text,
                  onTap: enabled && slot != null
                      ? () => onComplete({
                          'assignments': {slot.id: token.id},
                        })
                      : null,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContextApplication extends StatefulWidget {
  const _ContextApplication({
    required this.question,
    required this.enabled,
    required this.onComplete,
  });
  final Question question;
  final bool enabled;
  final NativeAnswerCallback onComplete;
  @override
  State<_ContextApplication> createState() => _ContextApplicationState();
}

class _ContextApplicationState extends State<_ContextApplication> {
  final List<String> built = [];

  @override
  Widget build(BuildContext context) {
    final tokens = widget.question.items('tokens');
    final byId = {for (final item in tokens) item.id: item};
    final scene = widget.question.structuredOptions['scene'];
    return Column(
      key: const ValueKey('native-context-application'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (scene is Map)
          Container(
            key: const ValueKey('context-scene'),
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceGreen,
              borderRadius: AppRadius.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${scene['speaker'] ?? 'Grammar Cat'} 🐱',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('“${scene['line'] ?? ''}”'),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '你要表达：${scene['targetMeaning'] ?? ''}',
                  style: const TextStyle(color: AppColors.primary),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        _NativePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (final id in built)
                    _NativeChip(
                      label: byId[id]?.text ?? id,
                      selected: true,
                      onTap: widget.enabled
                          ? () => setState(() => built.remove(id))
                          : null,
                    ),
                ],
              ),
              if (built.isEmpty)
                const Text(
                  '点击词块，把回应拼出来',
                  style: TextStyle(color: AppColors.secondaryText),
                ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  for (final token in tokens.where(
                    (token) => !built.contains(token.id),
                  ))
                    _NativeChip(
                      key: ValueKey('token-${token.id}'),
                      label: token.text,
                      onTap: widget.enabled
                          ? () {
                              final next = [...built, token.id];
                              setState(() => built.add(token.id));
                              if (next.length == tokens.length) {
                                widget.onComplete(next);
                              }
                            }
                          : null,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NativePanel extends StatelessWidget {
  const _NativePanel({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: AppColors.surfaceGreen,
      borderRadius: AppRadius.card,
      border: Border.all(color: AppColors.border),
    ),
    child: child,
  );
}

class _NativeChip extends StatelessWidget {
  const _NativeChip({
    super.key,
    required this.label,
    this.selected = false,
    this.warning = false,
    this.onTap,
  });
  final String label;
  final bool selected;
  final bool warning;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 180),
    decoration: BoxDecoration(
      color: warning
          ? AppColors.softOrange
          : selected
          ? AppColors.softGreen
          : AppColors.surface,
      borderRadius: AppRadius.small,
      border: Border.all(
        color: warning
            ? AppColors.orange
            : selected
            ? AppColors.primary
            : AppColors.border,
        width: 2,
      ),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: AppRadius.small,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    ),
  );
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({
    super.key,
    required this.label,
    required this.selected,
    this.value,
    this.onTap,
  });
  final String label;
  final String? value;
  final bool selected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: AppRadius.small,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 104,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: value == null ? AppColors.surface : AppColors.mint,
        borderRadius: AppRadius.small,
        border: Border.all(
          color: selected || value != null
              ? AppColors.primary
              : AppColors.border,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value ?? '点击放入',
            style: TextStyle(
              color: value == null
                  ? AppColors.secondaryText
                  : AppColors.primary,
            ),
          ),
        ],
      ),
    ),
  );
}

class _SentenceCard extends StatelessWidget {
  const _SentenceCard({
    super.key,
    required this.text,
    required this.selected,
    this.onTap,
  });
  final String text;
  final bool selected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.softGreen : AppColors.surface,
    borderRadius: AppRadius.small,
    child: InkWell(
      onTap: onTap,
      borderRadius: AppRadius.small,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: AppRadius.small,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );
}
