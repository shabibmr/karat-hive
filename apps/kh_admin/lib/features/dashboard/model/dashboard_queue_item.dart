/// One Quick Action Queues row on ADM-S02.
///
/// Parsed from verification-queue, abuse-report, or pending-review snapshots.
/// Settlement/GMV is never represented here (`BR-015`).
enum DashboardQueueKind {
  verification,
  abuse,
  review,
}

class DashboardQueueItem {
  const DashboardQueueItem({
    required this.id,
    required this.subject,
    required this.reference,
    required this.type,
    required this.status,
    required this.actionLabel,
    required this.route,
    required this.kind,
    this.submittedAt,
  });

  final String id;
  final String subject;
  final String reference;
  final String type;
  final String status;
  final String actionLabel;
  final String route;
  final DashboardQueueKind kind;
  final DateTime? submittedAt;

  /// Deep-link that opens this exact item in its owning screen (`TR-S6-05`).
  /// Verification and moderation panes read `selectedId`; the abuse queue reads
  /// `selected` and opens the report detail.
  String get deepLinkRoute {
    switch (kind) {
      case DashboardQueueKind.verification:
        return '$route?selectedId=$id';
      case DashboardQueueKind.abuse:
      case DashboardQueueKind.review:
        return '$route?selected=$id';
    }
  }

  /// GST (UTC+4) label matching the ADM-S02 queue column (`BR-021`).
  String get submittedLabel {
    if (submittedAt == null) return '—';
    final gst = submittedAt!.toUtc().add(const Duration(hours: 4));
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = gst.day.toString().padLeft(2, '0');
    final hour = gst.hour.toString().padLeft(2, '0');
    final minute = gst.minute.toString().padLeft(2, '0');
    return '$day ${months[gst.month - 1]} $hour:$minute';
  }

  factory DashboardQueueItem.fromVerificationJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final legal = json['legalBusinessName']?.toString();
    final trading = json['tradingName']?.toString();
    final subject = (legal != null && legal.isNotEmpty)
        ? legal
        : (trading != null && trading.isNotEmpty)
            ? trading
            : 'Vendor';
    final licence = json['tradeLicenceNumber']?.toString();
    final state = json['verificationState']?.toString() ?? 'PENDING';
    final status = state.contains('PENDING') ? 'PENDING' : state;

    return DashboardQueueItem(
      id: id,
      subject: subject,
      reference: (licence != null && licence.isNotEmpty) ? licence : id,
      type: 'KYC Verification',
      status: status,
      actionLabel: 'Review KYC',
      route: '/verification',
      kind: DashboardQueueKind.verification,
      submittedAt: _parseDate(json['submittedAt'] ?? json['createdAt']),
    );
  }

  factory DashboardQueueItem.fromAbuseJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final description = json['description']?.toString();
    final category = json['category']?.toString();
    final state = json['state']?.toString() ?? 'OPEN';

    return DashboardQueueItem(
      id: id,
      subject: 'Report #$id',
      reference: (description != null && description.isNotEmpty)
          ? description
          : (category ?? id),
      type: 'Abuse Report',
      status: state,
      actionLabel: 'Inspect',
      route: '/abuse',
      kind: DashboardQueueKind.abuse,
      submittedAt: _parseDate(json['createdAt']),
    );
  }

  factory DashboardQueueItem.fromReviewJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final authorObj = json['author'] is Map<String, dynamic>
        ? json['author'] as Map<String, dynamic>
        : null;
    final authorCust = authorObj?['customerProfile'] is Map<String, dynamic>
        ? authorObj!['customerProfile'] as Map<String, dynamic>
        : null;
    final authorVend = authorObj?['vendorProfile'] is Map<String, dynamic>
        ? authorObj!['vendorProfile'] as Map<String, dynamic>
        : null;
    final authorName = authorCust?['displayName']?.toString() ??
        authorVend?['tradingName']?.toString() ??
        authorObj?['displayName']?.toString();

    return DashboardQueueItem(
      id: id,
      subject: 'Review #$id',
      reference: 'By ${authorName ?? 'Customer'}',
      type: 'Review Moderation',
      status: 'MODERATION',
      actionLabel: 'Approve',
      route: '/moderation',
      kind: DashboardQueueKind.review,
      submittedAt: _parseDate(json['createdAt']),
    );
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw is DateTime) return raw;
    if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardQueueItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          kind == other.kind &&
          subject == other.subject &&
          reference == other.reference &&
          type == other.type &&
          status == other.status &&
          actionLabel == other.actionLabel &&
          route == other.route &&
          submittedAt == other.submittedAt;

  @override
  int get hashCode => Object.hash(
        id,
        kind,
        subject,
        reference,
        type,
        status,
        actionLabel,
        route,
        submittedAt,
      );
}
