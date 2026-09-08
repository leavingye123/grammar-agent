/// Resolves the single entry point shared by Home and the Grammar Tree.
///
/// A learner who has not started formal practice must see the Micro Lesson
/// first. Once formal progress exists, Continue Learning may resume practice
/// directly. Unready content is never routed into an empty question flow.
String? grammarLearningRoute({
  required int grammarPointId,
  required int lessonId,
  required String? grammarPointStatus,
  required String? lessonStatus,
  required bool hasMicroLesson,
  required bool lessonReady,
  bool relearn = false,
}) {
  if (!lessonReady) return null;

  final hasFormalProgress =
      grammarPointStatus == 'IN_PROGRESS' ||
      grammarPointStatus == 'COMPLETED' ||
      lessonStatus == 'IN_PROGRESS' ||
      lessonStatus == 'COMPLETED';

  if (!relearn && hasFormalProgress) return '/lesson/$lessonId';
  if (!hasMicroLesson) return null;
  return '/grammar-point/$grammarPointId/micro-lesson?lessonId=$lessonId';
}

bool hasFormalLearningProgress({
  required String? grammarPointStatus,
  required String? lessonStatus,
}) =>
    grammarPointStatus == 'IN_PROGRESS' ||
    grammarPointStatus == 'COMPLETED' ||
    lessonStatus == 'IN_PROGRESS' ||
    lessonStatus == 'COMPLETED';
