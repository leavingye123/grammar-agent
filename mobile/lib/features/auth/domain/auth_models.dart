import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.username,
    this.avatarUrl,
    this.nativeLanguage,
    required this.status,
    required this.createdAt,
  });
  final int id;
  final String email;
  final String username;
  final String? avatarUrl;
  final String? nativeLanguage;
  final String status;
  final DateTime createdAt;
  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}

@JsonSerializable()
class TokenPair {
  const TokenPair({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.accessExpiresIn,
    required this.refreshExpiresIn,
  });
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int accessExpiresIn;
  final int refreshExpiresIn;
  factory TokenPair.fromJson(Map<String, dynamic> json) =>
      _$TokenPairFromJson(json);
  Map<String, dynamic> toJson() => _$TokenPairToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AuthResponseData {
  const AuthResponseData({required this.user, required this.tokens});
  final UserProfile user;
  final TokenPair tokens;
  factory AuthResponseData.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDataFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseDataToJson(this);
}
