import 'package:json_annotation/json_annotation.dart';

part 'lesson_models.g.dart';

enum QuestionType {
  singleChoice,
  multipleChoice,
  fillBlank,
  sentenceOrder,
  trueFalse,
  correction,
  tokenSelect,
  tokenLabel,
  slotAssignment,
  transform,
}

QuestionType questionTypeFromWire(String value) => switch (value) {
  'SINGLE_CHOICE' => QuestionType.singleChoice,
  'MULTIPLE_CHOICE' => QuestionType.multipleChoice,
  'FILL_BLANK' => QuestionType.fillBlank,
  'SENTENCE_ORDER' => QuestionType.sentenceOrder,
  'TRUE_FALSE' => QuestionType.trueFalse,
  'CORRECTION' => QuestionType.correction,
  'TOKEN_SELECT' => QuestionType.tokenSelect,
  'TOKEN_LABEL' => QuestionType.tokenLabel,
  'SLOT_ASSIGNMENT' => QuestionType.slotAssignment,
  'TRANSFORM' => QuestionType.transform,
  _ => throw FormatException('Unsupported question type: $value'),
};
String questionTypeToWire(QuestionType value) => switch (value) {
  QuestionType.singleChoice => 'SINGLE_CHOICE',
  QuestionType.multipleChoice => 'MULTIPLE_CHOICE',
  QuestionType.fillBlank => 'FILL_BLANK',
  QuestionType.sentenceOrder => 'SENTENCE_ORDER',
  QuestionType.trueFalse => 'TRUE_FALSE',
  QuestionType.correction => 'CORRECTION',
  QuestionType.tokenSelect => 'TOKEN_SELECT',
  QuestionType.tokenLabel => 'TOKEN_LABEL',
  QuestionType.slotAssignment => 'SLOT_ASSIGNMENT',
  QuestionType.transform => 'TRANSFORM',
};

enum InteractionStyle {
  quickChoice,
  sentenceSpotlight,
  grammarPaint,
  sentenceSurgery,
  sentenceTransform,
  slotPuzzle,
  sentenceKnockout,
  patternComplete,
  contextApplication,
  tapToBuild,
}

InteractionStyle? interactionStyleFromWire(String? value) => switch (value) {
  null => null,
  'QUICK_CHOICE' => InteractionStyle.quickChoice,
  'SENTENCE_SPOTLIGHT' => InteractionStyle.sentenceSpotlight,
  'GRAMMAR_PAINT' => InteractionStyle.grammarPaint,
  'SENTENCE_SURGERY' => InteractionStyle.sentenceSurgery,
  'SENTENCE_TRANSFORM' => InteractionStyle.sentenceTransform,
  'SLOT_PUZZLE' => InteractionStyle.slotPuzzle,
  'SENTENCE_KNOCKOUT' => InteractionStyle.sentenceKnockout,
  'PATTERN_COMPLETE' => InteractionStyle.patternComplete,
  'CONTEXT_APPLICATION' => InteractionStyle.contextApplication,
  'TAP_TO_BUILD' => InteractionStyle.tapToBuild,
  _ => throw FormatException('Unsupported interaction style: $value'),
};

String? interactionStyleToWire(InteractionStyle? value) => switch (value) {
  null => null,
  InteractionStyle.quickChoice => 'QUICK_CHOICE',
  InteractionStyle.sentenceSpotlight => 'SENTENCE_SPOTLIGHT',
  InteractionStyle.grammarPaint => 'GRAMMAR_PAINT',
  InteractionStyle.sentenceSurgery => 'SENTENCE_SURGERY',
  InteractionStyle.sentenceTransform => 'SENTENCE_TRANSFORM',
  InteractionStyle.slotPuzzle => 'SLOT_PUZZLE',
  InteractionStyle.sentenceKnockout => 'SENTENCE_KNOCKOUT',
  InteractionStyle.patternComplete => 'PATTERN_COMPLETE',
  InteractionStyle.contextApplication => 'CONTEXT_APPLICATION',
  InteractionStyle.tapToBuild => 'TAP_TO_BUILD',
};

@JsonSerializable()
class Question {
  const Question({
    required this.id,
    this.questionCode,
    required this.questionType,
    this.interactionStyle,
    required this.questionContent,
    this.options,
    required this.difficulty,
    required this.sortOrder,
  });
  final int id;
  final String? questionCode;
  @JsonKey(fromJson: questionTypeFromWire, toJson: questionTypeToWire)
  final QuestionType questionType;
  @JsonKey(fromJson: interactionStyleFromWire, toJson: interactionStyleToWire)
  final InteractionStyle? interactionStyle;
  final String questionContent;
  final Object? options;
  final int difficulty;
  final int sortOrder;
  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);
  List<QuestionOption> get optionItems {
    final raw = options;
    if (raw is! List) return const [];
    return raw.asMap().entries.map((e) {
      final value = e.value;
      if (value is Map) {
        return QuestionOption(
          id: '${value['id'] ?? e.key}',
          text: '${value['text'] ?? value['label'] ?? ''}',
        );
      }
      return QuestionOption(id: '$value', text: '$value');
    }).toList();
  }

  Map<String, dynamic> get structuredOptions {
    final raw = options;
    return raw is Map ? Map<String, dynamic>.from(raw) : const {};
  }

  List<QuestionOption> items(String field) {
    final raw = structuredOptions[field];
    if (raw is! List) return const [];
    return raw.asMap().entries.map((entry) {
      final value = entry.value;
      if (value is Map) {
        return QuestionOption(
          id: '${value['id'] ?? entry.key}',
          text: '${value['text'] ?? value['label'] ?? ''}',
        );
      }
      return QuestionOption(id: '${entry.key}', text: '$value');
    }).toList();
  }
}

class QuestionOption {
  const QuestionOption({required this.id, required this.text});
  final String id;
  final String text;
}

@JsonSerializable()
class SubmitAnswerResult {
  const SubmitAnswerResult({
    required this.questionId,
    required this.correct,
    this.correctAnswer,
    this.explanation,
    required this.xpEarned,
    required this.grammarPointMastery,
  });
  final int questionId;
  final bool correct;
  final Object? correctAnswer;
  final String? explanation;
  final int xpEarned;
  final int grammarPointMastery;
  factory SubmitAnswerResult.fromJson(Map<String, dynamic> json) =>
      _$SubmitAnswerResultFromJson(json);
  Map<String, dynamic> toJson() => _$SubmitAnswerResultToJson(this);
}

@JsonSerializable()
class LessonCompletion {
  const LessonCompletion({
    required this.lessonId,
    required this.status,
    required this.totalCount,
    required this.correctCount,
    required this.score,
    required this.xpEarned,
    this.lessonAttemptId,
  });
  final int lessonId;
  final int? lessonAttemptId;
  final String status;
  final int totalCount;
  final int correctCount;
  final int score;
  final int xpEarned;
  factory LessonCompletion.fromJson(Map<String, dynamic> json) =>
      _$LessonCompletionFromJson(json);
  Map<String, dynamic> toJson() => _$LessonCompletionToJson(this);
}

Map<String, dynamic> answerRequest(
  QuestionType type,
  Object answer,
  int durationMs,
) {
  final normalized = switch (type) {
    QuestionType.singleChoice => {'optionId': answer},
    QuestionType.multipleChoice => {'optionIds': answer},
    QuestionType.sentenceOrder => {'tokens': answer},
    QuestionType.tokenSelect ||
    QuestionType.tokenLabel ||
    QuestionType.slotAssignment ||
    QuestionType.transform => answer,
    _ => answer,
  };
  return {'answer': normalized, 'durationMs': durationMs};
}
