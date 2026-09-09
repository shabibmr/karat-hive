import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:kh_admin/features/offers/model/offer_list_item.dart';

part 'offer_list_page.freezed.dart';

/// Cursor-paginated slice of the admin offers list (ADM-S10).
@freezed
class OfferListPage with _$OfferListPage {
  const OfferListPage._();

  const factory OfferListPage({
    required List<OfferListItem> items,
    String? nextCursor,
    bool? hasMore,
    int? totalCount,
  }) = _OfferListPage;

  bool get canLoadMore {
    if (hasMore == false) return false;
    final cursor = nextCursor;
    return cursor != null && cursor.isNotEmpty;
  }
}
