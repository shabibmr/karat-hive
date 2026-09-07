/// Masked vs revealed parties — distinct types so pre-acceptance UI cannot
/// read identity (AD-FE-07, BR-006, NFR-013).
library;

enum PartyRole {
  customer,
  vendor,
  unknown;

  static PartyRole parse(String? raw) => switch (raw) {
        'CUSTOMER' => customer,
        'VENDOR' => vendor,
        _ => unknown,
      };

  String get wire => switch (this) {
        customer => 'CUSTOMER',
        vendor => 'VENDOR',
        unknown => 'UNKNOWN',
      };
}

enum AccountState {
  active,
  suspended,
  deactivated,
  unknown;

  static AccountState parse(String? raw) => switch (raw) {
        'ACTIVE' => active,
        'SUSPENDED' => suspended,
        'DEACTIVATED' => deactivated,
        _ => unknown,
      };

  String get wire => switch (this) {
        active => 'ACTIVE',
        suspended => 'SUSPENDED',
        deactivated => 'DEACTIVATED',
        unknown => 'UNKNOWN',
      };
}

class RegionSummary {
  const RegionSummary({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.parentId,
    this.isActive = true,
    this.displayOrder = 0,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String? parentId;
  final bool isActive;
  final int displayOrder;

  String name(String locale) => locale == 'ar' ? nameAr : nameEn;

  static RegionSummary fromJson(Map<String, dynamic> j) => RegionSummary(
        id: j['id'] as String? ?? '',
        nameEn: j['nameEn'] as String? ?? '',
        nameAr: j['nameAr'] as String? ?? '',
        parentId: j['parentId'] as String?,
        isActive: j['isActive'] as bool? ?? true,
        displayOrder: j['displayOrder'] as int? ?? 0,
      );

  static RegionSummary? tryParse(Object? raw) {
    if (raw is Map<String, dynamic>) return RegionSummary.fromJson(raw);
    if (raw is Map) {
      return RegionSummary.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }
}

class CategorySummary {
  const CategorySummary({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.parentId,
    this.isActive = true,
    this.displayOrder = 0,
    this.icon,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String? parentId;
  final bool isActive;
  final int displayOrder;
  final String? icon;

  String name(String locale) => locale == 'ar' ? nameAr : nameEn;

  static CategorySummary fromJson(Map<String, dynamic> j) => CategorySummary(
        id: j['id'] as String? ?? '',
        nameEn: j['nameEn'] as String? ?? '',
        nameAr: j['nameAr'] as String? ?? '',
        parentId: j['parentId'] as String?,
        isActive: j['isActive'] as bool? ?? true,
        displayOrder: j['displayOrder'] as int? ?? 0,
        icon: j['icon'] as String?,
      );

  static CategorySummary? tryParse(Object? raw) {
    if (raw is Map<String, dynamic>) return CategorySummary.fromJson(raw);
    if (raw is Map) {
      return CategorySummary.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }
}

class RatingSummary {
  const RatingSummary({
    required this.average,
    required this.count,
    this.distribution = const {},
    this.limitedHistory = false,
  });

  final String average;
  final int count;
  final Map<String, int> distribution;
  final bool limitedHistory;

  static RatingSummary fromJson(Map<String, dynamic> j) {
    final distRaw = j['distribution'];
    final dist = <String, int>{};
    if (distRaw is Map) {
      for (final e in distRaw.entries) {
        dist[e.key.toString()] = (e.value as num?)?.toInt() ?? 0;
      }
    }
    final avg = j['average'];
    return RatingSummary(
      average: avg == null ? '0.0' : avg.toString(),
      count: (j['count'] as num?)?.toInt() ?? 0,
      distribution: dist,
      limitedHistory: j['limitedHistory'] as bool? ?? ((j['count'] as num?)?.toInt() ?? 0) < 3,
    );
  }

  static RatingSummary? tryParse(Object? raw) {
    if (raw is Map<String, dynamic>) return RatingSummary.fromJson(raw);
    if (raw is Map) return RatingSummary.fromJson(Map<String, dynamic>.from(raw));
    return null;
  }
}

/// Normalised E.164; `waMeDigits` is digits-only for `wa.me` (Architecture-Frontend §10.3).
class PhoneNumber {
  const PhoneNumber(this.e164);

  final String e164;

  String get waMeDigits => e164.replaceAll(RegExp(r'\D'), '');

  static PhoneNumber parse(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00')) {
      digits = digits.substring(2);
    }
    return PhoneNumber('+$digits');
  }
}

class BusinessDetails {
  const BusinessDetails({
    required this.tradingName,
    required this.legalBusinessName,
    this.contactPersonName,
    this.businessEmail,
    this.businessAddress,
    this.tradeLicenceNumber,
  });

  final String tradingName;
  final String legalBusinessName;
  final String? contactPersonName;
  final String? businessEmail;
  final String? businessAddress;
  final String? tradeLicenceNumber;
}

sealed class Party {
  const Party();
}

/// Everything visible before Acceptance. Has no identity fields at all (AD-FE-07).
class MaskedParty extends Party {
  const MaskedParty({
    required this.role,
    required this.pseudonym,
    required this.region,
    required this.completedConnections,
    this.rating,
  });

  final PartyRole role;
  final String pseudonym;
  final RegionSummary region;
  final RatingSummary? rating;
  final int completedConnections;

  static MaskedParty fromJson(
    Map<String, dynamic> j, {
    PartyRole role = PartyRole.unknown,
  }) {
    return MaskedParty(
      role: role,
      pseudonym: j['label'] as String? ?? j['pseudonym'] as String? ?? '',
      region: RegionSummary.tryParse(j['region']) ??
          const RegionSummary(id: '', nameEn: '', nameAr: ''),
      rating: RatingSummary.tryParse(j['rating']),
      completedConnections: (j['connectionCount'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Constructible only from a payload that included identity — Connection party.
class RevealedParty extends Party {
  const RevealedParty({
    required this.displayName,
    required this.mobile,
    this.address,
    this.business,
    this.rating,
    this.region,
    this.completedConnections,
    this.photoUrl,
  });

  final String displayName;
  final PhoneNumber mobile;
  final String? address;
  final BusinessDetails? business;
  final RatingSummary? rating;
  final RegionSummary? region;
  final int? completedConnections;
  final String? photoUrl;

  static RevealedParty fromVendorJson(Map<String, dynamic> j) {
    final mobileRaw = (j['mobileNumber'] ?? j['phone'] ?? '') as String;
    return RevealedParty(
      displayName: j['tradingName'] as String? ?? j['displayName'] as String? ?? '',
      mobile: PhoneNumber.parse(mobileRaw),
      address: j['businessAddress'] as String?,
      business: BusinessDetails(
        tradingName: j['tradingName'] as String? ?? '',
        legalBusinessName: j['legalBusinessName'] as String? ?? '',
        contactPersonName: j['contactPersonName'] as String?,
        businessEmail: j['businessEmail'] as String?,
        businessAddress: j['businessAddress'] as String?,
        tradeLicenceNumber: j['tradeLicenceNumber'] as String?,
      ),
      rating: RatingSummary.tryParse(j['rating']),
      region: RegionSummary.tryParse(j['region']),
      completedConnections: (j['connectionCount'] as num?)?.toInt(),
      photoUrl: j['logoUrl'] as String?,
    );
  }

  static RevealedParty fromCustomerJson(Map<String, dynamic> j) {
    final mobileRaw = (j['mobileNumber'] ?? j['phone'] ?? '') as String;
    return RevealedParty(
      displayName: j['displayName'] as String? ?? '',
      mobile: PhoneNumber.parse(mobileRaw),
      address: j['address'] as String?,
      rating: RatingSummary.tryParse(j['rating']),
      region: RegionSummary.tryParse(j['region']),
      completedConnections: (j['connectionCount'] as num?)?.toInt(),
      photoUrl: j['photoUrl'] as String?,
    );
  }
}
