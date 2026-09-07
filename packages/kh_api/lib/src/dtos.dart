import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

/// Wire maps for Customer config (CM-S06).
/// Prefer `kh_domain` `fromJson` once CM-S04 exports `PlatformConfig`,
/// `GoldRate`, and `Settings`. `MeUser` / `MeUser.customer` come from domain
/// (CM-S01).

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

class PlatformConfig {
  const PlatformConfig({
    required this.requestLifetimeHours,
    required this.offerValidityHours,
    required this.defaultOfferValidityHours,
    required this.bullionMinimumAed,
    required this.maxConcurrentLiveRequests,
    required this.maxRequestImages,
    required this.maxOfferImages,
    required this.maxImageBytes,
    required this.acceptedImageTypes,
    required this.karatList,
    required this.maxOfferRevisions,
    required this.requestExpiryWarningHours,
    this.termsUrl,
    this.privacyUrl,
    this.supportContactUrl,
    this.subscriptionContactUrl,
  });

  final int requestLifetimeHours;
  final List<int> offerValidityHours;
  final int defaultOfferValidityHours;
  final String bullionMinimumAed;
  final int maxConcurrentLiveRequests;
  final int maxRequestImages;
  final int maxOfferImages;
  final int maxImageBytes;
  final List<String> acceptedImageTypes;
  final List<String> karatList;
  final int maxOfferRevisions;
  final int requestExpiryWarningHours;
  final String? termsUrl;
  final String? privacyUrl;
  final String? supportContactUrl;
  final String? subscriptionContactUrl;

  static PlatformConfig fromJson(Map<String, dynamic> j) => PlatformConfig(
        requestLifetimeHours: j['requestLifetimeHours'] as int? ?? 48,
        offerValidityHours: ((j['offerValidityHours'] as List?) ?? const [])
            .map((e) => (e as num).toInt())
            .toList(growable: false),
        defaultOfferValidityHours: j['defaultOfferValidityHours'] as int? ?? 24,
        bullionMinimumAed: j['bullionMinimumAed'] as String? ?? '500.00',
        maxConcurrentLiveRequests: j['maxConcurrentLiveRequests'] as int? ?? 10,
        maxRequestImages: j['maxRequestImages'] as int? ?? 5,
        maxOfferImages: j['maxOfferImages'] as int? ?? 3,
        maxImageBytes: j['maxImageBytes'] as int? ?? 0,
        acceptedImageTypes: _stringList(j['acceptedImageTypes']),
        karatList: _stringList(j['karatList']),
        maxOfferRevisions: j['maxOfferRevisions'] as int? ?? 3,
        requestExpiryWarningHours: j['requestExpiryWarningHours'] as int? ?? 6,
        termsUrl: j['termsUrl'] as String?,
        privacyUrl: j['privacyUrl'] as String?,
        supportContactUrl: j['supportContactUrl'] as String?,
        subscriptionContactUrl: j['subscriptionContactUrl'] as String?,
      );
}

class GoldRate {
  const GoldRate({
    required this.available,
    required this.stale,
    this.source,
    this.sourceTimestamp,
    this.ingestedAt,
    this.staleAfter,
    this.rates = const [],
    this.disclaimer,
    this.reason,
  });

  final bool available;
  final bool stale;
  final String? source;
  final DateTime? sourceTimestamp;
  final DateTime? ingestedAt;
  final DateTime? staleAfter;
  final List<GoldRateQuote> rates;
  final String? disclaimer;
  final String? reason;

  static GoldRate fromJson(Map<String, dynamic> j) => GoldRate(
        available: j['available'] as bool? ?? false,
        stale: j['stale'] as bool? ?? false,
        source: j['source'] as String?,
        sourceTimestamp: _parseTime(j['sourceTimestamp']),
        ingestedAt: _parseTime(j['ingestedAt']),
        staleAfter: _parseTime(j['staleAfter']),
        rates: ((j['rates'] as List?) ?? const [])
            .map((e) => GoldRateQuote.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        disclaimer: j['disclaimer'] as String?,
        reason: j['reason'] as String?,
      );
}

class GoldRateQuote {
  const GoldRateQuote({required this.karat, required this.ratePerGramAed});

  final String karat;
  final String ratePerGramAed;

  static GoldRateQuote fromJson(Map<String, dynamic> j) => GoldRateQuote(
        karat: j['karat'] as String,
        ratePerGramAed: j['ratePerGramAed'] as String,
      );
}

class Settings {
  const Settings({
    required this.preferredLanguage,
    this.defaultRegionId,
    this.quietHours,
    this.defaultFilterPresetId,
    this.notifications = const {},
  });

  final String preferredLanguage;
  final String? defaultRegionId;
  final QuietHours? quietHours;
  final String? defaultFilterPresetId;
  final Map<String, NotificationPref> notifications;

  static Settings fromJson(Map<String, dynamic> j) {
    final raw = (j['notifications'] as Map?) ?? const {};
    return Settings(
      preferredLanguage: j['preferredLanguage'] as String? ?? 'en',
      defaultRegionId: j['defaultRegionId'] as String?,
      quietHours: j['quietHours'] == null
          ? null
          : QuietHours.fromJson(j['quietHours'] as Map<String, dynamic>),
      defaultFilterPresetId: j['defaultFilterPresetId'] as String?,
      notifications: raw.map(
        (k, v) => MapEntry(
          k.toString(),
          NotificationPref.fromJson((v as Map).cast<String, dynamic>()),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'preferredLanguage': preferredLanguage,
        if (defaultRegionId != null) 'defaultRegionId': defaultRegionId,
        if (quietHours != null) 'quietHours': quietHours!.toJson(),
        if (defaultFilterPresetId != null)
          'defaultFilterPresetId': defaultFilterPresetId,
        if (notifications.isNotEmpty)
          'notifications':
              notifications.map((k, v) => MapEntry(k, v.toJson())),
      };
}

class QuietHours {
  const QuietHours({
    required this.start,
    required this.end,
    this.timezone = 'Asia/Dubai',
  });

  final String start;
  final String end;
  final String timezone;

  static QuietHours fromJson(Map<String, dynamic> j) => QuietHours(
        start: j['start'] as String,
        end: j['end'] as String,
        timezone: j['timezone'] as String? ?? 'Asia/Dubai',
      );

  Map<String, dynamic> toJson() => {
        'start': start,
        'end': end,
        'timezone': timezone,
      };
}

class NotificationPref {
  const NotificationPref({
    required this.inApp,
    required this.push,
    required this.email,
  });

  final bool inApp;
  final bool push;
  final bool email;

  static NotificationPref fromJson(Map<String, dynamic> j) => NotificationPref(
        inApp: j['inApp'] as bool? ?? false,
        push: j['push'] as bool? ?? false,
        email: j['email'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'inApp': inApp,
        'push': push,
        'email': email,
      };
}

List<String> _stringList(Object? value) => ((value as List?) ?? const [])
    .map((e) => e.toString())
    .toList(growable: false);

DateTime? _parseTime(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
