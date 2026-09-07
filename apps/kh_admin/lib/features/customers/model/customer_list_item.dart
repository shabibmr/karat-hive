import 'customer_enums.dart';

/// One row in `GET /v1/admin/customers` (ADM-S03).
class CustomerListItem {
  const CustomerListItem({
    required this.id,
    required this.userId,
    required this.displayName,
    this.email,
    this.mobileNumber,
    this.accountState = CustomerAccountState.active,
    this.requestCount = 0,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String displayName;
  final String? email;
  final String? mobileNumber;
  final CustomerAccountState accountState;
  final int requestCount;
  final DateTime? createdAt;

  CustomerListItem copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? email,
    String? mobileNumber,
    CustomerAccountState? accountState,
    int? requestCount,
    DateTime? createdAt,
  }) {
    return CustomerListItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      accountState: accountState ?? this.accountState,
      requestCount: requestCount ?? this.requestCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CustomerListItem.fromJson(Map<String, dynamic> json) {
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

    int parseRequestCount() {
      if (json['requestCount'] is num) {
        return (json['requestCount'] as num).toInt();
      }
      final countObj = json['_count'];
      if (countObj is Map<String, dynamic> && countObj['requests'] is num) {
        return (countObj['requests'] as num).toInt();
      }
      final requestsList = json['requests'];
      if (requestsList is List) {
        return requestsList.length;
      }
      return 0;
    }

    return CustomerListItem(
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
      requestCount: parseRequestCount(),
      createdAt: parseDate(json['createdAt'] ?? user?['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'mobileNumber': mobileNumber,
      'accountState': accountState.apiValue,
      'requestCount': requestCount,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerListItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          displayName == other.displayName &&
          email == other.email &&
          mobileNumber == other.mobileNumber &&
          accountState == other.accountState &&
          requestCount == other.requestCount &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        displayName,
        email,
        mobileNumber,
        accountState,
        requestCount,
        createdAt,
      );

  @override
  String toString() =>
      'CustomerListItem(id: $id, userId: $userId, displayName: $displayName, email: $email, mobileNumber: $mobileNumber, accountState: $accountState, requestCount: $requestCount, createdAt: $createdAt)';
}
