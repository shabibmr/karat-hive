import 'package:json_annotation/json_annotation.dart';

/// Vendor KYC verification state (`VendorVerificationState` in Prisma).
@JsonEnum(alwaysCreate: true)
enum VendorVerificationState {
  @JsonValue('REGISTERED')
  registered,
  @JsonValue('PENDING_VERIFICATION')
  pendingVerification,
  @JsonValue('VERIFIED')
  verified,
  @JsonValue('REJECTED')
  rejected;

  String get apiValue {
    switch (this) {
      case VendorVerificationState.registered:
        return 'REGISTERED';
      case VendorVerificationState.pendingVerification:
        return 'PENDING_VERIFICATION';
      case VendorVerificationState.verified:
        return 'VERIFIED';
      case VendorVerificationState.rejected:
        return 'REJECTED';
    }
  }

  static VendorVerificationState? fromApi(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final state in VendorVerificationState.values) {
      if (state.apiValue == value) return state;
    }
    return null;
  }
}

/// Marketplace login state for vendor users (`UserAccountState` in Prisma).
@JsonEnum(alwaysCreate: true)
enum VendorAccountState {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('SUSPENDED')
  suspended,
  @JsonValue('DEACTIVATED')
  deactivated;

  String get apiValue {
    switch (this) {
      case VendorAccountState.active:
        return 'ACTIVE';
      case VendorAccountState.suspended:
        return 'SUSPENDED';
      case VendorAccountState.deactivated:
        return 'DEACTIVATED';
    }
  }

  static VendorAccountState? fromApi(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final state in VendorAccountState.values) {
      if (state.apiValue == value) return state;
    }
    return null;
  }
}
