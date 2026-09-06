import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/auth_models.dart';

abstract interface class AuthRepository {
  Future<UserProfile?> restore();
  Future<UserProfile> login(String email, String password);
  Future<UserProfile> register(String email, String username, String password);
  Future<void> logout();
}

class RemoteAuthRepository implements AuthRepository {
  const RemoteAuthRepository(this.client, this.storage);
  final ApiClient client;
  final TokenStorage storage;

  @override
  Future<UserProfile?> restore() async {
    final token = await storage.getAccessToken();
    if (token == null || token.isEmpty) return null;
    return client.get(
      ApiEndpoints.me,
      (j) => UserProfile.fromJson(Map<String, dynamic>.from(j! as Map)),
    );
  }

  Future<UserProfile> _authenticate(
    String path,
    Map<String, dynamic> body,
  ) async {
    final auth = await client.post(
      path,
      (j) => AuthResponseData.fromJson(Map<String, dynamic>.from(j! as Map)),
      data: body,
    );
    await storage.saveTokens(auth.tokens);
    return auth.user;
  }

  @override
  Future<UserProfile> login(String email, String password) => _authenticate(
    ApiEndpoints.login,
    {'email': email.trim(), 'password': password},
  );
  @override
  Future<UserProfile> register(
    String email,
    String username,
    String password,
  ) => _authenticate(ApiEndpoints.register, {
    'email': email.trim(),
    'username': username.trim(),
    'password': password,
  });
  @override
  Future<void> logout() async {
    final refresh = await storage.getRefreshToken();
    try {
      if (refresh != null) {
        await client.post<void>(
          ApiEndpoints.logout,
          (_) {},
          data: {'refreshToken': refresh},
        );
      }
    } finally {
      await storage.clearTokens();
    }
  }
}
