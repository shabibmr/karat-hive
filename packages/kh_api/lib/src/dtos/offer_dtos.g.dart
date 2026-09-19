// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MaskedVendorDto _$MaskedVendorDtoFromJson(Map<String, dynamic> json) =>
    _MaskedVendorDto(
      label: json['label'] as String,
      region: json['region'] == null
          ? null
          : RegionSummaryDto.fromJson(json['region'] as Map<String, dynamic>),
      connectionCount: (json['connectionCount'] as num).toInt(),
      rating: json['rating'] == null
          ? null
          : RatingSummaryDto.fromJson(json['rating'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MaskedVendorDtoToJson(_MaskedVendorDto instance) =>
    <String, dynamic>{
      'label': instance.label,
      'region': instance.region,
      'connectionCount': instance.connectionCount,
      'rating': instance.rating,
    };

_CustomerOfferDto _$CustomerOfferDtoFromJson(Map<String, dynamic> json) =>
    _CustomerOfferDto(
      id: json['id'] as String,
      requestId: json['requestId'] as String,
      state: json['state'] as String,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      decidedAt: json['decidedAt'] == null
          ? null
          : DateTime.parse(json['decidedAt'] as String),
      revisionCount: (json['revisionCount'] as num).toInt(),
      viewedByCustomerAt: json['viewedByCustomerAt'] == null
          ? null
          : DateTime.parse(json['viewedByCustomerAt'] as String),
      terms: OfferTermsDto.fromJson(json['terms'] as Map<String, dynamic>),
      media:
          (json['media'] as List<dynamic>?)
              ?.map((e) => MediaRefDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <MediaRefDto>[],
      vendor: MaskedVendorDto.fromJson(json['vendor'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CustomerOfferDtoToJson(_CustomerOfferDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'requestId': instance.requestId,
      'state': instance.state,
      'submittedAt': instance.submittedAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'decidedAt': instance.decidedAt?.toIso8601String(),
      'revisionCount': instance.revisionCount,
      'viewedByCustomerAt': instance.viewedByCustomerAt?.toIso8601String(),
      'terms': instance.terms,
      'media': instance.media,
      'vendor': instance.vendor,
    };

_VendorRatingSummaryDto _$VendorRatingSummaryDtoFromJson(
  Map<String, dynamic> json,
) => _VendorRatingSummaryDto(
  vendor: MaskedVendorDto.fromJson(json['vendor'] as Map<String, dynamic>),
  reviews: (json['reviews'] as List<dynamic>)
      .map((e) => VendorRatingReviewDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$VendorRatingSummaryDtoToJson(
  _VendorRatingSummaryDto instance,
) => <String, dynamic>{'vendor': instance.vendor, 'reviews': instance.reviews};

_VendorRatingReviewDto _$VendorRatingReviewDtoFromJson(
  Map<String, dynamic> json,
) => _VendorRatingReviewDto(
  id: json['id'] as String,
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String?,
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
  reviewerLabel: json['reviewerLabel'] as String,
);

Map<String, dynamic> _$VendorRatingReviewDtoToJson(
  _VendorRatingReviewDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'rating': instance.rating,
  'comment': instance.comment,
  'publishedAt': instance.publishedAt?.toIso8601String(),
  'reviewerLabel': instance.reviewerLabel,
};
