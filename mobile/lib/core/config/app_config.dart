import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();
  static const _definedUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_definedUrl.isNotEmpty) return _definedUrl;
    if (kIsWeb) return 'http://localhost:18080';
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:18080'
        : 'http://localhost:18080';
  }
}
