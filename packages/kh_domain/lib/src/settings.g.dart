// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccountDeletionRequest _$AccountDeletionRequestFromJson(
  Map<String, dynamic> json,
) => _AccountDeletionRequest(
  id: json['id'] as String,
  state: json['state'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  challengeId: json['challengeId'] as String?,
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  retryAfterSeconds: (json['retryAfterSeconds'] as num?)?.toInt(),
);

Map<String, dynamic> _$AccountDeletionRequestToJson(
  _AccountDeletionRequest instance,
) => <String, dynamic>{
  'id': instance.id,
  'state': instance.state,
  'createdAt': instance.createdAt.toIso8601String(),
  'challengeId': instance.challengeId,
  'expiresAt': instance.expiresAt?.toIso8601String(),
  'retryAfterSeconds': instance.retryAfterSeconds,
};

_QuietHours _$QuietHoursFromJson(Map<String, dynamic> json) => _QuietHours(
  start: json['start'] as String,
  end: json['end'] as String,
  timezone: json['timezone'] as String? ?? 'Asia/Dubai',
);

Map<String, dynamic> _$QuietHoursToJson(_QuietHours instance) =>
    <String, dynamic>{
      'start': instance.start,
      'end': instance.end,
      'timezone': instance.timezone,
    };

_NotificationChannelPref _$NotificationChannelPrefFromJson(
  Map<String, dynamic> json,
) => _NotificationChannelPref(
  inApp: json['inApp'] as bool,
  push: json['push'] as bool,
  emailChannel: json['emailChannel'] as bool,
);

Map<String, dynamic> _$NotificationChannelPrefToJson(
  _NotificationChannelPref instance,
) => <String, dynamic>{
  'inApp': instance.inApp,
  'push': instance.push,
  'emailChannel': instance.emailChannel,
};

_UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) =>
    _UserSettings(
      preferredLanguage: json['preferredLanguage'] as String,
      notifications: (json['notifications'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
          k,
          NotificationChannelPref.fromJson(e as Map<String, dynamic>),
        ),
      ),
      defaultRegionId: json['defaultRegionId'] as String?,
      quietHours: json['quietHours'] == null
          ? null
          : QuietHours.fromJson(json['quietHours'] as Map<String, dynamic>),
      defaultFilterPresetId: json['defaultFilterPresetId'] as String?,
    );

Map<String, dynamic> _$UserSettingsToJson(_UserSettings instance) =>
    <String, dynamic>{
      'preferredLanguage': instance.preferredLanguage,
      'notifications': instance.notifications.map(
        (k, e) => MapEntry(k, e.toJson()),
      ),
      'defaultRegionId': instance.defaultRegionId,
      'quietHours': instance.quietHours?.toJson(),
      'defaultFilterPresetId': instance.defaultFilterPresetId,
    };
