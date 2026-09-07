// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_request_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VendorRequestItem _$VendorRequestItemFromJson(Map<String, dynamic> json) =>
    _VendorRequestItem(
      id: json['id'] as String,
      reference: json['reference'] as String?,
      requestType: json['requestType'] as String,
      direction: json['direction'] as String,
      state: json['state'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String?,
      regionId: json['regionId'] as String,
      regionName: json['regionName'] as String?,
      weightGrams: (json['weightGrams'] as num?)?.toDouble(),
      weightIsApproximate: json['weightIsApproximate'] as bool? ?? false,
      purityKarat: json['purityKarat'] as String?,
      budgetMin: (json['budgetMin'] as num?)?.toDouble(),
      budgetMax: (json['budgetMax'] as num?)?.toDouble(),
      budgetIsFlexible: json['budgetIsFlexible'] as bool? ?? false,
      notes: json['notes'] as String?,
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      offerCount: (json['offerCount'] as num?)?.toInt() ?? 0,
      viewedAt: json['viewedAt'] == null
          ? null
          : DateTime.parse(json['viewedAt'] as String),
      hasResponded: json['hasResponded'] as bool? ?? false,
      customer: MaskedParty.fromJson(json['customer'] as Map<String, dynamic>),
      media:
          (json['media'] as List<dynamic>?)
              ?.map((e) => RequestMediaRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <RequestMediaRef>[],
    );

Map<String, dynamic> _$VendorRequestItemToJson(_VendorRequestItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reference': instance.reference,
      'requestType': instance.requestType,
      'direction': instance.direction,
      'state': instance.state,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'regionId': instance.regionId,
      'regionName': instance.regionName,
      'weightGrams': instance.weightGrams,
      'weightIsApproximate': instance.weightIsApproximate,
      'purityKarat': instance.purityKarat,
      'budgetMin': instance.budgetMin,
      'budgetMax': instance.budgetMax,
      'budgetIsFlexible': instance.budgetIsFlexible,
      'notes': instance.notes,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'offerCount': instance.offerCount,
      'viewedAt': instance.viewedAt?.toIso8601String(),
      'hasResponded': instance.hasResponded,
      'customer': instance.customer,
      'media': instance.media,
    };
