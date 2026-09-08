import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

export 'dtos/common_dtos.dart';
export 'dtos/request_dtos.dart';
export 'dtos/offer_dtos.dart';
export 'dtos/connection_dtos.dart';
export 'dtos/review_dtos.dart';
export 'dtos/notification_dtos.dart';
export 'dtos/settings_dtos.dart';
export 'dtos/gold_rate_dtos.dart';

part 'dtos.freezed.dart';
part 'dtos.g.dart';

/// Auth/session/upload wire maps. Config, rates, and settings live in
/// `kh_domain` (`PlatformConfig`, `GoldRateSnapshot`, `UserSettings`).

// --- converters for non-freezed nested types ---------------------------------

SessionTokens _sessionTokensFromJson(Map<String, dynamic> json) =>
    SessionTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      accessExpiresAt: DateTime.parse(json['accessExpiresAt'] as String),
      refreshExpiresAt: DateTime.parse(json['refreshExpiresAt'] as String),
    );

Map<String, dynamic> _sessionTokensToJson(SessionTokens tokens) => {
      'accessToken': tokens.accessToken,
      'refreshToken': tokens.refreshToken,
      'accessExpiresAt': tokens.accessExpiresAt.toIso8601String(),
      'refreshExpiresAt': tokens.refreshExpiresAt.toIso8601String(),
    };

MeUser _meUserFromJson(Map<String, dynamic> json) => MeUser.fromJson(json);

Map<String, dynamic> _meUserToJson(MeUser user) => user.toJson();

Map<String, dynamic> _normalizeSessionBundleJson(Map<String, dynamic> json) {
  final tokensJson = json['tokens'] is Map<String, dynamic>
      ? Map<String, dynamic>.from(json['tokens'] as Map<String, dynamic>)
      : <String, dynamic>{
          'accessToken': json['accessToken'],
          'refreshToken': json['refreshToken'],
          'accessExpiresAt': json['accessExpiresAt'],
          'refreshExpiresAt': json['refreshExpiresAt'],
        };
  return {
    'tokens': tokensJson,
    'user': json['user'],
  };
}

Map<String, dynamic> _normalizeUploadIntentJson(Map<String, dynamic> json) {
  return {
    ...json,
    'requiredHeaders': ((json['requiredHeaders'] as Map?) ?? const {})
        .map((k, v) => MapEntry(k.toString(), v.toString())),
    'maxBytes': json['maxBytes'] as int? ?? 0,
  };
}

/// LOGIN purpose returns a flat [SessionBundle]; REGISTER returns an ack object.
Map<String, dynamic> _normalizeOtpVerifyResultJson(Map<String, dynamic> json) {
  if (json['accessToken'] != null) {
    return {
      'mobileVerified': false,
      'challengeId': null,
      'session': _normalizeSessionBundleJson(json),
    };
  }
  return json;
}

// --- DTOs --------------------------------------------------------------------

@freezed
abstract class OtpChallenge with _$OtpChallenge {
  const factory OtpChallenge({
    required String challengeId,
    required DateTime expiresAt,
  }) = _OtpChallenge;

  factory OtpChallenge.fromJson(Map<String, dynamic> json) =>
      _$OtpChallengeFromJson(json);
}

@freezed
abstract class SessionBundle with _$SessionBundle {
  const factory SessionBundle({
    @JsonKey(fromJson: _sessionTokensFromJson, toJson: _sessionTokensToJson)
    required SessionTokens tokens,
    @JsonKey(fromJson: _meUserFromJson, toJson: _meUserToJson)
    required MeUser user,
  }) = _SessionBundle;

  factory SessionBundle.fromJson(Map<String, dynamic> json) =>
      _$SessionBundleFromJson(_normalizeSessionBundleJson(json));
}

/// OTP verify may return either a register-step ack or a full [SessionBundle]
/// (LOGIN purpose). Session payloads are detected by a top-level `accessToken`.
@freezed
abstract class OtpVerifyResult with _$OtpVerifyResult {
  const factory OtpVerifyResult({
    @Default(false) bool mobileVerified,
    String? challengeId,
    SessionBundle? session,
  }) = _OtpVerifyResult;

  factory OtpVerifyResult.fromJson(Map<String, dynamic> json) =>
      _$OtpVerifyResultFromJson(_normalizeOtpVerifyResultJson(json));
}

@freezed
abstract class UploadIntent with _$UploadIntent {
  const factory UploadIntent({
    required String key,
    required String uploadUrl,
    @Default(<String, String>{}) Map<String, String> requiredHeaders,
    @Default(0) int maxBytes,
  }) = _UploadIntent;

  factory UploadIntent.fromJson(Map<String, dynamic> json) =>
      _$UploadIntentFromJson(_normalizeUploadIntentJson(json));
}
