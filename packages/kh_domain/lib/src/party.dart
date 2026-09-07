/// Masked vs revealed parties — distinct types so pre-acceptance UI cannot
/// read identity (AD-FE-07, BR-006, NFR-013).
library;

enum UserRole {
  customer,
  vendor,
  unknown;

  static UserRole parse(String? value) {
    if (value == null) return UserRole.unknown;
    return switch (value.toUpperCase().trim()) {
      'CUSTOMER' => UserRole.customer,
      'VENDOR' => UserRole.vendor,
      _ => UserRole.unknown,
    };
  }

  String get wireName => switch (this) {
        UserRole.customer => 'CUSTOMER',
        UserRole.vendor => 'VENDOR',
        UserRole.unknown => 'UNKNOWN',
      };

  String get wire => wireName;
}

typedef PartyRole = UserRole;

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

  const RegionSummary.named(String name)
      : id = name,
        nameEn = name,
        nameAr = name,
        parentId = null,
        isActive = true,
        displayOrder = 0;

  final String id;
  final String nameEn;
  final String nameAr;
  final String? parentId;
  final bool isActive;
  final int displayOrder;

  String name(String locale) => locale == 'ar' ? nameAr : nameEn;

  bool get isNotEmpty => id.isNotEmpty || nameEn.isNotEmpty;

  static RegionSummary fromJson(Map<String, dynamic> j) => RegionSummary(
        id: j['id'] as String? ?? '',
        nameEn: j['nameEn'] as String? ?? '',
        nameAr: j['nameAr'] as String? ?? '',
        parentId: j['parentId'] as String?,
        isActive: j['isActive'] as bool? ?? true,
        displayOrder: j['displayOrder'] as int? ?? 0,
      );

  static RegionSummary? tryParse(Object? raw) {
    if (raw is RegionSummary) return raw;
    if (raw is String) return RegionSummary.named(raw);
    if (raw is Map<String, dynamic>) return RegionSummary.fromJson(raw);
    if (raw is Map) {
      return RegionSummary.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  @override
  String toString() => nameEn;
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
    if (raw is CategorySummary) return raw;
    if (raw is Map<String, dynamic>) return CategorySummary.fromJson(raw);
    if (raw is Map) {
      return CategorySummary.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  @override
  String toString() => nameEn;
}

/// Rating summary model carrying average score and review counts (SH-ID-03).
class RatingSummary {
  const RatingSummary({
    required this.average,
    this.count = 0,
    this.distribution = const {},
    this.limitedHistory = false,
  });

  /// Convenience constructor from a simple numeric score.
  const RatingSummary.score(this.average, [this.count = 0])
      : distribution = const {},
        limitedHistory = count < 3;

  final double average;
  final int count;
  final Map<String, int> distribution;
  final bool limitedHistory;

  String get averageString => average.toStringAsFixed(1);
  double get averageScore => average;

  static RatingSummary? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is RatingSummary) return json;
    if (json is num) {
      return RatingSummary.score(json.toDouble(), 1);
    }
    if (json is String) {
      final parsed = double.tryParse(json);
      return parsed != null ? RatingSummary.score(parsed, 1) : null;
    }
    if (json is Map) {
      final j = Map<String, dynamic>.from(json);
      final avgRaw = j['average'];
      final avg = avgRaw is num
          ? avgRaw.toDouble()
          : double.tryParse(avgRaw?.toString() ?? '') ?? 0.0;
      final count = (j['count'] as num?)?.toInt() ?? 0;
      final distRaw = j['distribution'] as Map?;
      final dist = <String, int>{};
      if (distRaw != null) {
        for (final entry in distRaw.entries) {
          dist[entry.key.toString()] = (entry.value as num?)?.toInt() ?? 0;
        }
      }
      final limited = j['limitedHistory'] as bool? ?? (count < 3);
      return RatingSummary(
        average: avg,
        count: count,
        distribution: dist,
        limitedHistory: limited,
      );
    }
    return null;
  }

  static RatingSummary? tryParse(Object? raw) => fromJson(raw);

  Map<String, dynamic> toJson() => {
        'average': average.toStringAsFixed(1),
        'count': count,
        if (distribution.isNotEmpty) 'distribution': distribution,
        'limitedHistory': limitedHistory,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RatingSummary &&
          runtimeType == other.runtimeType &&
          average == other.average &&
          count == other.count &&
          limitedHistory == other.limitedHistory;

  @override
  int get hashCode => Object.hash(average, count, limitedHistory);

  @override
  String toString() =>
      'RatingSummary(average: $average, count: $count, limitedHistory: $limitedHistory)';
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is PhoneNumber) return e164 == other.e164;
    if (other is String) return e164 == other || waMeDigits == other;
    return false;
  }

  @override
  int get hashCode => e164.hashCode;

  @override
  String toString() => e164;
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

  @override
  String toString() => tradingName.isNotEmpty ? tradingName : legalBusinessName;
}

String? _parseRegion(dynamic raw) {
  if (raw == null) return null;
  if (raw is String) return raw;
  if (raw is RegionSummary) return raw.nameEn;
  if (raw is Map<String, dynamic>) {
    return raw['nameEn'] as String? ??
        raw['name'] as String? ??
        raw['id'] as String?;
  }
  return raw.toString();
}

int _parseDealCount(Map<String, dynamic> json) {
  final raw = json['dealCount'] ??
      json['completedConnections'] ??
      json['connectionCount'];
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  if (raw is String) return int.tryParse(raw) ?? 0;
  return 0;
}

String? _parseAddress(dynamic raw) {
  if (raw == null) return null;
  if (raw is String) return raw;
  if (raw is Map<String, dynamic>) {
    final parts = [
      raw['street'],
      raw['city'],
      raw['region'],
      raw['country'],
    ].where((e) => e != null && e.toString().trim().isNotEmpty).join(', ');
    return parts.isNotEmpty ? parts : raw.toString();
  }
  return raw.toString();
}

BusinessDetails? _parseBusiness(dynamic raw) {
  if (raw == null) return null;
  if (raw is BusinessDetails) return raw;
  if (raw is String) {
    return BusinessDetails(tradingName: raw, legalBusinessName: raw);
  }
  if (raw is Map<String, dynamic>) {
    return BusinessDetails(
      tradingName: raw['tradingName'] as String? ?? '',
      legalBusinessName: raw['legalBusinessName'] as String? ?? '',
      contactPersonName: raw['contactPersonName'] as String?,
      businessEmail: raw['businessEmail'] as String?,
      businessAddress: raw['businessAddress'] as String?,
      tradeLicenceNumber: raw['tradeLicenceNumber'] as String?,
    );
  }
  return null;
}

Map<String, dynamic> _normalizeMaskedPartyJson(Map<String, dynamic> json) {
  return {
    'role': (json['role'] ?? json['userType'] ?? json['partyRole'])?.toString(),
    'region': _parseRegion(json['region']),
    'pseudonym': json['label'] ?? json['pseudonym'],
    'rating': json['rating'],
    'dealCount': _parseDealCount(json),
  };
}

Map<String, dynamic> _normalizeRevealedPartyJson(Map<String, dynamic> json) {
  final name =
      (json['name'] as String? ?? json['displayName'] as String?)?.trim();
  final mobile = (json['mobile'] as String? ??
          json['mobileNumber'] as String? ??
          json['phone'] as String? ??
          json['phoneNumber'] as String?)
      ?.trim();

  return {
    'name': name,
    'mobile': mobile,
    'role': (json['role'] ?? json['userType'] ?? json['partyRole'])?.toString(),
    'address': _parseAddress(json['address']),
    'business': _parseBusiness(json['business'] ?? json['legalBusinessName']),
    'rating': json['rating'],
    'dealCount': _parseDealCount(json),
  };
}

/// Abstract representation of a counterparty in Karat Hive.
sealed class Party {
  const Party();

  UserRole get role;
  RatingSummary? get rating;
  int get dealCount;

  /// Alias for [dealCount] matching architecture naming conventions.
  int get completedConnections;

  /// Convenience accessor for the numeric rating average if available.
  double? get ratingScore;

  /// Whether this party's identity has been revealed (post-Acceptance).
  bool get isRevealed;

  /// Whether this party is masked (pre-Acceptance).
  bool get isMasked;

  factory Party.fromJson(Map<String, dynamic> json) {
    final name =
        (json['name'] as String? ?? json['displayName'] as String?)?.trim();
    final mobile = (json['mobile'] as String? ??
            json['mobileNumber'] as String? ??
            json['phone'] as String? ??
            json['phoneNumber'] as String?)
        ?.trim();

    final isExplicitlyMasked = json['isMasked'] == true ||
        json['type']?.toString().toUpperCase() == 'MASKED' ||
        json['revealed'] == false;

    final hasIdentity = !isExplicitlyMasked &&
        name != null &&
        name.isNotEmpty &&
        mobile != null &&
        mobile.isNotEmpty;

    if (hasIdentity) {
      return RevealedParty.fromJson(json);
    } else {
      return MaskedParty.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();
}

/// A counterparty whose identity is hidden before Acceptance (AD-FE-07).
class MaskedParty extends Party {
  const MaskedParty({
    required this.role,
    this.region,
    this.pseudonym,
    this.rating,
    this.dealCount = 0,
  });

  @override
  final UserRole role;
  final String? region;
  final String? pseudonym;
  @override
  final RatingSummary? rating;
  @override
  final int dealCount;

  String get displayPseudonym {
    if (pseudonym != null && pseudonym!.trim().isNotEmpty) {
      return pseudonym!;
    }
    final roleLabel = role == UserRole.vendor
        ? 'Vendor'
        : role == UserRole.customer
            ? 'Customer'
            : 'Counterparty';
    return region != null && region!.trim().isNotEmpty
        ? '$roleLabel in $region'
        : roleLabel;
  }

  @override
  int get completedConnections => dealCount;

  @override
  double? get ratingScore => rating?.average;

  @override
  bool get isRevealed => false;

  @override
  bool get isMasked => true;

  MaskedParty copyWith({
    UserRole? role,
    String? region,
    String? pseudonym,
    RatingSummary? rating,
    int? dealCount,
  }) {
    return MaskedParty(
      role: role ?? this.role,
      region: region ?? this.region,
      pseudonym: pseudonym ?? this.pseudonym,
      rating: rating ?? this.rating,
      dealCount: dealCount ?? this.dealCount,
    );
  }

  factory MaskedParty.fromJson(
    Map<String, dynamic> json, {
    UserRole role = UserRole.unknown,
  }) {
    final normalized = _normalizeMaskedPartyJson(json);
    final finalRole = normalized['role'] != null
        ? UserRole.parse(normalized['role'] as String?)
        : role;
    return MaskedParty(
      role: finalRole,
      region: normalized['region'] as String?,
      pseudonym: normalized['pseudonym'] as String?,
      rating: RatingSummary.fromJson(normalized['rating']),
      dealCount: (normalized['dealCount'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'role': role.wireName,
        if (region != null) 'region': region,
        if (pseudonym != null) 'pseudonym': pseudonym,
        if (rating != null) 'rating': rating!.toJson(),
        'dealCount': dealCount,
        'isMasked': true,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaskedParty &&
          runtimeType == other.runtimeType &&
          role == other.role &&
          region == other.region &&
          pseudonym == other.pseudonym &&
          rating == other.rating &&
          dealCount == other.dealCount;

  @override
  int get hashCode => Object.hash(role, region, pseudonym, rating, dealCount);
}

/// A counterparty whose identity has been revealed post-Acceptance (AD-FE-07).
class RevealedParty extends Party {
  const RevealedParty._({
    required this.displayName,
    required this.mobile,
    this.role = UserRole.unknown,
    this.address,
    this.business,
    this.rating,
    this.region,
    this.completedConnections = 0,
    this.dealCount = 0,
    this.photoUrl,
  });

  factory RevealedParty({
    String? displayName,
    String? name,
    required dynamic mobile,
    UserRole role = UserRole.unknown,
    String? address,
    dynamic business,
    RatingSummary? rating,
    RegionSummary? region,
    int? completedConnections,
    int dealCount = 0,
    String? photoUrl,
  }) {
    final finalName = displayName ?? name ?? '';
    final PhoneNumber finalMobile = mobile is PhoneNumber
        ? mobile
        : PhoneNumber.parse(mobile?.toString() ?? '');
    final BusinessDetails? finalBusiness = business is BusinessDetails
        ? business
        : (business != null && business.toString().isNotEmpty
            ? BusinessDetails(
                tradingName: business.toString(),
                legalBusinessName: business.toString(),
              )
            : null);
    final count = dealCount != 0 ? dealCount : (completedConnections ?? 0);
    return RevealedParty._(
      displayName: finalName,
      mobile: finalMobile,
      role: role,
      address: address,
      business: finalBusiness,
      rating: rating,
      region: region,
      completedConnections: count,
      dealCount: count,
      photoUrl: photoUrl,
    );
  }

  final String displayName;
  final PhoneNumber mobile;
  @override
  final UserRole role;
  final String? address;
  final BusinessDetails? business;
  @override
  final RatingSummary? rating;
  final RegionSummary? region;
  @override
  final int completedConnections;
  @override
  final int dealCount;
  final String? photoUrl;

  String get name => displayName;

  @override
  double? get ratingScore => rating?.average;

  @override
  bool get isRevealed => true;

  @override
  bool get isMasked => false;

  RevealedParty copyWith({
    String? displayName,
    PhoneNumber? mobile,
    UserRole? role,
    String? address,
    BusinessDetails? business,
    RatingSummary? rating,
    RegionSummary? region,
    int? completedConnections,
    int? dealCount,
    String? photoUrl,
  }) {
    return RevealedParty(
      displayName: displayName ?? this.displayName,
      mobile: mobile ?? this.mobile,
      role: role ?? this.role,
      address: address ?? this.address,
      business: business ?? this.business,
      rating: rating ?? this.rating,
      region: region ?? this.region,
      completedConnections: completedConnections ?? this.completedConnections,
      dealCount: dealCount ?? this.dealCount,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  factory RevealedParty.fromJson(Map<String, dynamic> json) {
    final normalized = _normalizeRevealedPartyJson(json);
    final name = normalized['name'] as String?;
    final mobile = normalized['mobile'] as String?;

    if (name == null || name.isEmpty) {
      throw const FormatException(
        'Cannot construct RevealedParty: missing or empty identity field "name" / "displayName".',
      );
    }
    if (mobile == null || mobile.isEmpty) {
      throw const FormatException(
        'Cannot construct RevealedParty: missing or empty identity field "mobile" / "mobileNumber".',
      );
    }

    final count = (normalized['dealCount'] as num?)?.toInt() ?? 0;
    return RevealedParty(
      displayName: name,
      mobile: PhoneNumber.parse(mobile),
      role: UserRole.parse(normalized['role'] as String?),
      address: normalized['address'] as String?,
      business: _parseBusiness(normalized['business']),
      rating: RatingSummary.fromJson(normalized['rating']),
      completedConnections: count,
      dealCount: count,
    );
  }

  static RevealedParty fromVendorJson(Map<String, dynamic> j) {
    final mobileRaw = (j['mobileNumber'] ?? j['phone'] ?? '') as String;
    final count = (j['connectionCount'] as num?)?.toInt() ?? 0;
    return RevealedParty(
      displayName: j['tradingName'] as String? ?? j['displayName'] as String? ?? '',
      mobile: PhoneNumber.parse(mobileRaw),
      role: UserRole.vendor,
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
      completedConnections: count,
      dealCount: count,
      photoUrl: j['logoUrl'] as String?,
    );
  }

  static RevealedParty fromCustomerJson(Map<String, dynamic> j) {
    final mobileRaw = (j['mobileNumber'] ?? j['phone'] ?? '') as String;
    final count = (j['connectionCount'] as num?)?.toInt() ?? 0;
    return RevealedParty(
      displayName: j['displayName'] as String? ?? '',
      mobile: PhoneNumber.parse(mobileRaw),
      role: UserRole.customer,
      address: j['address'] as String?,
      rating: RatingSummary.tryParse(j['rating']),
      region: RegionSummary.tryParse(j['region']),
      completedConnections: count,
      dealCount: count,
      photoUrl: j['photoUrl'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'mobile': mobile.e164,
        'role': role.wireName,
        if (address != null) 'address': address,
        if (business != null) 'business': business!.tradingName,
        if (rating != null) 'rating': rating!.toJson(),
        'dealCount': dealCount,
        'isRevealed': true,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RevealedParty &&
          runtimeType == other.runtimeType &&
          displayName == other.displayName &&
          mobile == other.mobile &&
          role == other.role &&
          address == other.address &&
          business?.tradingName == other.business?.tradingName &&
          rating == other.rating &&
          dealCount == other.dealCount;

  @override
  int get hashCode => Object.hash(displayName, mobile, role, address, rating, dealCount);
}
