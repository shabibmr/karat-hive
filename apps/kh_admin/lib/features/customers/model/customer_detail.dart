import 'package:kh_admin/features/customers/model/customer_enums.dart';

/// Summary of a Request submitted by the customer, displayed in Customer Detail.
class CustomerRequestSummary {
  const CustomerRequestSummary({
    required this.id,
    this.reference,
    this.requestType,
    this.direction,
    this.state,
    this.notes,
    this.budgetMin,
    this.budgetMax,
    this.createdAt,
    this.offerCount = 0,
  });

  final String id;
  final String? reference;
  final String? requestType;
  final String? direction;
  final String? state;
  final String? notes;
  final double? budgetMin;
  final double? budgetMax;
  final DateTime? createdAt;
  final int offerCount;

  CustomerRequestSummary copyWith({
    String? id,
    String? reference,
    String? requestType,
    String? direction,
    String? state,
    String? notes,
    double? budgetMin,
    double? budgetMax,
    DateTime? createdAt,
    int? offerCount,
  }) {
    return CustomerRequestSummary(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      requestType: requestType ?? this.requestType,
      direction: direction ?? this.direction,
      state: state ?? this.state,
      notes: notes ?? this.notes,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      createdAt: createdAt ?? this.createdAt,
      offerCount: offerCount ?? this.offerCount,
    );
  }

  factory CustomerRequestSummary.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    double? parseDouble(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    return CustomerRequestSummary(
      id: json['id']?.toString() ?? '',
      reference: json['reference']?.toString(),
      requestType: json['requestType']?.toString(),
      direction: json['direction']?.toString(),
      state: json['state']?.toString(),
      notes: json['notes']?.toString(),
      budgetMin: parseDouble(json['budgetMin']),
      budgetMax: parseDouble(json['budgetMax']),
      createdAt: parseDate(json['createdAt']),
      offerCount: (json['offerCount'] as num?)?.toInt() ??
          ((json['_count'] is Map && (json['_count'] as Map)['offers'] is num)
              ? ((json['_count'] as Map)['offers'] as num).toInt()
              : 0),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerRequestSummary &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          reference == other.reference &&
          requestType == other.requestType &&
          direction == other.direction &&
          state == other.state &&
          notes == other.notes &&
          budgetMin == other.budgetMin &&
          budgetMax == other.budgetMax &&
          createdAt == other.createdAt &&
          offerCount == other.offerCount;

  @override
  int get hashCode => Object.hash(
        id,
        reference,
        requestType,
        direction,
        state,
        notes,
        budgetMin,
        budgetMax,
        createdAt,
        offerCount,
      );

  @override
  String toString() =>
      'CustomerRequestSummary(id: $id, reference: $reference, state: $state, requestType: $requestType, offerCount: $offerCount)';
}

/// An admin internal note associated with a Customer.
class CustomerAdminNote {
  const CustomerAdminNote({
    required this.id,
    required this.text,
    required this.authorName,
    required this.createdAt,
  });

  final String id;
  final String text;
  final String authorName;
  final DateTime createdAt;

  CustomerAdminNote copyWith({
    String? id,
    String? text,
    String? authorName,
    DateTime? createdAt,
  }) {
    return CustomerAdminNote(
      id: id ?? this.id,
      text: text ?? this.text,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CustomerAdminNote.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is DateTime) return val;
      if (val is String) {
        final parsed = DateTime.tryParse(val);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    final authorObj = json['author'];
    final authorName = json['authorName']?.toString() ??
        (authorObj is Map<String, dynamic>
            ? authorObj['displayName']?.toString()
            : (authorObj is String ? authorObj : null)) ??
        'Platform Admin';

    return CustomerAdminNote(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? json['note']?.toString() ?? '',
      authorName: authorName,
      createdAt: parseDate(json['createdAt'] ?? json['timestamp']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerAdminNote &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          authorName == other.authorName &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(id, text, authorName, createdAt);

  @override
  String toString() =>
      'CustomerAdminNote(id: $id, authorName: $authorName, text: $text, createdAt: $createdAt)';
}

/// Full customer profile and activity details for ADM-S04.
class CustomerDetail {
  const CustomerDetail({
    required this.id,
    required this.userId,
    required this.displayName,
    this.email,
    this.mobileNumber,
    this.accountState = CustomerAccountState.active,
    this.createdAt,
    this.defaultRegion,
    this.requests = const [],
    this.adminNotes = const [],
  });

  final String id;
  final String userId;
  final String displayName;
  final String? email;
  final String? mobileNumber;
  final CustomerAccountState accountState;
  final DateTime? createdAt;
  final String? defaultRegion;
  final List<CustomerRequestSummary> requests;
  final List<CustomerAdminNote> adminNotes;

  CustomerDetail copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? email,
    String? mobileNumber,
    CustomerAccountState? accountState,
    DateTime? createdAt,
    String? defaultRegion,
    List<CustomerRequestSummary>? requests,
    List<CustomerAdminNote>? adminNotes,
  }) {
    return CustomerDetail(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      accountState: accountState ?? this.accountState,
      createdAt: createdAt ?? this.createdAt,
      defaultRegion: defaultRegion ?? this.defaultRegion,
      requests: requests ?? this.requests,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }

  factory CustomerDetail.fromJson(
    Map<String, dynamic> json, {
    List<CustomerAdminNote>? notes,
  }) {
    DateTime? parseDate(dynamic val) {
      if (val is DateTime) return val;
      if (val is String) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    final user = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : null;

    final rawState = json['accountState']?.toString() ??
        user?['accountState']?.toString();

    String? parseRegion(dynamic val) {
      if (val == null) return null;
      if (val is String) return val;
      if (val is Map<String, dynamic>) {
        return val['nameEn']?.toString() ??
            val['name']?.toString() ??
            val['nameAr']?.toString();
      }
      return null;
    }

    List<CustomerRequestSummary> parseRequests(dynamic val) {
      if (val is! List) return const [];
      return val
          .whereType<Map<String, dynamic>>()
          .map(CustomerRequestSummary.fromJson)
          .toList();
    }

    List<CustomerAdminNote> parseNotes(dynamic val) {
      if (val is! List) return const [];
      return val
          .whereType<Map<String, dynamic>>()
          .map(CustomerAdminNote.fromJson)
          .toList();
    }

    return CustomerDetail(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ??
          user?['id']?.toString() ??
          '',
      displayName: json['displayName']?.toString() ?? '',
      email: json['email']?.toString() ?? user?['email']?.toString(),
      mobileNumber:
          json['mobileNumber']?.toString() ?? user?['mobileNumber']?.toString(),
      accountState: CustomerAccountState.fromApi(rawState) ??
          CustomerAccountState.active,
      createdAt: parseDate(json['createdAt'] ?? user?['createdAt']),
      defaultRegion: parseRegion(json['defaultRegion']),
      requests: parseRequests(json['requests']),
      adminNotes: notes ?? parseNotes(json['adminNotes'] ?? json['notes']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerDetail &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          displayName == other.displayName &&
          email == other.email &&
          mobileNumber == other.mobileNumber &&
          accountState == other.accountState &&
          createdAt == other.createdAt &&
          defaultRegion == other.defaultRegion &&
          requests == other.requests &&
          adminNotes == other.adminNotes;

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        displayName,
        email,
        mobileNumber,
        accountState,
        createdAt,
        defaultRegion,
        requests,
        adminNotes,
      );

  @override
  String toString() =>
      'CustomerDetail(id: $id, userId: $userId, displayName: $displayName, email: $email, mobileNumber: $mobileNumber, accountState: $accountState, requests: ${requests.length}, adminNotes: ${adminNotes.length})';
}
