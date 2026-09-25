import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

Map<String, dynamic> _normalizeAccountDeletionRequestJson(
  Map<String, dynamic> json,
) => {
  'id': json['id'] as String,
  'state': json['state'] as String? ?? 'QUEUED',
  'createdAt':
      (DateTime.tryParse(json['createdAt'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0))
          .toIso8601String(),
  'challengeId': json['challengeId'] as String?,
  'expiresAt': json['expiresAt'] is String
      ? (DateTime.tryParse(json['expiresAt'] as String)?.toIso8601String())
      : null,
  'retryAfterSeconds': (json['retryAfterSeconds'] as num?)?.toInt(),
};

@freezed
abstract class AccountDeletionRequest with _$AccountDeletionRequest {
  const factory AccountDeletionRequest({
    required String id,
    required String state,
    required DateTime createdAt,
    String? challengeId,
    DateTime? expiresAt,
    int? retryAfterSeconds,
  }) = _AccountDeletionRequest;

  factory AccountDeletionRequest.fromJson(Map<String, dynamic> json) =>
      _$AccountDeletionRequestFromJson(
        _normalizeAccountDeletionRequestJson(json),
      );
}

@freezed
abstract class QuietHours with _$QuietHours {
  const factory QuietHours({
    required String start,
    required String end,
    @Default('Asia/Dubai') String timezone,
  }) = _QuietHours;

  factory QuietHours.fromJson(Map<String, dynamic> json) =>
      _$QuietHoursFromJson(json);
}

@freezed
abstract class NotificationChannelPref with _$NotificationChannelPref {
  const factory NotificationChannelPref({
    required bool inApp,
    required bool push,
    // Wire key is `emailChannel`, not `email` — `email` is a reserved
    // identity key on the backend (edge/masking/identity-keys.ts) and trips
    // MaskingInterceptor's leak check on this non-identity boolean.
    required bool emailChannel,
  }) = _NotificationChannelPref;

  factory NotificationChannelPref.fromJson(Map<String, dynamic> json) =>
      _$NotificationChannelPrefFromJson(json);
}

Map<String, dynamic> _normalizeUserSettingsJson(Map<String, dynamic> json) {
  final ntf = <String, dynamic>{};
  final raw = json['notifications'];
  if (raw is Map) {
    for (final e in raw.entries) {
      if (e.value is Map) {
        ntf[e.key.toString()] = Map<String, dynamic>.from(e.value as Map);
      }
    }
  }
  final qh = json['quietHours'];
  return {
    'preferredLanguage': json['preferredLanguage'] as String? ?? 'en',
    'defaultRegionId': json['defaultRegionId'] as String?,
    'quietHours': qh is Map ? Map<String, dynamic>.from(qh) : null,
    'defaultFilterPresetId': json['defaultFilterPresetId'] as String?,
    'notifications': ntf,
  };
}

@freezed
abstract class UserSettings with _$UserSettings {
  const factory UserSettings({
    required String preferredLanguage,
    required Map<String, NotificationChannelPref> notifications,
    String? defaultRegionId,
    QuietHours? quietHours,
    String? defaultFilterPresetId,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(_normalizeUserSettingsJson(json));
}
