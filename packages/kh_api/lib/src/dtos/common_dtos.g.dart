// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegionSummaryDto _$RegionSummaryDtoFromJson(Map<String, dynamic> json) =>
    _RegionSummaryDto(
      id: json['id'] as String,
      nameEn: json['nameEn'] as String,
      nameAr: json['nameAr'] as String,
      isActive: json['isActive'] as bool,
      displayOrder: (json['displayOrder'] as num).toInt(),
    );

Map<String, dynamic> _$RegionSummaryDtoToJson(_RegionSummaryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameEn': instance.nameEn,
      'nameAr': instance.nameAr,
      'isActive': instance.isActive,
      'displayOrder': instance.displayOrder,
    };

_RatingSummaryDto _$RatingSummaryDtoFromJson(Map<String, dynamic> json) =>
    _RatingSummaryDto(
      average: json['average'] as String,
      count: (json['count'] as num).toInt(),
      distribution:
          (json['distribution'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      limitedHistory: json['limitedHistory'] as bool? ?? false,
    );

Map<String, dynamic> _$RatingSummaryDtoToJson(_RatingSummaryDto instance) =>
    <String, dynamic>{
      'average': instance.average,
      'count': instance.count,
      'distribution': instance.distribution,
      'limitedHistory': instance.limitedHistory,
    };

_OfferTermsDto _$OfferTermsDtoFromJson(Map<String, dynamic> json) =>
    _OfferTermsDto(
      offeredPrice: json['offeredPrice'] as String,
      makingCharges: json['makingCharges'] as String?,
      ratePerGram: json['ratePerGram'] as String?,
      deliveryTimeframe: json['deliveryTimeframe'] as String?,
      warrantyTerms: json['warrantyTerms'] as String?,
      vendorNote: json['vendorNote'] as String?,
      validityHours: (json['validityHours'] as num).toInt(),
    );

Map<String, dynamic> _$OfferTermsDtoToJson(_OfferTermsDto instance) =>
    <String, dynamic>{
      'offeredPrice': instance.offeredPrice,
      'makingCharges': instance.makingCharges,
      'ratePerGram': instance.ratePerGram,
      'deliveryTimeframe': instance.deliveryTimeframe,
      'warrantyTerms': instance.warrantyTerms,
      'vendorNote': instance.vendorNote,
      'validityHours': instance.validityHours,
    };

_MediaRefDto _$MediaRefDtoFromJson(Map<String, dynamic> json) => _MediaRefDto(
  id: json['id'] as String,
  key: json['key'] as String,
  displayOrder: (json['displayOrder'] as num).toInt(),
  state: json['state'] as String?,
  purpose: json['purpose'] as String?,
  contentType: json['contentType'] as String?,
  byteSize: (json['byteSize'] as num?)?.toInt(),
);

Map<String, dynamic> _$MediaRefDtoToJson(_MediaRefDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'displayOrder': instance.displayOrder,
      'state': instance.state,
      'purpose': instance.purpose,
      'contentType': instance.contentType,
      'byteSize': instance.byteSize,
    };
