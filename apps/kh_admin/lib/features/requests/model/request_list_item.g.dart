// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RequestListItemImpl _$$RequestListItemImplFromJson(
  Map<String, dynamic> json,
) => _$RequestListItemImpl(
  id: json['id'] as String,
  reference: json['reference'] as String?,
  requestType: $enumDecode(
    _$RequestTypeEnumMap,
    json['requestType'],
    unknownValue: RequestType.findOrnament,
  ),
  direction: $enumDecode(
    _$DirectionEnumMap,
    json['direction'],
    unknownValue: Direction.buy,
  ),
  state: $enumDecode(
    _$RequestStateEnumMap,
    json['state'],
    unknownValue: RequestState.draft,
  ),
  customerName: json['customerName'] as String? ?? 'Unknown Customer',
  customerId: json['customerId'] as String?,
  customerPhone: json['customerPhone'] as String?,
  categoryName: json['categoryName'] as String? ?? '—',
  regionName: json['regionName'] as String? ?? '—',
  indicativeValue: (json['indicativeValue'] as num?)?.toDouble(),
  budgetMin: (json['budgetMin'] as num?)?.toDouble(),
  budgetMax: (json['budgetMax'] as num?)?.toDouble(),
  offerCount: (json['offerCount'] as num?)?.toInt() ?? 0,
  notes: json['notes'] as String?,
  ornamentType: json['ornamentType'] as String?,
  weightGrams: (json['weightGrams'] as num?)?.toDouble(),
  purityKarat: json['purityKarat'] as String?,
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$RequestListItemImplToJson(
  _$RequestListItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'reference': instance.reference,
  'requestType': _$RequestTypeEnumMap[instance.requestType]!,
  'direction': _$DirectionEnumMap[instance.direction]!,
  'state': _$RequestStateEnumMap[instance.state]!,
  'customerName': instance.customerName,
  'customerId': instance.customerId,
  'customerPhone': instance.customerPhone,
  'categoryName': instance.categoryName,
  'regionName': instance.regionName,
  'indicativeValue': instance.indicativeValue,
  'budgetMin': instance.budgetMin,
  'budgetMax': instance.budgetMax,
  'offerCount': instance.offerCount,
  'notes': instance.notes,
  'ornamentType': instance.ornamentType,
  'weightGrams': instance.weightGrams,
  'purityKarat': instance.purityKarat,
  'publishedAt': instance.publishedAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
};

const _$RequestTypeEnumMap = {
  RequestType.findOrnament: 'FIND_ORNAMENT',
  RequestType.sellOldGold: 'SELL_OLD_GOLD',
  RequestType.goldCoin: 'GOLD_COIN',
  RequestType.goldBullion: 'GOLD_BULLION',
};

const _$DirectionEnumMap = {Direction.buy: 'BUY', Direction.sell: 'SELL'};

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
