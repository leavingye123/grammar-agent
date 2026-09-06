import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../data/home_repository.dart';
import '../domain/home_models.dart';

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepository(ref.watch(apiClientProvider)),
);
final dashboardProvider = FutureProvider<Dashboard>(
  (ref) => ref.watch(homeRepositoryProvider).dashboard(),
);
