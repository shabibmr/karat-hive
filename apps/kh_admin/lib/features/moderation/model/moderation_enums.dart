library;

/// Enums for ADM-S16 Review Moderation Queue.

enum ReviewState {
  pendingModeration,
  published,
  rejected,
  redacted,
  withdrawn;

  String get wireValue {
    switch (this) {
      case ReviewState.pendingModeration:
        return 'PENDING_MODERATION';
      case ReviewState.published:
        return 'PUBLISHED';
      case ReviewState.rejected:
        return 'REJECTED';
      case ReviewState.redacted:
        return 'REDACTED';
      case ReviewState.withdrawn:
        return 'WITHDRAWN';
    }
  }

  static ReviewState? fromWire(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'PENDING_MODERATION':
        return ReviewState.pendingModeration;
      case 'PUBLISHED':
        return ReviewState.published;
      case 'REJECTED':
        return ReviewState.rejected;
      case 'REDACTED':
        return ReviewState.redacted;
      case 'WITHDRAWN':
        return ReviewState.withdrawn;
      default:
        return null;
    }
  }

  String get label {
    switch (this) {
      case ReviewState.pendingModeration:
        return 'Pending Moderation';
      case ReviewState.published:
        return 'Published';
      case ReviewState.rejected:
        return 'Rejected';
      case ReviewState.redacted:
        return 'Redacted';
      case ReviewState.withdrawn:
        return 'Withdrawn';
    }
  }
}

enum AuthorType {
  customer,
  vendor;

  String get wireValue {
    switch (this) {
      case AuthorType.customer:
        return 'CUSTOMER';
      case AuthorType.vendor:
        return 'VENDOR';
    }
  }

  static AuthorType? fromWire(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'CUSTOMER':
        return AuthorType.customer;
      case 'VENDOR':
        return AuthorType.vendor;
      default:
        return null;
    }
  }

  String get label {
    switch (this) {
      case AuthorType.customer:
        return 'Customer';
      case AuthorType.vendor:
        return 'Vendor';
    }
  }
}
