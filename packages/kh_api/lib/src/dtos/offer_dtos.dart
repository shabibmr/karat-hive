import 'package:freezed_annotation/freezed_annotation.dart';

import 'common_dtos.dart';

part 'offer_dtos.freezed.dart';
part 'offer_dtos.g.dart';

Map<String, dynamic> _normalizeMaskedVendorJson(Map<String, dynamic> json) => {
      ...json,
      'label': json['label'] as String? ?? '',
      'connectionCount': json['connectionCount'] as int? ?? 0,
    };

/// `offer.presenter.ts` `MaskedVendorDto`. The **masked** counterpart to the
/// revealed vendor on a Connection (`AD-FE-07`): it has no name, licence or
/// phone field to render — identity is absent until Acceptance (`BR-006`,
/// `NFR-013`).
@freezed
abstract class MaskedVendorDto with _$MaskedVendorDto {
  const factory MaskedVendorDto({
    required String label,
    RegionSummaryDto? region,
    required int connectionCount,
    RatingSummaryDto? rating,
  }) = _MaskedVendorDto;

  factory MaskedVendorDto.fromJson(Map<String, dynamic> json) =>
      _$MaskedVendorDtoFromJson(_normalizeMaskedVendorJson(json));
}

Map<String, dynamic> _normalizeCustomerOfferJson(Map<String, dynamic> json) => {
      ...json,
      'id': json['id'] as String,
      'requestId': json['requestId'] as String? ?? '',
      'state': json['state'] as String? ?? 'PENDING',
      'revisionCount': json['revisionCount'] as int? ?? 0,
      'terms': (json['terms'] as Map<String, dynamic>?) ?? const {},
      'media': (json['media'] as List?) ?? const [],
      'vendor': (json['vendor'] as Map<String, dynamic>?) ?? const {},
    };

/// `offer.presenter.ts` `OfferForCustomer`. Also parses the nested offer shape
/// on `RequestForCustomer.offers` (media / viewedByCustomerAt simply absent
/// there).
@freezed
abstract class CustomerOfferDto with _$CustomerOfferDto {
  const CustomerOfferDto._();

  const factory CustomerOfferDto({
    required String id,
    required String requestId,
    required String state,
    required DateTime submittedAt,
    required DateTime expiresAt,
    DateTime? decidedAt,
    required int revisionCount,
    DateTime? viewedByCustomerAt,
    required OfferTermsDto terms,
    @Default(<MediaRefDto>[]) List<MediaRefDto> media,
    required MaskedVendorDto vendor,
  }) = _CustomerOfferDto;

  factory CustomerOfferDto.fromJson(Map<String, dynamic> json) =>
      _$CustomerOfferDtoFromJson(_normalizeCustomerOfferJson(json));

  bool get isUnread => viewedByCustomerAt == null;
}

Map<String, dynamic> _normalizeVendorRatingSummaryJson(
        Map<String, dynamic> json) =>
    {
      'vendor': (json['vendor'] as Map<String, dynamic>?) ?? const {},
      'reviews': (json['reviews'] as List?) ?? const [],
    };

/// `offer.presenter.ts` `VendorRatingSummary` — backs `CUS-S13`'s
/// `GET /v1/offers/:id/vendor-rating`.
@freezed
abstract class VendorRatingSummaryDto with _$VendorRatingSummaryDto {
  const factory VendorRatingSummaryDto({
    required MaskedVendorDto vendor,
    required List<VendorRatingReviewDto> reviews,
  }) = _VendorRatingSummaryDto;

  factory VendorRatingSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$VendorRatingSummaryDtoFromJson(_normalizeVendorRatingSummaryJson(json));
}

Map<String, dynamic> _normalizeVendorRatingReviewJson(
        Map<String, dynamic> json) =>
    {
      'id': json['id'] as String,
      'rating': json['rating'] as int? ?? 0,
      'comment': json['comment'] as String?,
      'publishedAt': json['publishedAt'] as String?,
      'reviewerLabel': json['reviewerLabel'] as String? ?? '',
    };

@freezed
abstract class VendorRatingReviewDto with _$VendorRatingReviewDto {
  const factory VendorRatingReviewDto({
    required String id,
    required int rating,
    String? comment,
    DateTime? publishedAt,
    required String reviewerLabel,
  }) = _VendorRatingReviewDto;

  factory VendorRatingReviewDto.fromJson(Map<String, dynamic> json) =>
      _$VendorRatingReviewDtoFromJson(_normalizeVendorRatingReviewJson(json));
}
