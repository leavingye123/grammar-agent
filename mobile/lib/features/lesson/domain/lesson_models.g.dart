// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
  id: (json['id'] as num).toInt(),
  questionCode: json['questionCode'] as String?,
  questionType: questionTypeFromWire(json['questionType'] as String),
  questionContent: json['questionContent'] as String,
  options: json['options'],
  difficulty: (json['difficulty'] as num).toInt(),
  sortOrder: (json['sortOrder'] as num).toInt(),
);

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
  'id': instance.id,
  'questionCode': instance.questionCode,
  'questionType': questionTypeToWire(instance.questionType),
  'questionContent': instance.questionContent,
  'options': instance.options,
  'difficulty': instance.difficulty,
  'sortOrder': instance.sortOrder,
};

SubmitAnswerResult _$SubmitAnswerResultFromJson(Map<String, dynamic> json) =>
    SubmitAnswerResult(
      questionId: (json['questionId'] as num).toInt(),
      correct: json['correct'] as bool,
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'] as String?,
      xpEarned: (json['xpEarned'] as num).toInt(),
      grammarPointMastery: (json['grammarPointMastery'] as num).toInt(),
    );

Map<String, dynamic> _$SubmitAnswerResultToJson(SubmitAnswerResult instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'correct': instance.correct,
      'correctAnswer': instance.correctAnswer,
      'explanation': instance.explanation,
      'xpEarned': instance.xpEarned,
      'grammarPointMastery': instance.grammarPointMastery,
    };

LessonCompletion _$LessonCompletionFromJson(Map<String, dynamic> json) =>
    LessonCompletion(
      lessonAttemptId: (json['lessonAttemptId'] as num?)?.toInt(),
      lessonId: (json['lessonId'] as num).toInt(),
      status: json['status'] as String,
      totalCount: (json['totalCount'] as num).toInt(),
      correctCount: (json['correctCount'] as num).toInt(),
      score: (json['score'] as num).toInt(),
      xpEarned: (json['xpEarned'] as num).toInt(),
    );

Map<String, dynamic> _$LessonCompletionToJson(LessonCompletion instance) =>
    <String, dynamic>{
      'lessonAttemptId': instance.lessonAttemptId,
      'lessonId': instance.lessonId,
      'status': instance.status,
      'totalCount': instance.totalCount,
      'correctCount': instance.correctCount,
      'score': instance.score,
      'xpEarned': instance.xpEarned,
    };
