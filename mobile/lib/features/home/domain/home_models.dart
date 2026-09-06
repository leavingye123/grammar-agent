import 'package:json_annotation/json_annotation.dart';

part 'home_models.g.dart';

@JsonSerializable()
class Dashboard {
  const Dashboard({
    required this.user,
    this.continueLearning,
    required this.today,
    required this.review,
    required this.progress,
    required this.statistics,
    required this.streak,
  });
  final DashboardUser user;
  final ContinueLearning? continueLearning;
  final DashboardToday today;
  final DashboardReview review;
  final DashboardProgress progress;
  final DashboardStatistics statistics;
  final DashboardStreak streak;
  factory Dashboard.fromJson(Map<String, dynamic> json) =>
      _$DashboardFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardToJson(this);
}

@JsonSerializable()
class DashboardUser {
  const DashboardUser({
    required this.username,
    required this.currentLanguage,
    required this.currentLevel,
  });
  final String username;
  final String currentLanguage;
  final String? currentLevel;
  factory DashboardUser.fromJson(Map<String, dynamic> json) =>
      _$DashboardUserFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardUserToJson(this);
}

@JsonSerializable()
class ContinueLearning {
  const ContinueLearning({
    required this.grammarPointId,
    required this.grammarPointTitle,
    required this.lessonId,
    required this.lessonTitle,
  });
  final int grammarPointId;
  final String grammarPointTitle;
  final int lessonId;
  final String lessonTitle;
  factory ContinueLearning.fromJson(Map<String, dynamic> json) =>
      _$ContinueLearningFromJson(json);
  Map<String, dynamic> toJson() => _$ContinueLearningToJson(this);
}

@JsonSerializable()
class DashboardToday {
  const DashboardToday({
    required this.completedLessons,
    required this.xpEarned,
    required this.goalXp,
  });
  final int completedLessons;
  final int xpEarned;
  final int goalXp;
  factory DashboardToday.fromJson(Map<String, dynamic> json) =>
      _$DashboardTodayFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardTodayToJson(this);
}

@JsonSerializable()
class DashboardReview {
  const DashboardReview({required this.dueCount});
  final int dueCount;
  factory DashboardReview.fromJson(Map<String, dynamic> json) =>
      _$DashboardReviewFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardReviewToJson(this);
}

@JsonSerializable()
class DashboardProgress {
  const DashboardProgress({
    required this.completedLessons,
    required this.totalLessons,
    required this.averageMastery,
  });
  final int completedLessons;
  final int totalLessons;
  final int averageMastery;
  factory DashboardProgress.fromJson(Map<String, dynamic> json) =>
      _$DashboardProgressFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardProgressToJson(this);
}

@JsonSerializable()
class DashboardStatistics {
  const DashboardStatistics({
    required this.totalAnsweredQuestions,
    required this.correctAnswers,
    required this.accuracy,
    required this.totalXp,
  });
  final int totalAnsweredQuestions;
  final int correctAnswers;
  final int accuracy;
  final int totalXp;
  factory DashboardStatistics.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardStatisticsToJson(this);
}

@JsonSerializable()
class DashboardStreak {
  const DashboardStreak({required this.currentStreak, required this.maxStreak});
  final int currentStreak;
  final int maxStreak;
  factory DashboardStreak.fromJson(Map<String, dynamic> json) =>
      _$DashboardStreakFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardStreakToJson(this);
}
