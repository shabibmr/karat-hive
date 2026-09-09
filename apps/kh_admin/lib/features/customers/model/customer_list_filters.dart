import 'package:kh_admin/features/customers/model/customer_enums.dart';

/// Filter criteria for customer list screen (ADM-S03).
class CustomerListFilters {
  const CustomerListFilters({
    this.query = '',
    this.accountState,
  });

  final String query;
  final CustomerAccountState? accountState;

  CustomerListFilters copyWith({
    String? query,
    CustomerAccountState? accountState,
    bool clearAccountState = false,
  }) {
    return CustomerListFilters(
      query: query ?? this.query,
      accountState:
          clearAccountState ? null : (accountState ?? this.accountState),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerListFilters &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          accountState == other.accountState;

  @override
  int get hashCode => Object.hash(query, accountState);

  @override
  String toString() =>
      'CustomerListFilters(query: $query, accountState: $accountState)';
}
