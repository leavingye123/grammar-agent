import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../data/course_repository.dart';
import '../domain/course_models.dart';

final courseRepositoryProvider = Provider<CourseRepository>(
  (ref) => CourseRepository(ref.watch(apiClientProvider)),
);
final learningPathProvider = FutureProvider<LearningPath>(
  (ref) => ref.watch(courseRepositoryProvider).learningPath(),
);
final grammarPointProvider = FutureProvider.family<GrammarPointDetail, int>(
  (ref, id) => ref.watch(courseRepositoryProvider).grammarPoint(id),
);
final grammarPointLessonsProvider =
    FutureProvider.family<List<LessonSummary>, int>(
      (ref, id) => ref.watch(courseRepositoryProvider).lessons(id),
    );
final lessonProvider = FutureProvider.family<LessonDetail, int>(
  (ref, id) => ref.watch(courseRepositoryProvider).lesson(id),
);
