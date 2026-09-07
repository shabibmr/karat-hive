import 'connection_list_item.dart';

/// Cursor-paginated slice of connections for ADM-S12.
class ConnectionListPage {
  const ConnectionListPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
    this.totalCount,
  });

  final List<ConnectionListItem> items;
  final String? nextCursor;
  final bool hasMore;
  final int? totalCount;

  bool get canLoadMore => hasMore && nextCursor != null && nextCursor!.isNotEmpty;
}
