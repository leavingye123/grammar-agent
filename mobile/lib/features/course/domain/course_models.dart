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
    this.questionCount = 0,
    this.contentStatus = 'COMING_SOON',
    this.status,
  });
  final int id;
  final String title;
  final String? description;
  final String lessonType;
  final int xpReward;
  final int sortOrder;
  @JsonKey(defaultValue: 0)
  final int questionCount;
  @JsonKey(defaultValue: 'COMING_SOON')
  final String contentStatus;
  final String? status;
  bool get contentAvailable => contentStatus == 'READY' && questionCount > 0;
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
    this.microLesson,
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
  final MicroLesson? microLesson;
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
    this.questionCount = 0,
    this.contentStatus = 'COMING_SOON',
  });
  final int id;
  final int grammarPointId;
  final String title;
  final String? description;
  final String lessonType;
  final int xpReward;
  final int sortOrder;
  @JsonKey(defaultValue: 0)
  final int questionCount;
  @JsonKey(defaultValue: 'COMING_SOON')
  final String contentStatus;
  bool get contentAvailable => contentStatus == 'READY' && questionCount > 0;
  factory LessonDetail.fromJson(Map<String, dynamic> json) =>
      _$LessonDetailFromJson(json);
  Map<String, dynamic> toJson() => _$LessonDetailToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MicroLesson {
  const MicroLesson({
    required this.learningObjective,
    required this.shortIntroduction,
    required this.coreRule,
    required this.structure,
    required this.examples,
    required this.commonMistakes,
    this.memoryTip,
    required this.quickCheck,
  });
  final String learningObjective;
  final String shortIntroduction;
  final String coreRule;
  final String structure;
  final List<MicroLessonExample> examples;
  final List<MicroLessonMistake> commonMistakes;
  final String? memoryTip;
  final List<MicroQuickCheck> quickCheck;
  factory MicroLesson.fromJson(Map<String, dynamic> json) =>
      _$MicroLessonFromJson(json);
  Map<String, dynamic> toJson() => _$MicroLessonToJson(this);
}

@JsonSerializable()
class MicroLessonExample {
  const MicroLessonExample({required this.sentence, required this.note});
  final String sentence;
  final String note;
  factory MicroLessonExample.fromJson(Map<String, dynamic> json) =>
      _$MicroLessonExampleFromJson(json);
  Map<String, dynamic> toJson() => _$MicroLessonExampleToJson(this);
}

@JsonSerializable()
class MicroLessonMistake {
  const MicroLessonMistake({
    required this.incorrect,
    required this.correct,
    required this.reason,
  });
  final String incorrect;
  final String correct;
  final String reason;
  factory MicroLessonMistake.fromJson(Map<String, dynamic> json) =>
      _$MicroLessonMistakeFromJson(json);
  Map<String, dynamic> toJson() => _$MicroLessonMistakeToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MicroQuickCheck {
  const MicroQuickCheck({
    required this.checkCode,
    required this.prompt,
    required this.options,
    required this.correctOptionId,
    required this.explanation,
  });
  final String checkCode;
  final String prompt;
  final List<MicroQuickCheckOption> options;
  final String correctOptionId;
  final String explanation;
  factory MicroQuickCheck.fromJson(Map<String, dynamic> json) =>
      _$MicroQuickCheckFromJson(json);
  Map<String, dynamic> toJson() => _$MicroQuickCheckToJson(this);
}

@JsonSerializable()
class MicroQuickCheckOption {
  const MicroQuickCheckOption({required this.id, required this.text});
  final String id;
  final String text;
  factory MicroQuickCheckOption.fromJson(Map<String, dynamic> json) =>
      _$MicroQuickCheckOptionFromJson(json);
  Map<String, dynamic> toJson() => _$MicroQuickCheckOptionToJson(this);
}
