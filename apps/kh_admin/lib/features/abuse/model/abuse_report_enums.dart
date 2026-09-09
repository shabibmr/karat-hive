library;

/// Enums for ADM-S21 Abuse Report Queue.

enum AbuseReportState {
  open,
  underReview,
  resolved,
  dismissed;

  String get wireValue {
    switch (this) {
      case AbuseReportState.open:
        return 'OPEN';
      case AbuseReportState.underReview:
        return 'UNDER_REVIEW';
      case AbuseReportState.resolved:
        return 'RESOLVED';
      case AbuseReportState.dismissed:
        return 'DISMISSED';
    }
  }

  static AbuseReportState? fromWire(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'OPEN':
        return AbuseReportState.open;
      case 'UNDER_REVIEW':
        return AbuseReportState.underReview;
      case 'RESOLVED':
        return AbuseReportState.resolved;
      case 'DISMISSED':
        return AbuseReportState.dismissed;
      default:
        return null;
    }
  }

  String get label {
    switch (this) {
      case AbuseReportState.open:
        return 'Open';
      case AbuseReportState.underReview:
        return 'Under Review';
      case AbuseReportState.resolved:
        return 'Resolved';
      case AbuseReportState.dismissed:
        return 'Dismissed';
    }
  }
}

/// FR-ADM-032 AC3 — the four resolutions an Admin can take against the reported
/// party from an abuse report. Each requires a rationale. Sent to
/// `POST /v1/admin/abuse-reports/:id/action` as [wireValue].
enum AbuseReportAction {
  dismiss,
  warn,
  suspend,
  deactivate;

  String get wireValue {
    switch (this) {
      case AbuseReportAction.dismiss:
        return 'DISMISS';
      case AbuseReportAction.warn:
        return 'WARN';
      case AbuseReportAction.suspend:
        return 'SUSPEND';
      case AbuseReportAction.deactivate:
        return 'DEACTIVATE';
    }
  }

  /// Menu label.
  String get label {
    switch (this) {
      case AbuseReportAction.dismiss:
        return 'Dismiss report';
      case AbuseReportAction.warn:
        return 'Warn reported party';
      case AbuseReportAction.suspend:
        return 'Suspend reported party';
      case AbuseReportAction.deactivate:
        return 'Deactivate reported party';
    }
  }

  /// Past-tense outcome for the confirmation snackbar.
  String get pastTense {
    switch (this) {
      case AbuseReportAction.dismiss:
        return 'DISMISSED';
      case AbuseReportAction.warn:
        return 'resolved with a warning';
      case AbuseReportAction.suspend:
        return 'resolved — reported party suspended';
      case AbuseReportAction.deactivate:
        return 'resolved — reported party deactivated';
    }
  }

  /// Whether this action changes the reported party's account state (used to
  /// gate the extra confirmation copy).
  bool get sanctionsParty =>
      this == AbuseReportAction.suspend || this == AbuseReportAction.deactivate;
}

enum AbuseEntityType {
  request,
  offer,
  connection,
  review,
  vendor,
  customer;

  String get wireValue {
    switch (this) {
      case AbuseEntityType.request:
        return 'REQUEST';
      case AbuseEntityType.offer:
        return 'OFFER';
      case AbuseEntityType.connection:
        return 'CONNECTION';
      case AbuseEntityType.review:
        return 'REVIEW';
      case AbuseEntityType.vendor:
        return 'VENDOR';
      case AbuseEntityType.customer:
        return 'CUSTOMER';
    }
  }

  static AbuseEntityType? fromWire(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'REQUEST':
        return AbuseEntityType.request;
      case 'OFFER':
        return AbuseEntityType.offer;
      case 'CONNECTION':
        return AbuseEntityType.connection;
      case 'REVIEW':
        return AbuseEntityType.review;
      case 'VENDOR':
        return AbuseEntityType.vendor;
      case 'CUSTOMER':
        return AbuseEntityType.customer;
      default:
        return null;
    }
  }

  String get label {
    switch (this) {
      case AbuseEntityType.request:
        return 'Request';
      case AbuseEntityType.offer:
        return 'Offer';
      case AbuseEntityType.connection:
        return 'Connection';
      case AbuseEntityType.review:
        return 'Review';
      case AbuseEntityType.vendor:
        return 'Vendor';
      case AbuseEntityType.customer:
        return 'Customer';
    }
  }
}
