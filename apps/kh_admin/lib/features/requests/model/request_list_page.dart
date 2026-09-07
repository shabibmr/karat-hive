import 'package:freezed_annotation/freezed_annotation.dart';

import 'request_list_item.dart';

part 'request_list_page.freezed.dart';

/// Cursor-paginated slice of the admin request list.
@freezed
class RequestListPage with _$RequestListPage {
  const RequestListPage._();

  const factory RequestListPage({
    required List<RequestListItem> items,
    String? nextCursor,
    bool? hasMore,
    int? totalCount,
  }) = _RequestListPage;

  bool get canLoadMore {
    if (hasMore == false) return false;
    final cursor = nextCursor;
    return cursor != null && cursor.isNotEmpty;
  }
}
