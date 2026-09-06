import 'package:json_annotation/json_annotation.dart';

part 'lesson_models.g.dart';

enum QuestionType {
  singleChoice,
  multipleChoice,
  fillBlank,
  sentenceOrder,
  trueFalse,
  correction,
}

QuestionType questionTypeFromWire(String value) => switch (value) {
  'SINGLE_CHOICE' => QuestionType.singleChoice,
  'MULTIPLE_CHOICE' => QuestionType.multipleChoice,
  'FILL_BLANK' => QuestionType.fillBlank,
  'SENTENCE_ORDER' => QuestionType.sentenceOrder,
  'TRUE_FALSE' => QuestionType.trueFalse,
  'CORRECTION' => QuestionType.correction,
  _ => throw FormatException('Unsupported question type: $value'),
};
String questionTypeToWire(QuestionType value) => switch (value) {
  QuestionType.singleChoice => 'SINGLE_CHOICE',
  QuestionType.multipleChoice => 'MULTIPLE_CHOICE',
  QuestionType.fillBlank => 'FILL_BLANK',
  QuestionType.sentenceOrder => 'SENTENCE_ORDER',
  QuestionType.trueFalse => 'TRUE_FALSE',
  QuestionType.correction => 'CORRECTION',
};

@JsonSerializable()
class Question {
  const Question({
    required this.id,
    required this.questionType,
    required this.questionContent,
    this.options,
    required this.difficulty,
    required this.sortOrder,
  });
  final int id;
  @JsonKey(fromJson: questionTypeFromWire, toJson: questionTypeToWire)
  final QuestionType questionType;
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
  });
  final int lessonId;
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
    _ => answer,
  };
  return {'answer': normalized, 'durationMs': durationMs};
}
