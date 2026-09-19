import 'package:freezed_annotation/freezed_annotation.dart';

import 'party.dart';
import 'vendor_lifecycle.dart';

part 'session.freezed.dart';
part 'session.g.dart';

/// `defaultRegion` serializes as just the region id, matching the pre-freezed
/// manual `toJson` (the wire never round-trips a full nested region object
/// back for this field).
class _DefaultRegionConverter
    implements JsonConverter<RegionSummary?, Object?> {
  const _DefaultRegionConverter();

  @override
  RegionSummary? fromJson(Object? json) => RegionSummary.tryParse(json);

  @override
  Object? toJson(RegionSummary? object) => object?.id;
}

class _NullableRatingSummaryConverter
    implements JsonConverter<RatingSummary?, Object?> {
  const _NullableRatingSummaryConverter();

  @override
  RatingSummary? fromJson(Object? json) => RatingSummary.tryParse(json);

  @override
  Object? toJson(RatingSummary? object) => object?.toJson();
}

Map<String, dynamic> _normalizeCustomerMeJson(Map<String, dynamic> json) => {
      'displayName': json['displayName'] as String? ?? '',
      'photoUrl': json['photoUrl'] as String?,
      'defaultRegion': json['defaultRegion'],
      'rating': json['rating'],
      'reviewCount': (json['reviewCount'] as num?)?.toInt() ?? 0,
      'connectionCount': (json['connectionCount'] as num?)?.toInt() ?? 0,
      'liveRequestCount': (json['liveRequestCount'] as num?)?.toInt(),
      'canCreateRequest': json['canCreateRequest'] as bool?,
      'lifetimeRequestCount': (json['lifetimeRequestCount'] as num?)?.toInt(),
    };

@freezed
abstract class CustomerMe with _$CustomerMe {
  const factory CustomerMe({
    required String displayName,
    required int reviewCount,
    required int connectionCount,
    String? photoUrl,
    @_DefaultRegionConverter() RegionSummary? defaultRegion,
    @_NullableRatingSummaryConverter() RatingSummary? rating,
    int? liveRequestCount,
    bool? canCreateRequest,
    int? lifetimeRequestCount,
  }) = _CustomerMe;

  factory CustomerMe.fromJson(Map<String, dynamic> json) =>
      _$CustomerMeFromJson(_normalizeCustomerMeJson(json));
}

/// One weekday entry in `VendorMe.businessHours` / availability PATCH.
Map<String, dynamic> _normalizeBusinessDayHoursJson(
        Map<String, dynamic> json) =>
    {
      'open': json['open'] as String? ?? '',
      'close': json['close'] as String? ?? '',
      'closed': json['closed'] as bool? ?? false,
    };

@freezed
abstract class BusinessDayHours with _$BusinessDayHours {
  const factory BusinessDayHours({
    required String open,
    required String close,
    @Default(false) bool closed,
  }) = _BusinessDayHours;

  factory BusinessDayHours.fromJson(Map<String, dynamic> json) =>
      _$BusinessDayHoursFromJson(_normalizeBusinessDayHoursJson(json));

  static BusinessDayHours? tryParse(Object? raw) {
    if (raw is! Map) return null;
    return BusinessDayHours.fromJson(Map<String, dynamic>.from(raw));
  }
}

class VendorMe {
  const VendorMe({
    required this.vendorProfileId,
    required this.lifecycle,
    required this.awaitingApproval,
    required this.tradingName,
    required this.legalBusinessName,
    required this.categoryCount,
    required this.regionCount,
    this.categoryIds = const [],
    this.regionIds = const [],
    this.awayMode = false,
    this.awaitingApprovalReason,
    this.verificationMessage,
    this.verifiedAt,
    this.rating,
    this.offersSubmittedCount = 0,
    this.connectionCount = 0,
    this.maskedPreview,
    this.description,
    this.tradeLicenceNumber = '',
    this.registeredAddress = '',
    this.contactPersonName = '',
    this.businessEmail = '',
    this.businessHours = const {},
  });

  final String vendorProfileId;
  final VendorLifecycle lifecycle;
  final bool awaitingApproval;
  final String tradingName;
  final String legalBusinessName;
  final String tradeLicenceNumber;
  final String registeredAddress;
  final int categoryCount;
  final int regionCount;
  final List<String> categoryIds;
  final List<String> regionIds;
  final bool awayMode;
  final AwaitingApprovalReason? awaitingApprovalReason;
  final String? verificationMessage;

  /// FR-VEN-024 AC3 — verification date (UTC).
  final DateTime? verifiedAt;

  /// FR-VEN-024 AC3 / SH-ID-03 aggregate rating.
  final RatingSummary? rating;

  /// FR-VEN-024 AC3 — lifetime Offers submitted.
  final int offersSubmittedCount;

  /// FR-VEN-024 AC3 — lifetime Connections. Falls back to
  /// `offersAcceptedCount` when the wire omits `connectionCount`.
  final int connectionCount;

  /// FR-VEN-024 AC4 — what Customers see pre-acceptance (`maskedPreview`).
  final MaskedParty? maskedPreview;

  /// Safe-edit showroom blurb (VEN-S15 / FR-VEN-024). Not a BR-004 field.
  final String? description;

  /// Safe-edit contact name (VEN-S15).
  final String contactPersonName;

  /// Safe-edit business email (VEN-S15).
  final String businessEmail;

  /// Per-weekday open/close (`mon`…`sun`). Patched via availability.
  final Map<String, BusinessDayHours> businessHours;

  static VendorMe fromJson(Map<String, dynamic> j) {
    List<String> strs(Object? raw) => (raw as List? ?? const [])
        .map((e) => e.toString())
        .toList(growable: false);

    final maskedRaw = j['maskedPreview'];
    final MaskedParty? masked = maskedRaw is Map
        ? MaskedParty.fromJson(
            Map<String, dynamic>.from(maskedRaw),
            role: UserRole.vendor,
          )
        : null;

    final connectionCount = (j['connectionCount'] as num?)?.toInt() ??
        (j['offersAcceptedCount'] as num?)?.toInt() ??
        masked?.dealCount ??
        0;

    final hoursRaw = j['businessHours'];
    final hours = <String, BusinessDayHours>{};
    if (hoursRaw is Map) {
      for (final e in hoursRaw.entries) {
        final day = BusinessDayHours.tryParse(e.value);
        if (day != null) hours[e.key.toString()] = day;
      }
    }

    return VendorMe(
      vendorProfileId: (j['vendorProfileId'] ?? j['id'] ?? '') as String,
      lifecycle: VendorLifecycle.parse(j['lifecycle'] as String?),
      awaitingApproval: j['awaitingApproval'] as bool? ?? true,
      tradingName: j['tradingName'] as String? ?? '',
      legalBusinessName: j['legalBusinessName'] as String? ?? '',
      categoryCount: (j['categoryCount'] as num?)?.toInt() ?? 0,
      regionCount: (j['regionCount'] as num?)?.toInt() ?? 0,
      categoryIds: strs(j['categoryIds']),
      regionIds: strs(j['regionIds']),
      awayMode: j['awayMode'] as bool? ?? false,
      awaitingApprovalReason:
          AwaitingApprovalReason.parse(j['awaitingApprovalReason'] as String?),
      verificationMessage: j['verificationMessage'] as String?,
      verifiedAt: j['verifiedAt'] is String
          ? DateTime.tryParse(j['verifiedAt'] as String)
          : null,
      rating: RatingSummary.tryParse(j['rating']),
      offersSubmittedCount: (j['offersSubmittedCount'] as num?)?.toInt() ?? 0,
      connectionCount: connectionCount,
      maskedPreview: masked,
      description: j['description'] as String?,
      tradeLicenceNumber: j['tradeLicenceNumber'] as String? ?? '',
      registeredAddress: (j['registeredAddress'] ?? j['businessAddress']) as String? ?? '',
      contactPersonName: j['contactPersonName'] as String? ?? '',
      businessEmail: j['businessEmail'] as String? ?? '',
      businessHours: hours,
    );
  }

  Map<String, dynamic> toJson() => {
        'vendorProfileId': vendorProfileId,
        'lifecycle': lifecycle.name.toUpperCase(),
        'awaitingApproval': awaitingApproval,
        'tradingName': tradingName,
        'legalBusinessName': legalBusinessName,
        if (tradeLicenceNumber.isNotEmpty) 'tradeLicenceNumber': tradeLicenceNumber,
        if (registeredAddress.isNotEmpty) 'registeredAddress': registeredAddress,
        'categoryCount': categoryCount,
        'regionCount': regionCount,
        'categoryIds': categoryIds,
        'regionIds': regionIds,
        'awayMode': awayMode,
        if (awaitingApprovalReason != null)
          'awaitingApprovalReason': awaitingApprovalReason!.name.toUpperCase(),
        if (verificationMessage != null)
          'verificationMessage': verificationMessage,
        if (verifiedAt != null) 'verifiedAt': verifiedAt!.toIso8601String(),
        if (rating != null) 'rating': rating!.toJson(),
        'offersSubmittedCount': offersSubmittedCount,
        'connectionCount': connectionCount,
        if (maskedPreview != null) 'maskedPreview': maskedPreview!.toJson(),
        if (description != null) 'description': description,
        'contactPersonName': contactPersonName,
        'businessEmail': businessEmail,
        if (businessHours.isNotEmpty)
          'businessHours': {
            for (final e in businessHours.entries) e.key: e.value.toJson(),
          },
      };
}

class MeUser {
  const MeUser({
    required this.userId,
    required this.userType,
    required this.mobileNumber,
    required this.preferredLanguage,
    this.email,
    this.vendor,
    this.customer,
    this.oauthBound = false,
    this.liveRequestCount,
    this.canCreateRequest,
    this.accountState = AccountState.unknown,
    this.createdAt,
  });

  final String userId;
  final String userType;
  final String mobileNumber;
  final String preferredLanguage;
  final String? email;
  final bool oauthBound;
  final VendorMe? vendor;
  final CustomerMe? customer;
  final int? liveRequestCount;
  final bool? canCreateRequest;
  final AccountState accountState;
  final DateTime? createdAt;

  /// Account role from `userType`. `null` for an unrecognised discriminator
  /// (e.g. `ADMIN`, which has no mobile shell).
  UserRole? get role => UserRole.parse(userType);

  static MeUser fromJson(Map<String, dynamic> j) {
    final customer = j['customer'] == null
        ? null
        : CustomerMe.fromJson(Map<String, dynamic>.from(j['customer'] as Map));
    return MeUser(
      userId: (j['userId'] ?? j['id'] ?? '') as String,
      userType: j['userType'] as String? ?? '',
      mobileNumber: j['mobileNumber'] as String? ?? '',
      preferredLanguage: j['preferredLanguage'] as String? ?? 'en',
      email: j['email'] as String?,
      vendor: j['vendor'] == null
          ? null
          : VendorMe.fromJson(Map<String, dynamic>.from(j['vendor'] as Map)),
      customer: customer,
      oauthBound: j['oauthBound'] as bool? ?? false,
      liveRequestCount: customer?.liveRequestCount ??
          (j['liveRequestCount'] as num?)?.toInt(),
      canCreateRequest: customer?.canCreateRequest ??
          j['canCreateRequest'] as bool?,
      accountState: AccountState.parse(j['accountState'] as String?),
      createdAt: j['createdAt'] is String
          ? DateTime.tryParse(j['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userType': userType,
        'mobileNumber': mobileNumber,
        'preferredLanguage': preferredLanguage,
        if (email != null) 'email': email,
        if (vendor != null) 'vendor': vendor!.toJson(),
        if (customer != null) 'customer': customer!.toJson(),
        'oauthBound': oauthBound,
        if (liveRequestCount != null) 'liveRequestCount': liveRequestCount,
        if (canCreateRequest != null) 'canCreateRequest': canCreateRequest,
        'accountState': accountState.wire,
      };
}
