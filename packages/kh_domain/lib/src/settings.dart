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
        start: j['start'] as String? ?? '',
        end: j['end'] as String? ?? '',
        timezone: j['timezone'] as String? ?? 'Asia/Dubai',
      );

  Map<String, dynamic> toJson() => {
        'start': start,
        'end': end,
        'timezone': timezone,
      };
}

class NotificationChannelPref {
  const NotificationChannelPref({
    required this.inApp,
    required this.push,
    required this.email,
  });

  final bool inApp;
  final bool push;
  final bool email;

  static NotificationChannelPref fromJson(Map<String, dynamic> j) =>
      NotificationChannelPref(
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

class UserSettings {
  const UserSettings({
    required this.preferredLanguage,
    required this.notifications,
    this.defaultRegionId,
    this.quietHours,
    this.defaultFilterPresetId,
  });

  final String preferredLanguage;
  final String? defaultRegionId;
  final QuietHours? quietHours;
  final String? defaultFilterPresetId;
  final Map<String, NotificationChannelPref> notifications;

  static UserSettings fromJson(Map<String, dynamic> j) {
    final ntf = <String, NotificationChannelPref>{};
    final raw = j['notifications'];
    if (raw is Map) {
      for (final e in raw.entries) {
        if (e.value is Map) {
          ntf[e.key.toString()] = NotificationChannelPref.fromJson(
            Map<String, dynamic>.from(e.value as Map),
          );
        }
      }
    }
    final qh = j['quietHours'];
    return UserSettings(
      preferredLanguage: j['preferredLanguage'] as String? ?? 'en',
      defaultRegionId: j['defaultRegionId'] as String?,
      quietHours: qh is Map
          ? QuietHours.fromJson(Map<String, dynamic>.from(qh))
          : null,
      defaultFilterPresetId: j['defaultFilterPresetId'] as String?,
      notifications: ntf,
    );
  }
}
