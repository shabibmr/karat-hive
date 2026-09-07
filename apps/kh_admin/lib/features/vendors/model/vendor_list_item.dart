import 'package:freezed_annotation/freezed_annotation.dart';

import 'vendor_enums.dart';

part 'vendor_list_item.freezed.dart';
part 'vendor_list_item.g.dart';

/// One row in `GET /v1/admin/vendors` (ADM-S05).
@freezed
class VendorListItem with _$VendorListItem {
  const factory VendorListItem({
    required String id,
    required String legalBusinessName,
    required String tradingName,
    @JsonKey(unknownEnumValue: VendorVerificationState.registered)
    required VendorVerificationState verificationState,
    @JsonKey(unknownEnumValue: VendorAccountState.active)
    required VendorAccountState accountState,
    String? tradeLicenceNumber,
    String? region,
    int? offerCount,
    double? acceptanceRate,
    double? rating,
    @JsonKey(name: 'oldestWaitingHours') int? waitingHours,
    @JsonKey(name: 'createdAt') DateTime? registeredAt,
  }) = _VendorListItem;

  factory VendorListItem.fromJson(Map<String, dynamic> json) =>
      _$VendorListItemFromJson(json);
}
