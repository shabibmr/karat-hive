import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

Map<String, dynamic> _normalizeAppNotificationJson(Map<String, dynamic> json) => {
      'id': json['id'] as String,
      'type': json['type'] as String? ?? '',
      'title': json['title'] as String? ?? '',
      'body': json['body'] as String? ?? '',
      'deepLink': json['deepLink'] as String? ?? '',
      'isCritical': json['isCritical'] as bool? ?? false,
      'readAt': json['readAt'] is String
          ? (DateTime.tryParse(json['readAt'] as String)?.toIso8601String())
          : null,
      'createdAt': (DateTime.tryParse(json['createdAt'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0))
          .toIso8601String(),
    };

@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String type,
    required String title,
    required String body,
    required String deepLink,
    required bool isCritical,
    required DateTime createdAt,
    DateTime? readAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(_normalizeAppNotificationJson(json));
}
