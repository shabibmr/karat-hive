import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:kh_admin/features/vendors/model/vendor_enums.dart';

part 'vendor_list_filters.freezed.dart';

/// Filter bar state for ADM-S05 (`verificationState`, `accountState`, `q`).
@freezed
class VendorListFilters with _$VendorListFilters {
  const factory VendorListFilters({
    VendorVerificationState? verificationState,
    VendorAccountState? accountState,
    @Default('') String query,
  }) = _VendorListFilters;
}
