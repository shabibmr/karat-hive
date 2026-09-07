// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerProfileSummaryImpl _$$CustomerProfileSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerProfileSummaryImpl(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  email: json['email'] as String?,
  mobileNumber: json['mobileNumber'] as String?,
  accountState: json['accountState'] as String? ?? 'ACTIVE',
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$CustomerProfileSummaryImplToJson(
  _$CustomerProfileSummaryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'email': instance.email,
  'mobileNumber': instance.mobileNumber,
  'accountState': instance.accountState,
  'createdAt': instance.createdAt?.toIso8601String(),
};

_$RequestMediaItemImpl _$$RequestMediaItemImplFromJson(
  Map<String, dynamic> json,
) => _$RequestMediaItemImpl(
  id: json['id'] as String,
  url: json['url'] as String,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  fileName: json['fileName'] as String?,
  mimeType: json['mimeType'] as String?,
  sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
  displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$RequestMediaItemImplToJson(
  _$RequestMediaItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'thumbnailUrl': instance.thumbnailUrl,
  'fileName': instance.fileName,
  'mimeType': instance.mimeType,
  'sizeBytes': instance.sizeBytes,
  'displayOrder': instance.displayOrder,
};

_$MatchedVendorItemImpl _$$MatchedVendorItemImplFromJson(
  Map<String, dynamic> json,
) => _$MatchedVendorItemImpl(
  vendorId: json['vendorId'] as String,
  businessName: json['businessName'] as String,
  tradingName: json['tradingName'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  isEligible: json['isEligible'] as bool? ?? true,
  matchedAt: DateTime.parse(json['matchedAt'] as String),
  viewedAt: json['viewedAt'] == null
      ? null
      : DateTime.parse(json['viewedAt'] as String),
);

Map<String, dynamic> _$$MatchedVendorItemImplToJson(
  _$MatchedVendorItemImpl instance,
) => <String, dynamic>{
  'vendorId': instance.vendorId,
  'businessName': instance.businessName,
  'tradingName': instance.tradingName,
  'rating': instance.rating,
  'isEligible': instance.isEligible,
  'matchedAt': instance.matchedAt.toIso8601String(),
  'viewedAt': instance.viewedAt?.toIso8601String(),
};

_$RequestOfferItemImpl _$$RequestOfferItemImplFromJson(
  Map<String, dynamic> json,
) => _$RequestOfferItemImpl(
  id: json['id'] as String,
  vendorId: json['vendorId'] as String,
  vendorName: json['vendorName'] as String,
  priceAED: (json['priceAED'] as num).toDouble(),
  state:
      $enumDecodeNullable(
        _$OfferStateEnumMap,
        json['state'],
        unknownValue: OfferState.pending,
      ) ??
      OfferState.pending,
  outcome: json['outcome'] as String?,
  submittedAt: DateTime.parse(json['submittedAt'] as String),
  notes: json['notes'] as String?,
  estimatedDays: (json['estimatedDays'] as num?)?.toInt(),
);

Map<String, dynamic> _$$RequestOfferItemImplToJson(
  _$RequestOfferItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'vendorId': instance.vendorId,
  'vendorName': instance.vendorName,
  'priceAED': instance.priceAED,
  'state': _$OfferStateEnumMap[instance.state]!,
  'outcome': instance.outcome,
  'submittedAt': instance.submittedAt.toIso8601String(),
  'notes': instance.notes,
  'estimatedDays': instance.estimatedDays,
};

const _$OfferStateEnumMap = {
  OfferState.pending: 'PENDING',
  OfferState.accepted: 'ACCEPTED',
  OfferState.rejected: 'REJECTED',
  OfferState.expired: 'EXPIRED',
  OfferState.withdrawn: 'WITHDRAWN',
  OfferState.withdrawnBySystem: 'WITHDRAWN_BY_SYSTEM',
};

_$RequestTimelineEventImpl _$$RequestTimelineEventImplFromJson(
  Map<String, dynamic> json,
) => _$RequestTimelineEventImpl(
  state:
      $enumDecodeNullable(
        _$RequestStateEnumMap,
        json['state'],
        unknownValue: RequestState.draft,
      ) ??
      RequestState.draft,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actor: json['actor'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$RequestTimelineEventImplToJson(
  _$RequestTimelineEventImpl instance,
) => <String, dynamic>{
  'state': _$RequestStateEnumMap[instance.state]!,
  'timestamp': instance.timestamp.toIso8601String(),
  'actor': instance.actor,
  'notes': instance.notes,
};

const _$RequestStateEnumMap = {
  RequestState.draft: 'DRAFT',
  RequestState.published: 'PUBLISHED',
  RequestState.offersReceived: 'OFFERS_RECEIVED',
  RequestState.accepted: 'ACCEPTED',
  RequestState.closed: 'CLOSED',
  RequestState.expired: 'EXPIRED',
  RequestState.cancelled: 'CANCELLED',
  RequestState.removed: 'REMOVED',
};

_$RequestConnectionSummaryImpl _$$RequestConnectionSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$RequestConnectionSummaryImpl(
  id: json['id'] as String,
  vendorId: json['vendorId'] as String,
  vendorName: json['vendorName'] as String,
  customerId: json['customerId'] as String,
  customerName: json['customerName'] as String,
  state: json['state'] as String? ?? 'ACTIVE',
  connectedAt: DateTime.parse(json['connectedAt'] as String),
  identityRevealedAt: json['identityRevealedAt'] == null
      ? null
      : DateTime.parse(json['identityRevealedAt'] as String),
  closedAt: json['closedAt'] == null
      ? null
      : DateTime.parse(json['closedAt'] as String),
  whatsappUrl: json['whatsappUrl'] as String?,
  channel: json['channel'] as String?,
);

Map<String, dynamic> _$$RequestConnectionSummaryImplToJson(
  _$RequestConnectionSummaryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'vendorId': instance.vendorId,
  'vendorName': instance.vendorName,
  'customerId': instance.customerId,
  'customerName': instance.customerName,
  'state': instance.state,
  'connectedAt': instance.connectedAt.toIso8601String(),
  'identityRevealedAt': instance.identityRevealedAt?.toIso8601String(),
  'closedAt': instance.closedAt?.toIso8601String(),
  'whatsappUrl': instance.whatsappUrl,
  'channel': instance.channel,
};

_$RequestInternalNoteItemImpl _$$RequestInternalNoteItemImplFromJson(
  Map<String, dynamic> json,
) => _$RequestInternalNoteItemImpl(
  id: json['id'] as String,
  authorName: json['authorName'] as String,
  text: json['text'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$RequestInternalNoteItemImplToJson(
  _$RequestInternalNoteItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'authorName': instance.authorName,
  'text': instance.text,
  'createdAt': instance.createdAt.toIso8601String(),
};

_$RequestDetailImpl _$$RequestDetailImplFromJson(
  Map<String, dynamic> json,
) => _$RequestDetailImpl(
  id: json['id'] as String,
  reference: json['reference'] as String?,
  requestType:
      $enumDecodeNullable(
        _$RequestTypeEnumMap,
        json['requestType'],
        unknownValue: RequestType.findOrnament,
      ) ??
      RequestType.findOrnament,
  direction:
      $enumDecodeNullable(
        _$DirectionEnumMap,
        json['direction'],
        unknownValue: Direction.buy,
      ) ??
      Direction.buy,
  state:
      $enumDecodeNullable(
        _$RequestStateEnumMap,
        json['state'],
        unknownValue: RequestState.draft,
      ) ??
      RequestState.draft,
  customer: CustomerProfileSummary.fromJson(
    json['customer'] as Map<String, dynamic>,
  ),
  categoryName: json['categoryName'] as String? ?? '—',
  regionName: json['regionName'] as String? ?? '—',
  ornamentType: json['ornamentType'] as String?,
  weightGrams: (json['weightGrams'] as num?)?.toDouble(),
  weightIsApproximate: json['weightIsApproximate'] as bool? ?? false,
  purityKarat: json['purityKarat'] as String?,
  condition: json['condition'] as String?,
  denominationGrams: (json['denominationGrams'] as num?)?.toDouble(),
  quantity: (json['quantity'] as num?)?.toInt(),
  mintOrRefiner: json['mintOrRefiner'] as String?,
  notes: json['notes'] as String?,
  indicativeValue: (json['indicativeValue'] as num?)?.toDouble(),
  budgetMin: (json['budgetMin'] as num?)?.toDouble(),
  budgetMax: (json['budgetMax'] as num?)?.toDouble(),
  budgetIsFlexible: json['budgetIsFlexible'] as bool? ?? false,
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  cancellationReason: json['cancellationReason'] as String?,
  removalReasonCode: json['removalReasonCode'] as String?,
  removalReasonText: json['removalReasonText'] as String?,
  removalPolicyClause: json['removalPolicyClause'] as String?,
  media:
      (json['media'] as List<dynamic>?)
          ?.map((e) => RequestMediaItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  matchedVendors:
      (json['matchedVendors'] as List<dynamic>?)
          ?.map((e) => MatchedVendorItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  offers:
      (json['offers'] as List<dynamic>?)
          ?.map((e) => RequestOfferItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  timeline:
      (json['timeline'] as List<dynamic>?)
          ?.map((e) => RequestTimelineEvent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  connection: json['connection'] == null
      ? null
      : RequestConnectionSummary.fromJson(
          json['connection'] as Map<String, dynamic>,
        ),
  internalNotes:
      (json['internalNotes'] as List<dynamic>?)
          ?.map(
            (e) => RequestInternalNoteItem.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$$RequestDetailImplToJson(_$RequestDetailImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reference': instance.reference,
      'requestType': _$RequestTypeEnumMap[instance.requestType]!,
      'direction': _$DirectionEnumMap[instance.direction]!,
      'state': _$RequestStateEnumMap[instance.state]!,
      'customer': instance.customer,
      'categoryName': instance.categoryName,
      'regionName': instance.regionName,
      'ornamentType': instance.ornamentType,
      'weightGrams': instance.weightGrams,
      'weightIsApproximate': instance.weightIsApproximate,
      'purityKarat': instance.purityKarat,
      'condition': instance.condition,
      'denominationGrams': instance.denominationGrams,
      'quantity': instance.quantity,
      'mintOrRefiner': instance.mintOrRefiner,
      'notes': instance.notes,
      'indicativeValue': instance.indicativeValue,
      'budgetMin': instance.budgetMin,
      'budgetMax': instance.budgetMax,
      'budgetIsFlexible': instance.budgetIsFlexible,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'cancellationReason': instance.cancellationReason,
      'removalReasonCode': instance.removalReasonCode,
      'removalReasonText': instance.removalReasonText,
      'removalPolicyClause': instance.removalPolicyClause,
      'media': instance.media,
      'matchedVendors': instance.matchedVendors,
      'offers': instance.offers,
      'timeline': instance.timeline,
      'connection': instance.connection,
      'internalNotes': instance.internalNotes,
    };

const _$RequestTypeEnumMap = {
  RequestType.findOrnament: 'FIND_ORNAMENT',
  RequestType.sellOldGold: 'SELL_OLD_GOLD',
  RequestType.goldCoin: 'GOLD_COIN',
  RequestType.goldBullion: 'GOLD_BULLION',
};

const _$DirectionEnumMap = {Direction.buy: 'BUY', Direction.sell: 'SELL'};
