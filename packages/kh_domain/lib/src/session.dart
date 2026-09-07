import 'party.dart';
import 'vendor_lifecycle.dart';

class CustomerMe {
  const CustomerMe({
    required this.displayName,
    required this.reviewCount,
    required this.connectionCount,
    this.photoUrl,
    this.defaultRegion,
    this.rating,
    this.liveRequestCount,
    this.canCreateRequest,
    this.lifetimeRequestCount,
  });

  final String displayName;
  final String? photoUrl;
  final RegionSummary? defaultRegion;
  final RatingSummary? rating;
  final int reviewCount;
  final int connectionCount;
  final int? liveRequestCount;
  final bool? canCreateRequest;
  final int? lifetimeRequestCount;

  static CustomerMe fromJson(Map<String, dynamic> j) => CustomerMe(
        displayName: j['displayName'] as String? ?? '',
        photoUrl: j['photoUrl'] as String?,
        defaultRegion: RegionSummary.tryParse(j['defaultRegion']),
        rating: RatingSummary.tryParse(j['rating']),
        reviewCount: (j['reviewCount'] as num?)?.toInt() ?? 0,
        connectionCount: (j['connectionCount'] as num?)?.toInt() ?? 0,
        liveRequestCount: (j['liveRequestCount'] as num?)?.toInt(),
        canCreateRequest: j['canCreateRequest'] as bool?,
        lifetimeRequestCount: (j['lifetimeRequestCount'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (defaultRegion != null) 'defaultRegion': defaultRegion!.id,
        if (rating != null) 'rating': rating!.toJson(),
        'reviewCount': reviewCount,
        'connectionCount': connectionCount,
        if (liveRequestCount != null) 'liveRequestCount': liveRequestCount,
        if (canCreateRequest != null) 'canCreateRequest': canCreateRequest,
        if (lifetimeRequestCount != null)
          'lifetimeRequestCount': lifetimeRequestCount,
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

  static VendorMe fromJson(Map<String, dynamic> j) {
    List<String> strs(Object? raw) => (raw as List? ?? const [])
        .map((e) => e.toString())
        .toList(growable: false);

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
    );
  }

  Map<String, dynamic> toJson() => {
        'vendorProfileId': vendorProfileId,
        'lifecycle': lifecycle.name.toUpperCase(),
        'awaitingApproval': awaitingApproval,
        'tradingName': tradingName,
        'legalBusinessName': legalBusinessName,
        'categoryCount': categoryCount,
        'regionCount': regionCount,
        'categoryIds': categoryIds,
        'regionIds': regionIds,
        'awayMode': awayMode,
        if (awaitingApprovalReason != null)
          'awaitingApprovalReason': awaitingApprovalReason!.name.toUpperCase(),
        if (verificationMessage != null)
          'verificationMessage': verificationMessage,
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
  final VendorMe? vendor;
  final CustomerMe? customer;
  final bool oauthBound;
  final int? liveRequestCount;
  final bool? canCreateRequest;
  final AccountState accountState;
  final DateTime? createdAt;

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
