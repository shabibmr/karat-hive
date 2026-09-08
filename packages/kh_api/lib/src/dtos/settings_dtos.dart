/// `settings.service.ts` `UserSettingsResponse` — `GET /v1/me/settings`
/// (`CUS-S21`).
class UserSettingsDto {
  const UserSettingsDto({
    required this.preferredLanguage,
    this.defaultRegionId,
    this.quietHours,
    this.defaultFilterPresetId,
    this.notifications = const {},
  });

  final String preferredLanguage; // en | ar
  final String? defaultRegionId;
  final QuietHoursDto? quietHours;
  final String? defaultFilterPresetId;
  final Map<String, NotificationChannelPrefsDto> notifications;

  static UserSettingsDto fromJson(Map<String, dynamic> j) => UserSettingsDto(
        preferredLanguage: j['preferredLanguage'] as String? ?? 'en',
        defaultRegionId: j['defaultRegionId'] as String?,
        quietHours: j['quietHours'] == null
            ? null
            : QuietHoursDto.fromJson(j['quietHours'] as Map<String, dynamic>),
        defaultFilterPresetId: j['defaultFilterPresetId'] as String?,
        notifications: ((j['notifications'] as Map?) ?? const {}).map(
          (k, v) => MapEntry(
            k.toString(),
            NotificationChannelPrefsDto.fromJson(v as Map<String, dynamic>),
          ),
        ),
      );
}

class QuietHoursDto {
  const QuietHoursDto({
    required this.start,
    required this.end,
    this.timezone = 'Asia/Dubai',
  });

  final String start;
  final String end;
  final String timezone;

  static QuietHoursDto fromJson(Map<String, dynamic> j) => QuietHoursDto(
        start: j['start'] as String? ?? '',
        end: j['end'] as String? ?? '',
        timezone: j['timezone'] as String? ?? 'Asia/Dubai',
      );

  Map<String, dynamic> toJson() => {'start': start, 'end': end};
}

class NotificationChannelPrefsDto {
  const NotificationChannelPrefsDto({
    this.inApp = true,
    this.push = true,
    this.email = false,
  });

  final bool inApp;
  final bool push;
  final bool email;

  static NotificationChannelPrefsDto fromJson(Map<String, dynamic> j) =>
      NotificationChannelPrefsDto(
        inApp: j['inApp'] as bool? ?? true,
        push: j['push'] as bool? ?? true,
        email: j['email'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() =>
      {'inApp': inApp, 'push': push, 'email': email};
}

/// `PATCH /v1/me/settings` body — mirrors `patchSettingsSchema`.
class UserSettingsPatch {
  const UserSettingsPatch({
    this.preferredLanguage,
    this.defaultRegionId,
    this.clearDefaultRegion = false,
    this.quietHours,
    this.clearQuietHours = false,
    this.notifications,
  });

  final String? preferredLanguage;
  final String? defaultRegionId;
  final bool clearDefaultRegion;
  final QuietHoursDto? quietHours;
  final bool clearQuietHours;
  final Map<String, Map<String, bool>>? notifications;

  Map<String, dynamic> toJson() => {
        if (preferredLanguage != null) 'preferredLanguage': preferredLanguage,
        if (clearDefaultRegion)
          'defaultRegionId': null
        else if (defaultRegionId != null)
          'defaultRegionId': defaultRegionId,
        if (clearQuietHours)
          'quietHours': null
        else if (quietHours != null)
          'quietHours': quietHours!.toJson(),
        if (notifications != null) 'notifications': notifications,
      };
}

/// `settings.service.ts` `PlatformConfigResponse` — `GET /v1/platform-config`.
class PlatformConfigDto {
  const PlatformConfigDto({
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
    required this.termsUrl,
    required this.privacyUrl,
    required this.supportContactUrl,
    required this.subscriptionContactUrl,
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
  final String termsUrl;
  final String privacyUrl;
  final String supportContactUrl;
  final String subscriptionContactUrl;

  static int _i(dynamic v, int d) =>
      v is num ? v.toInt() : int.tryParse('$v') ?? d;

  static PlatformConfigDto fromJson(Map<String, dynamic> j) => PlatformConfigDto(
        requestLifetimeHours: _i(j['requestLifetimeHours'], 48),
        offerValidityHours: ((j['offerValidityHours'] as List?) ?? const [12, 24, 48])
            .map((e) => _i(e, 0))
            .toList(growable: false),
        defaultOfferValidityHours: _i(j['defaultOfferValidityHours'], 24),
        bullionMinimumAed: (j['bullionMinimumAed'] ?? '0').toString(),
        maxConcurrentLiveRequests: _i(j['maxConcurrentLiveRequests'], 10),
        maxRequestImages: _i(j['maxRequestImages'], 5),
        maxOfferImages: _i(j['maxOfferImages'], 3),
        maxImageBytes: _i(j['maxImageBytes'], 5242880),
        acceptedImageTypes: ((j['acceptedImageTypes'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(growable: false),
        karatList: ((j['karatList'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(growable: false),
        maxOfferRevisions: _i(j['maxOfferRevisions'], 3),
        requestExpiryWarningHours: _i(j['requestExpiryWarningHours'], 6),
        termsUrl: j['termsUrl'] as String? ?? '',
        privacyUrl: j['privacyUrl'] as String? ?? '',
        supportContactUrl: j['supportContactUrl'] as String? ?? '',
        subscriptionContactUrl: j['subscriptionContactUrl'] as String? ?? '',
      );
}
