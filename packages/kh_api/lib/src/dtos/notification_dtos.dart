import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_dtos.freezed.dart';
part 'notification_dtos.g.dart';

Map<String, dynamic> _normalizeNotificationJson(Map<String, dynamic> json) => {
      ...json,
      'id': json['id'] as String,
      'type': json['type'] as String? ?? '',
      'title': json['title'] as String? ?? '',
      'body': json['body'] as String? ?? '',
      'deepLink': json['deepLink'] as String? ?? '',
      'isCritical': json['isCritical'] as bool? ?? false,
    };

/// `notification.presenter.ts` `NotificationView`. Backs `CUS-S19`.
@freezed
abstract class NotificationDto with _$NotificationDto {
  const NotificationDto._();

  const factory NotificationDto({
    required String id,
    required String type,
    required String title,
    required String body,
    required String deepLink,
    required bool isCritical,
    DateTime? readAt,
    required DateTime createdAt,
  }) = _NotificationDto;

  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDtoFromJson(_normalizeNotificationJson(json));

  bool get isUnread => readAt == null;
}
