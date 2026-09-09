import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/option_card.dart';
import '../domain/lesson_models.dart';
import 'activities/native_practice_activity.dart';

/// A formal question type maps to one of several tap-first interaction
/// renderers. The style is derived deterministically from the question shape
/// and authored content conventions; the backend stays the only answer truth.
enum PracticeInteractionStyle {
  quickChoice,
  dialogue,
  ruleMatch,
  tokenTap,
  wordSlot,
  fixIt,
  pairMatch,
  categorySort,
  tapToBuild,
  trueFalse,
  multipleSelect,
  legacyText,
  sentenceSpotlight,
  grammarPaint,
  sentenceSurgery,
  sentenceTransform,
  slotPuzzle,
  sentenceKnockout,
  patternComplete,
  contextApplication,
}

// Content conventions shared with the authored curriculum (A1 pilot):
// new activities open with a short Chinese instruction that names the
// interaction; structural signals below stay stable even if copy is edited.
const _kTokenTapPrefix = '点击句子中的';
const _kRuleMatchPrefix = '根据规则选择';
const _kCategorySortHint = '类别';
const _kPairSeparator = ' → ';
final _kDialogueLine = RegExp(r'^[A-Z][a-zA-Z]{1,11}: ', multiLine: true);
final _kLatinLetter = RegExp(r'[A-Za-z]');
final _kMarkedToken = RegExp(r'\*([^*]+)\*');

PracticeInteractionStyle resolveInteractionStyle(Question question) {
  final explicit = question.interactionStyle;
  if (explicit != null) {
    return switch (explicit) {
      InteractionStyle.quickChoice => PracticeInteractionStyle.quickChoice,
      InteractionStyle.sentenceSpotlight =>
        PracticeInteractionStyle.sentenceSpotlight,
      InteractionStyle.grammarPaint => PracticeInteractionStyle.grammarPaint,
      InteractionStyle.sentenceSurgery =>
        PracticeInteractionStyle.sentenceSurgery,
      InteractionStyle.sentenceTransform =>
        PracticeInteractionStyle.sentenceTransform,
      InteractionStyle.slotPuzzle => PracticeInteractionStyle.slotPuzzle,
      InteractionStyle.sentenceKnockout =>
        PracticeInteractionStyle.sentenceKnockout,
      InteractionStyle.patternComplete =>
        PracticeInteractionStyle.patternComplete,
      InteractionStyle.contextApplication =>
        PracticeInteractionStyle.contextApplication,
      InteractionStyle.tapToBuild => PracticeInteractionStyle.tapToBuild,
    };
  }
  final options = question.optionItems;
  switch (question.questionType) {
    case QuestionType.sentenceOrder:
      return PracticeInteractionStyle.tapToBuild;
    case QuestionType.trueFalse:
      return PracticeInteractionStyle.trueFalse;
    case QuestionType.fillBlank:
      return options.isNotEmpty
          ? PracticeInteractionStyle.wordSlot
          : PracticeInteractionStyle.legacyText;
    case QuestionType.correction:
      return options.isNotEmpty &&
              _kMarkedToken.hasMatch(question.questionContent)
          ? PracticeInteractionStyle.fixIt
          : PracticeInteractionStyle.legacyText;
    case QuestionType.multipleChoice:
      final paired =
          options.isNotEmpty &&
          options.every((option) => option.text.contains(_kPairSeparator));
      if (!paired) return PracticeInteractionStyle.multipleSelect;
      return question.questionContent.contains(_kCategorySortHint)
          ? PracticeInteractionStyle.categorySort
          : PracticeInteractionStyle.pairMatch;
    case QuestionType.singleChoice:
      if (question.questionContent.startsWith(_kTokenTapPrefix)) {
        return PracticeInteractionStyle.tokenTap;
      }
      if (question.questionContent.startsWith(_kRuleMatchPrefix)) {
        return PracticeInteractionStyle.ruleMatch;
      }
      if (_kDialogueLine.hasMatch(question.questionContent)) {
        return PracticeInteractionStyle.dialogue;
      }
      return PracticeInteractionStyle.quickChoice;
    case QuestionType.tokenSelect:
      return PracticeInteractionStyle.tokenTap;
    case QuestionType.tokenLabel || QuestionType.slotAssignment:
      return PracticeInteractionStyle.pairMatch;
    case QuestionType.transform:
      return PracticeInteractionStyle.fixIt;
  }
}

String interactionLabel(PracticeInteractionStyle style) => switch (style) {
  PracticeInteractionStyle.quickChoice => '选出正确的答案',
  PracticeInteractionStyle.dialogue => '选择合适的回答',
  PracticeInteractionStyle.ruleMatch => '根据规则选择',
  PracticeInteractionStyle.tokenTap => '点击句子中正确的词',
  PracticeInteractionStyle.wordSlot => '点词块补全句子',
  PracticeInteractionStyle.fixIt => '把错误的词换成正确的',
  PracticeInteractionStyle.pairMatch => '左右配对',
  PracticeInteractionStyle.categorySort => '把单词放进正确的类别',
  PracticeInteractionStyle.tapToBuild => '按顺序点击词块组句',
  PracticeInteractionStyle.trueFalse => '判断句子是否正确',
  PracticeInteractionStyle.multipleSelect => '选择所有正确答案',
  PracticeInteractionStyle.legacyText => '写出答案',
  PracticeInteractionStyle.sentenceSpotlight => '在句子上找一找',
  PracticeInteractionStyle.grammarPaint => '给句子涂上语法角色',
  PracticeInteractionStyle.sentenceSurgery => '给句子做一次小手术',
  PracticeInteractionStyle.sentenceTransform => '替换句子成分',
  PracticeInteractionStyle.slotPuzzle => '把词放进结构槽位',
  PracticeInteractionStyle.sentenceKnockout => '找出结构不同的一句',
  PracticeInteractionStyle.patternComplete => '观察并补全结构',
  PracticeInteractionStyle.contextApplication => '在情境中拼出句子',
};

/// True when the interaction completes itself and submits without a
/// separate 提交 button; only multi-select and legacy keyboard need one.
bool autoSubmits(PracticeInteractionStyle style) => switch (style) {
  PracticeInteractionStyle.multipleSelect ||
  PracticeInteractionStyle.legacyText => false,
  _ => true,
};

/// Splits an authored "中文指令。English sentence." prompt.
(String, String) splitInstruction(String content) {
  final index = content.indexOf(_kLatinLetter);
  if (index <= 0) return (content, '');
  return (content.substring(0, index).trim(), content.substring(index).trim());
}

/// The text shown above the activity. Sentence-building styles render the
/// sentence inside the activity itself; chat styles render their own bubbles.
String activityPrompt(Question question, PracticeInteractionStyle style) {
  final content = question.questionContent;
  return switch (style) {
    PracticeInteractionStyle.tokenTap ||
    PracticeInteractionStyle.wordSlot ||
    PracticeInteractionStyle.fixIt => splitInstruction(content).$1,
    PracticeInteractionStyle.dialogue => '',
    _ => content,
  };
}

bool _isNativeStyle(PracticeInteractionStyle style) => switch (style) {
  PracticeInteractionStyle.sentenceSpotlight ||
  PracticeInteractionStyle.grammarPaint ||
  PracticeInteractionStyle.sentenceSurgery ||
  PracticeInteractionStyle.sentenceTransform ||
  PracticeInteractionStyle.slotPuzzle ||
  PracticeInteractionStyle.sentenceKnockout ||
  PracticeInteractionStyle.patternComplete ||
  PracticeInteractionStyle.contextApplication => true,
  _ => false,
};

class PracticeActivityInput extends StatelessWidget {
  const PracticeActivityInput({
    super.key,
    required this.question,
    required this.style,
    required this.enabled,
    required this.onChanged,
    this.onAutoSubmit,
  });

  final Question question;
  final PracticeInteractionStyle style;
  final bool enabled;
  final ValueChanged<Object?> onChanged;
  final VoidCallback? onAutoSubmit;

  void _submit(Object? answer) {
    onChanged(answer);
    onAutoSubmit?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_isNativeStyle(style)) {
      return NativePracticeActivity(
        question: question,
        enabled: enabled,
        onComplete: _submit,
      );
    }
    return switch (style) {
      PracticeInteractionStyle.quickChoice => _QuickChoiceCards(
        question: question,
        enabled: enabled,
        onSubmit: _submit,
      ),
      PracticeInteractionStyle.dialogue => _DialogueChoice(
        question: question,
        enabled: enabled,
        onSubmit: _submit,
      ),
      PracticeInteractionStyle.ruleMatch => _RuleMatchChips(
        question: question,
        enabled: enabled,
        onSubmit: _submit,
      ),
      PracticeInteractionStyle.tokenTap => _TokenTapSentence(
        question: question,
        enabled: enabled,
        onSubmit: _submit,
      ),
      PracticeInteractionStyle.wordSlot => _WordSlotFill(
        question: question,
        enabled: enabled,
        onSubmit: _submit,
      ),
      PracticeInteractionStyle.fixIt => _FixItSentence(
        question: question,
        enabled: enabled,
        onSubmit: _submit,
      ),
      PracticeInteractionStyle.pairMatch => _PairMatchBoard(
        question: question,
        enabled: enabled,
        onSubmit: _submit,
      ),
      PracticeInteractionStyle.categorySort => _CategorySortBoard(
        question: question,
        enabled: enabled,
        onSubmit: _submit,
      ),
      PracticeInteractionStyle.tapToBuild => _TapToBuildSentence(
        question: question,
        enabled: enabled,
        onSubmit: _submit,
      ),
      PracticeInteractionStyle.trueFalse => _TrueFalseToggle(
        question: question,
        enabled: enabled,
        onSubmit: _submit,
      ),
      PracticeInteractionStyle.multipleSelect => _MultipleSelectCards(
        question: question,
        enabled: enabled,
        onChanged: onChanged,
      ),
      PracticeInteractionStyle.legacyText => _LegacyTextField(
        question: question,
        enabled: enabled,
        onChanged: onChanged,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

typedef _AnswerSubmit = void Function(Object? answer);

class _QuickChoiceCards extends StatelessWidget {
  const _QuickChoiceCards({
    required this.question,
    required this.enabled,
    required this.onSubmit,
  });
  final Question question;
  final bool enabled;
  final _AnswerSubmit onSubmit;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final option in question.optionItems)
        OptionCard(
          selected: false,
          label: option.text,
          onTap: enabled ? () => onSubmit(option.id) : null,
        ),
    ],
  );
}

class _RuleMatchChips extends StatelessWidget {
  const _RuleMatchChips({
    required this.question,
    required this.enabled,
    required this.onSubmit,
  });
  final Question question;
  final bool enabled;
  final _AnswerSubmit onSubmit;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.md,
    runSpacing: AppSpacing.md,
    children: [
      for (final option in question.optionItems)
        _WordBlockChip(
          label: option.text,
          onTap: enabled ? () => onSubmit(option.id) : null,
        ),
    ],
  );
}

class _DialogueChoice extends StatelessWidget {
  const _DialogueChoice({
    required this.question,
    required this.enabled,
    required this.onSubmit,
  });
  final Question question;
  final bool enabled;
  final _AnswerSubmit onSubmit;

  @override
  Widget build(BuildContext context) {
    final lines = question.questionContent
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines) _DialogueBubble(line: line),
        const SizedBox(height: AppSpacing.lg),
        for (final option in question.optionItems)
          OptionCard(
            selected: false,
            label: option.text,
            onTap: enabled ? () => onSubmit(option.id) : null,
          ),
      ],
    );
  }
}

class _DialogueBubble extends StatelessWidget {
  const _DialogueBubble({required this.line});
  final String line;

  @override
  Widget build(BuildContext context) {
    final colon = line.indexOf(': ');
    final speaker = colon > 0 ? line.substring(0, colon) : '';
    final text = colon > 0 ? line.substring(colon + 2) : line;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.softGreen,
            child: Text(speaker.isEmpty ? '?' : speaker.substring(0, 1)),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceGreen,
                borderRadius: AppRadius.small,
                border: text.contains('___')
                    ? Border.all(color: AppColors.primary)
                    : null,
              ),
              child: Text(
                text.contains('___') ? text.replaceAll('___', '＿＿＿') : text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TokenTapSentence extends StatelessWidget {
  const _TokenTapSentence({
    required this.question,
    required this.enabled,
    required this.onSubmit,
  });
  final Question question;
  final bool enabled;
  final _AnswerSubmit onSubmit;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: [
      for (final option in question.optionItems)
        _WordBlockChip(
          label: option.text,
          onTap: enabled ? () => onSubmit(option.id) : null,
        ),
    ],
  );
}

class _WordSlotFill extends StatefulWidget {
  const _WordSlotFill({
    required this.question,
    required this.enabled,
    required this.onSubmit,
  });
  final Question question;
  final bool enabled;
  final _AnswerSubmit onSubmit;

  @override
  State<_WordSlotFill> createState() => _WordSlotFillState();
}

class _WordSlotFillState extends State<_WordSlotFill> {
  String? _picked;

  @override
  Widget build(BuildContext context) {
    final (_, sentence) = splitInstruction(widget.question.questionContent);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: Theme.of(context).textTheme.titleMedium,
            children: [
              if (!sentence.contains('___'))
                TextSpan(text: sentence)
              else ...[
                TextSpan(text: sentence.substring(0, sentence.indexOf('___'))),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _picked == null
                          ? AppColors.surfaceGreen
                          : AppColors.mint,
                      borderRadius: AppRadius.small,
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: Text(
                      _picked ?? '＿＿',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                TextSpan(text: sentence.substring(sentence.indexOf('___') + 3)),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final option in widget.question.optionItems)
              _WordBlockChip(
                label: option.text,
                onTap: widget.enabled
                    ? () {
                        setState(() => _picked = option.text);
                        widget.onSubmit(option.text);
                      }
                    : null,
              ),
          ],
        ),
      ],
    );
  }
}

class _FixItSentence extends StatefulWidget {
  const _FixItSentence({
    required this.question,
    required this.enabled,
    required this.onSubmit,
  });
  final Question question;
  final bool enabled;
  final _AnswerSubmit onSubmit;

  @override
  State<_FixItSentence> createState() => _FixItSentenceState();
}

class _FixItSentenceState extends State<_FixItSentence> {
  String? _replacement;

  @override
  Widget build(BuildContext context) {
    final (_, sentence) = splitInstruction(widget.question.questionContent);
    final marked = _kMarkedToken.firstMatch(sentence);
    final tokens = sentence.replaceAll('*', '').split(' ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: Theme.of(context).textTheme.titleMedium,
            children: [
              for (final token in tokens)
                TextSpan(
                  text:
                      '${marked != null && token == marked.group(1) && _replacement != null ? _replacement : token} ',
                  style: marked != null && token == marked.group(1)
                      ? TextStyle(
                          color: _replacement == null
                              ? AppColors.orange
                              : AppColors.primary,
                          fontWeight: FontWeight.w700,
                          decoration: _replacement == null
                              ? TextDecoration.underline
                              : null,
                        )
                      : null,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final option in widget.question.optionItems)
              _WordBlockChip(
                label: option.text,
                onTap: widget.enabled
                    ? () {
                        setState(() => _replacement = option.text);
                        if (marked != null) {
                          widget.onSubmit(
                            sentence.replaceFirst(
                              marked.group(0)!,
                              option.text,
                            ),
                          );
                        }
                      }
                    : null,
              ),
          ],
        ),
      ],
    );
  }
}

class _PairMatchBoard extends StatefulWidget {
  const _PairMatchBoard({
    required this.question,
    required this.enabled,
    required this.onSubmit,
  });
  final Question question;
  final bool enabled;
  final _AnswerSubmit onSubmit;

  @override
  State<_PairMatchBoard> createState() => _PairMatchBoardState();
}

class _PairMatchBoardState extends State<_PairMatchBoard> {
  String? _selectedLeft;
  final Map<String, String> _pairs = {}; // left -> right

  List<String> get _lefts => widget.question.optionItems
      .map((option) => option.text.split(_kPairSeparator).first.trim())
      .toSet()
      .toList();
  List<String> get _rights => widget.question.optionItems
      .map((option) => option.text.split(_kPairSeparator).last.trim())
      .toSet()
      .toList();

  void _tapLeft(String left) {
    setState(() {
      if (_pairs.containsKey(left)) {
        _pairs.remove(left);
        _selectedLeft = null;
      } else {
        _selectedLeft = left;
      }
    });
  }

  void _tapRight(String right) {
    final left = _selectedLeft;
    if (left == null) return;
    final option = widget.question.optionItems
        .where((option) => option.text == '$left$_kPairSeparator$right')
        .firstOrNull;
    if (option == null) return; // Authored grids cover every combination.
    setState(() {
      _pairs[left] = right;
      _selectedLeft = null;
    });
    if (_pairs.length == _lefts.length) {
      final ids = <String>[];
      for (final entry in _pairs.entries) {
        final match = widget.question.optionItems
            .where(
              (option) =>
                  option.text == '${entry.key}$_kPairSeparator${entry.value}',
            )
            .firstOrNull;
        if (match != null) ids.add(match.id);
      }
      widget.onSubmit(ids);
    }
  }

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          children: [
            for (final left in _lefts)
              _MatchCard(
                label: left,
                state: _pairs.containsKey(left)
                    ? _MatchCardState.paired
                    : _selectedLeft == left
                    ? _MatchCardState.selected
                    : _MatchCardState.idle,
                onTap: widget.enabled ? () => _tapLeft(left) : null,
              ),
          ],
        ),
      ),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: Column(
          children: [
            for (final right in _rights)
              _MatchCard(
                label: right,
                state: _pairs.containsValue(right)
                    ? _MatchCardState.paired
                    : _selectedLeft != null
                    ? _MatchCardState.hinted
                    : _MatchCardState.idle,
                onTap: widget.enabled ? () => _tapRight(right) : null,
              ),
          ],
        ),
      ),
    ],
  );
}

enum _MatchCardState { idle, selected, hinted, paired }

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.label, required this.state, this.onTap});
  final String label;
  final _MatchCardState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final highlighted =
        state == _MatchCardState.selected || state == _MatchCardState.hinted;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: state == _MatchCardState.paired
            ? AppColors.mint
            : highlighted
            ? AppColors.softGreen
            : AppColors.surface,
        borderRadius: AppRadius.small,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.small,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.small,
              border: Border.all(
                color: highlighted ? AppColors.primary : AppColors.border,
                width: highlighted ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: state == _MatchCardState.paired
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
                if (state == _MatchCardState.paired)
                  const Icon(Icons.link, size: 18, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategorySortBoard extends StatefulWidget {
  const _CategorySortBoard({
    required this.question,
    required this.enabled,
    required this.onSubmit,
  });
  final Question question;
  final bool enabled;
  final _AnswerSubmit onSubmit;

  @override
  State<_CategorySortBoard> createState() => _CategorySortBoardState();
}

class _CategorySortBoardState extends State<_CategorySortBoard> {
  String? _selectedWord;
  final Map<String, String> _sorted = {}; // word -> category

  List<String> get _words => widget.question.optionItems
      .map((option) => option.text.split(_kPairSeparator).first.trim())
      .toSet()
      .toList();
  List<String> get _categories => widget.question.optionItems
      .map((option) => option.text.split(_kPairSeparator).last.trim())
      .toSet()
      .toList();

  void _assign(String category) {
    final word = _selectedWord;
    if (word == null) return;
    final option = widget.question.optionItems
        .where((option) => option.text == '$word$_kPairSeparator$category')
        .firstOrNull;
    if (option == null) return;
    setState(() {
      _sorted[word] = category;
      _selectedWord = null;
    });
    if (_sorted.length == _words.length) {
      final ids = <String>[];
      for (final entry in _sorted.entries) {
        final match = widget.question.optionItems
            .where(
              (option) =>
                  option.text == '${entry.key}$_kPairSeparator${entry.value}',
            )
            .firstOrNull;
        if (match != null) ids.add(match.id);
      }
      widget.onSubmit(ids);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unassigned = _words.where((word) => !_sorted.containsKey(word));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (unassigned.isEmpty)
          const Text(
            '所有单词都已分类',
            style: TextStyle(color: AppColors.secondaryText),
          )
        else
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              for (final word in unassigned)
                _WordBlockChip(
                  label: word,
                  emphasized: _selectedWord == word,
                  onTap: widget.enabled
                      ? () => setState(() => _selectedWord = word)
                      : null,
                ),
            ],
          ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final category in _categories) ...[
              Expanded(
                child: _SortZone(
                  category: category,
                  words: [
                    for (final entry in _sorted.entries)
                      if (entry.value == category) entry.key,
                  ],
                  onTapWord: widget.enabled
                      ? (word) => setState(() {
                          _sorted.remove(word);
                          _selectedWord = word;
                        })
                      : null,
                  onTapZone: widget.enabled ? () => _assign(category) : null,
                ),
              ),
              if (category != _categories.last)
                const SizedBox(width: AppSpacing.md),
            ],
          ],
        ),
      ],
    );
  }
}

class _SortZone extends StatelessWidget {
  const _SortZone({
    required this.category,
    required this.words,
    this.onTapZone,
    this.onTapWord,
  });
  final String category;
  final List<String> words;
  final VoidCallback? onTapZone;
  final void Function(String word)? onTapWord;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surfaceGreen,
    borderRadius: AppRadius.small,
    child: InkWell(
      onTap: onTapZone,
      borderRadius: AppRadius.small,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: AppRadius.small,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              category,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (words.isEmpty)
              const Text(
                '点击放入',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
              )
            else
              for (final word in words)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: _WordBlockChip(
                    label: word,
                    small: true,
                    onTap: onTapWord == null ? null : () => onTapWord!(word),
                  ),
                ),
          ],
        ),
      ),
    ),
  );
}

class _TapToBuildSentence extends StatefulWidget {
  const _TapToBuildSentence({
    required this.question,
    required this.enabled,
    required this.onSubmit,
  });
  final Question question;
  final bool enabled;
  final _AnswerSubmit onSubmit;

  @override
  State<_TapToBuildSentence> createState() => _TapToBuildSentenceState();
}

class _TapToBuildSentenceState extends State<_TapToBuildSentence> {
  final List<int> _built = []; // indices into optionItems

  @override
  Widget build(BuildContext context) {
    final options = widget.question.optionItems;
    final bank = [
      for (var i = 0; i < options.length; i++)
        if (!_built.contains(i)) i,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceGreen,
            borderRadius: AppRadius.small,
            border: Border.all(color: AppColors.border),
          ),
          child: _built.isEmpty
              ? const Text(
                  '按顺序点击下方词块',
                  style: TextStyle(color: AppColors.secondaryText),
                )
              : Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final index in _built)
                      _WordBlockChip(
                        label: options[index].text,
                        onTap: widget.enabled
                            ? () => setState(() => _built.remove(index))
                            : null,
                      ),
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final index in bank)
              _WordBlockChip(
                label: options[index].text,
                onTap: widget.enabled
                    ? () {
                        setState(() => _built.add(index));
                        if (bank.length == 1) {
                          // The last token was just placed; the sentence is complete.
                          widget.onSubmit([
                            for (final built in _built) options[built].text,
                          ]);
                        }
                      }
                    : null,
              ),
          ],
        ),
      ],
    );
  }
}

class _TrueFalseToggle extends StatelessWidget {
  const _TrueFalseToggle({
    required this.question,
    required this.enabled,
    required this.onSubmit,
  });
  final Question question;
  final bool enabled;
  final _AnswerSubmit onSubmit;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _BigTapButton(
          label: '✓ 正确',
          onTap: enabled ? () => onSubmit(true) : null,
        ),
      ),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: _BigTapButton(
          label: '✕ 错误',
          onTap: enabled ? () => onSubmit(false) : null,
        ),
      ),
    ],
  );
}

class _MultipleSelectCards extends StatefulWidget {
  const _MultipleSelectCards({
    required this.question,
    required this.enabled,
    required this.onChanged,
  });
  final Question question;
  final bool enabled;
  final ValueChanged<Object?> onChanged;

  @override
  State<_MultipleSelectCards> createState() => _MultipleSelectCardsState();
}

class _MultipleSelectCardsState extends State<_MultipleSelectCards> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final option in widget.question.optionItems)
        OptionCard(
          multiple: true,
          selected: _selected.contains(option.id),
          onTap: widget.enabled
              ? () {
                  setState(() {
                    _selected.contains(option.id)
                        ? _selected.remove(option.id)
                        : _selected.add(option.id);
                  });
                  widget.onChanged(_selected.toList());
                }
              : null,
          label: option.text,
        ),
    ],
  );
}

class _LegacyTextField extends StatelessWidget {
  const _LegacyTextField({
    required this.question,
    required this.enabled,
    required this.onChanged,
  });
  final Question question;
  final bool enabled;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    enabled: enabled,
    minLines: 2,
    maxLines: 4,
    onChanged: (value) => onChanged(value.trim()),
    decoration: const InputDecoration(labelText: '写出修改后的句子'),
  );
}

class _WordBlockChip extends StatelessWidget {
  const _WordBlockChip({
    required this.label,
    this.onTap,
    this.emphasized = false,
    this.small = false,
  });
  final String label;
  final VoidCallback? onTap;
  final bool emphasized;
  final bool small;

  @override
  Widget build(BuildContext context) => Material(
    color: emphasized ? AppColors.softGreen : AppColors.mint,
    borderRadius: AppRadius.small,
    child: InkWell(
      onTap: onTap,
      borderRadius: AppRadius.small,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: small ? AppSpacing.md : AppSpacing.xl,
          vertical: small ? AppSpacing.xs + 2 : AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          borderRadius: AppRadius.small,
          border: Border.all(
            color: emphasized ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: small ? 13 : 16,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
    ),
  );
}

class _BigTapButton extends StatelessWidget {
  const _BigTapButton({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onTap,
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    ),
    child: Text(label),
  );
}
