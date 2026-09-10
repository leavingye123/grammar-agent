import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:grammar_agent/core/network/api_client.dart';
import 'package:grammar_agent/features/auth/presentation/auth_controller.dart';
import 'package:grammar_agent/features/books/book_repository.dart';
import 'package:grammar_agent/features/books/book_screens.dart';
import 'package:grammar_agent/features/home/presentation/home_providers.dart';
import 'package:grammar_agent/features/profile/presentation/profile_screen.dart';

void main() {
  testWidgets('profile entry opens generic book catalog', (tester) async {
    final backend = _BookBackend();
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))..httpClientAdapter = backend;
    final router = _router('/profile');
    addTearDown(() { router.dispose(); dio.close(); });
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authProvider.overrideWith(_SignedIn.new),
        dashboardProvider.overrideWith((ref) => throw Exception('Dashboard unavailable')),
        grammarBookRepositoryProvider.overrideWithValue(GrammarBookRepository(ApiClient(dio))),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('语法书'), 300);
    await tester.tap(find.text('语法书'));
    await tester.pumpAndSettle();
    expect(find.text('Grammar Books'), findsOneWidget);
    expect(find.byKey(const ValueKey('grammar-book-10')), findsOneWidget);
    expect(find.byKey(const ValueKey('grammar-book-11')), findsOneWidget);
  });

  testWidgets('detail, four pilot units, selection, refresh and reopen use backend state', (tester) async {
    final backend = _BookBackend();
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))..httpClientAdapter = backend;
    final router = _router('/grammar-books');
    addTearDown(() { router.dispose(); dio.close(); });
    await tester.pumpWidget(ProviderScope(
      overrides: [grammarBookRepositoryProvider.overrideWithValue(GrammarBookRepository(ApiClient(dio)))],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('grammar-book-10')));
    await tester.pumpAndSettle();
    expect(find.text('A Digital Workbook for Beginning ESOL'), findsOneWidget);
    for (final title in [
      '4. Be and Subject Pronouns', '5. Be and Questions', '6. Have', '7. Have – Questions and Colors',
    ]) {
      await tester.scrollUntilVisible(find.text(title), 250,
          scrollable: find.byType(Scrollable).last);
      expect(find.text(title), findsOneWidget);
    }
    final review = tester.widget<ListTile>(find.ancestor(
      of: find.text('A1-022 · 对应关系待审核'), matching: find.byType(ListTile),
    ));
    expect(review.onTap, isNull);
    await tester.scrollUntilVisible(find.text('使用这本语法书'), -250,
        scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('使用这本语法书'));
    await tester.pumpAndSettle();
    expect(backend.selectedId, 10);
    expect(find.text('✓ 当前语法书'), findsOneWidget);
    final request = backend.requests.singleWhere((r) => r.method == 'PUT');
    expect(request.path, '/api/v1/users/me/grammar-book-preferences/en');
    expect(request.data, {'grammarBookId': 10});
    router.pop();
    await tester.pumpAndSettle();
    final reads = backend.requests.where((r) => r.path == '/api/v1/grammar-books').length;
    await tester.drag(find.byType(ListView), const Offset(0, 500));
    await tester.pumpAndSettle();
    expect(backend.requests.where((r) => r.path == '/api/v1/grammar-books').length, greaterThan(reads));
    await tester.tap(find.byKey(const ValueKey('grammar-book-10')));
    await tester.pumpAndSettle();
    expect(find.text('✓ 当前语法书'), findsOneWidget);
    expect(backend.requests.where((r) => r.path == '/api/v1/grammar-books/10').length, greaterThanOrEqualTo(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('save failure remains retryable and never claims selected', (tester) async {
    final backend = _BookBackend()..rejectSelection = true;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))..httpClientAdapter = backend;
    addTearDown(() => dio.close());
    await tester.pumpWidget(ProviderScope(
      overrides: [grammarBookRepositoryProvider.overrideWithValue(GrammarBookRepository(ApiClient(dio)))],
      child: const MaterialApp(home: GrammarBookDetailScreen(id: 10)),
    ));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('使用这本语法书'));
    await tester.tap(find.text('使用这本语法书'));
    await tester.pumpAndSettle();
    expect(find.text('暂时无法保存选择，请重试。'), findsOneWidget);
    expect(find.text('✓ 当前语法书'), findsNothing);
    backend.rejectSelection = false;
    await tester.tap(find.text('使用这本语法书'));
    await tester.pumpAndSettle();
    expect(find.text('✓ 当前语法书'), findsOneWidget);
  });

  testWidgets('catalog error retry and empty state preserve navigation', (tester) async {
    final backend = _BookBackend()..failList = true;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'))..httpClientAdapter = backend;
    addTearDown(() => dio.close());
    await tester.pumpWidget(ProviderScope(
      overrides: [grammarBookRepositoryProvider.overrideWithValue(GrammarBookRepository(ApiClient(dio)))],
      child: const MaterialApp(home: GrammarBooksScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('重试'), findsOneWidget);
    backend.failList = false;
    backend.empty = true;
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(find.text('语法书正在准备中'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _SignedIn extends AuthController {
  @override
  AuthState build() => const AuthState(AuthStatus.authenticated);
}

GoRouter _router(String initial) => GoRouter(initialLocation: initial, routes: [
  GoRoute(path: '/profile', builder: (_, _) => const Scaffold(body: ProfileScreen())),
  GoRoute(path: '/grammar-books', builder: (_, _) => const GrammarBooksScreen()),
  GoRoute(path: '/grammar-books/:id', builder: (_, state) =>
      GrammarBookDetailScreen(id: int.parse(state.pathParameters['id']!))),
]);

// Models persistence at the HTTP boundary; no widget/local-storage selected flag.
class _BookBackend implements HttpClientAdapter {
  int? selectedId;
  bool rejectSelection = false, failList = false, empty = false;
  final requests = <RequestOptions>[];
  Map<String, dynamic> book(int id) => {
    'id': id, 'bookCode': 'BOOK-$id', 'languageCode': 'en',
    'title': id == 10 ? 'A Digital Workbook for Beginning ESOL' : 'Another English Book',
    'subtitle': id == 10 ? 'PCC ESOL' : 'Second book',
    'authors': 'Eric Dodson; Davida Jordan; Timothy Krause',
    'publisher': 'Portland Community College', 'edition': 'Online',
    'description': '四个章节试点', 'levelMin': 'Beginning', 'levelMax': 'Intermediate',
    'status': 'AVAILABLE', 'selected': selectedId == id,
    'licenseCode': 'CC-BY-4.0', 'licenseUrl': 'https://creativecommons.org/licenses/by/4.0/',
    'attributionText': 'Original authors · CC BY 4.0 · Changes indicated',
    'sourceUrl': 'https://openoregon.pressbooks.pub/esol23/',
    'progress': {'studiedGrammarPoints': 1, 'mappedGrammarPoints': 4},
    'sections': [
      {'id': 20, 'parentSectionId': null, 'sectionType': 'LEVEL', 'title': 'Beginning', 'orderIndex': 0, 'mappings': []},
      for (final unit in [
        (id: 21, order: 4, title: 'Be and Subject Pronouns'),
        (id: 22, order: 5, title: 'Be and Questions'),
        (id: 23, order: 6, title: 'Have'),
        (id: 24, order: 7, title: 'Have – Questions and Colors'),
      ])
        {
          'id': unit.id, 'parentSectionId': 20, 'sectionType': 'UNIT',
          'title': unit.title, 'orderIndex': unit.order,
          'mappings': unit.order == 6 ? [
            {'grammarPointId': 22, 'grammarPointCode': 'A1-022', 'title': 'Have got',
              'mappingStatus': 'MAPPING_REVIEW_REQUIRED'},
          ] : [],
        },
    ],
  };
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    Object? data;
    int code = 0, status = 200;
    if (options.method == 'PUT') {
      if (rejectSelection) {
        code = 40001; // HTTP 200 still requires envelope validation.
      } else {
        selectedId = (options.data as Map)['grammarBookId'] as int;
        data = {'languageCode': 'en', 'grammarBookId': selectedId};
      }
    } else if (options.path == '/api/v1/grammar-books') {
      if (failList) { code = 50000; status = 503; }
      data = empty ? [] : [book(10), book(11)];
    } else {
      data = book(int.parse(options.path.split('/').last));
    }
    return ResponseBody.fromString(jsonEncode({'code': code, 'message': code == 0 ? 'success' : 'Unavailable', 'data': data}),
      status, headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
  }
  @override
  void close({bool force = false}) {}
}
