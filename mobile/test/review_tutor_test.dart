import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grammar_agent/core/network/api_client.dart';
import 'package:grammar_agent/features/review/data/review_repository.dart';
import 'package:grammar_agent/features/review/domain/review_models.dart';
import 'package:grammar_agent/features/review/presentation/review_providers.dart';
import 'package:grammar_agent/features/review/presentation/review_screens.dart';
import 'package:grammar_agent/features/tutor/data/tutor_repository.dart';
import 'package:grammar_agent/features/tutor/presentation/tutor_sheet.dart';

void main() {
  for (final scenario in [
    (correct: false, available: true),
    (correct: true, available: true),
    (correct: false, available: false),
  ]) {
    testWidgets(
      'Review Tutor: correct=${scenario.correct}, AI=${scenario.available}',
      (tester) async {
        final adapter = _ReviewAdapter(scenario.correct, scenario.available);
        final dio = Dio(BaseOptions(baseUrl: 'http://localhost:18080'))
          ..httpClientAdapter = adapter;
        addTearDown(() => dio.close());
        final api = ApiClient(dio);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              reviewRepositoryProvider.overrideWithValue(ReviewRepository(api)),
              tutorRepositoryProvider.overrideWithValue(TutorRepository(api)),
            ],
            child: MaterialApp(
              home: ReviewPracticeScreen(
                items: [
                  _question(900, 'A1-016-Q001'),
                  _question(901, 'A1-016-Q002'),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(GrammarTutorButton), findsNothing);
        expect(adapter.requests, isEmpty);

        await tester.tap(find.text(scenario.correct ? 'an' : 'a'));
        await tester.pump();
        await tester.tap(find.text('提交答案'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byType(GrammarTutorButton));
        await tester.pumpAndSettle();
        final button = tester.widget<GrammarTutorButton>(
          find.byType(GrammarTutorButton),
        );
        expect(button.grammarPointId, 16);
        expect(button.questionCode, 'A1-016-Q001');
        expect(button.wrongAnswer, !scenario.correct);
        expect(button.reviewFeedback, isTrue);
        final label = scenario.correct
            ? '还有疑问？问 Grammar Cat'
            : '🐱 还是没弄懂？\n问 Grammar Cat';
        expect(
          find.descendant(
            of: find.byType(GrammarTutorButton),
            matching: find.byType(
              scenario.correct ? TextButton : OutlinedButton,
            ),
          ),
          findsOneWidget,
        );
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(find.byType(GrammarTutorSheet), findsOneWidget);
        expect(
          adapter.requests.last.queryParameters['scene'],
          scenario.correct ? 'answered' : 'wrong',
        );

        if (scenario.available) {
          await tester.enterText(find.byType(TextField), '为什么？');
          await tester.tap(find.text('发送'));
          await tester.pumpAndSettle();
          final request = adapter.requests.last;
          expect(request.path, '/api/v1/ai/tutor/chat');
          expect(
            (request.data as Map).keys,
            unorderedEquals([
              'grammarPointId',
              'questionCode',
              'message',
              'history',
            ]),
          );
          expect((request.data as Map)['grammarPointId'], 16);
          expect((request.data as Map)['questionCode'], 'A1-016-Q001');
          expect((request.data as Map)['history'], isEmpty);
          expect(find.textContaining('Grammar Cat：简单解释'), findsOneWidget);
        } else {
          expect(find.text('Grammar Cat AI 暂未开启，你可以继续学习。'), findsOneWidget);
          expect(
            tester.widget<TextField>(find.byType(TextField)).enabled,
            isFalse,
          );
          expect(
            adapter.requests.where((r) => r.path.endsWith('/chat')),
            isEmpty,
          );
        }

        await tester.tap(find.byTooltip('关闭'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(find.text('继续'), 120);
        await tester.tap(find.text('继续'));
        await tester.pumpAndSettle();
        expect(find.text('复习 2/2'), findsOneWidget);
        expect(find.byType(GrammarTutorButton), findsNothing);
        expect(find.byType(GrammarTutorSheet), findsNothing);
        expect(
          adapter.requests.where((r) => r.path.endsWith('/answer')),
          hasLength(1),
        );
      },
    );
  }
}

ReviewQuestion _question(int id, String code) => ReviewQuestion.fromJson({
  'wrongQuestionId': id,
  'grammarPointId': 16,
  'wrongCount': 2,
  'lastWrongAt': '2026-09-08T00:00:00Z',
  'question': {
    'id': id,
    'questionCode': code,
    'questionType': 'SINGLE_CHOICE',
    'questionContent': 'This is ___ apple.',
    'options': [
      {'id': 'A', 'text': 'a'},
      {'id': 'B', 'text': 'an'},
    ],
    'difficulty': 1,
    'sortOrder': 1,
  },
});

class _ReviewAdapter implements HttpClientAdapter {
  _ReviewAdapter(this.correct, this.available);
  final bool correct;
  final bool available;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final Map<String, dynamic> data;
    if (options.path.endsWith('/answer')) {
      data = {
        'questionId': 900,
        'correct': correct,
        'correctAnswer': {'optionId': 'B'},
        'explanation': '元音音素前用 an。',
        'mastered': correct,
        'wrongCount': correct ? 2 : 3,
        'grammarPointMastery': correct ? 80 : 40,
      };
    } else {
      data = {
        'available': available,
        'answer': '简单解释',
        'suggestedQuestions': [
          for (final text in ['为什么这样用？', '解释简单一点', '给我一个例子', '怎么记？'])
            {'text': text},
        ],
      };
    }
    return ResponseBody.fromString(
      jsonEncode({'code': 0, 'message': 'success', 'data': data}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
