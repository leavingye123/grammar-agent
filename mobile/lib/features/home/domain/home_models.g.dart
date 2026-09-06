// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dashboard _$DashboardFromJson(Map<String, dynamic> json) => Dashboard(
  user: DashboardUser.fromJson(json['user'] as Map<String, dynamic>),
  continueLearning: json['continueLearning'] == null
      ? null
      : ContinueLearning.fromJson(
          json['continueLearning'] as Map<String, dynamic>,
        ),
  today: DashboardToday.fromJson(json['today'] as Map<String, dynamic>),
  review: DashboardReview.fromJson(json['review'] as Map<String, dynamic>),
  progress: DashboardProgress.fromJson(
    json['progress'] as Map<String, dynamic>,
  ),
  statistics: DashboardStatistics.fromJson(
    json['statistics'] as Map<String, dynamic>,
  ),
  streak: DashboardStreak.fromJson(json['streak'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DashboardToJson(Dashboard instance) => <String, dynamic>{
  'user': instance.user,
  'continueLearning': instance.continueLearning,
  'today': instance.today,
  'review': instance.review,
  'progress': instance.progress,
  'statistics': instance.statistics,
  'streak': instance.streak,
};

DashboardUser _$DashboardUserFromJson(Map<String, dynamic> json) =>
    DashboardUser(
      username: json['username'] as String,
      currentLanguage: json['currentLanguage'] as String,
      currentLevel: json['currentLevel'] as String?,
    );

Map<String, dynamic> _$DashboardUserToJson(DashboardUser instance) =>
    <String, dynamic>{
      'username': instance.username,
      'currentLanguage': instance.currentLanguage,
      'currentLevel': instance.currentLevel,
    };

ContinueLearning _$ContinueLearningFromJson(Map<String, dynamic> json) =>
    ContinueLearning(
      grammarPointId: (json['grammarPointId'] as num).toInt(),
      grammarPointTitle: json['grammarPointTitle'] as String,
      lessonId: (json['lessonId'] as num).toInt(),
      lessonTitle: json['lessonTitle'] as String,
    );

Map<String, dynamic> _$ContinueLearningToJson(ContinueLearning instance) =>
    <String, dynamic>{
      'grammarPointId': instance.grammarPointId,
      'grammarPointTitle': instance.grammarPointTitle,
      'lessonId': instance.lessonId,
      'lessonTitle': instance.lessonTitle,
    };

DashboardToday _$DashboardTodayFromJson(Map<String, dynamic> json) =>
    DashboardToday(
      completedLessons: (json['completedLessons'] as num).toInt(),
      xpEarned: (json['xpEarned'] as num).toInt(),
      goalXp: (json['goalXp'] as num).toInt(),
    );

Map<String, dynamic> _$DashboardTodayToJson(DashboardToday instance) =>
    <String, dynamic>{
      'completedLessons': instance.completedLessons,
      'xpEarned': instance.xpEarned,
      'goalXp': instance.goalXp,
    };

DashboardReview _$DashboardReviewFromJson(Map<String, dynamic> json) =>
    DashboardReview(dueCount: (json['dueCount'] as num).toInt());

Map<String, dynamic> _$DashboardReviewToJson(DashboardReview instance) =>
    <String, dynamic>{'dueCount': instance.dueCount};

DashboardProgress _$DashboardProgressFromJson(Map<String, dynamic> json) =>
    DashboardProgress(
      completedLessons: (json['completedLessons'] as num).toInt(),
      totalLessons: (json['totalLessons'] as num).toInt(),
      averageMastery: (json['averageMastery'] as num).toInt(),
    );

Map<String, dynamic> _$DashboardProgressToJson(DashboardProgress instance) =>
    <String, dynamic>{
      'completedLessons': instance.completedLessons,
      'totalLessons': instance.totalLessons,
      'averageMastery': instance.averageMastery,
    };

DashboardStatistics _$DashboardStatisticsFromJson(Map<String, dynamic> json) =>
    DashboardStatistics(
      totalAnsweredQuestions: (json['totalAnsweredQuestions'] as num).toInt(),
      correctAnswers: (json['correctAnswers'] as num).toInt(),
      accuracy: (json['accuracy'] as num).toInt(),
      totalXp: (json['totalXp'] as num).toInt(),
    );

Map<String, dynamic> _$DashboardStatisticsToJson(
  DashboardStatistics instance,
) => <String, dynamic>{
  'totalAnsweredQuestions': instance.totalAnsweredQuestions,
  'correctAnswers': instance.correctAnswers,
  'accuracy': instance.accuracy,
  'totalXp': instance.totalXp,
};

DashboardStreak _$DashboardStreakFromJson(Map<String, dynamic> json) =>
    DashboardStreak(
      currentStreak: (json['currentStreak'] as num).toInt(),
      maxStreak: (json['maxStreak'] as num).toInt(),
    );

Map<String, dynamic> _$DashboardStreakToJson(DashboardStreak instance) =>
    <String, dynamic>{
      'currentStreak': instance.currentStreak,
      'maxStreak': instance.maxStreak,
    };
