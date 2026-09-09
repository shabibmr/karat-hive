import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:kh_admin/features/offers/model/offer_enums.dart';

part 'offer_list_filters.freezed.dart';

/// Filter bar state for ADM-S10 (`state`, `requestType`, `q`).
@freezed
class OfferListFilters with _$OfferListFilters {
  const factory OfferListFilters({
    OfferState? state,
    RequestType? requestType,
    @Default('') String query,
    String? vendorId,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? minPrice,
    double? maxPrice,
  }) = _OfferListFilters;
}
