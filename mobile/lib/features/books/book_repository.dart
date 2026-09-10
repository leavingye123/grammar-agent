import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/network_providers.dart';

final grammarBookRepositoryProvider = Provider<GrammarBookRepository>(
  (ref) => GrammarBookRepository(ref.watch(apiClientProvider)),
);
final grammarBooksProvider = FutureProvider.autoDispose<List<GrammarBook>>(
  (ref) => ref.watch(grammarBookRepositoryProvider).list(),
);
final grammarBookProvider = FutureProvider.autoDispose.family<GrammarBook, int>(
  (ref, id) => ref.watch(grammarBookRepositoryProvider).detail(id),
);

class BookMapping {
  BookMapping(Map<String, dynamic> json)
      : id = (json['grammarPointId'] as num).toInt(),
        title = json['title'] as String,
        code = json['grammarPointCode'] as String,
        approved = json['mappingStatus'] == 'APPROVED';
  final int id;
  final String title;
  final String code;
  final bool approved;
}

class BookSection {
  BookSection(Map<String, dynamic> json)
      : id = (json['id'] as num).toInt(),
        parentId = (json['parentSectionId'] as num?)?.toInt(),
        type = json['sectionType'] as String,
        title = json['title'] as String,
        description = json['description'] as String? ?? '',
        order = (json['orderIndex'] as num).toInt(),
        mappings = (json['mappings'] as List).map((e) => BookMapping(Map<String, dynamic>.from(e as Map))).toList();
  final int id;
  final int? parentId;
  final String type;
  final String title;
  final String description;
  final int order;
  final List<BookMapping> mappings;
}

class GrammarBook {
  GrammarBook(Map<String, dynamic> json)
      : id = (json['id'] as num).toInt(),
        title = json['title'] as String,
        subtitle = json['subtitle'] as String? ?? '',
        language = json['languageCode'] as String,
        authors = json['authors'] as String? ?? '',
        publisher = json['publisher'] as String? ?? '',
        edition = json['edition'] as String? ?? '',
        description = json['description'] as String? ?? '',
        levelMin = json['levelMin'] as String? ?? '',
        levelMax = json['levelMax'] as String? ?? '',
        license = json['licenseCode'] as String,
        licenseUrl = json['licenseUrl'] as String? ?? '',
        attribution = json['attributionText'] as String? ?? '',
        sourceUrl = json['sourceUrl'] as String? ?? '',
        selected = json['selected'] == true,
        studied = ((json['progress'] as Map)['studiedGrammarPoints'] as num).toInt(),
        mapped = ((json['progress'] as Map)['mappedGrammarPoints'] as num).toInt(),
        sections = (json['sections'] as List).map((e) => BookSection(Map<String, dynamic>.from(e as Map))).toList();
  final int id;
  final String title, subtitle, language, authors, publisher, edition, description;
  final String levelMin, levelMax, license, licenseUrl, attribution, sourceUrl;
  final bool selected;
  final int studied, mapped;
  final List<BookSection> sections;
}

class GrammarBookRepository {
  const GrammarBookRepository(this.api);
  final ApiClient api;
  Future<List<GrammarBook>> list() => api.get('/api/v1/grammar-books',
      (json) => (json as List).map((e) => GrammarBook(Map<String, dynamic>.from(e as Map))).toList());
  Future<GrammarBook> detail(int id) => api.get('/api/v1/grammar-books/$id',
      (json) => GrammarBook(Map<String, dynamic>.from(json as Map)));
  Future<void> select(GrammarBook book) async {
    await api.put<void>(
      '/api/v1/users/me/grammar-book-preferences/${Uri.encodeComponent(book.language)}',
      (_) {},
      data: {'grammarBookId': book.id},
    );
  }
}
