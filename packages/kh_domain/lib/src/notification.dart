class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.deepLink,
    required this.isCritical,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final String deepLink;
  final bool isCritical;
  final DateTime? readAt;
  final DateTime createdAt;

  static AppNotification fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'] as String,
        type: j['type'] as String? ?? '',
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        deepLink: j['deepLink'] as String? ?? '',
        isCritical: j['isCritical'] as bool? ?? false,
        readAt: j['readAt'] is String ? DateTime.tryParse(j['readAt'] as String) : null,
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
}
