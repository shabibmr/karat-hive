// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MediaRef _$MediaRefFromJson(Map<String, dynamic> json) => _MediaRef(
  id: json['id'] as String,
  key: json['key'] as String,
  state: const _MediaStateConverter().fromJson(json['state'] as String?),
  purpose: const _MediaPurposeConverter().fromJson(json['purpose'] as String?),
  contentType: json['contentType'] as String,
  byteSize: (json['byteSize'] as num).toInt(),
  displayOrder: (json['displayOrder'] as num).toInt(),
  thumbnailUrl: json['thumbnailUrl'] as String?,
  displayUrl: json['displayUrl'] as String?,
);

Map<String, dynamic> _$MediaRefToJson(_MediaRef instance) => <String, dynamic>{
  'id': instance.id,
  'key': instance.key,
  'state': const _MediaStateConverter().toJson(instance.state),
  'purpose': const _MediaPurposeConverter().toJson(instance.purpose),
  'contentType': instance.contentType,
  'byteSize': instance.byteSize,
  'displayOrder': instance.displayOrder,
  'thumbnailUrl': instance.thumbnailUrl,
  'displayUrl': instance.displayUrl,
};

_RequestForCustomer _$RequestForCustomerFromJson(
  Map<String, dynamic> json,
) => _RequestForCustomer(
  id: json['id'] as String,
  requestType: const _RequestTypeConverter().fromJson(
    json['requestType'] as String?,
  ),
  direction: const _DirectionConverter().fromJson(json['direction'] as String?),
  state: const _RequestStateConverter().fromJson(json['state'] as String?),
  category: CategorySummary.fromJson(json['category'] as Map<String, dynamic>),
  region: RegionSummary.fromJson(json['region'] as Map<String, dynamic>),
  weightIsApproximate: json['weightIsApproximate'] as bool,
  budgetIsFlexible: json['budgetIsFlexible'] as bool,
  offerCount: (json['offerCount'] as num).toInt(),
  media: (json['media'] as List<dynamic>)
      .map((e) => MediaRef.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  reference: json['reference'] as String?,
  notes: json['notes'] as String?,
  weightGrams: json['weightGrams'] as String?,
  purityKarat: const _NullableKaratConverter().fromJson(
    json['purityKarat'] as String?,
  ),
  ornamentType: const _NullableOrnamentTypeConverter().fromJson(
    json['ornamentType'] as String?,
  ),
  condition: const _NullableItemConditionConverter().fromJson(
    json['condition'] as String?,
  ),
  denominationGrams: json['denominationGrams'] as String?,
  quantity: (json['quantity'] as num?)?.toInt(),
  mintOrRefiner: json['mintOrRefiner'] as String?,
  budgetMin: json['budgetMin'] as String?,
  budgetMax: json['budgetMax'] as String?,
  indicativeValue: json['indicativeValue'] as String?,
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  cancellationReason: json['cancellationReason'] as String?,
  acceptedOfferId: json['acceptedOfferId'] as String?,
  unreadOfferCount: (json['unreadOfferCount'] as num?)?.toInt(),
  connectionId: json['connectionId'] as String?,
);

Map<String, dynamic> _$RequestForCustomerToJson(
  _RequestForCustomer instance,
) => <String, dynamic>{
  'id': instance.id,
  'requestType': const _RequestTypeConverter().toJson(instance.requestType),
  'direction': const _DirectionConverter().toJson(instance.direction),
  'state': const _RequestStateConverter().toJson(instance.state),
  'category': instance.category.toJson(),
  'region': instance.region.toJson(),
  'weightIsApproximate': instance.weightIsApproximate,
  'budgetIsFlexible': instance.budgetIsFlexible,
  'offerCount': instance.offerCount,
  'media': instance.media.map((e) => e.toJson()).toList(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'reference': instance.reference,
  'notes': instance.notes,
  'weightGrams': instance.weightGrams,
  'purityKarat': const _NullableKaratConverter().toJson(instance.purityKarat),
  'ornamentType': const _NullableOrnamentTypeConverter().toJson(
    instance.ornamentType,
  ),
  'condition': const _NullableItemConditionConverter().toJson(
    instance.condition,
  ),
  'denominationGrams': instance.denominationGrams,
  'quantity': instance.quantity,
  'mintOrRefiner': instance.mintOrRefiner,
  'budgetMin': instance.budgetMin,
  'budgetMax': instance.budgetMax,
  'indicativeValue': instance.indicativeValue,
  'publishedAt': instance.publishedAt?.toIso8601String(),
  'expiresAt': instance.expiresAt?.toIso8601String(),
  'cancellationReason': instance.cancellationReason,
  'acceptedOfferId': instance.acceptedOfferId,
  'unreadOfferCount': instance.unreadOfferCount,
  'connectionId': instance.connectionId,
};
