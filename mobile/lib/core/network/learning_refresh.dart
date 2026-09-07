import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/course/presentation/course_providers.dart';
import '../../features/home/presentation/home_providers.dart';
import '../../features/review/presentation/review_providers.dart';

/// Invalidate shared read models after a server-confirmed write or account change.
void refreshLearningData(Ref ref) {
  ref.invalidate(dashboardProvider);
  ref.invalidate(myLearningPathProvider);
  ref.invalidate(reviewSummaryProvider);
  ref.invalidate(reviewDueProvider);
  ref.invalidate(wrongQuestionsProvider);
}
