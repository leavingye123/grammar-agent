// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LanguageModel _$LanguageModelFromJson(Map<String, dynamic> json) =>
    LanguageModel(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      nativeName: json['nativeName'] as String,
    );

Map<String, dynamic> _$LanguageModelToJson(LanguageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'nativeName': instance.nativeName,
    };

LessonSummary _$LessonSummaryFromJson(Map<String, dynamic> json) =>
    LessonSummary(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      lessonType: json['lessonType'] as String,
      xpReward: (json['xpReward'] as num).toInt(),
      sortOrder: (json['sortOrder'] as num).toInt(),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$LessonSummaryToJson(LessonSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'lessonType': instance.lessonType,
      'xpReward': instance.xpReward,
      'sortOrder': instance.sortOrder,
      'status': instance.status,
    };

GrammarPointSummary _$GrammarPointSummaryFromJson(Map<String, dynamic> json) =>
    GrammarPointSummary(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      title: json['title'] as String,
      difficulty: (json['difficulty'] as num).toInt(),
      sortOrder: (json['sortOrder'] as num).toInt(),
      prerequisiteCodes:
          (json['prerequisiteCodes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      lessons: (json['lessons'] as List<dynamic>)
          .map((e) => LessonSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      masteryScore: (json['masteryScore'] as num?)?.toInt(),
      completedLessons: (json['completedLessons'] as num?)?.toInt(),
      totalLessons: (json['totalLessons'] as num?)?.toInt(),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$GrammarPointSummaryToJson(
  GrammarPointSummary instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'title': instance.title,
  'difficulty': instance.difficulty,
  'sortOrder': instance.sortOrder,
  'prerequisiteCodes': instance.prerequisiteCodes,
  'lessons': instance.lessons.map((e) => e.toJson()).toList(),
  'masteryScore': instance.masteryScore,
  'completedLessons': instance.completedLessons,
  'totalLessons': instance.totalLessons,
  'status': instance.status,
};

ChapterModel _$ChapterModelFromJson(Map<String, dynamic> json) => ChapterModel(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  sortOrder: (json['sortOrder'] as num).toInt(),
  grammarPoints: (json['grammarPoints'] as List<dynamic>)
      .map((e) => GrammarPointSummary.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ChapterModelToJson(ChapterModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'sortOrder': instance.sortOrder,
      'grammarPoints': instance.grammarPoints.map((e) => e.toJson()).toList(),
    };

LevelModel _$LevelModelFromJson(Map<String, dynamic> json) => LevelModel(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  name: json['name'] as String,
  sortOrder: (json['sortOrder'] as num).toInt(),
  chapters: (json['chapters'] as List<dynamic>)
      .map((e) => ChapterModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LevelModelToJson(LevelModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'sortOrder': instance.sortOrder,
      'chapters': instance.chapters.map((e) => e.toJson()).toList(),
    };

LearningPath _$LearningPathFromJson(Map<String, dynamic> json) => LearningPath(
  language: LanguageModel.fromJson(json['language'] as Map<String, dynamic>),
  levels: (json['levels'] as List<dynamic>)
      .map((e) => LevelModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LearningPathToJson(LearningPath instance) =>
    <String, dynamic>{
      'language': instance.language.toJson(),
      'levels': instance.levels.map((e) => e.toJson()).toList(),
    };

Prerequisite _$PrerequisiteFromJson(Map<String, dynamic> json) => Prerequisite(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  title: json['title'] as String,
);

Map<String, dynamic> _$PrerequisiteToJson(Prerequisite instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'title': instance.title,
    };

GrammarPointDetail _$GrammarPointDetailFromJson(Map<String, dynamic> json) =>
    GrammarPointDetail(
      id: (json['id'] as num).toInt(),
      chapterId: (json['chapterId'] as num).toInt(),
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      grammarRule: json['grammarRule'] as String?,
      examples: json['examples'],
      commonErrors: json['commonErrors'],
      difficulty: (json['difficulty'] as num).toInt(),
      sortOrder: (json['sortOrder'] as num).toInt(),
      prerequisites: (json['prerequisites'] as List<dynamic>)
          .map((e) => Prerequisite.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GrammarPointDetailToJson(GrammarPointDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chapterId': instance.chapterId,
      'code': instance.code,
      'title': instance.title,
      'description': instance.description,
      'grammarRule': instance.grammarRule,
      'examples': instance.examples,
      'commonErrors': instance.commonErrors,
      'difficulty': instance.difficulty,
      'sortOrder': instance.sortOrder,
      'prerequisites': instance.prerequisites.map((e) => e.toJson()).toList(),
    };

LessonDetail _$LessonDetailFromJson(Map<String, dynamic> json) => LessonDetail(
  id: (json['id'] as num).toInt(),
  grammarPointId: (json['grammarPointId'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String?,
  lessonType: json['lessonType'] as String,
  xpReward: (json['xpReward'] as num).toInt(),
  sortOrder: (json['sortOrder'] as num).toInt(),
);

Map<String, dynamic> _$LessonDetailToJson(LessonDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'grammarPointId': instance.grammarPointId,
      'title': instance.title,
      'description': instance.description,
      'lessonType': instance.lessonType,
      'xpReward': instance.xpReward,
      'sortOrder': instance.sortOrder,
    };
