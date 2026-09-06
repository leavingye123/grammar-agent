import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/domain/auth_models.dart';

abstract interface class TokenStorage {
  Future<void> saveTokens(TokenPair tokens);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
}

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();
  static const _accessKey = 'grammar_agent_access_token';
  static const _refreshKey = 'grammar_agent_refresh_token';
  final FlutterSecureStorage _storage;
  @override
  Future<void> saveTokens(TokenPair tokens) async {
    await _storage.write(key: _accessKey, value: tokens.accessToken);
    await _storage.write(key: _refreshKey, value: tokens.refreshToken);
  }

  @override
  Future<String?> getAccessToken() => _storage.read(key: _accessKey);
  @override
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);
  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}

class MemoryTokenStorage implements TokenStorage {
  String? accessToken;
  String? refreshToken;
  @override
  Future<void> saveTokens(TokenPair tokens) async {
    accessToken = tokens.accessToken;
    refreshToken = tokens.refreshToken;
  }

  @override
  Future<String?> getAccessToken() async => accessToken;
  @override
  Future<String?> getRefreshToken() async => refreshToken;
  @override
  Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
  }
}
