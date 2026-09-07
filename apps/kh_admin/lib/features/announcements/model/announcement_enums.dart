library;

/// Enums for ADM-S18 Announcement Composer (FR-ADM-029).

enum AnnouncementStatus {
  scheduled,
  dispatched,
  cancelled,
  draft;

  String get wireValue {
    switch (this) {
      case AnnouncementStatus.scheduled:
        return 'SCHEDULED';
      case AnnouncementStatus.dispatched:
        return 'DISPATCHED';
      case AnnouncementStatus.cancelled:
        return 'CANCELLED';
      case AnnouncementStatus.draft:
        return 'DRAFT';
    }
  }

  static AnnouncementStatus? fromWire(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'SCHEDULED':
        return AnnouncementStatus.scheduled;
      case 'DISPATCHED':
      case 'SENT':
        return AnnouncementStatus.dispatched;
      case 'CANCELLED':
      case 'CANCELED':
        return AnnouncementStatus.cancelled;
      case 'DRAFT':
        return AnnouncementStatus.draft;
      default:
        return null;
    }
  }

  String get label {
    switch (this) {
      case AnnouncementStatus.scheduled:
        return 'Scheduled';
      case AnnouncementStatus.dispatched:
        return 'Dispatched';
      case AnnouncementStatus.cancelled:
        return 'Cancelled';
      case AnnouncementStatus.draft:
        return 'Draft';
    }
  }
}

enum AudienceType {
  all,
  vendors,
  customers;

  String get wireValue {
    switch (this) {
      case AudienceType.all:
        return 'ALL';
      case AudienceType.vendors:
        return 'VENDOR';
      case AudienceType.customers:
        return 'CUSTOMER';
    }
  }

  static AudienceType? fromWire(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'ALL':
      case 'BOTH':
        return AudienceType.all;
      case 'VENDOR':
      case 'VENDORS':
        return AudienceType.vendors;
      case 'CUSTOMER':
      case 'CUSTOMERS':
        return AudienceType.customers;
      default:
        return null;
    }
  }

  String get label {
    switch (this) {
      case AudienceType.all:
        return 'All Users';
      case AudienceType.vendors:
        return 'Vendors Only';
      case AudienceType.customers:
        return 'Customers Only';
    }
  }
}
