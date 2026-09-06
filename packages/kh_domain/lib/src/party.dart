/// User/Party role enumeration matching AD-FE-07 and backend conventions.
enum UserRole {
  customer,
  vendor,
  unknown;

  /// Parses a string wire value (e.g. 'CUSTOMER', 'VENDOR') into a [UserRole].
  ///
  /// Falls back to [UserRole.unknown] on unrecognised or null inputs (NFR-027).
  static UserRole parse(String? value) {
    if (value == null) return UserRole.unknown;
    return switch (value.toUpperCase().trim()) {
      'CUSTOMER' => UserRole.customer,
      'VENDOR' => UserRole.vendor,
      _ => UserRole.unknown,
    };
  }

  /// The uppercase wire representation sent to and from the API.
  String get wireName => switch (this) {
        UserRole.customer => 'CUSTOMER',
        UserRole.vendor => 'VENDOR',
        UserRole.unknown => 'UNKNOWN',
      };
}

/// Alias for [UserRole] matching architecture docs.
typedef PartyRole = UserRole;

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
    if (json is Map<String, dynamic>) {
      final avgRaw = json['average'];
      final avg = avgRaw is num
          ? avgRaw.toDouble()
          : double.tryParse(avgRaw?.toString() ?? '') ?? 0.0;
      final count = (json['count'] as num?)?.toInt() ?? 0;
      final distRaw = json['distribution'] as Map?;
      final dist = <String, int>{};
      if (distRaw != null) {
        for (final entry in distRaw.entries) {
          dist[entry.key.toString()] = (entry.value as num?)?.toInt() ?? 0;
        }
      }
      final limited = json['limitedHistory'] as bool? ?? (count < 3);
      return RatingSummary(
        average: avg,
        count: count,
        distribution: dist,
        limitedHistory: limited,
      );
    }
    return null;
  }

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

/// Abstract representation of a counterparty in Karat Hive.
///
/// Under AD-FE-07 ("masking as a type"), pre-acceptance screens hold a
/// [MaskedParty] which has NO identity fields (name, mobile, address).
/// Identity fields exist ONLY on [RevealedParty].
///
/// Because this is a `sealed class`, exhaustive pattern matching is
/// compiler-enforced.
sealed class Party {
  const Party({
    required this.role,
    this.rating,
    this.dealCount = 0,
  });

  /// The party's platform role ([UserRole.customer] or [UserRole.vendor]).
  final UserRole role;

  /// Optional rating summary (SH-ID-03).
  final RatingSummary? rating;

  /// Number of completed transactions / connections (SH-ID-07).
  final int dealCount;

  /// Alias for [dealCount] matching architecture naming conventions.
  int get completedConnections => dealCount;

  /// Convenience accessor for the numeric rating average if available.
  double? get ratingScore => rating?.average;

  /// Whether this party's identity has been revealed (post-Acceptance).
  bool get isRevealed => this is RevealedParty;

  /// Whether this party is masked (pre-Acceptance).
  bool get isMasked => this is MaskedParty;

  /// Deserializes a party payload from JSON into either a [MaskedParty]
  /// or a [RevealedParty].
  ///
  /// If the payload contains valid identity fields ([name]/[displayName] and [mobile]),
  /// and is not explicitly flagged as masked, a [RevealedParty] is constructed.
  /// Otherwise, a [MaskedParty] is constructed. Pre-acceptance payloads can NEVER
  /// produce a [RevealedParty].
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

  /// Serializes the party to a JSON map.
  Map<String, dynamic> toJson();
}

/// A counterparty whose identity is hidden before Acceptance (AD-FE-07).
///
/// Pre-acceptance screens (VEN-S06 feed, offer creation, etc.) can ONLY
/// construct and consume [MaskedParty].
/// It structurally lacks [name], [mobile], and [address] so the UI cannot
/// reference them even by accident.
final class MaskedParty extends Party {
  const MaskedParty({
    required super.role,
    this.region,
    this.pseudonym,
    super.rating,
    super.dealCount = 0,
  });

  /// Geographic region of the party (e.g. "Deira", "Dubai").
  final String? region;

  /// Display pseudonym (e.g. "Vendor in Deira", "Customer in Sharjah").
  final String? pseudonym;

  /// Returns the explicit pseudonym, or generates a safe masked label
  /// from the role and region (e.g. "Vendor in Deira").
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

  /// Constructs a [MaskedParty] from a JSON map.
  factory MaskedParty.fromJson(Map<String, dynamic> json) {
    return MaskedParty(
      role: _parseRole(json),
      region: _parseRegion(json['region']),
      pseudonym: json['pseudonym'] as String?,
      rating: RatingSummary.fromJson(json['rating']),
      dealCount: _parseDealCount(json),
    );
  }

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

  @override
  String toString() =>
      'MaskedParty(role: $role, region: $region, pseudonym: $pseudonym, rating: $rating, dealCount: $dealCount)';
}

/// A counterparty whose identity has been revealed post-Acceptance (AD-FE-07).
///
/// Only constructible from a Connection payload that included verified
/// identity fields ([name], [mobile]). Pre-acceptance screens MUST NOT
/// be able to produce or hold a [RevealedParty].
final class RevealedParty extends Party {
  const RevealedParty({
    required this.name,
    required this.mobile,
    required super.role,
    this.address,
    this.business,
    super.rating,
    super.dealCount = 0,
  });

  /// Display name of the counterparty (individual or business name).
  final String name;

  /// Normalised WhatsApp-safe phone number (wa.me compatible).
  final String mobile;

  /// Optional physical address or store location.
  final String? address;

  /// Optional business details / legal business name (Vendor only).
  final String? business;

  /// Alias for [name] matching frontend architecture conventions.
  String get displayName => name;

  /// Constructs a [RevealedParty] from a JSON map.
  ///
  /// Throws [FormatException] if identity fields ([name] or [mobile]) are missing
  /// or empty, guaranteeing that a masked payload cannot produce a [RevealedParty].
  factory RevealedParty.fromJson(Map<String, dynamic> json) {
    final name =
        (json['name'] as String? ?? json['displayName'] as String?)?.trim();
    final mobile = (json['mobile'] as String? ??
            json['mobileNumber'] as String? ??
            json['phone'] as String? ??
            json['phoneNumber'] as String?)
        ?.trim();

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

    return RevealedParty(
      name: name,
      mobile: mobile,
      role: _parseRole(json),
      address: _parseAddress(json['address']),
      business: _parseBusiness(json['business'] ?? json['legalBusinessName']),
      rating: RatingSummary.fromJson(json['rating']),
      dealCount: _parseDealCount(json),
    );
  }

  RevealedParty copyWith({
    String? name,
    String? mobile,
    UserRole? role,
    String? address,
    String? business,
    RatingSummary? rating,
    int? dealCount,
  }) {
    return RevealedParty(
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      role: role ?? this.role,
      address: address ?? this.address,
      business: business ?? this.business,
      rating: rating ?? this.rating,
      dealCount: dealCount ?? this.dealCount,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'mobile': mobile,
        'role': role.wireName,
        if (address != null) 'address': address,
        if (business != null) 'business': business,
        if (rating != null) 'rating': rating!.toJson(),
        'dealCount': dealCount,
        'isRevealed': true,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RevealedParty &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          mobile == other.mobile &&
          role == other.role &&
          address == other.address &&
          business == other.business &&
          rating == other.rating &&
          dealCount == other.dealCount;

  @override
  int get hashCode =>
      Object.hash(name, mobile, role, address, business, rating, dealCount);

  @override
  String toString() =>
      'RevealedParty(name: $name, mobile: $mobile, role: $role, address: $address, business: $business, rating: $rating, dealCount: $dealCount)';
}

UserRole _parseRole(Map<String, dynamic> json) {
  final raw = json['role'] ?? json['userType'] ?? json['partyRole'];
  return UserRole.parse(raw?.toString());
}

String? _parseRegion(dynamic raw) {
  if (raw == null) return null;
  if (raw is String) return raw;
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

String? _parseBusiness(dynamic raw) {
  if (raw == null) return null;
  if (raw is String) return raw;
  if (raw is Map<String, dynamic>) {
    return raw['legalBusinessName'] as String? ??
        raw['tradingName'] as String? ??
        raw['companyName'] as String?;
  }
  return raw.toString();
}
