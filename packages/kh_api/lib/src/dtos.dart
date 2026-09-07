import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

/// Auth/session/upload wire maps. Config, rates, and settings live in
/// `kh_domain` (`PlatformConfig`, `GoldRateSnapshot`, `UserSettings`).

class OtpChallenge {
  const OtpChallenge({required this.challengeId, required this.expiresAt});
  final String challengeId;
  final DateTime expiresAt;

  static OtpChallenge fromJson(Map<String, dynamic> j) => OtpChallenge(
        challengeId: j['challengeId'] as String,
        expiresAt: DateTime.parse(j['expiresAt'] as String),
      );
}

class OtpVerifyResult {
  const OtpVerifyResult({this.mobileVerified = false, this.challengeId, this.session});
  final bool mobileVerified;
  final String? challengeId;
  final SessionBundle? session;

  static OtpVerifyResult fromJson(Map<String, dynamic> j) {
    if (j['accessToken'] != null) {
      return OtpVerifyResult(session: SessionBundle.fromJson(j));
    }
    return OtpVerifyResult(
      mobileVerified: j['mobileVerified'] as bool? ?? false,
      challengeId: j['challengeId'] as String?,
    );
  }
}

class SessionBundle {
  const SessionBundle({required this.tokens, required this.user});
  final SessionTokens tokens;
  final MeUser user;

  static SessionBundle fromJson(Map<String, dynamic> j) => SessionBundle(
        tokens: SessionTokens(
          accessToken: j['accessToken'] as String,
          refreshToken: j['refreshToken'] as String,
          accessExpiresAt: DateTime.parse(j['accessExpiresAt'] as String),
          refreshExpiresAt: DateTime.parse(j['refreshExpiresAt'] as String),
        ),
        user: MeUser.fromJson(j['user'] as Map<String, dynamic>),
      );
}

class UploadIntent {
  const UploadIntent({
    required this.key,
    required this.uploadUrl,
    required this.requiredHeaders,
    required this.maxBytes,
  });
  final String key;
  final String uploadUrl;
  final Map<String, String> requiredHeaders;
  final int maxBytes;

  static UploadIntent fromJson(Map<String, dynamic> j) => UploadIntent(
        key: j['key'] as String,
        uploadUrl: j['uploadUrl'] as String,
        requiredHeaders: ((j['requiredHeaders'] as Map?) ?? const {})
            .map((k, v) => MapEntry(k.toString(), v.toString())),
        maxBytes: j['maxBytes'] as int? ?? 0,
      );
}
