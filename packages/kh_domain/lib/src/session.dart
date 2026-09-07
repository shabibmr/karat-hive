import 'package:freezed_annotation/freezed_annotation.dart';

import 'vendor_lifecycle.dart';

part 'session.freezed.dart';
part 'session.g.dart';

class _VendorLifecycleConverter
    implements JsonConverter<VendorLifecycle, String?> {
  const _VendorLifecycleConverter();

  @override
  VendorLifecycle fromJson(String? json) => VendorLifecycle.parse(json);

  @override
  String toJson(VendorLifecycle object) => switch (object) {
        VendorLifecycle.registered => 'REGISTERED',
        VendorLifecycle.pendingVerification => 'PENDING_VERIFICATION',
        VendorLifecycle.verified => 'VERIFIED',
        VendorLifecycle.active => 'ACTIVE',
        VendorLifecycle.suspended => 'SUSPENDED',
        VendorLifecycle.rejected => 'REJECTED',
        VendorLifecycle.deactivated => 'DEACTIVATED',
        VendorLifecycle.unknown => 'UNKNOWN',
      };
}

class _AwaitingApprovalReasonConverter
    implements JsonConverter<AwaitingApprovalReason?, String?> {
  const _AwaitingApprovalReasonConverter();

  @override
  AwaitingApprovalReason? fromJson(String? json) =>
      AwaitingApprovalReason.parse(json);

  @override
  String? toJson(AwaitingApprovalReason? object) => switch (object) {
        null => null,
        AwaitingApprovalReason.pendingDocuments => 'PENDING_DOCUMENTS',
        AwaitingApprovalReason.pendingAdmin => 'PENDING_ADMIN',
        AwaitingApprovalReason.categoriesRequired => 'CATEGORIES_REQUIRED',
        AwaitingApprovalReason.rejected => 'REJECTED',
        AwaitingApprovalReason.unknown => 'UNKNOWN',
      };
}

Map<String, dynamic> _normalizeVendorMeJson(Map<String, dynamic> json) {
  return {
    ...json,
    'awaitingApproval': json['awaitingApproval'] as bool? ?? true,
    'tradingName': json['tradingName'] as String? ?? '',
    'legalBusinessName': json['legalBusinessName'] as String? ?? '',
    'categoryCount': json['categoryCount'] as int? ?? 0,
    'regionCount': json['regionCount'] as int? ?? 0,
    'categoryIds': ((json['categoryIds'] as List?) ?? const [])
        .map((e) => e.toString())
        .toList(growable: false),
    'regionIds': ((json['regionIds'] as List?) ?? const [])
        .map((e) => e.toString())
        .toList(growable: false),
    'awayMode': json['awayMode'] as bool? ?? false,
    // Preserve legacy parse(null) → unknown behaviour via the converter.
    'awaitingApprovalReason': json['awaitingApprovalReason']?.toString(),
  };
}

Map<String, dynamic> _normalizeMeUserJson(Map<String, dynamic> json) {
  final vendor = json['vendor'];
  return {
    ...json,
    'mobileNumber': json['mobileNumber'] as String? ?? '',
    'preferredLanguage': json['preferredLanguage'] as String? ?? 'en',
    'vendor': vendor is Map
        ? Map<String, dynamic>.from(vendor)
        : null,
  };
}

/// Vendor slice of `/me` (CP2-F06 freezed pattern).
@freezed
abstract class VendorMe with _$VendorMe {
  const factory VendorMe({
    required String vendorProfileId,
    @_VendorLifecycleConverter() required VendorLifecycle lifecycle,
    required bool awaitingApproval,
    required String tradingName,
    required String legalBusinessName,
    required int categoryCount,
    required int regionCount,
    @Default(<String>[]) List<String> categoryIds,
    @Default(<String>[]) List<String> regionIds,
    @Default(false) bool awayMode,
    @_AwaitingApprovalReasonConverter()
    AwaitingApprovalReason? awaitingApprovalReason,
    String? verificationMessage,
  }) = _VendorMe;

  factory VendorMe.fromJson(Map<String, dynamic> json) =>
      _$VendorMeFromJson(_normalizeVendorMeJson(json));
}

/// Authenticated user payload from `/me` (CP2-F06 freezed pattern).
@freezed
abstract class MeUser with _$MeUser {
  const factory MeUser({
    required String userId,
    required String userType,
    required String mobileNumber,
    required String preferredLanguage,
    String? email,
    VendorMe? vendor,
  }) = _MeUser;

  factory MeUser.fromJson(Map<String, dynamic> json) =>
      _$MeUserFromJson(_normalizeMeUserJson(json));
}
