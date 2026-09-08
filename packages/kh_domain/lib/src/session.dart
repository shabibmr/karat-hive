import 'vendor_lifecycle.dart';

/// Account role, derived from the backend `userType` discriminator. The mobile
/// binary is dual-mode: one account has exactly one role and the role gate
/// (`SH-SHELL-04`) routes the session to the matching shell
/// (Architecture-Frontend §4.3, §7.2).
enum UserRole {
  customer,
  vendor;

  static UserRole? parse(String? raw) => switch (raw?.toUpperCase()) {
        'CUSTOMER' => customer,
        'VENDOR' => vendor,
        _ => null,
      };
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
  });

  final String vendorProfileId;
  final VendorLifecycle lifecycle;
  final bool awaitingApproval;
  final String tradingName;
  final String legalBusinessName;
  final int categoryCount;
  final int regionCount;
  final List<String> categoryIds;
  final List<String> regionIds;
  final bool awayMode;
  final AwaitingApprovalReason? awaitingApprovalReason;
  final String? verificationMessage;

  static VendorMe fromJson(Map<String, dynamic> j) => VendorMe(
        vendorProfileId: j['vendorProfileId'] as String,
        lifecycle: VendorLifecycle.parse(j['lifecycle'] as String?),
        awaitingApproval: j['awaitingApproval'] as bool? ?? true,
        tradingName: j['tradingName'] as String? ?? '',
        legalBusinessName: j['legalBusinessName'] as String? ?? '',
        categoryCount: j['categoryCount'] as int? ?? 0,
        regionCount: j['regionCount'] as int? ?? 0,
        categoryIds: ((j['categoryIds'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(growable: false),
        regionIds: ((j['regionIds'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(growable: false),
        awayMode: j['awayMode'] as bool? ?? false,
        awaitingApprovalReason:
            AwaitingApprovalReason.parse(j['awaitingApprovalReason'] as String?),
        verificationMessage: j['verificationMessage'] as String?,
      );
}

/// A named region reference as it appears on the Customer profile
/// (`me.presenter.ts` `CustomerMe.defaultRegion`).
class ProfileRegionRef {
  const ProfileRegionRef({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  final String id;
  final String nameEn;
  final String nameAr;

  static ProfileRegionRef? fromJson(Map<String, dynamic>? j) => j == null
      ? null
      : ProfileRegionRef(
          id: j['id'] as String? ?? '',
          nameEn: j['nameEn'] as String? ?? '',
          nameAr: j['nameAr'] as String? ?? '',
        );
}

/// A rating summary as it appears on the Customer profile
/// (`me.presenter.ts` `CustomerMe.rating` — `average` is a number here, unlike
/// the string-encoded ratings on the marketplace presenters).
class ProfileRatingSummary {
  const ProfileRatingSummary({required this.average, required this.count});

  final double average;
  final int count;

  static ProfileRatingSummary? fromJson(Map<String, dynamic>? j) => j == null
      ? null
      : ProfileRatingSummary(
          average: (j['average'] as num?)?.toDouble() ?? 0,
          count: j['count'] as int? ?? 0,
        );
}

/// Customer profile block on `GET /v1/me` (`me.presenter.ts` `CustomerMe`).
///
/// `liveRequestCount` / `canCreateRequest` back the `CUS-S03` concurrent-request
/// gate (`SAM-GAP-2`); they are optional because the backend only computes them
/// on the authenticated `GET /v1/me`.
class CustomerMe {
  const CustomerMe({
    required this.displayName,
    this.photoUrl,
    this.defaultRegion,
    this.rating,
    required this.reviewCount,
    required this.connectionCount,
    this.liveRequestCount,
    this.canCreateRequest,
  });

  final String displayName;
  final String? photoUrl;
  final ProfileRegionRef? defaultRegion;
  final ProfileRatingSummary? rating;
  final int reviewCount;
  final int connectionCount;
  final int? liveRequestCount;
  final bool? canCreateRequest;

  static CustomerMe fromJson(Map<String, dynamic> j) => CustomerMe(
        displayName: j['displayName'] as String? ?? '',
        photoUrl: j['photoUrl'] as String?,
        defaultRegion:
            ProfileRegionRef.fromJson(j['defaultRegion'] as Map<String, dynamic>?),
        rating: ProfileRatingSummary.fromJson(j['rating'] as Map<String, dynamic>?),
        reviewCount: j['reviewCount'] as int? ?? 0,
        connectionCount: j['connectionCount'] as int? ?? 0,
        liveRequestCount: j['liveRequestCount'] as int?,
        canCreateRequest: j['canCreateRequest'] as bool?,
      );
}

class MeUser {
  const MeUser({
    required this.userId,
    required this.userType,
    required this.mobileNumber,
    required this.preferredLanguage,
    this.email,
    this.oauthBound,
    this.vendor,
    this.customer,
  });

  final String userId;
  final String userType;
  final String mobileNumber;
  final String preferredLanguage;
  final String? email;
  final bool? oauthBound;
  final VendorMe? vendor;
  final CustomerMe? customer;

  /// Account role from `userType`. `null` for an unrecognised discriminator
  /// (e.g. `ADMIN`, which has no mobile shell).
  UserRole? get role => UserRole.parse(userType);

  static MeUser fromJson(Map<String, dynamic> j) => MeUser(
        userId: j['userId'] as String,
        userType: j['userType'] as String,
        mobileNumber: j['mobileNumber'] as String? ?? '',
        preferredLanguage: j['preferredLanguage'] as String? ?? 'en',
        email: j['email'] as String?,
        oauthBound: j['oauthBound'] as bool?,
        vendor: j['vendor'] == null
            ? null
            : VendorMe.fromJson(j['vendor'] as Map<String, dynamic>),
        customer: j['customer'] == null
            ? null
            : CustomerMe.fromJson(j['customer'] as Map<String, dynamic>),
      );
}
