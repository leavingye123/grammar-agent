import 'package:json_annotation/json_annotation.dart';

import '../../lesson/domain/lesson_models.dart';

part 'review_models.g.dart';

@JsonSerializable()
class ReviewSummary {
  const ReviewSummary({
    required this.dueCount,
    required this.unmasteredCount,
    required this.masteredCount,
    this.nextReviewAt,
  });
  final int dueCount;
  final int unmasteredCount;
  final int masteredCount;
  final DateTime? nextReviewAt;
  factory ReviewSummary.fromJson(Map<String, dynamic> json) =>
      _$ReviewSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewSummaryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ReviewQuestion {
  const ReviewQuestion({
    required this.wrongQuestionId,
    required this.question,
    required this.wrongCount,
    required this.lastWrongAt,
    this.nextReviewAt,
  });
  final int wrongQuestionId;
  final Question question;
  final int wrongCount;
  final DateTime lastWrongAt;
  final DateTime? nextReviewAt;
  factory ReviewQuestion.fromJson(Map<String, dynamic> json) =>
      _$ReviewQuestionFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewQuestionToJson(this);
}

@JsonSerializable()
class ReviewAnswerResult {
  const ReviewAnswerResult({
    required this.questionId,
    required this.correct,
    this.correctAnswer,
    this.explanation,
    required this.mastered,
    required this.wrongCount,
    this.nextReviewAt,
    required this.grammarPointMastery,
  });
  final int questionId;
  final bool correct;
  final Object? correctAnswer;
  final String? explanation;
  final bool mastered;
  final int wrongCount;
  final DateTime? nextReviewAt;
  final int grammarPointMastery;
  factory ReviewAnswerResult.fromJson(Map<String, dynamic> json) =>
      _$ReviewAnswerResultFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewAnswerResultToJson(this);
}
