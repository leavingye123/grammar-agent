import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/network_providers.dart';

final tutorRepositoryProvider = Provider<TutorRepository>(
  (ref) => TutorRepository(ref.watch(apiClientProvider)),
);

class TutorMessage {
  const TutorMessage(this.role, this.content);
  final String role;
  final String content;

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

List<String> _questions(Map<String, dynamic> json) =>
    (json['suggestedQuestions'] as List)
        .map((item) => (item as Map)['text'] as String)
        .take(4)
        .toList();

class TutorStatus {
  const TutorStatus(this.available, this.suggestedQuestions);
  final bool available;
  final List<String> suggestedQuestions;

  factory TutorStatus.fromJson(Map<String, dynamic> json) =>
      TutorStatus(json['available'] == true, _questions(json));
}

class TutorReply {
  const TutorReply(this.answer, this.suggestedQuestions);
  final String answer;
  final List<String> suggestedQuestions;

  factory TutorReply.fromJson(Map<String, dynamic> json) =>
      TutorReply(json['answer'] as String, _questions(json));
}

class TutorRepository {
  const TutorRepository(this._api);
  final ApiClient _api;

  Future<TutorStatus> status(String scene, {int? lessonAttemptId}) => _api.get(
    '/api/v1/ai/tutor/status',
    (json) => TutorStatus.fromJson(Map<String, dynamic>.from(json as Map)),
    query: {'scene': scene, 'lessonAttemptId': ?lessonAttemptId},
  );

  Future<TutorReply> chat({
    int? grammarPointId,
    int? lessonAttemptId,
    required String message,
    String? questionCode,
    List<TutorMessage> history = const [],
  }) => _api.post(
    '/api/v1/ai/tutor/chat',
    (json) => TutorReply.fromJson(Map<String, dynamic>.from(json as Map)),
    options: Options(receiveTimeout: const Duration(seconds: 90)),
    data: {
      'grammarPointId': ?grammarPointId,
      'lessonAttemptId': ?lessonAttemptId,
      'message': message,
      'questionCode': ?questionCode,
      'history': history
          .skip(history.length > 8 ? history.length - 8 : 0)
          .map(
            (item) => TutorMessage(
              item.role,
              item.content.length > 2000
                  ? item.content.substring(0, 2000)
                  : item.content,
            ).toJson(),
          )
          .toList(),
    },
  );
}
