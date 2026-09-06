import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/auth_screens.dart';
import '../../features/course/presentation/course_screens.dart';
import '../../features/lesson/presentation/lesson_screens.dart';
import '../../features/lesson/domain/lesson_models.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/review/presentation/review_screens.dart';
import 'home_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final path = state.matchedLocation;
      final public = path == '/login' || path == '/register';
      if (auth.status == AuthStatus.bootstrapping) {
        return path == '/splash' ? null : '/splash';
      }
      if (auth.status == AuthStatus.unauthenticated) {
        return public ? null : '/login';
      }
      if (public || path == '/splash' || path == '/home') {
        return '/learning-path';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/home', redirect: (_, _) => '/learning-path'),
      ShellRoute(
        builder: (_, _, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/learning-path',
            builder: (_, _) => const LearningPathScreen(),
          ),
          GoRoute(path: '/review', builder: (_, _) => const ReviewScreen()),
          GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/grammar-point/:id',
        builder: (_, s) =>
            GrammarPointScreen(id: int.parse(s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/lesson/:id',
        builder: (_, s) => LessonScreen(id: int.parse(s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/lesson/:id/result',
        builder: (_, s) => LessonResultScreen(
          lessonId: int.parse(s.pathParameters['id']!),
          completion: s.extra! as LessonCompletion,
        ),
      ),
      GoRoute(
        path: '/review/wrong',
        builder: (_, _) => const WrongQuestionsScreen(),
      ),
    ],
  );
});
