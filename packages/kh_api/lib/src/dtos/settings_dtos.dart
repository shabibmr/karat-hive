import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_dtos.freezed.dart';
part 'settings_dtos.g.dart';

Map<String, dynamic> _normalizeUserSettingsJson(Map<String, dynamic> json) => {
  ...json,
  'preferredLanguage': json['preferredLanguage'] as String? ?? 'en',
  'notifications': ((json['notifications'] as Map?) ?? const {}).map(
    (k, v) => MapEntry(k.toString(), v),
  ),
};

/// `settings.service.ts` `UserSettingsResponse` — `GET /v1/me/settings`
/// (`CUS-S21`).
@freezed
abstract class UserSettingsDto with _$UserSettingsDto {
  const factory UserSettingsDto({
    required String preferredLanguage, // en | ar
    String? defaultRegionId,
    QuietHoursDto? quietHours,
    String? defaultFilterPresetId,
    @Default(<String, NotificationChannelPrefsDto>{})
    Map<String, NotificationChannelPrefsDto> notifications,
  }) = _UserSettingsDto;

  factory UserSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsDtoFromJson(_normalizeUserSettingsJson(json));
}

Map<String, dynamic> _normalizeQuietHoursJson(Map<String, dynamic> json) => {
  'start': json['start'] as String? ?? '',
  'end': json['end'] as String? ?? '',
  'timezone': json['timezone'] as String? ?? 'Asia/Dubai',
};

@freezed
abstract class QuietHoursDto with _$QuietHoursDto {
  const factory QuietHoursDto({
    required String start,
    required String end,
    // Never sent back to the server — outbound payloads are start/end only.
    @Default('Asia/Dubai') @JsonKey(includeToJson: false) String timezone,
  }) = _QuietHoursDto;

  factory QuietHoursDto.fromJson(Map<String, dynamic> json) =>
      _$QuietHoursDtoFromJson(_normalizeQuietHoursJson(json));
}

@freezed
abstract class NotificationChannelPrefsDto with _$NotificationChannelPrefsDto {
  const factory NotificationChannelPrefsDto({
    @Default(true) bool inApp,
    @Default(true) bool push,
    // Wire key is `emailChannel`, not `email` — `email` is a reserved
    // identity key on the backend (edge/masking/identity-keys.ts) and trips
    // MaskingInterceptor's leak check on this non-identity boolean.
    @Default(false) bool emailChannel,
  }) = _NotificationChannelPrefsDto;

  factory NotificationChannelPrefsDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationChannelPrefsDtoFromJson(json);
}

/// `PATCH /v1/me/settings` body — mirrors `patchSettingsSchema`. Left as a
/// plain class (not freezed): its [toJson] has sentinel-null semantics
/// (`clearDefaultRegion`/`clearQuietHours` force an explicit `null` while an
/// absent value is omitted entirely) that don't map onto declarative
/// `@JsonKey`/`includeIfNull` annotations.
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

int _platformConfigInt(dynamic v, int d) =>
    v is num ? v.toInt() : int.tryParse('$v') ?? d;

Map<String, dynamic> _normalizePlatformConfigJson(
  Map<String, dynamic> json,
) => {
  'requestLifetimeHours': _platformConfigInt(json['requestLifetimeHours'], 48),
  'offerValidityHours':
      ((json['offerValidityHours'] as List?) ?? const [12, 24, 48])
          .map((e) => _platformConfigInt(e, 0))
          .toList(growable: false),
  'defaultOfferValidityHours': _platformConfigInt(
    json['defaultOfferValidityHours'],
    24,
  ),
  'bullionMinimumAed': (json['bullionMinimumAed'] ?? '0').toString(),
  'maxConcurrentLiveRequests': _platformConfigInt(
    json['maxConcurrentLiveRequests'],
    10,
  ),
  'maxRequestImages': _platformConfigInt(json['maxRequestImages'], 5),
  'maxOfferImages': _platformConfigInt(json['maxOfferImages'], 3),
  'maxImageBytes': _platformConfigInt(json['maxImageBytes'], 5242880),
  'acceptedImageTypes': ((json['acceptedImageTypes'] as List?) ?? const [])
      .map((e) => e.toString())
      .toList(growable: false),
  'karatList': ((json['karatList'] as List?) ?? const [])
      .map((e) => e.toString())
      .toList(growable: false),
  'maxOfferRevisions': _platformConfigInt(json['maxOfferRevisions'], 3),
  'requestExpiryWarningHours': _platformConfigInt(
    json['requestExpiryWarningHours'],
    6,
  ),
  'termsUrl': json['termsUrl'] as String? ?? '',
  'privacyUrl': json['privacyUrl'] as String? ?? '',
  'supportContactUrl': json['supportContactUrl'] as String? ?? '',
  'subscriptionContactUrl': json['subscriptionContactUrl'] as String? ?? '',
};

/// `settings.service.ts` `PlatformConfigResponse` — `GET /v1/platform-config`.
@freezed
abstract class PlatformConfigDto with _$PlatformConfigDto {
  const factory PlatformConfigDto({
    required int requestLifetimeHours,
    required List<int> offerValidityHours,
    required int defaultOfferValidityHours,
    required String bullionMinimumAed,
    required int maxConcurrentLiveRequests,
    required int maxRequestImages,
    required int maxOfferImages,
    required int maxImageBytes,
    required List<String> acceptedImageTypes,
    required List<String> karatList,
    required int maxOfferRevisions,
    required int requestExpiryWarningHours,
    required String termsUrl,
    required String privacyUrl,
    required String supportContactUrl,
    required String subscriptionContactUrl,
  }) = _PlatformConfigDto;

  factory PlatformConfigDto.fromJson(Map<String, dynamic> json) =>
      _$PlatformConfigDtoFromJson(_normalizePlatformConfigJson(json));
}
