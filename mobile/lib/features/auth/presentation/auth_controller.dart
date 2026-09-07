import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/network/learning_refresh.dart';
import '../data/auth_repository.dart';
import '../domain/auth_models.dart';

enum AuthStatus { bootstrapping, unauthenticated, authenticated }

class AuthState {
  const AuthState(this.status, {this.user, this.loading = false, this.error});
  final AuthStatus status;
  final UserProfile? user;
  final bool loading;
  final String? error;
  AuthState copyWith({
    AuthStatus? status,
    UserProfile? user,
    bool? loading,
    String? error,
    bool clearError = false,
  }) => AuthState(
    status ?? this.status,
    user: user ?? this.user,
    loading: loading ?? this.loading,
    error: clearError ? null : error ?? this.error,
  );
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => RemoteAuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStorageProvider),
  ),
);

final authProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  late AuthRepository _repository;
  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    Future.microtask(bootstrap);
    return const AuthState(AuthStatus.bootstrapping);
  }

  Future<void> bootstrap() async {
    try {
      final user = await _repository.restore();
      state = user == null
          ? const AuthState(AuthStatus.unauthenticated)
          : AuthState(AuthStatus.authenticated, user: user);
    } catch (_) {
      await ref.read(tokenStorageProvider).clearTokens();
      state = const AuthState(AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) =>
      _run(() => _repository.login(email, password));
  Future<bool> register(String email, String username, String password) =>
      _run(() => _repository.register(email, username, password));

  Future<bool> _run(Future<UserProfile> Function() action) async {
    if (state.loading) return false;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final user = await action();
      refreshLearningData(ref);
      state = AuthState(AuthStatus.authenticated, user: user);
      return true;
    } catch (error) {
      state = AuthState(AuthStatus.unauthenticated, error: error.toString());
      return false;
    }
  }

  Future<void> logout() async {
    if (state.loading) return;
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _repository.logout();
    } catch (_) {
      await ref.read(tokenStorageProvider).clearTokens();
    }
    state = const AuthState(AuthStatus.unauthenticated);
    refreshLearningData(ref);
  }

  void expireSession() => state = const AuthState(
    AuthStatus.unauthenticated,
    error: '登录已过期，请重新登录。',
  );
}
