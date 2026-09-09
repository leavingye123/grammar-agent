// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewSummary _$ReviewSummaryFromJson(Map<String, dynamic> json) =>
    ReviewSummary(
      dueCount: (json['dueCount'] as num).toInt(),
      unmasteredCount: (json['unmasteredCount'] as num).toInt(),
      masteredCount: (json['masteredCount'] as num).toInt(),
      nextReviewAt: json['nextReviewAt'] == null
          ? null
          : DateTime.parse(json['nextReviewAt'] as String),
    );

Map<String, dynamic> _$ReviewSummaryToJson(ReviewSummary instance) =>
    <String, dynamic>{
      'dueCount': instance.dueCount,
      'unmasteredCount': instance.unmasteredCount,
      'masteredCount': instance.masteredCount,
      'nextReviewAt': instance.nextReviewAt?.toIso8601String(),
    };

ReviewQuestion _$ReviewQuestionFromJson(Map<String, dynamic> json) =>
    ReviewQuestion(
      wrongQuestionId: (json['wrongQuestionId'] as num).toInt(),
      grammarPointId: (json['grammarPointId'] as num?)?.toInt(),
      question: Question.fromJson(json['question'] as Map<String, dynamic>),
      wrongCount: (json['wrongCount'] as num).toInt(),
      lastWrongAt: DateTime.parse(json['lastWrongAt'] as String),
      nextReviewAt: json['nextReviewAt'] == null
          ? null
          : DateTime.parse(json['nextReviewAt'] as String),
    );

Map<String, dynamic> _$ReviewQuestionToJson(ReviewQuestion instance) =>
    <String, dynamic>{
      'wrongQuestionId': instance.wrongQuestionId,
      'grammarPointId': instance.grammarPointId,
      'question': instance.question.toJson(),
      'wrongCount': instance.wrongCount,
      'lastWrongAt': instance.lastWrongAt.toIso8601String(),
      'nextReviewAt': instance.nextReviewAt?.toIso8601String(),
    };

ReviewAnswerResult _$ReviewAnswerResultFromJson(Map<String, dynamic> json) =>
    ReviewAnswerResult(
      questionId: (json['questionId'] as num).toInt(),
      correct: json['correct'] as bool,
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'] as String?,
      mastered: json['mastered'] as bool,
      wrongCount: (json['wrongCount'] as num).toInt(),
      nextReviewAt: json['nextReviewAt'] == null
          ? null
          : DateTime.parse(json['nextReviewAt'] as String),
      grammarPointMastery: (json['grammarPointMastery'] as num).toInt(),
    );

Map<String, dynamic> _$ReviewAnswerResultToJson(ReviewAnswerResult instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'correct': instance.correct,
      'correctAnswer': instance.correctAnswer,
      'explanation': instance.explanation,
      'mastered': instance.mastered,
      'wrongCount': instance.wrongCount,
      'nextReviewAt': instance.nextReviewAt?.toIso8601String(),
      'grammarPointMastery': instance.grammarPointMastery,
    };
