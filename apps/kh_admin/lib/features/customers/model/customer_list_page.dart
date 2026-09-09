import 'package:kh_admin/features/customers/model/customer_list_item.dart';

/// Cursor-paginated slice of the admin customer list.
class CustomerListPage {
  const CustomerListPage({
    required this.items,
    this.nextCursor,
    this.hasMore,
  });

  final List<CustomerListItem> items;
  final String? nextCursor;
  final bool? hasMore;

  bool get canLoadMore {
    if (hasMore == false) return false;
    final cursor = nextCursor;
    return cursor != null && cursor.isNotEmpty;
  }

  CustomerListPage copyWith({
    List<CustomerListItem>? items,
    String? nextCursor,
    bool? hasMore,
  }) {
    return CustomerListPage(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerListPage &&
          runtimeType == other.runtimeType &&
          items == other.items &&
          nextCursor == other.nextCursor &&
          hasMore == other.hasMore;

  @override
  int get hashCode => Object.hash(items, nextCursor, hasMore);

  @override
  String toString() =>
      'CustomerListPage(itemsCount: ${items.length}, nextCursor: $nextCursor, hasMore: $hasMore)';
}
