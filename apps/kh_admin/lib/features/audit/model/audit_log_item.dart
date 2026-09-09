import 'dart:convert';

/// ADM-S22 · Audit log item representing an immutable security/admin event.
///
/// Per BR-021, all timestamps are stored in UTC and displayed in Gulf Standard
/// Time (GST, UTC+4).
class AuditLogItem {
  const AuditLogItem({
    required this.id,
    this.actorUserId,
    required this.action,
    required this.entityType,
    this.entityId,
    this.beforeValue,
    this.afterValue,
    this.ip,
    this.userAgent,
    required this.occurredAt,
  });

  final String id;
  final String? actorUserId;
  final String action;
  final String entityType;
  final String? entityId;
  final dynamic beforeValue;
  final dynamic afterValue;
  final String? ip;
  final String? userAgent;
  final DateTime occurredAt;

  /// Returns occurredAt adjusted to Gulf Standard Time (GST = UTC+4 per BR-021).
  DateTime get occurredAtGst =>
      occurredAt.toUtc().add(const Duration(hours: 4));

  /// Formats a [DateTime] into a GST string (`YYYY-MM-DD HH:mm:ss GST`).
  static String formatDateTimeGst(DateTime dateTime) {
    final gst = dateTime.toUtc().add(const Duration(hours: 4));
    final y = gst.year.toString().padLeft(4, '0');
    final m = gst.month.toString().padLeft(2, '0');
    final d = gst.day.toString().padLeft(2, '0');
    final h = gst.hour.toString().padLeft(2, '0');
    final min = gst.minute.toString().padLeft(2, '0');
    final s = gst.second.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min:$s GST';
  }

  /// Formatting helper for GST display.
  String get formattedGst => formatDateTimeGst(occurredAt);

  AuditLogItem copyWith({
    String? id,
    String? actorUserId,
    String? action,
    String? entityType,
    String? entityId,
    dynamic beforeValue,
    dynamic afterValue,
    String? ip,
    String? userAgent,
    DateTime? occurredAt,
  }) {
    return AuditLogItem(
      id: id ?? this.id,
      actorUserId: actorUserId ?? this.actorUserId,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      beforeValue: beforeValue ?? this.beforeValue,
      afterValue: afterValue ?? this.afterValue,
      ip: ip ?? this.ip,
      userAgent: userAgent ?? this.userAgent,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }

  factory AuditLogItem.fromJson(Map<String, dynamic> json) {
    dynamic parsePayload(dynamic value) {
      if (value == null) return null;
      if (value is Map || value is List) return value;
      if (value is String) {
        try {
          return jsonDecode(value);
        } on Object catch (_) {
          return value;
        }
      }
      return value;
    }

    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    return AuditLogItem(
      id: json['id']?.toString() ?? '',
      actorUserId: json['actorUserId']?.toString(),
      action: json['action']?.toString() ?? '',
      entityType: json['entityType']?.toString() ?? '',
      entityId: json['entityId']?.toString(),
      beforeValue: parsePayload(json['beforeValue']),
      afterValue: parsePayload(json['afterValue']),
      ip: json['ip']?.toString() ?? json['ipAddress']?.toString(),
      userAgent: json['userAgent']?.toString(),
      occurredAt: parseDate(json['occurredAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actorUserId': actorUserId,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'beforeValue': beforeValue,
      'afterValue': afterValue,
      'ip': ip,
      'userAgent': userAgent,
      'occurredAt': occurredAt.toUtc().toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuditLogItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AuditLogItem(id: $id, action: $action, occurredAt: $formattedGst)';
}
