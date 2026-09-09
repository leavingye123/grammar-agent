import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:grammar_agent/core/network/api_client.dart';
import 'package:grammar_agent/features/course/presentation/course_providers.dart';
import 'package:grammar_agent/features/home/presentation/home_providers.dart';
import 'package:grammar_agent/features/lesson/domain/lesson_models.dart';
import 'package:grammar_agent/features/lesson/presentation/lesson_screens.dart';
import 'package:grammar_agent/features/tutor/data/tutor_repository.dart';
import 'package:grammar_agent/features/tutor/presentation/tutor_sheet.dart';

import 'widget_test.dart' as fixtures;

void main() {
  for (final scenario in [
    (perfect: true, available: true),
    (perfect: false, available: true),
    (perfect: false, available: false),
  ]) {
    testWidgets(
      'Result summary: perfect=${scenario.perfect}, AI=${scenario.available}',
      (tester) async {
        final adapter = _ResultAdapter(scenario.perfect, scenario.available);
        final dio = Dio(BaseOptions(baseUrl: 'http://localhost:18080'))
          ..httpClientAdapter = adapter;
        addTearDown(() => dio.close());
        final completion = LessonCompletion.fromJson({
          'lessonId': 1,
          'lessonAttemptId': 99,
          'status': 'COMPLETED',
          'totalCount': 5,
          'correctCount': scenario.perfect ? 5 : 4,
          'score': scenario.perfect ? 100 : 80,
          'xpEarned': 8,
        });
        final router = GoRouter(
          initialLocation: '/result',
          routes: [
            GoRoute(
              path: '/result',
              builder: (_, _) =>
                  LessonResultScreen(lessonId: 1, completion: completion),
            ),
            GoRoute(
              path: '/learning-path',
              builder: (_, _) => const Scaffold(body: Text('已返回语法树')),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              myLearningPathProvider.overrideWith(
                (_) async => fixtures.samplePath,
              ),
              dashboardProvider.overrideWith(
                (_) async => fixtures.sampleDashboard,
              ),
              tutorRepositoryProvider.overrideWithValue(
                TutorRepository(ApiClient(dio)),
              ),
            ],
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();
        expect(adapter.requests, isEmpty);
        await tester.scrollUntilVisible(
          find.text('帮我总结这次练习'),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(find.text('帮我总结这次练习'));
        await tester.pumpAndSettle();
        expect(
          adapter.requests,
          isEmpty,
        ); // Rendering/scrolling never requests AI.
        if (scenario.perfect) {
          expect(find.textContaining('这次全部答对了。'), findsOneWidget);
        }
        await tester.tap(find.text('帮我总结这次练习'));
        await tester.pumpAndSettle();
        expect(find.byType(GrammarTutorSheet), findsOneWidget);
        expect(adapter.requests.first.queryParameters['lessonAttemptId'], 99);
        expect(adapter.requests.first.queryParameters['scene'], 'result');
        final chats = adapter.requests
            .where((r) => r.path.endsWith('/chat'))
            .toList();
        if (scenario.available) {
          expect(chats, hasLength(1));
          final data = chats.single.data as Map;
          expect(
            data.keys,
            unorderedEquals(['lessonAttemptId', 'message', 'history']),
          );
          expect(data['lessonAttemptId'], 99);
          expect(data['message'], '帮我总结这次练习');
          expect(find.textContaining('Grammar Cat：本次总结'), findsOneWidget);
          expect(
            find.text('我这次主要错在哪里？'),
            scenario.perfect ? findsNothing : findsOneWidget,
          );
        } else {
          expect(chats, isEmpty);
          expect(find.text('Grammar Cat AI 暂未开启，你可以继续学习。'), findsOneWidget);
        }
        await tester.tap(find.byTooltip('关闭'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('返回语法树'));
        await tester.tap(find.text('返回语法树'));
        await tester.pumpAndSettle();
        expect(find.text('已返回语法树'), findsOneWidget);
        expect(completion.xpEarned, 8);
      },
    );
  }
}

class _ResultAdapter implements HttpClientAdapter {
  _ResultAdapter(this.perfect, this.available);
  final bool perfect;
  final bool available;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({
        'code': 0,
        'message': 'success',
        'data': {
          'available': available,
          'answer': '本次总结',
          'suggestedQuestions': [
            for (final text in [
              perfect ? '帮我总结这次用到的规则' : '我这次主要错在哪里？',
              '这个知识点怎么记？',
              perfect ? '再给我一个简单例子' : '能再解释一下我错的题吗？',
              '接下来应该注意什么？',
            ])
              {'text': text},
          ],
        },
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
