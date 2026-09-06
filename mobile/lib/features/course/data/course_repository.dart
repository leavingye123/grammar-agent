import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/course_models.dart';

class CourseRepository {
  const CourseRepository(this.client);
  final ApiClient client;
  Future<LearningPath> learningPath() => client.get(
    ApiEndpoints.learningPath('en'),
    (j) => LearningPath.fromJson(Map<String, dynamic>.from(j! as Map)),
  );
  Future<LearningPath> myLearningPath() => client.get(
    ApiEndpoints.myLearningPath('en'),
    (j) => LearningPath.fromJson(Map<String, dynamic>.from(j! as Map)),
  );
  Future<GrammarPointDetail> grammarPoint(int id) => client.get(
    ApiEndpoints.grammarPoint(id),
    (j) => GrammarPointDetail.fromJson(Map<String, dynamic>.from(j! as Map)),
  );
  Future<List<LessonSummary>> lessons(int id) => client.get(
    ApiEndpoints.grammarPointLessons(id),
    (j) => (j! as List)
        .map((e) => LessonSummary.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
  );
  Future<LessonDetail> lesson(int id) => client.get(
    ApiEndpoints.lesson(id),
    (j) => LessonDetail.fromJson(Map<String, dynamic>.from(j! as Map)),
  );
}
