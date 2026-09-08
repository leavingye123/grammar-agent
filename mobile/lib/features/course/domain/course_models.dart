import 'package:json_annotation/json_annotation.dart';

part 'course_models.g.dart';

@JsonSerializable()
class LanguageModel {
  const LanguageModel({
    required this.id,
    required this.code,
    required this.name,
    required this.nativeName,
  });
  final int id;
  final String code;
  final String name;
  final String nativeName;
  factory LanguageModel.fromJson(Map<String, dynamic> json) =>
      _$LanguageModelFromJson(json);
  Map<String, dynamic> toJson() => _$LanguageModelToJson(this);
}

@JsonSerializable()
class LessonSummary {
  const LessonSummary({
    required this.id,
    required this.title,
    this.description,
    required this.lessonType,
    required this.xpReward,
    required this.sortOrder,
    this.status,
  });
  final int id;
  final String title;
  final String? description;
  final String lessonType;
  final int xpReward;
  final int sortOrder;
  final String? status;
  factory LessonSummary.fromJson(Map<String, dynamic> json) =>
      _$LessonSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$LessonSummaryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GrammarPointSummary {
  const GrammarPointSummary({
    required this.id,
    required this.code,
    required this.title,
    required this.difficulty,
    required this.sortOrder,
    this.prerequisiteCodes = const [],
    required this.lessons,
    this.masteryScore,
    this.completedLessons,
    this.totalLessons,
    this.status,
  });
  final int id;
  final String code;
  final String title;
  final int difficulty;
  final int sortOrder;
  @JsonKey(defaultValue: <String>[])
  final List<String> prerequisiteCodes;
  final List<LessonSummary> lessons;
  final int? masteryScore;
  final int? completedLessons;
  final int? totalLessons;
  final String? status;
  factory GrammarPointSummary.fromJson(Map<String, dynamic> json) =>
      _$GrammarPointSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$GrammarPointSummaryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ChapterModel {
  const ChapterModel({
    required this.id,
    required this.title,
    required this.sortOrder,
    required this.grammarPoints,
  });
  final int id;
  final String title;
  final int sortOrder;
  final List<GrammarPointSummary> grammarPoints;
  factory ChapterModel.fromJson(Map<String, dynamic> json) =>
      _$ChapterModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChapterModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LevelModel {
  const LevelModel({
    required this.id,
    required this.code,
    required this.name,
    required this.sortOrder,
    required this.chapters,
  });
  final int id;
  final String code;
  final String name;
  final int sortOrder;
  final List<ChapterModel> chapters;
  factory LevelModel.fromJson(Map<String, dynamic> json) =>
      _$LevelModelFromJson(json);
  Map<String, dynamic> toJson() => _$LevelModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LearningPath {
  const LearningPath({required this.language, required this.levels});
  final LanguageModel language;
  final List<LevelModel> levels;
  factory LearningPath.fromJson(Map<String, dynamic> json) =>
      _$LearningPathFromJson(json);
  Map<String, dynamic> toJson() => _$LearningPathToJson(this);
}

@JsonSerializable()
class Prerequisite {
  const Prerequisite({
    required this.id,
    required this.code,
    required this.title,
  });
  final int id;
  final String code;
  final String title;
  factory Prerequisite.fromJson(Map<String, dynamic> json) =>
      _$PrerequisiteFromJson(json);
  Map<String, dynamic> toJson() => _$PrerequisiteToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GrammarPointDetail {
  const GrammarPointDetail({
    required this.id,
    required this.chapterId,
    required this.code,
    required this.title,
    this.description,
    this.grammarRule,
    this.examples,
    this.commonErrors,
    required this.difficulty,
    required this.sortOrder,
    required this.prerequisites,
  });
  final int id;
  final int chapterId;
  final String code;
  final String title;
  final String? description;
  final String? grammarRule;
  final Object? examples;
  final Object? commonErrors;
  final int difficulty;
  final int sortOrder;
  final List<Prerequisite> prerequisites;
  factory GrammarPointDetail.fromJson(Map<String, dynamic> json) =>
      _$GrammarPointDetailFromJson(json);
  Map<String, dynamic> toJson() => _$GrammarPointDetailToJson(this);
}

@JsonSerializable()
class LessonDetail {
  const LessonDetail({
    required this.id,
    required this.grammarPointId,
    required this.title,
    this.description,
    required this.lessonType,
    required this.xpReward,
    required this.sortOrder,
  });
  final int id;
  final int grammarPointId;
  final String title;
  final String? description;
  final String lessonType;
  final int xpReward;
  final int sortOrder;
  factory LessonDetail.fromJson(Map<String, dynamic> json) =>
      _$LessonDetailFromJson(json);
  Map<String, dynamic> toJson() => _$LessonDetailToJson(this);
}
