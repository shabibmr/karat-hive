/// `notification.presenter.ts` `NotificationView`. Backs `CUS-S19`.
class NotificationDto {
  const NotificationDto({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.deepLink,
    required this.isCritical,
    this.readAt,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final String deepLink;
  final bool isCritical;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isUnread => readAt == null;

  static NotificationDto fromJson(Map<String, dynamic> j) => NotificationDto(
        id: j['id'] as String,
        type: j['type'] as String? ?? '',
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        deepLink: j['deepLink'] as String? ?? '',
        isCritical: j['isCritical'] as bool? ?? false,
        readAt: j['readAt'] == null
            ? null
            : DateTime.parse(j['readAt'] as String),
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}
