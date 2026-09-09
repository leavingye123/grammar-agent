import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/option_card.dart';
import '../../../core/widgets/learning_widgets.dart';

import '../domain/lesson_models.dart';
import 'activities/native_practice_activity.dart';

class QuestionInput extends StatefulWidget {
  const QuestionInput({
    super.key,
    required this.question,
    required this.enabled,
    required this.onChanged,
  });
  final Question question;
  final bool enabled;
  final ValueChanged<Object?> onChanged;
  @override
  State<QuestionInput> createState() => _QuestionInputState();
}

class _QuestionInputState extends State<QuestionInput> {
  String? single;
  final Set<String> multiple = {};
  bool? truth;
  final List<String> ordered = [];
  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    if (q.interactionStyle != null &&
        q.interactionStyle != InteractionStyle.quickChoice) {
      return NativePracticeActivity(
        question: q,
        enabled: widget.enabled,
        onComplete: widget.onChanged,
      );
    }
    final options = q.optionItems;
    return switch (q.questionType) {
      QuestionType.singleChoice => Column(
        children: [
          for (final o in options)
            OptionCard(
              selected: single == o.id,
              label: o.text,
              onTap: widget.enabled
                  ? () {
                      setState(() => single = o.id);
                      widget.onChanged(o.id);
                    }
                  : null,
            ),
        ],
      ),
      QuestionType.multipleChoice => Column(
        children: [
          for (final o in options)
            OptionCard(
              multiple: true,
              selected: multiple.contains(o.id),
              onTap: widget.enabled
                  ? () {
                      setState(
                        () => multiple.contains(o.id)
                            ? multiple.remove(o.id)
                            : multiple.add(o.id),
                      );
                      widget.onChanged(multiple.toList());
                    }
                  : null,
              label: o.text,
            ),
        ],
      ),
      QuestionType.fillBlank => TextField(
        enabled: widget.enabled,
        onChanged: (v) => widget.onChanged(v.trim()),
        decoration: const InputDecoration(labelText: '填写答案'),
      ),
      QuestionType.correction => TextField(
        enabled: widget.enabled,
        minLines: 2,
        maxLines: 4,
        onChanged: (v) => widget.onChanged(v.trim()),
        decoration: const InputDecoration(labelText: '写出修改后的句子'),
      ),
      QuestionType.trueFalse => SegmentedButton<bool>(
        segments: const [
          ButtonSegment(value: true, label: Text('正确')),
          ButtonSegment(value: false, label: Text('错误')),
        ],
        selected: truth == null ? {} : {truth!},
        emptySelectionAllowed: true,
        onSelectionChanged: widget.enabled
            ? (values) {
                setState(() => truth = values.firstOrNull);
                widget.onChanged(truth);
              }
            : null,
      ),
      QuestionType.sentenceOrder => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in options.where((o) => !ordered.contains(o.text)))
                ActionChip(
                  label: Text(o.text),
                  onPressed: widget.enabled
                      ? () {
                          setState(() => ordered.add(o.text));
                          widget.onChanged(List<String>.of(ordered));
                        }
                      : null,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (ordered.isEmpty)
            const Text('点击上方词块组成句子')
          else
            for (var index = 0; index < ordered.length; index++)
              ListTile(
                key: ValueKey('$index-${ordered[index]}'),
                dense: true,
                leading: Text('${index + 1}'),
                title: Text(ordered[index]),
                trailing: widget.enabled
                    ? Wrap(
                        children: [
                          IconButton(
                            tooltip: '上移',
                            icon: const Icon(Icons.arrow_upward),
                            onPressed: index == 0
                                ? null
                                : () {
                                    setState(() {
                                      final item = ordered.removeAt(index);
                                      ordered.insert(index - 1, item);
                                    });
                                    widget.onChanged(List<String>.of(ordered));
                                  },
                          ),
                          IconButton(
                            tooltip: '移除',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() => ordered.removeAt(index));
                              widget.onChanged(List<String>.of(ordered));
                            },
                          ),
                        ],
                      )
                    : null,
              ),
        ],
      ),
      QuestionType.tokenSelect ||
      QuestionType.tokenLabel ||
      QuestionType.slotAssignment ||
      QuestionType.transform => const Text('此题需要使用结构化交互完成'),
    };
  }
}

class FeedbackPanel extends StatelessWidget {
  const FeedbackPanel({
    super.key,
    required this.correct,
    required this.correctAnswer,
    this.explanation,
    this.extra,
    this.question,
  });
  final bool correct;
  final Object? correctAnswer;
  final String? explanation;
  final String? extra;
  final Question? question;
  @override
  Widget build(BuildContext context) {
    final color = correct ? AppColors.primary : AppColors.orange;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: correct ? AppColors.mint : AppColors.softOrange,
        borderRadius: AppRadius.card,
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            correct ? '✓ 正确' : '✕ 错误',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
          CatMessage(
            correct ? '漂亮！这个规则你已经越来越熟了。' : '这里容易混，我们看一下原因。',
            celebrating: correct,
          ),
          const SizedBox(height: 8),
          Text(
            '正确答案：${formatCorrectAnswer(correctAnswer, question: question)}',
          ),
          if (explanation?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(explanation!),
          ],
          if (extra != null) ...[
            const SizedBox(height: 8),
            Text(extra!, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }
}

String formatCorrectAnswer(Object? value, {Question? question}) {
  String option(Object? id) {
    final text = question?.optionItems
        .where((o) => o.id == '$id')
        .firstOrNull
        ?.text;
    return text == null ? '$id' : '$id · $text';
  }

  if (value is Map) {
    if (value['optionId'] != null) return option(value['optionId']);
    if (value['optionIds'] is List) {
      return (value['optionIds'] as List).map(option).join('、');
    }
    if (value['tokens'] is List) {
      return (value['tokens'] as List).join(' ').replaceAll(' .', '.');
    }
    for (final key in ['answers', 'acceptedAnswers']) {
      if (value[key] is List) return (value[key] as List).join(' / ');
    }
    if (value['value'] is bool) return value['value'] == true ? '正确' : '错误';
  }
  return value is String ? value : jsonEncode(value);
}
