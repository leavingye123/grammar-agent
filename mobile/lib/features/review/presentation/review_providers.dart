import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../data/review_repository.dart';
import '../domain/review_models.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => ReviewRepository(ref.watch(apiClientProvider)),
);
final reviewSummaryProvider = FutureProvider<ReviewSummary>(
  (ref) => ref.watch(reviewRepositoryProvider).summary(),
);
final reviewDueProvider = FutureProvider<List<ReviewQuestion>>(
  (ref) => ref.watch(reviewRepositoryProvider).due(),
);
final wrongQuestionsProvider = FutureProvider<List<ReviewQuestion>>(
  (ref) => ref.watch(reviewRepositoryProvider).wrong(),
);
