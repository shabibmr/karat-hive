import 'package:kh_admin/features/connections/model/connection_enums.dart';

/// Single item in the ADM-S12 Connection List table.
class ConnectionListItem {
  ConnectionListItem({
    required this.id,
    required this.requestId,
    required this.offerId,
    this.requestType,
    required this.customerName,
    required this.vendorName,
    required this.agreedPriceAed,
    required this.state,
    this.contactEventsCount = 0,
    this.lastContactAt,
    required this.createdAt,
    bool? hasNoContact48h,
    DateTime? now,
  }) : hasNoContact48h = hasNoContact48h ??
            calculateHasNoContact48h(
              state: state,
              createdAt: createdAt,
              contactEventsCount: contactEventsCount,
              lastContactAt: lastContactAt,
              now: now,
            );

  final String id;
  final String requestId;
  final String offerId;
  final String? requestType;
  final String customerName;
  final String vendorName;
  final double agreedPriceAed;
  final ConnectionState state;
  final int contactEventsCount;
  final DateTime? lastContactAt;
  final DateTime createdAt;
  final bool hasNoContact48h;

  /// Calculates the 48h introduction SLA breach status.
  ///
  /// True if state is ACTIVE and createdAt > 48h ago and contactEventsCount == 0
  /// (or lastContactAt is null and createdAt > 48h).
  static bool calculateHasNoContact48h({
    required ConnectionState state,
    required DateTime createdAt,
    int contactEventsCount = 0,
    DateTime? lastContactAt,
    DateTime? now,
  }) {
    if (state != ConnectionState.active) return false;
    final referenceTime = now ?? DateTime.now();
    final difference = referenceTime.difference(createdAt);
    if (difference < const Duration(hours: 48)) return false;
    return contactEventsCount == 0 || lastContactAt == null;
  }

  factory ConnectionListItem.fromJson(
    Map<String, dynamic> json, {
    DateTime? now,
  }) {
    final state = ConnectionState.fromApi(json['state']?.toString()) ??
        ConnectionState.active;

    final createdAt =
        DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now();

    final lastContactStr = json['lastContactAt']?.toString();
    final lastContactAt =
        lastContactStr != null ? DateTime.tryParse(lastContactStr) : null;

    final contactEventsCount = json['contactEventsCount'] is int
        ? json['contactEventsCount'] as int
        : (int.tryParse(json['contactEventsCount']?.toString() ?? '') ?? 0);

    final agreedPrice = json['agreedPriceAed'] is num
        ? (json['agreedPriceAed'] as num).toDouble()
        : (double.tryParse(json['agreedPriceAed']?.toString() ?? '') ?? 0.0);

    final hasNoContact48h = json['hasNoContact48h'] is bool
        ? json['hasNoContact48h'] as bool
        : calculateHasNoContact48h(
            state: state,
            createdAt: createdAt,
            contactEventsCount: contactEventsCount,
            lastContactAt: lastContactAt,
            now: now,
          );

    return ConnectionListItem(
      id: json['id']?.toString() ?? '',
      requestId: json['requestId']?.toString() ?? '',
      offerId: json['offerId']?.toString() ?? '',
      requestType: json['requestType']?.toString(),
      customerName: json['customerName']?.toString() ?? 'Customer',
      vendorName: json['vendorName']?.toString() ?? 'Vendor',
      agreedPriceAed: agreedPrice,
      state: state,
      contactEventsCount: contactEventsCount,
      lastContactAt: lastContactAt,
      createdAt: createdAt,
      hasNoContact48h: hasNoContact48h,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'requestId': requestId,
        'offerId': offerId,
        'requestType': requestType,
        'customerName': customerName,
        'vendorName': vendorName,
        'agreedPriceAed': agreedPriceAed,
        'state': state.apiValue,
        'contactEventsCount': contactEventsCount,
        'lastContactAt': lastContactAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'hasNoContact48h': hasNoContact48h,
      };

  ConnectionListItem copyWith({
    String? id,
    String? requestId,
    String? offerId,
    String? requestType,
    String? customerName,
    String? vendorName,
    double? agreedPriceAed,
    ConnectionState? state,
    int? contactEventsCount,
    DateTime? lastContactAt,
    DateTime? createdAt,
    bool? hasNoContact48h,
  }) {
    return ConnectionListItem(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      offerId: offerId ?? this.offerId,
      requestType: requestType ?? this.requestType,
      customerName: customerName ?? this.customerName,
      vendorName: vendorName ?? this.vendorName,
      agreedPriceAed: agreedPriceAed ?? this.agreedPriceAed,
      state: state ?? this.state,
      contactEventsCount: contactEventsCount ?? this.contactEventsCount,
      lastContactAt: lastContactAt ?? this.lastContactAt,
      createdAt: createdAt ?? this.createdAt,
      hasNoContact48h: hasNoContact48h ?? this.hasNoContact48h,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionListItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          requestId == other.requestId &&
          offerId == other.offerId &&
          requestType == other.requestType &&
          customerName == other.customerName &&
          vendorName == other.vendorName &&
          agreedPriceAed == other.agreedPriceAed &&
          state == other.state &&
          contactEventsCount == other.contactEventsCount &&
          lastContactAt == other.lastContactAt &&
          createdAt == other.createdAt &&
          hasNoContact48h == other.hasNoContact48h;

  @override
  int get hashCode => Object.hash(
        id,
        requestId,
        offerId,
        requestType,
        customerName,
        vendorName,
        agreedPriceAed,
        state,
        contactEventsCount,
        lastContactAt,
        createdAt,
        hasNoContact48h,
      );
}
