import 'connection_enums.dart';

/// Customer profile information in the connection detail context.
class ConnectionCustomerInfo {
  const ConnectionCustomerInfo({
    required this.id,
    required this.displayName,
    this.email,
    this.mobileNumber,
  });

  final String id;
  final String displayName;
  final String? email;
  final String? mobileNumber;

  factory ConnectionCustomerInfo.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : (json['user'] is Map ? Map<String, dynamic>.from(json['user'] as Map) : null);

    return ConnectionCustomerInfo(
      id: json['id']?.toString() ?? '',
      displayName: json['displayName']?.toString() ??
          user?['email']?.toString() ??
          user?['mobileNumber']?.toString() ??
          'Customer',
      email: json['email']?.toString() ?? user?['email']?.toString(),
      mobileNumber:
          json['mobileNumber']?.toString() ?? user?['mobileNumber']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'email': email,
        'mobileNumber': mobileNumber,
      };

  ConnectionCustomerInfo copyWith({
    String? id,
    String? displayName,
    String? email,
    String? mobileNumber,
  }) {
    return ConnectionCustomerInfo(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
    );
  }
}

/// Vendor profile information in the connection detail context.
class ConnectionVendorInfo {
  const ConnectionVendorInfo({
    required this.id,
    required this.legalBusinessName,
    this.tradingName,
    this.tradeLicenceNumber,
    this.email,
    this.mobileNumber,
    this.rating,
  });

  final String id;
  final String legalBusinessName;
  final String? tradingName;
  final String? tradeLicenceNumber;
  final String? email;
  final String? mobileNumber;
  final double? rating;

  factory ConnectionVendorInfo.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : (json['user'] is Map ? Map<String, dynamic>.from(json['user'] as Map) : null);

    final ratingVal = json['rating'] ?? json['aggregateRating'];
    final rating = ratingVal is num
        ? ratingVal.toDouble()
        : double.tryParse(ratingVal?.toString() ?? '');

    return ConnectionVendorInfo(
      id: json['id']?.toString() ?? '',
      legalBusinessName: json['legalBusinessName']?.toString() ??
          json['tradingName']?.toString() ??
          'Vendor',
      tradingName: json['tradingName']?.toString(),
      tradeLicenceNumber: json['tradeLicenceNumber']?.toString(),
      email: json['email']?.toString() ??
          json['businessEmail']?.toString() ??
          user?['email']?.toString(),
      mobileNumber:
          json['mobileNumber']?.toString() ?? user?['mobileNumber']?.toString(),
      rating: rating,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'legalBusinessName': legalBusinessName,
        'tradingName': tradingName,
        'tradeLicenceNumber': tradeLicenceNumber,
        'email': email,
        'mobileNumber': mobileNumber,
        'rating': rating,
      };

  ConnectionVendorInfo copyWith({
    String? id,
    String? legalBusinessName,
    String? tradingName,
    String? tradeLicenceNumber,
    String? email,
    String? mobileNumber,
    double? rating,
  }) {
    return ConnectionVendorInfo(
      id: id ?? this.id,
      legalBusinessName: legalBusinessName ?? this.legalBusinessName,
      tradingName: tradingName ?? this.tradingName,
      tradeLicenceNumber: tradeLicenceNumber ?? this.tradeLicenceNumber,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      rating: rating ?? this.rating,
    );
  }
}

/// Request summary in connection detail.
class ConnectionRequestSummary {
  const ConnectionRequestSummary({
    required this.id,
    this.reference,
    this.requestType,
    this.description,
    this.indicativeValue,
    this.budgetMin,
    this.budgetMax,
    this.weightGrams,
    this.purityKarat,
    this.ornamentType,
  });

  final String id;
  final String? reference;
  final String? requestType;
  final String? description;
  final double? indicativeValue;
  final double? budgetMin;
  final double? budgetMax;
  final double? weightGrams;
  final String? purityKarat;
  final String? ornamentType;

  factory ConnectionRequestSummary.fromJson(Map<String, dynamic> json) {
    double? parseNum(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    return ConnectionRequestSummary(
      id: json['id']?.toString() ?? '',
      reference: json['reference']?.toString(),
      requestType: json['requestType']?.toString(),
      description: json['notes']?.toString() ?? json['description']?.toString(),
      indicativeValue: parseNum(json['indicativeValue']),
      budgetMin: parseNum(json['budgetMin']),
      budgetMax: parseNum(json['budgetMax']),
      weightGrams: parseNum(json['weightGrams']),
      purityKarat: json['purityKarat']?.toString(),
      ornamentType: json['ornamentType']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'requestType': requestType,
        'description': description,
        'indicativeValue': indicativeValue,
        'budgetMin': budgetMin,
        'budgetMax': budgetMax,
        'weightGrams': weightGrams,
        'purityKarat': purityKarat,
        'ornamentType': ornamentType,
      };

  ConnectionRequestSummary copyWith({
    String? id,
    String? reference,
    String? requestType,
    String? description,
    double? indicativeValue,
    double? budgetMin,
    double? budgetMax,
    double? weightGrams,
    String? purityKarat,
    String? ornamentType,
  }) {
    return ConnectionRequestSummary(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      requestType: requestType ?? this.requestType,
      description: description ?? this.description,
      indicativeValue: indicativeValue ?? this.indicativeValue,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      weightGrams: weightGrams ?? this.weightGrams,
      purityKarat: purityKarat ?? this.purityKarat,
      ornamentType: ornamentType ?? this.ornamentType,
    );
  }
}

/// Accepted offer summary in connection detail.
class ConnectionOfferSummary {
  const ConnectionOfferSummary({
    required this.id,
    this.reference,
    required this.agreedPriceAed,
    this.makingCharges,
    this.ratePerGram,
    this.validityHours,
    this.expiresAt,
    this.deliveryTimeframe,
    this.warrantyTerms,
    this.vendorNote,
  });

  final String id;
  final String? reference;
  final double agreedPriceAed;
  final double? makingCharges;
  final double? ratePerGram;
  final int? validityHours;
  final DateTime? expiresAt;
  final String? deliveryTimeframe;
  final String? warrantyTerms;
  final String? vendorNote;

  factory ConnectionOfferSummary.fromJson(Map<String, dynamic> json) {
    double? parseNum(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    final priceVal = json['offeredPrice'] ?? json['agreedPriceAed'];
    final agreedPrice = parseNum(priceVal) ?? 0.0;

    final expiresStr = json['expiresAt']?.toString();

    return ConnectionOfferSummary(
      id: json['id']?.toString() ?? '',
      reference: json['reference']?.toString(),
      agreedPriceAed: agreedPrice,
      makingCharges: parseNum(json['makingCharges']),
      ratePerGram: parseNum(json['ratePerGram']),
      validityHours: json['validityHours'] is int
          ? json['validityHours'] as int
          : int.tryParse(json['validityHours']?.toString() ?? ''),
      expiresAt: expiresStr != null ? DateTime.tryParse(expiresStr) : null,
      deliveryTimeframe: json['deliveryTimeframe']?.toString(),
      warrantyTerms: json['warrantyTerms']?.toString(),
      vendorNote: json['vendorNote']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'agreedPriceAed': agreedPriceAed,
        'makingCharges': makingCharges,
        'ratePerGram': ratePerGram,
        'validityHours': validityHours,
        'expiresAt': expiresAt?.toIso8601String(),
        'deliveryTimeframe': deliveryTimeframe,
        'warrantyTerms': warrantyTerms,
        'vendorNote': vendorNote,
      };

  ConnectionOfferSummary copyWith({
    String? id,
    String? reference,
    double? agreedPriceAed,
    double? makingCharges,
    double? ratePerGram,
    int? validityHours,
    DateTime? expiresAt,
    String? deliveryTimeframe,
    String? warrantyTerms,
    String? vendorNote,
  }) {
    return ConnectionOfferSummary(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      agreedPriceAed: agreedPriceAed ?? this.agreedPriceAed,
      makingCharges: makingCharges ?? this.makingCharges,
      ratePerGram: ratePerGram ?? this.ratePerGram,
      validityHours: validityHours ?? this.validityHours,
      expiresAt: expiresAt ?? this.expiresAt,
      deliveryTimeframe: deliveryTimeframe ?? this.deliveryTimeframe,
      warrantyTerms: warrantyTerms ?? this.warrantyTerms,
      vendorNote: vendorNote ?? this.vendorNote,
    );
  }
}

/// Off-platform contact event (e.g. WhatsApp initiation).
class ConnectionContactEvent {
  const ConnectionContactEvent({
    required this.id,
    required this.channel,
    required this.initiatedBy,
    required this.occurredAt,
  });

  final String id;
  final String channel;
  final String initiatedBy;
  final DateTime occurredAt;

  factory ConnectionContactEvent.fromJson(Map<String, dynamic> json) {
    final occurredStr = json['occurredAt'] ?? json['createdAt'];
    return ConnectionContactEvent(
      id: json['id']?.toString() ?? '',
      channel: json['channel']?.toString() ?? 'WHATSAPP',
      initiatedBy: json['initiatedBy']?.toString() ?? 'CUSTOMER',
      occurredAt: DateTime.tryParse(occurredStr?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'channel': channel,
        'initiatedBy': initiatedBy,
        'occurredAt': occurredAt.toIso8601String(),
      };

  ConnectionContactEvent copyWith({
    String? id,
    String? channel,
    String? initiatedBy,
    DateTime? occurredAt,
  }) {
    return ConnectionContactEvent(
      id: id ?? this.id,
      channel: channel ?? this.channel,
      initiatedBy: initiatedBy ?? this.initiatedBy,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }
}

/// Internal admin note on a connection.
class ConnectionAdminNote {
  const ConnectionAdminNote({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String author;
  final String text;
  final DateTime createdAt;

  factory ConnectionAdminNote.fromJson(Map<String, dynamic> json) {
    final author = json['author'];
    String? authorName;
    if (author is Map) {
      authorName = author['displayName']?.toString() ?? author['email']?.toString();
    } else if (author is String) {
      authorName = author;
    }
    authorName ??= json['authorAdminId']?.toString();

    return ConnectionAdminNote(
      id: json['id']?.toString() ?? '',
      author: authorName ?? 'Admin',
      text: json['text']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  ConnectionAdminNote copyWith({
    String? id,
    String? author,
    String? text,
    DateTime? createdAt,
  }) {
    return ConnectionAdminNote(
      id: id ?? this.id,
      author: author ?? this.author,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Full Connection record for investigation (ADM-S13).
class ConnectionDetail {
  const ConnectionDetail({
    required this.id,
    required this.state,
    required this.createdAt,
    this.identityRevealedAt,
    this.closedAt,
    this.closedBy,
    this.request,
    this.offer,
    this.customer,
    this.vendor,
    this.contactEvents = const [],
    this.adminNotes = const [],
  });

  final String id;
  final ConnectionState state;
  final DateTime createdAt;
  final DateTime? identityRevealedAt;
  final DateTime? closedAt;
  final String? closedBy;
  final ConnectionRequestSummary? request;
  final ConnectionOfferSummary? offer;
  final ConnectionCustomerInfo? customer;
  final ConnectionVendorInfo? vendor;
  final List<ConnectionContactEvent> contactEvents;
  final List<ConnectionAdminNote> adminNotes;

  factory ConnectionDetail.fromJson(Map<String, dynamic> json) {
    final state = ConnectionState.fromApi(json['state']?.toString()) ??
        ConnectionState.active;

    final createdAt =
        DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now();

    final revealedStr = json['identityRevealedAt']?.toString();
    final identityRevealedAt =
        revealedStr != null ? DateTime.tryParse(revealedStr) : null;

    final closedAtStr = json['closedAt']?.toString();
    final closedAt = closedAtStr != null ? DateTime.tryParse(closedAtStr) : null;

    final requestJson = json['request'] is Map
        ? Map<String, dynamic>.from(json['request'] as Map)
        : null;

    final offerJson = json['offer'] is Map
        ? Map<String, dynamic>.from(json['offer'] as Map)
        : null;

    final customerJson = json['customer'] is Map
        ? Map<String, dynamic>.from(json['customer'] as Map)
        : (requestJson != null && requestJson['customerProfile'] is Map
            ? Map<String, dynamic>.from(requestJson['customerProfile'] as Map)
            : null);

    final vendorJson = json['vendor'] is Map
        ? Map<String, dynamic>.from(json['vendor'] as Map)
        : (offerJson != null && offerJson['vendorProfile'] is Map
            ? Map<String, dynamic>.from(offerJson['vendorProfile'] as Map)
            : null);

    final contactEventsRaw = json['contactEvents'];
    final contactEvents = (contactEventsRaw is List)
        ? contactEventsRaw
            .whereType<Map>()
            .map((e) => ConnectionContactEvent.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false)
        : const <ConnectionContactEvent>[];

    final adminNotesRaw = json['adminNotes'] ?? json['notes'];
    final adminNotes = (adminNotesRaw is List)
        ? adminNotesRaw
            .whereType<Map>()
            .map((e) => ConnectionAdminNote.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false)
        : const <ConnectionAdminNote>[];

    return ConnectionDetail(
      id: json['id']?.toString() ?? '',
      state: state,
      createdAt: createdAt,
      identityRevealedAt: identityRevealedAt,
      closedAt: closedAt,
      closedBy: json['closedBy']?.toString(),
      request: requestJson != null
          ? ConnectionRequestSummary.fromJson(requestJson)
          : null,
      offer: offerJson != null
          ? ConnectionOfferSummary.fromJson(offerJson)
          : null,
      customer: customerJson != null
          ? ConnectionCustomerInfo.fromJson(customerJson)
          : null,
      vendor: vendorJson != null
          ? ConnectionVendorInfo.fromJson(vendorJson)
          : null,
      contactEvents: contactEvents,
      adminNotes: adminNotes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'state': state.apiValue,
        'createdAt': createdAt.toIso8601String(),
        'identityRevealedAt': identityRevealedAt?.toIso8601String(),
        'closedAt': closedAt?.toIso8601String(),
        'closedBy': closedBy,
        'request': request?.toJson(),
        'offer': offer?.toJson(),
        'customer': customer?.toJson(),
        'vendor': vendor?.toJson(),
        'contactEvents': contactEvents.map((e) => e.toJson()).toList(),
        'adminNotes': adminNotes.map((e) => e.toJson()).toList(),
      };

  ConnectionDetail copyWith({
    String? id,
    ConnectionState? state,
    DateTime? createdAt,
    DateTime? identityRevealedAt,
    DateTime? closedAt,
    String? closedBy,
    ConnectionRequestSummary? request,
    ConnectionOfferSummary? offer,
    ConnectionCustomerInfo? customer,
    ConnectionVendorInfo? vendor,
    List<ConnectionContactEvent>? contactEvents,
    List<ConnectionAdminNote>? adminNotes,
  }) {
    return ConnectionDetail(
      id: id ?? this.id,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      identityRevealedAt: identityRevealedAt ?? this.identityRevealedAt,
      closedAt: closedAt ?? this.closedAt,
      closedBy: closedBy ?? this.closedBy,
      request: request ?? this.request,
      offer: offer ?? this.offer,
      customer: customer ?? this.customer,
      vendor: vendor ?? this.vendor,
      contactEvents: contactEvents ?? this.contactEvents,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }
}
