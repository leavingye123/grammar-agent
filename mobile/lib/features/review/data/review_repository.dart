import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../lesson/domain/lesson_models.dart';
import '../domain/review_models.dart';

class ReviewRepository {
  const ReviewRepository(this.client);
  final ApiClient client;
  Future<ReviewSummary> summary() => client.get(
    ApiEndpoints.reviewSummary,
    (j) => ReviewSummary.fromJson(Map<String, dynamic>.from(j! as Map)),
  );
  Future<List<ReviewQuestion>> due() => client.get(
    ApiEndpoints.reviewDue,
    (j) => (j! as List)
        .map(
          (e) => ReviewQuestion.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(),
    query: {'limit': 20},
  );
  Future<List<ReviewQuestion>> wrong() => client.get(
    ApiEndpoints.wrongQuestions,
    (j) => (j! as List)
        .map(
          (e) => ReviewQuestion.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(),
    query: {'page': 1, 'size': 20},
  );
  Future<ReviewAnswerResult> submit(
    int questionId,
    QuestionType type,
    Object answer,
    int durationMs,
  ) => client.post(
    ApiEndpoints.reviewAnswer(questionId),
    (j) => ReviewAnswerResult.fromJson(Map<String, dynamic>.from(j! as Map)),
    data: answerRequest(type, answer, durationMs),
  );
}
