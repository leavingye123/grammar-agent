import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/lesson_models.dart';

class LessonRepository {
  const LessonRepository(this.client);
  final ApiClient client;
  Future<List<Question>> questions(int lessonId) => client.get(
    ApiEndpoints.lessonQuestions(lessonId),
    (j) => (j! as List)
        .map((e) => Question.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
  );
  Future<SubmitAnswerResult> submit(
    int questionId,
    QuestionType type,
    Object answer,
    int durationMs,
  ) => client.post(
    ApiEndpoints.submitAnswer(questionId),
    (j) => SubmitAnswerResult.fromJson(Map<String, dynamic>.from(j! as Map)),
    data: answerRequest(type, answer, durationMs),
  );
  Future<LessonCompletion> complete(int lessonId) => client.post(
    ApiEndpoints.completeLesson(lessonId),
    (j) => LessonCompletion.fromJson(Map<String, dynamic>.from(j! as Map)),
  );
}
