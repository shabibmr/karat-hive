import 'package:freezed_annotation/freezed_annotation.dart';

import 'request_enums.dart';

part 'request_detail.freezed.dart';
part 'request_detail.g.dart';

/// Unmasked customer profile overview on ADM-S09.
@freezed
class CustomerProfileSummary with _$CustomerProfileSummary {
  const factory CustomerProfileSummary({
    required String id,
    required String fullName,
    String? email,
    String? mobileNumber,
    @Default('ACTIVE') String accountState,
    DateTime? createdAt,
  }) = _CustomerProfileSummary;

  factory CustomerProfileSummary.fromJson(Map<String, dynamic> json) =>
      _$CustomerProfileSummaryFromJson(json);

  factory CustomerProfileSummary.fromApiResponse(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : null;

    final fullName = json['fullName']?.toString() ??
        json['name']?.toString() ??
        json['contactPersonName']?.toString() ??
        user?['fullName']?.toString() ??
        'Unmasked Customer';

    final email = json['email']?.toString() ?? user?['email']?.toString();
    final mobile = json['mobileNumber']?.toString() ??
        json['phone']?.toString() ??
        user?['mobileNumber']?.toString();
    final accState = json['accountState']?.toString() ??
        user?['accountState']?.toString() ??
        'ACTIVE';

    DateTime? created;
    final createdVal = json['createdAt'] ?? user?['createdAt'];
    if (createdVal is String) created = DateTime.tryParse(createdVal);
    if (createdVal is DateTime) created = createdVal;

    return CustomerProfileSummary(
      id: json['id']?.toString() ?? '',
      fullName: fullName,
      email: email,
      mobileNumber: mobile,
      accountState: accState,
      createdAt: created,
    );
  }
}

/// Image or document media uploaded for a request.
@freezed
class RequestMediaItem with _$RequestMediaItem {
  const factory RequestMediaItem({
    required String id,
    required String url,
    String? thumbnailUrl,
    String? fileName,
    String? mimeType,
    int? sizeBytes,
    @Default(0) int displayOrder,
  }) = _RequestMediaItem;

  factory RequestMediaItem.fromJson(Map<String, dynamic> json) =>
      _$RequestMediaItemFromJson(json);

  factory RequestMediaItem.fromApiResponse(Map<String, dynamic> json) {
    final media = json['media'] is Map<String, dynamic>
        ? json['media'] as Map<String, dynamic>
        : json;

    return RequestMediaItem(
      id: media['id']?.toString() ?? json['mediaId']?.toString() ?? '',
      url: media['url']?.toString() ??
          media['storageKey']?.toString() ??
          media['originalUrl']?.toString() ??
          '',
      thumbnailUrl: media['thumbnailUrl']?.toString(),
      fileName: media['fileName']?.toString() ??
          media['originalFileName']?.toString(),
      mimeType: media['mimeType']?.toString() ??
          media['contentType']?.toString(),
      sizeBytes: (media['sizeBytes'] ?? media['byteSize']) as int?,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Vendor matched to this request by the matching engine.
@freezed
class MatchedVendorItem with _$MatchedVendorItem {
  const factory MatchedVendorItem({
    required String vendorId,
    required String businessName,
    String? tradingName,
    double? rating,
    @Default(true) bool isEligible,
    required DateTime matchedAt,
    DateTime? viewedAt,
  }) = _MatchedVendorItem;

  factory MatchedVendorItem.fromJson(Map<String, dynamic> json) =>
      _$MatchedVendorItemFromJson(json);

  factory MatchedVendorItem.fromApiResponse(Map<String, dynamic> json) {
    final vendor = json['vendor'] ?? json['vendorProfile'];
    String name = json['businessName']?.toString() ?? '';
    String? trading;
    double? rat;

    if (vendor is Map<String, dynamic>) {
      name = vendor['legalBusinessName']?.toString() ??
          vendor['businessName']?.toString() ??
          vendor['tradingName']?.toString() ??
          name;
      trading = vendor['tradingName']?.toString();
      if (vendor['rating'] is num) {
        rat = (vendor['rating'] as num).toDouble();
      }
    }

    if (name.isEmpty) {
      name = json['legalBusinessName']?.toString() ??
          'Vendor #${json['vendorProfileId'] ?? json['vendorId'] ?? ''}';
    }

    DateTime parseDt(dynamic val) {
      if (val is DateTime) return val;
      if (val is String) {
        final d = DateTime.tryParse(val);
        if (d != null) return d;
      }
      return DateTime.now();
    }

    return MatchedVendorItem(
      vendorId: json['vendorProfileId']?.toString() ??
          json['vendorId']?.toString() ??
          '',
      businessName: name,
      tradingName: trading,
      rating: rat ?? (json['rating'] as num?)?.toDouble(),
      isEligible: json['isEligible'] != false,
      matchedAt: parseDt(json['matchedAt']),
      viewedAt: json['viewedAt'] != null ? parseDt(json['viewedAt']) : null,
    );
  }
}

/// An offer submitted by a vendor on this request.
@freezed
class RequestOfferItem with _$RequestOfferItem {
  const factory RequestOfferItem({
    required String id,
    required String vendorId,
    required String vendorName,
    required double priceAED,
    @JsonKey(unknownEnumValue: OfferState.pending)
    @Default(OfferState.pending)
    OfferState state,
    String? outcome,
    required DateTime submittedAt,
    String? notes,
    int? estimatedDays,
  }) = _RequestOfferItem;

  factory RequestOfferItem.fromJson(Map<String, dynamic> json) =>
      _$RequestOfferItemFromJson(json);

  factory RequestOfferItem.fromApiResponse(Map<String, dynamic> json) {
    final vendor = json['vendor'] ?? json['vendorProfile'];
    String vName = json['vendorName']?.toString() ?? '';
    if (vendor is Map<String, dynamic>) {
      vName = vendor['legalBusinessName']?.toString() ??
          vendor['tradingName']?.toString() ??
          vName;
    }
    if (vName.isEmpty) {
      vName = 'Vendor #${json['vendorId'] ?? json['vendorProfileId'] ?? ''}';
    }

    double price = 0.0;
    final pVal = json['priceAED'] ?? json['price'] ?? json['offeredPrice'];
    if (pVal is num) {
      price = pVal.toDouble();
    } else if (pVal is String) {
      price = double.tryParse(pVal) ?? 0.0;
    }

    DateTime parseDt(dynamic val) {
      if (val is DateTime) return val;
      if (val is String) {
        final d = DateTime.tryParse(val);
        if (d != null) return d;
      }
      return DateTime.now();
    }

    final stateStr = json['state']?.toString();

    return RequestOfferItem(
      id: json['id']?.toString() ?? '',
      vendorId: json['vendorId']?.toString() ??
          json['vendorProfileId']?.toString() ??
          '',
      vendorName: vName,
      priceAED: price,
      state: OfferState.fromApi(stateStr) ?? OfferState.pending,
      outcome: json['outcome']?.toString(),
      submittedAt: parseDt(json['submittedAt'] ?? json['createdAt']),
      notes: json['notes']?.toString() ?? json['description']?.toString(),
      estimatedDays: (json['estimatedDays'] as num?)?.toInt(),
    );
  }
}

/// State transition audit entry.
@freezed
class RequestTimelineEvent with _$RequestTimelineEvent {
  const factory RequestTimelineEvent({
    @JsonKey(unknownEnumValue: RequestState.draft)
    @Default(RequestState.draft)
    RequestState state,
    required DateTime timestamp,
    String? actor,
    String? notes,
  }) = _RequestTimelineEvent;

  factory RequestTimelineEvent.fromJson(Map<String, dynamic> json) =>
      _$RequestTimelineEventFromJson(json);

  factory RequestTimelineEvent.fromApiResponse(Map<String, dynamic> json) {
    DateTime parseDt(dynamic val) {
      if (val is DateTime) return val;
      if (val is String) {
        final d = DateTime.tryParse(val);
        if (d != null) return d;
      }
      return DateTime.now();
    }

    final stateStr = json['state']?.toString() ?? json['toState']?.toString();

    return RequestTimelineEvent(
      state: RequestState.fromApi(stateStr) ?? RequestState.draft,
      timestamp: parseDt(json['timestamp'] ?? json['createdAt']),
      actor: json['actor']?.toString() ?? json['actorType']?.toString(),
      notes: json['notes']?.toString() ?? json['reason']?.toString(),
    );
  }
}

/// Resulting accepted connection details.
@freezed
class RequestConnectionSummary with _$RequestConnectionSummary {
  const factory RequestConnectionSummary({
    required String id,
    required String vendorId,
    required String vendorName,
    required String customerId,
    required String customerName,
    @Default('ACTIVE') String state,
    required DateTime connectedAt,
    String? whatsappUrl,
    String? channel,
  }) = _RequestConnectionSummary;

  factory RequestConnectionSummary.fromJson(Map<String, dynamic> json) =>
      _$RequestConnectionSummaryFromJson(json);

  factory RequestConnectionSummary.fromApiResponse(Map<String, dynamic> json) {
    final vendor = json['vendor'] ?? json['vendorProfile'];
    final customer = json['customer'] ?? json['customerProfile'];

    String vName = json['vendorName']?.toString() ?? '';
    if (vendor is Map<String, dynamic>) {
      vName = vendor['legalBusinessName']?.toString() ??
          vendor['tradingName']?.toString() ??
          vName;
    }
    if (vName.isEmpty) vName = 'Connected Vendor';

    String cName = json['customerName']?.toString() ?? '';
    if (customer is Map<String, dynamic>) {
      cName = customer['fullName']?.toString() ??
          customer['name']?.toString() ??
          cName;
    }
    if (cName.isEmpty) cName = 'Connected Customer';

    DateTime parseDt(dynamic val) {
      if (val is DateTime) return val;
      if (val is String) {
        final d = DateTime.tryParse(val);
        if (d != null) return d;
      }
      return DateTime.now();
    }

    return RequestConnectionSummary(
      id: json['id']?.toString() ?? '',
      vendorId: json['vendorId']?.toString() ??
          json['vendorProfileId']?.toString() ??
          '',
      vendorName: vName,
      customerId: json['customerId']?.toString() ??
          json['customerProfileId']?.toString() ??
          '',
      customerName: cName,
      state: json['state']?.toString() ?? 'ACTIVE',
      connectedAt: parseDt(json['connectedAt'] ?? json['createdAt']),
      whatsappUrl: json['whatsappUrl']?.toString() ?? json['chatLink']?.toString(),
      channel: json['channel']?.toString() ?? 'WHATSAPP',
    );
  }
}

/// Admin internal context note.
@freezed
class RequestInternalNoteItem with _$RequestInternalNoteItem {
  const factory RequestInternalNoteItem({
    required String id,
    required String authorName,
    required String text,
    required DateTime createdAt,
  }) = _RequestInternalNoteItem;

  factory RequestInternalNoteItem.fromJson(Map<String, dynamic> json) =>
      _$RequestInternalNoteItemFromJson(json);

  factory RequestInternalNoteItem.fromApiResponse(Map<String, dynamic> json) {
    DateTime parseDt(dynamic val) {
      if (val is DateTime) return val;
      if (val is String) {
        final d = DateTime.tryParse(val);
        if (d != null) return d;
      }
      return DateTime.now();
    }

    return RequestInternalNoteItem(
      id: json['id']?.toString() ?? '',
      authorName: json['authorName']?.toString() ??
          json['author']?.toString() ??
          'Platform Admin',
      text: json['text']?.toString() ?? json['note']?.toString() ?? '',
      createdAt: parseDt(json['createdAt'] ?? json['timestamp']),
    );
  }
}

/// Full Request model for ADM-S09 Request Detail screen.
@freezed
class RequestDetail with _$RequestDetail {
  const RequestDetail._();

  const factory RequestDetail({
    required String id,
    String? reference,
    @JsonKey(unknownEnumValue: RequestType.findOrnament)
    @Default(RequestType.findOrnament)
    RequestType requestType,
    @JsonKey(unknownEnumValue: Direction.buy)
    @Default(Direction.buy)
    Direction direction,
    @JsonKey(unknownEnumValue: RequestState.draft)
    @Default(RequestState.draft)
    RequestState state,
    required CustomerProfileSummary customer,
    @Default('—') String categoryName,
    @Default('—') String regionName,
    String? ornamentType,
    double? weightGrams,
    @Default(false) bool weightIsApproximate,
    String? purityKarat,
    String? condition,
    double? denominationGrams,
    int? quantity,
    String? mintOrRefiner,
    String? notes,
    double? indicativeValue,
    double? budgetMin,
    double? budgetMax,
    @Default(false) bool budgetIsFlexible,
    DateTime? publishedAt,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? cancellationReason,
    String? removalReasonCode,
    String? removalReasonText,
    String? removalPolicyClause,
    @Default([]) List<RequestMediaItem> media,
    @Default([]) List<MatchedVendorItem> matchedVendors,
    @Default([]) List<RequestOfferItem> offers,
    @Default([]) List<RequestTimelineEvent> timeline,
    RequestConnectionSummary? connection,
    @Default([]) List<RequestInternalNoteItem> internalNotes,
  }) = _RequestDetail;

  bool get isRemoved => state == RequestState.removed;
  bool get isAccepted => state == RequestState.accepted || connection != null;

  factory RequestDetail.fromJson(Map<String, dynamic> json) =>
      _$RequestDetailFromJson(json);

  factory RequestDetail.fromApiResponse(Map<String, dynamic> json) {
    final customerRaw = json['customer'] ?? json['customerProfile'];
    CustomerProfileSummary customerSummary;
    if (customerRaw is Map<String, dynamic>) {
      customerSummary = CustomerProfileSummary.fromApiResponse(customerRaw);
    } else {
      customerSummary = CustomerProfileSummary(
        id: json['customerId']?.toString() ?? json['customerProfileId']?.toString() ?? '',
        fullName: json['customerName']?.toString() ?? 'Unmasked Customer',
        mobileNumber: json['customerPhone']?.toString(),
        email: json['customerEmail']?.toString(),
      );
    }

    final categoryObj = json['category'];
    String catName = json['categoryName']?.toString() ?? '';
    if (categoryObj is Map<String, dynamic>) {
      catName = categoryObj['nameEn']?.toString() ??
          categoryObj['name']?.toString() ??
          catName;
    } else if (categoryObj is String && categoryObj.isNotEmpty) {
      catName = categoryObj;
    }
    if (catName.isEmpty) catName = '—';

    final regionObj = json['region'];
    String regName = json['regionName']?.toString() ?? '';
    if (regionObj is Map<String, dynamic>) {
      regName = regionObj['nameEn']?.toString() ??
          regionObj['name']?.toString() ??
          regName;
    } else if (regionObj is String && regionObj.isNotEmpty) {
      regName = regionObj;
    }
    if (regName.isEmpty) regName = '—';

    List<RequestMediaItem> parseMedia(dynamic val) {
      if (val is! List) return const [];
      return val
          .whereType<Map<String, dynamic>>()
          .map(RequestMediaItem.fromApiResponse)
          .toList();
    }

    List<MatchedVendorItem> parseVendors(dynamic val) {
      if (val is! List) return const [];
      return val
          .whereType<Map<String, dynamic>>()
          .map(MatchedVendorItem.fromApiResponse)
          .toList();
    }

    List<RequestOfferItem> parseOffers(dynamic val) {
      if (val is! List) return const [];
      return val
          .whereType<Map<String, dynamic>>()
          .map(RequestOfferItem.fromApiResponse)
          .toList();
    }

    List<RequestTimelineEvent> parseTimeline(dynamic val) {
      if (val is! List) return const [];
      return val
          .whereType<Map<String, dynamic>>()
          .map(RequestTimelineEvent.fromApiResponse)
          .toList();
    }

    List<RequestInternalNoteItem> parseNotes(dynamic val) {
      if (val is! List) return const [];
      return val
          .whereType<Map<String, dynamic>>()
          .map(RequestInternalNoteItem.fromApiResponse)
          .toList();
    }

    RequestConnectionSummary? parseConnection(dynamic val) {
      if (val is Map<String, dynamic>) {
        return RequestConnectionSummary.fromApiResponse(val);
      }
      if (val is List && val.isNotEmpty && val.first is Map<String, dynamic>) {
        return RequestConnectionSummary.fromApiResponse(val.first as Map<String, dynamic>);
      }
      return null;
    }

    DateTime? parseDt(dynamic val) {
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    double? parseNum(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    final reqType = RequestType.fromApi(json['requestType']?.toString()) ??
        RequestType.findOrnament;
    final dir = Direction.fromApi(json['direction']?.toString()) ??
        Direction.buy;
    final st = RequestState.fromApi(json['state']?.toString()) ??
        RequestState.draft;

    return RequestDetail(
      id: json['id']?.toString() ?? '',
      reference: json['reference']?.toString(),
      requestType: reqType,
      direction: dir,
      state: st,
      customer: customerSummary,
      categoryName: catName,
      regionName: regName,
      ornamentType: json['ornamentType']?.toString(),
      weightGrams: parseNum(json['weightGrams']),
      weightIsApproximate: json['weightIsApproximate'] == true,
      purityKarat: json['purityKarat']?.toString(),
      condition: json['condition']?.toString(),
      denominationGrams: parseNum(json['denominationGrams']),
      quantity: (json['quantity'] as num?)?.toInt(),
      mintOrRefiner: json['mintOrRefiner']?.toString(),
      notes: json['notes']?.toString(),
      indicativeValue: parseNum(json['indicativeValue']),
      budgetMin: parseNum(json['budgetMin']),
      budgetMax: parseNum(json['budgetMax']),
      budgetIsFlexible: json['budgetIsFlexible'] == true,
      publishedAt: parseDt(json['publishedAt']),
      expiresAt: parseDt(json['expiresAt']),
      createdAt: parseDt(json['createdAt']),
      updatedAt: parseDt(json['updatedAt']),
      cancellationReason: json['cancellationReason']?.toString(),
      removalReasonCode: json['removalReasonCode']?.toString(),
      removalReasonText: json['removalReasonText']?.toString(),
      removalPolicyClause: json['removalPolicyClause']?.toString(),
      media: parseMedia(json['media'] ?? json['requestMedia']),
      matchedVendors: parseVendors(json['matchedVendors'] ?? json['matches']),
      offers: parseOffers(json['offers']),
      timeline: parseTimeline(json['timeline'] ?? json['transitions'] ?? json['history']),
      connection: parseConnection(json['connection'] ?? json['connections']),
      internalNotes: parseNotes(json['internalNotes'] ?? json['adminNotes']),
    );
  }
}
