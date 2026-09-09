import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/network_providers.dart';
import '../../../core/error/app_exception.dart';
import 'tutor_stream.dart';

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

  Stream<TutorStreamEvent> streamChat({
    int? grammarPointId,
    int? lessonAttemptId,
    required String message,
    String? questionCode,
    List<TutorMessage> history = const [],
    CancelToken? cancelToken,
  }) async* {
    try {
      final response = await _api.dio.post<ResponseBody>(
        '/api/v1/ai/tutor/chat/stream',
        data: _request(grammarPointId, lessonAttemptId, message, questionCode, history),
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(seconds: 90),
          headers: {'Accept': 'text/event-stream, application/json'},
        ),
      );
      if (response.data == null ||
          !(response.headers.value(Headers.contentTypeHeader) ?? '').startsWith('text/event-stream')) {
        throw const AppException('Grammar Cat 响应格式不正确。', code: 50210);
      }
      yield* decodeTutorStream(response.data!.stream.timeout(const Duration(seconds: 90)));
    } on DioException catch (error) {
      // Fallback only for an older backend without the stream route, never after partial output/provider failure.
      if (error.response?.statusCode == 404 || error.response?.statusCode == 405) {
        final body = error.response?.data;
        if (body is ResponseBody) await body.stream.drain<void>();
        if (cancelToken?.isCancelled == true) return;
        final reply = await chat(grammarPointId: grammarPointId, lessonAttemptId: lessonAttemptId,
            message: message, questionCode: questionCode, history: history);
        if (cancelToken?.isCancelled == true) return;
        yield TutorStreamEvent.delta(reply.answer);
        yield TutorStreamEvent.done(reply.suggestedQuestions);
        return;
      }
      if (CancelToken.isCancel(error)) return;
      int? code;
      final body = error.response?.data;
      if (body is ResponseBody) {
        // Consume the small pre-stream ApiResponse safely; never show raw bodies/stack traces.
        try {
          final bytes = <int>[];
          await for (final chunk in body.stream.timeout(const Duration(seconds: 10))) {
            bytes.addAll(chunk);
            if (bytes.length > 16384) break;
          }
          final raw = jsonDecode(utf8.decode(bytes));
          if (raw is Map) code = (raw['code'] as num?)?.toInt();
        } catch (_) { /* Generic safe message below. */ }
      }
      throw AppException(
        error.response?.statusCode == 401 ? '登录已过期，请重新登录。' : 'Grammar Cat 回复失败，请重试。',
        code: code ?? (error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.connectionTimeout ? 50410 : 50210),
      );
    }
  }

  Map<String, dynamic> _request(int? pointId, int? attemptId, String message,
      String? questionCode, List<TutorMessage> history) => {
    'grammarPointId': ?pointId,
    'lessonAttemptId': ?attemptId,
    'message': message,
    'questionCode': ?questionCode,
    'history': history.skip(history.length > 8 ? history.length - 8 : 0).map(
      (item) => TutorMessage(item.role, item.content.length > 2000
          ? item.content.substring(0, 2000) : item.content).toJson(),
    ).toList(),
  };

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
