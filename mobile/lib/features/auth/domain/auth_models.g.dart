// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String,
  username: json['username'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  nativeLanguage: json['nativeLanguage'] as String?,
  status: json['status'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
      'nativeLanguage': instance.nativeLanguage,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
    };

TokenPair _$TokenPairFromJson(Map<String, dynamic> json) => TokenPair(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  tokenType: json['tokenType'] as String,
  accessExpiresIn: (json['accessExpiresIn'] as num).toInt(),
  refreshExpiresIn: (json['refreshExpiresIn'] as num).toInt(),
);

Map<String, dynamic> _$TokenPairToJson(TokenPair instance) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'tokenType': instance.tokenType,
  'accessExpiresIn': instance.accessExpiresIn,
  'refreshExpiresIn': instance.refreshExpiresIn,
};

AuthResponseData _$AuthResponseDataFromJson(Map<String, dynamic> json) =>
    AuthResponseData(
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
      tokens: TokenPair.fromJson(json['tokens'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseDataToJson(AuthResponseData instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
      'tokens': instance.tokens.toJson(),
    };
