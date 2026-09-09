import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:kh_admin/features/vendors/model/vendor_list_item.dart';

part 'vendor_list_page.freezed.dart';

/// Cursor-paginated slice of the admin vendor list.
@freezed
class VendorListPage with _$VendorListPage {
  const VendorListPage._();

  const factory VendorListPage({
    required List<VendorListItem> items,
    String? nextCursor,
    bool? hasMore,
  }) = _VendorListPage;

  bool get canLoadMore {
    if (hasMore == false) return false;
    final cursor = nextCursor;
    return cursor != null && cursor.isNotEmpty;
  }
}
