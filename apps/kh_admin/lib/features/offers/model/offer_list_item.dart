import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:kh_admin/features/offers/model/offer_enums.dart';

part 'offer_list_item.freezed.dart';
part 'offer_list_item.g.dart';

/// One row in `GET /v1/admin/offers` (ADM-S10).
@freezed
class OfferListItem with _$OfferListItem {
  const factory OfferListItem({
    required String id,
    String? reference,
    required String requestId,
    String? requestReference,
    @JsonKey(unknownEnumValue: RequestType.findOrnament)
    RequestType? requestType,
    required String vendorId,
    required String vendorName,
    required double offeredPrice,
    @Default(OfferState.pending)
    @JsonKey(unknownEnumValue: OfferState.pending)
    OfferState state,
    required DateTime submittedAt,
    DateTime? expiresAt,
    String? outcome,
    double? makingCharges,
    double? ratePerGram,
  }) = _OfferListItem;

  factory OfferListItem.fromJson(Map<String, dynamic> json) =>
      _$OfferListItemFromJson(json);
}
