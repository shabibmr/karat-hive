// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserSettingsDto _$UserSettingsDtoFromJson(Map<String, dynamic> json) =>
    _UserSettingsDto(
      preferredLanguage: json['preferredLanguage'] as String,
      defaultRegionId: json['defaultRegionId'] as String?,
      quietHours: json['quietHours'] == null
          ? null
          : QuietHoursDto.fromJson(json['quietHours'] as Map<String, dynamic>),
      defaultFilterPresetId: json['defaultFilterPresetId'] as String?,
      notifications:
          (json['notifications'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              k,
              NotificationChannelPrefsDto.fromJson(e as Map<String, dynamic>),
            ),
          ) ??
          const <String, NotificationChannelPrefsDto>{},
    );

Map<String, dynamic> _$UserSettingsDtoToJson(_UserSettingsDto instance) =>
    <String, dynamic>{
      'preferredLanguage': instance.preferredLanguage,
      'defaultRegionId': instance.defaultRegionId,
      'quietHours': instance.quietHours,
      'defaultFilterPresetId': instance.defaultFilterPresetId,
      'notifications': instance.notifications,
    };

_QuietHoursDto _$QuietHoursDtoFromJson(Map<String, dynamic> json) =>
    _QuietHoursDto(
      start: json['start'] as String,
      end: json['end'] as String,
      timezone: json['timezone'] as String? ?? 'Asia/Dubai',
    );

Map<String, dynamic> _$QuietHoursDtoToJson(_QuietHoursDto instance) =>
    <String, dynamic>{'start': instance.start, 'end': instance.end};

_NotificationChannelPrefsDto _$NotificationChannelPrefsDtoFromJson(
  Map<String, dynamic> json,
) => _NotificationChannelPrefsDto(
  inApp: json['inApp'] as bool? ?? true,
  push: json['push'] as bool? ?? true,
  email: json['email'] as bool? ?? false,
);

Map<String, dynamic> _$NotificationChannelPrefsDtoToJson(
  _NotificationChannelPrefsDto instance,
) => <String, dynamic>{
  'inApp': instance.inApp,
  'push': instance.push,
  'email': instance.email,
};

_PlatformConfigDto _$PlatformConfigDtoFromJson(
  Map<String, dynamic> json,
) => _PlatformConfigDto(
  requestLifetimeHours: (json['requestLifetimeHours'] as num).toInt(),
  offerValidityHours: (json['offerValidityHours'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  defaultOfferValidityHours: (json['defaultOfferValidityHours'] as num).toInt(),
  bullionMinimumAed: json['bullionMinimumAed'] as String,
  maxConcurrentLiveRequests: (json['maxConcurrentLiveRequests'] as num).toInt(),
  maxRequestImages: (json['maxRequestImages'] as num).toInt(),
  maxOfferImages: (json['maxOfferImages'] as num).toInt(),
  maxImageBytes: (json['maxImageBytes'] as num).toInt(),
  acceptedImageTypes: (json['acceptedImageTypes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  karatList: (json['karatList'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  maxOfferRevisions: (json['maxOfferRevisions'] as num).toInt(),
  requestExpiryWarningHours: (json['requestExpiryWarningHours'] as num).toInt(),
  termsUrl: json['termsUrl'] as String,
  privacyUrl: json['privacyUrl'] as String,
  supportContactUrl: json['supportContactUrl'] as String,
  subscriptionContactUrl: json['subscriptionContactUrl'] as String,
);

Map<String, dynamic> _$PlatformConfigDtoToJson(_PlatformConfigDto instance) =>
    <String, dynamic>{
      'requestLifetimeHours': instance.requestLifetimeHours,
      'offerValidityHours': instance.offerValidityHours,
      'defaultOfferValidityHours': instance.defaultOfferValidityHours,
      'bullionMinimumAed': instance.bullionMinimumAed,
      'maxConcurrentLiveRequests': instance.maxConcurrentLiveRequests,
      'maxRequestImages': instance.maxRequestImages,
      'maxOfferImages': instance.maxOfferImages,
      'maxImageBytes': instance.maxImageBytes,
      'acceptedImageTypes': instance.acceptedImageTypes,
      'karatList': instance.karatList,
      'maxOfferRevisions': instance.maxOfferRevisions,
      'requestExpiryWarningHours': instance.requestExpiryWarningHours,
      'termsUrl': instance.termsUrl,
      'privacyUrl': instance.privacyUrl,
      'supportContactUrl': instance.supportContactUrl,
      'subscriptionContactUrl': instance.subscriptionContactUrl,
    };
