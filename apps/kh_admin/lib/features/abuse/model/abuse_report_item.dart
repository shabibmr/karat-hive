import 'package:kh_admin/features/abuse/model/abuse_report_enums.dart';

/// Single item in the ADM-S21 Abuse Report Queue.
class AbuseReportItem {
  const AbuseReportItem({
    required this.id,
    required this.reporterUserId,
    required this.reportedUserId,
    required this.entityType,
    required this.entityId,
    required this.category,
    required this.description,
    required this.state,
    this.resolution,
    this.resolvedByAdminId,
    required this.createdAt,
    this.updatedAt,
    this.reporterName,
    this.reporterEmail,
    this.reporterPhone,
    this.reportedName,
    this.reportedEmail,
    this.reportedPhone,
  });

  final String id;
  final String reporterUserId;
  final String reportedUserId;
  final AbuseEntityType entityType;
  final String entityId;
  final String category;
  final String description;
  final AbuseReportState state;
  final String? resolution;
  final String? resolvedByAdminId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Reporter details visible to Admin only (FR-ADM-032). Never disclosed to reported party.
  final String? reporterName;
  final String? reporterEmail;
  final String? reporterPhone;

  // Reported party details
  final String? reportedName;
  final String? reportedEmail;
  final String? reportedPhone;

  factory AbuseReportItem.fromJson(Map<String, dynamic> json) {
    final reporterObj = json['reporter'] is Map<String, dynamic>
        ? json['reporter'] as Map<String, dynamic>
        : null;
    final reportedObj = json['reported'] is Map<String, dynamic>
        ? json['reported'] as Map<String, dynamic>
        : null;

    final reporterCust = reporterObj?['customerProfile'] is Map<String, dynamic>
        ? reporterObj!['customerProfile'] as Map<String, dynamic>
        : null;
    final reporterVend = reporterObj?['vendorProfile'] is Map<String, dynamic>
        ? reporterObj!['vendorProfile'] as Map<String, dynamic>
        : null;

    final reportedCust = reportedObj?['customerProfile'] is Map<String, dynamic>
        ? reportedObj!['customerProfile'] as Map<String, dynamic>
        : null;
    final reportedVend = reportedObj?['vendorProfile'] is Map<String, dynamic>
        ? reportedObj!['vendorProfile'] as Map<String, dynamic>
        : null;

    final reporterName = reporterCust?['displayName']?.toString() ??
        reporterVend?['tradingName']?.toString() ??
        reporterObj?['displayName']?.toString();

    final reportedName = reportedCust?['displayName']?.toString() ??
        reportedVend?['tradingName']?.toString() ??
        reportedObj?['displayName']?.toString();

    final stateStr = json['state']?.toString();
    final entityTypeStr = json['entityType']?.toString();

    return AbuseReportItem(
      id: json['id']?.toString() ?? '',
      reporterUserId: json['reporterUserId']?.toString() ?? '',
      reportedUserId: json['reportedUserId']?.toString() ?? '',
      entityType: AbuseEntityType.fromWire(entityTypeStr) ?? AbuseEntityType.vendor,
      entityId: json['entityId']?.toString() ?? '',
      category: json['category']?.toString() ?? 'OTHER',
      description: json['description']?.toString() ?? '',
      state: AbuseReportState.fromWire(stateStr) ?? AbuseReportState.open,
      resolution: json['resolution']?.toString(),
      resolvedByAdminId: json['resolvedByAdminId']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      reporterName: reporterName,
      reporterEmail: reporterObj?['email']?.toString(),
      reporterPhone: reporterObj?['mobileNumber']?.toString(),
      reportedName: reportedName,
      reportedEmail: reportedObj?['email']?.toString(),
      reportedPhone: reportedObj?['mobileNumber']?.toString(),
    );
  }
}
