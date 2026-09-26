// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomerRequestDto _$CustomerRequestDtoFromJson(Map<String, dynamic> json) =>
    _CustomerRequestDto(
      id: json['id'] as String,
      reference: json['reference'] as String?,
      requestType: json['requestType'] as String,
      direction: json['direction'] as String,
      state: json['state'] as String,
      region: RegionSummaryDto.fromJson(json['region'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
      weightGrams: json['weightGrams'] as String?,
      weightIsApproximate: json['weightIsApproximate'] as bool,
      purityKarat: json['purityKarat'] as String?,
      ornamentType: json['ornamentType'] as String?,
      condition: json['condition'] as String?,
      denominationGrams: json['denominationGrams'] as String?,
      quantity: (json['quantity'] as num?)?.toInt(),
      mintOrRefiner: json['mintOrRefiner'] as String?,
      budgetMin: json['budgetMin'] as String?,
      budgetMax: json['budgetMax'] as String?,
      budgetIsFlexible: json['budgetIsFlexible'] as bool,
      indicativeValue: json['indicativeValue'] as String?,
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      offerCount: (json['offerCount'] as num).toInt(),
      unreadOfferCount: (json['unreadOfferCount'] as num?)?.toInt(),
      media:
          (json['media'] as List<dynamic>?)
              ?.map((e) => MediaRefDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <MediaRefDto>[],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      gemstones: json['gemstones'] as Map<String, dynamic>?,
      cancellationReason: json['cancellationReason'] as String?,
      acceptedOfferId: json['acceptedOfferId'] as String?,
      connectionId: json['connectionId'] as String?,
      offers: (json['offers'] as List<dynamic>?)
          ?.map((e) => CustomerOfferDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CustomerRequestDtoToJson(_CustomerRequestDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reference': instance.reference,
      'requestType': instance.requestType,
      'direction': instance.direction,
      'state': instance.state,
      'region': instance.region,
      'notes': instance.notes,
      'weightGrams': instance.weightGrams,
      'weightIsApproximate': instance.weightIsApproximate,
      'purityKarat': instance.purityKarat,
      'ornamentType': instance.ornamentType,
      'condition': instance.condition,
      'denominationGrams': instance.denominationGrams,
      'quantity': instance.quantity,
      'mintOrRefiner': instance.mintOrRefiner,
      'budgetMin': instance.budgetMin,
      'budgetMax': instance.budgetMax,
      'budgetIsFlexible': instance.budgetIsFlexible,
      'indicativeValue': instance.indicativeValue,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'offerCount': instance.offerCount,
      'unreadOfferCount': instance.unreadOfferCount,
      'media': instance.media,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'gemstones': instance.gemstones,
      'cancellationReason': instance.cancellationReason,
      'acceptedOfferId': instance.acceptedOfferId,
      'connectionId': instance.connectionId,
      'offers': instance.offers,
    };

_RequestDraftInput _$RequestDraftInputFromJson(Map<String, dynamic> json) =>
    _RequestDraftInput(
      requestType: json['requestType'] as String?,
      direction: json['direction'] as String?,
      regionId: json['regionId'] as String?,
      notes: json['notes'] as String?,
      weightGrams: json['weightGrams'],
      weightIsApproximate: json['weightIsApproximate'] as bool?,
      purityKarat: json['purityKarat'] as String?,
      ornamentType: json['ornamentType'] as String?,
      condition: json['condition'] as String?,
      denominationGrams: json['denominationGrams'],
      quantity: (json['quantity'] as num?)?.toInt(),
      mintOrRefiner: json['mintOrRefiner'] as String?,
      budgetMin: json['budgetMin'],
      budgetMax: json['budgetMax'],
      budgetIsFlexible: json['budgetIsFlexible'] as bool?,
      gemstones: json['gemstones'] as Map<String, dynamic>?,
      mediaKeys: (json['mediaKeys'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$RequestDraftInputToJson(_RequestDraftInput instance) =>
    <String, dynamic>{
      'requestType': ?instance.requestType,
      'direction': ?instance.direction,
      'regionId': ?instance.regionId,
      'notes': ?instance.notes,
      'weightGrams': ?instance.weightGrams,
      'weightIsApproximate': ?instance.weightIsApproximate,
      'purityKarat': ?instance.purityKarat,
      'ornamentType': ?instance.ornamentType,
      'condition': ?instance.condition,
      'denominationGrams': ?instance.denominationGrams,
      'quantity': ?instance.quantity,
      'mintOrRefiner': ?instance.mintOrRefiner,
      'budgetMin': ?instance.budgetMin,
      'budgetMax': ?instance.budgetMax,
      'budgetIsFlexible': ?instance.budgetIsFlexible,
      'gemstones': ?instance.gemstones,
      'mediaKeys': ?instance.mediaKeys,
    };
