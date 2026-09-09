// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OfferParentRequestSummaryImpl _$$OfferParentRequestSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$OfferParentRequestSummaryImpl(
  id: json['id'] as String,
  reference: json['reference'] as String?,
  requestType: $enumDecodeNullable(
    _$RequestTypeEnumMap,
    json['requestType'],
    unknownValue: RequestType.findOrnament,
  ),
  customer: const _PartyConverter().fromJson(json['customer']),
  categoryName: json['categoryName'] as String?,
  regionName: json['regionName'] as String?,
  indicativeValue: (json['indicativeValue'] as num?)?.toDouble(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$OfferParentRequestSummaryImplToJson(
  _$OfferParentRequestSummaryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'reference': instance.reference,
  'requestType': _$RequestTypeEnumMap[instance.requestType],
  'customer': const _PartyConverter().toJson(instance.customer),
  'categoryName': instance.categoryName,
  'regionName': instance.regionName,
  'indicativeValue': instance.indicativeValue,
  'notes': instance.notes,
};

const _$RequestTypeEnumMap = {
  RequestType.findOrnament: 'FIND_ORNAMENT',
  RequestType.sellOldGold: 'SELL_OLD_GOLD',
  RequestType.goldCoin: 'GOLD_COIN',
  RequestType.goldBullion: 'GOLD_BULLION',
};

_$OfferVendorSummaryImpl _$$OfferVendorSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$OfferVendorSummaryImpl(
  id: json['id'] as String,
  legalBusinessName: json['legalBusinessName'] as String,
  tradingName: json['tradingName'] as String?,
  tradeLicenceNumber: json['tradeLicenceNumber'] as String?,
  contactPersonName: json['contactPersonName'] as String?,
  mobileNumber: json['mobileNumber'] as String?,
  email: json['email'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  completedDeals: (json['completedDeals'] as num?)?.toInt(),
);

Map<String, dynamic> _$$OfferVendorSummaryImplToJson(
  _$OfferVendorSummaryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'legalBusinessName': instance.legalBusinessName,
  'tradingName': instance.tradingName,
  'tradeLicenceNumber': instance.tradeLicenceNumber,
  'contactPersonName': instance.contactPersonName,
  'mobileNumber': instance.mobileNumber,
  'email': instance.email,
  'rating': instance.rating,
  'completedDeals': instance.completedDeals,
};

_$OfferAttachmentImpl _$$OfferAttachmentImplFromJson(
  Map<String, dynamic> json,
) => _$OfferAttachmentImpl(
  id: json['id'] as String,
  fileName: json['fileName'] as String,
  url: json['url'] as String?,
  mimeType: json['mimeType'] as String?,
  sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
  uploadedAt: json['uploadedAt'] == null
      ? null
      : DateTime.parse(json['uploadedAt'] as String),
);

Map<String, dynamic> _$$OfferAttachmentImplToJson(
  _$OfferAttachmentImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'fileName': instance.fileName,
  'url': instance.url,
  'mimeType': instance.mimeType,
  'sizeBytes': instance.sizeBytes,
  'uploadedAt': instance.uploadedAt?.toIso8601String(),
};

_$OfferRevisionItemImpl _$$OfferRevisionItemImplFromJson(
  Map<String, dynamic> json,
) => _$OfferRevisionItemImpl(
  revisionNumber: (json['revisionNumber'] as num).toInt(),
  revisedAt: DateTime.parse(json['revisedAt'] as String),
  offeredPrice: (json['offeredPrice'] as num).toDouble(),
  makingCharges: (json['makingCharges'] as num?)?.toDouble(),
  ratePerGram: (json['ratePerGram'] as num?)?.toDouble(),
  deliveryTimeframe: json['deliveryTimeframe'] as String?,
  vendorNote: json['vendorNote'] as String?,
  changeSummary: json['changeSummary'] as String?,
);

Map<String, dynamic> _$$OfferRevisionItemImplToJson(
  _$OfferRevisionItemImpl instance,
) => <String, dynamic>{
  'revisionNumber': instance.revisionNumber,
  'revisedAt': instance.revisedAt.toIso8601String(),
  'offeredPrice': instance.offeredPrice,
  'makingCharges': instance.makingCharges,
  'ratePerGram': instance.ratePerGram,
  'deliveryTimeframe': instance.deliveryTimeframe,
  'vendorNote': instance.vendorNote,
  'changeSummary': instance.changeSummary,
};

_$OfferStateTransitionItemImpl _$$OfferStateTransitionItemImplFromJson(
  Map<String, dynamic> json,
) => _$OfferStateTransitionItemImpl(
  fromState: json['fromState'] as String?,
  toState: json['toState'] as String,
  transitionedAt: DateTime.parse(json['transitionedAt'] as String),
  actor: json['actor'] as String?,
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$$OfferStateTransitionItemImplToJson(
  _$OfferStateTransitionItemImpl instance,
) => <String, dynamic>{
  'fromState': instance.fromState,
  'toState': instance.toState,
  'transitionedAt': instance.transitionedAt.toIso8601String(),
  'actor': instance.actor,
  'reason': instance.reason,
};

_$OfferInternalNoteItemImpl _$$OfferInternalNoteItemImplFromJson(
  Map<String, dynamic> json,
) => _$OfferInternalNoteItemImpl(
  id: json['id'] as String,
  author: json['author'] as String,
  text: json['text'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$OfferInternalNoteItemImplToJson(
  _$OfferInternalNoteItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'author': instance.author,
  'text': instance.text,
  'createdAt': instance.createdAt.toIso8601String(),
};

_$OfferDetailImpl _$$OfferDetailImplFromJson(
  Map<String, dynamic> json,
) => _$OfferDetailImpl(
  id: json['id'] as String,
  reference: json['reference'] as String?,
  state:
      $enumDecodeNullable(
        _$OfferStateEnumMap,
        json['state'],
        unknownValue: OfferState.pending,
      ) ??
      OfferState.pending,
  offeredPrice: (json['offeredPrice'] as num).toDouble(),
  makingCharges: (json['makingCharges'] as num?)?.toDouble(),
  ratePerGram: (json['ratePerGram'] as num?)?.toDouble(),
  goldPrice: (json['goldPrice'] as num?)?.toDouble(),
  vat: (json['vat'] as num?)?.toDouble(),
  totalAmount: (json['totalAmount'] as num?)?.toDouble(),
  deliveryTimeframe: json['deliveryTimeframe'] as String?,
  warrantyTerms: json['warrantyTerms'] as String?,
  vendorNote: json['vendorNote'] as String?,
  validityHours: (json['validityHours'] as num?)?.toInt(),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  submittedAt: DateTime.parse(json['submittedAt'] as String),
  decidedAt: json['decidedAt'] == null
      ? null
      : DateTime.parse(json['decidedAt'] as String),
  declineReason: json['declineReason'] as String?,
  revisionCount: (json['revisionCount'] as num?)?.toInt() ?? 0,
  winningOfferId: json['winningOfferId'] as String?,
  winningOfferReference: json['winningOfferReference'] as String?,
  winningOfferPrice: (json['winningOfferPrice'] as num?)?.toDouble(),
  winningVendorName: json['winningVendorName'] as String?,
  parentRequest: json['parentRequest'] == null
      ? null
      : OfferParentRequestSummary.fromJson(
          json['parentRequest'] as Map<String, dynamic>,
        ),
  vendor: json['vendor'] == null
      ? null
      : OfferVendorSummary.fromJson(json['vendor'] as Map<String, dynamic>),
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => OfferAttachment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  revisions:
      (json['revisions'] as List<dynamic>?)
          ?.map((e) => OfferRevisionItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  stateTransitions:
      (json['stateTransitions'] as List<dynamic>?)
          ?.map(
            (e) => OfferStateTransitionItem.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  internalNotes:
      (json['internalNotes'] as List<dynamic>?)
          ?.map(
            (e) => OfferInternalNoteItem.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$$OfferDetailImplToJson(_$OfferDetailImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reference': instance.reference,
      'state': _$OfferStateEnumMap[instance.state]!,
      'offeredPrice': instance.offeredPrice,
      'makingCharges': instance.makingCharges,
      'ratePerGram': instance.ratePerGram,
      'goldPrice': instance.goldPrice,
      'vat': instance.vat,
      'totalAmount': instance.totalAmount,
      'deliveryTimeframe': instance.deliveryTimeframe,
      'warrantyTerms': instance.warrantyTerms,
      'vendorNote': instance.vendorNote,
      'validityHours': instance.validityHours,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'submittedAt': instance.submittedAt.toIso8601String(),
      'decidedAt': instance.decidedAt?.toIso8601String(),
      'declineReason': instance.declineReason,
      'revisionCount': instance.revisionCount,
      'winningOfferId': instance.winningOfferId,
      'winningOfferReference': instance.winningOfferReference,
      'winningOfferPrice': instance.winningOfferPrice,
      'winningVendorName': instance.winningVendorName,
      'parentRequest': instance.parentRequest,
      'vendor': instance.vendor,
      'attachments': instance.attachments,
      'revisions': instance.revisions,
      'stateTransitions': instance.stateTransitions,
      'internalNotes': instance.internalNotes,
    };

const _$OfferStateEnumMap = {
  OfferState.pending: 'PENDING',
  OfferState.accepted: 'ACCEPTED',
  OfferState.rejected: 'REJECTED',
  OfferState.expired: 'EXPIRED',
  OfferState.withdrawn: 'WITHDRAWN',
  OfferState.withdrawnBySystem: 'WITHDRAWN_BY_SYSTEM',
};
