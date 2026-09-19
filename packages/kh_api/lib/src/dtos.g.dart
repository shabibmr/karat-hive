// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OtpChallenge _$OtpChallengeFromJson(Map<String, dynamic> json) =>
    _OtpChallenge(
      challengeId: json['challengeId'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$OtpChallengeToJson(_OtpChallenge instance) =>
    <String, dynamic>{
      'challengeId': instance.challengeId,
      'expiresAt': instance.expiresAt.toIso8601String(),
    };

_SessionBundle _$SessionBundleFromJson(Map<String, dynamic> json) =>
    _SessionBundle(
      tokens: _sessionTokensFromJson(json['tokens'] as Map<String, dynamic>),
      user: _meUserFromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SessionBundleToJson(_SessionBundle instance) =>
    <String, dynamic>{
      'tokens': _sessionTokensToJson(instance.tokens),
      'user': _meUserToJson(instance.user),
    };

_OtpVerifyResult _$OtpVerifyResultFromJson(Map<String, dynamic> json) =>
    _OtpVerifyResult(
      mobileVerified: json['mobileVerified'] as bool? ?? false,
      challengeId: json['challengeId'] as String?,
      session: json['session'] == null
          ? null
          : SessionBundle.fromJson(json['session'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OtpVerifyResultToJson(_OtpVerifyResult instance) =>
    <String, dynamic>{
      'mobileVerified': instance.mobileVerified,
      'challengeId': instance.challengeId,
      'session': instance.session,
    };

_UploadIntent _$UploadIntentFromJson(Map<String, dynamic> json) =>
    _UploadIntent(
      key: json['key'] as String,
      uploadUrl: json['uploadUrl'] as String,
      requiredHeaders:
          (json['requiredHeaders'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
      maxBytes: (json['maxBytes'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$UploadIntentToJson(_UploadIntent instance) =>
    <String, dynamic>{
      'key': instance.key,
      'uploadUrl': instance.uploadUrl,
      'requiredHeaders': instance.requiredHeaders,
      'maxBytes': instance.maxBytes,
    };

_AuthSessionDto _$AuthSessionDtoFromJson(Map<String, dynamic> json) =>
    _AuthSessionDto(
      id: json['id'] as String,
      deviceLabel: json['deviceLabel'] as String?,
      lastIp: json['lastIp'] as String?,
      lastUsedAt: DateTime.parse(json['lastUsedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isCurrent: json['isCurrent'] as bool? ?? false,
    );

Map<String, dynamic> _$AuthSessionDtoToJson(_AuthSessionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deviceLabel': instance.deviceLabel,
      'lastIp': instance.lastIp,
      'lastUsedAt': instance.lastUsedAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'isCurrent': instance.isCurrent,
    };
