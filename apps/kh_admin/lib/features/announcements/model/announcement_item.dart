import 'announcement_enums.dart';

/// Per-announcement delivery and open metrics.
class DispatchStats {
  const DispatchStats({
    required this.sent,
    required this.delivered,
    required this.opened,
  });

  final int sent;
  final int delivered;
  final int opened;

  factory DispatchStats.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return DispatchStats(
      sent: parseInt(json['sent']),
      delivered: parseInt(json['delivered']),
      opened: parseInt(json['opened']),
    );
  }

  Map<String, dynamic> toJson() => {
        'sent': sent,
        'delivered': delivered,
        'opened': opened,
      };
}

/// Delivery channels configured for an announcement.
class AnnouncementChannels {
  const AnnouncementChannels({
    this.inApp = true,
    this.push = false,
    this.email = false,
  });

  final bool inApp;
  final bool push;
  final bool email;

  bool get hasAny => inApp || push || email;

  factory AnnouncementChannels.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AnnouncementChannels();
    return AnnouncementChannels(
      inApp: json['inApp'] == true || json['in_app'] == true,
      push: json['push'] == true,
      email: json['email'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'inApp': inApp,
        'push': push,
        'email': email,
      };

  String get displayString {
    final list = <String>[];
    if (inApp) list.add('In-App');
    if (push) list.add('Push');
    if (email) list.add('Email');
    if (list.isEmpty) return 'None';
    return list.join(', ');
  }
}

/// Single item in the ADM-S18 Announcement Composer list.
class AnnouncementItem {
  const AnnouncementItem({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.bodyEn,
    required this.bodyAr,
    required this.audience,
    required this.channels,
    required this.critical,
    this.scheduledFor,
    this.cancelledAt,
    this.dispatchStats,
    this.createdByDisplayName,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String titleEn;
  final String titleAr;
  final String bodyEn;
  final String bodyAr;
  final Map<String, dynamic> audience;
  final AnnouncementChannels channels;
  final bool critical;
  final DateTime? scheduledFor;
  final DateTime? cancelledAt;
  final DispatchStats? dispatchStats;
  final String? createdByDisplayName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AnnouncementStatus get status {
    if (cancelledAt != null) return AnnouncementStatus.cancelled;
    if (dispatchStats != null) return AnnouncementStatus.dispatched;
    return AnnouncementStatus.scheduled;
  }

  AudienceType get audienceType {
    final rawUserType = audience['userType']?.toString() ?? audience['target']?.toString();
    return AudienceType.fromWire(rawUserType) ?? AudienceType.all;
  }

  /// Cancel is allowed until dispatch stats are written (`SAM-GAP-10` / inventory).
  bool get canCancel => cancelledAt == null && dispatchStats == null;

  factory AnnouncementItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    final createdByObj = json['createdBy'] is Map<String, dynamic>
        ? json['createdBy'] as Map<String, dynamic>
        : null;

    final audienceMap = json['audience'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['audience'] as Map<String, dynamic>)
        : <String, dynamic>{};

    final channelsMap = json['channels'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['channels'] as Map<String, dynamic>)
        : null;

    final statsMap = json['dispatchStats'] is Map<String, dynamic>
        ? json['dispatchStats'] as Map<String, dynamic>
        : (json['dispatch_stats'] is Map<String, dynamic>
            ? json['dispatch_stats'] as Map<String, dynamic>
            : null);

    return AnnouncementItem(
      id: json['id']?.toString() ?? '',
      titleEn: json['titleEn']?.toString() ?? json['title_en']?.toString() ?? '',
      titleAr: json['titleAr']?.toString() ?? json['title_ar']?.toString() ?? '',
      bodyEn: json['bodyEn']?.toString() ?? json['body_en']?.toString() ?? '',
      bodyAr: json['bodyAr']?.toString() ?? json['body_ar']?.toString() ?? '',
      audience: audienceMap,
      channels: AnnouncementChannels.fromJson(channelsMap),
      critical: json['critical'] == true,
      scheduledFor: parseDate(json['scheduledFor'] ?? json['scheduled_for']),
      cancelledAt: parseDate(json['cancelledAt'] ?? json['cancelled_at']),
      dispatchStats: statsMap != null ? DispatchStats.fromJson(statsMap) : null,
      createdByDisplayName: createdByObj?['displayName']?.toString() ??
          json['createdByName']?.toString(),
      createdAt: parseDate(json['createdAt'] ?? json['created_at']) ?? DateTime.now(),
      updatedAt: parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }
}
