import 'common_dtos.dart';

/// `offer.presenter.ts` `MaskedVendorDto`. The **masked** counterpart to the
/// revealed vendor on a Connection (`AD-FE-07`): it has no name, licence or
/// phone field to render — identity is absent until Acceptance (`BR-006`,
/// `NFR-013`).
class MaskedVendorDto {
  const MaskedVendorDto({
    required this.label,
    this.region,
    required this.connectionCount,
    this.rating,
  });

  final String label;
  final RegionSummaryDto? region;
  final int connectionCount;
  final RatingSummaryDto? rating;

  static MaskedVendorDto fromJson(Map<String, dynamic> j) => MaskedVendorDto(
        label: j['label'] as String? ?? '',
        region: j['region'] == null
            ? null
            : RegionSummaryDto.fromJson(j['region'] as Map<String, dynamic>),
        connectionCount: j['connectionCount'] as int? ?? 0,
        rating: RatingSummaryDto.fromJson(j['rating'] as Map<String, dynamic>?),
      );
}

/// `offer.presenter.ts` `OfferForCustomer`. Also parses the nested offer shape
/// on `RequestForCustomer.offers` (media / viewedByCustomerAt simply absent
/// there).
class CustomerOfferDto {
  const CustomerOfferDto({
    required this.id,
    required this.requestId,
    required this.state,
    required this.submittedAt,
    required this.expiresAt,
    this.decidedAt,
    required this.revisionCount,
    this.viewedByCustomerAt,
    required this.terms,
    this.media = const [],
    required this.vendor,
  });

  final String id;
  final String requestId;
  final String state;
  final DateTime submittedAt;
  final DateTime expiresAt;
  final DateTime? decidedAt;
  final int revisionCount;
  final DateTime? viewedByCustomerAt;
  final OfferTermsDto terms;
  final List<MediaRefDto> media;
  final MaskedVendorDto vendor;

  bool get isUnread => viewedByCustomerAt == null;

  static CustomerOfferDto fromJson(Map<String, dynamic> j) => CustomerOfferDto(
        id: j['id'] as String,
        requestId: j['requestId'] as String? ?? '',
        state: j['state'] as String? ?? 'PENDING',
        submittedAt: DateTime.parse(j['submittedAt'] as String),
        expiresAt: DateTime.parse(j['expiresAt'] as String),
        decidedAt: j['decidedAt'] == null
            ? null
            : DateTime.parse(j['decidedAt'] as String),
        revisionCount: j['revisionCount'] as int? ?? 0,
        viewedByCustomerAt: j['viewedByCustomerAt'] == null
            ? null
            : DateTime.parse(j['viewedByCustomerAt'] as String),
        terms: OfferTermsDto.fromJson(
            (j['terms'] as Map<String, dynamic>?) ?? const {}),
        media: mediaListFromJson(j['media']),
        vendor: MaskedVendorDto.fromJson(
            (j['vendor'] as Map<String, dynamic>?) ?? const {}),
      );
}

/// `offer.presenter.ts` `VendorRatingSummary` — backs `CUS-S13`'s
/// `GET /v1/offers/:id/vendor-rating`.
class VendorRatingSummaryDto {
  const VendorRatingSummaryDto({required this.vendor, required this.reviews});

  final MaskedVendorDto vendor;
  final List<VendorRatingReviewDto> reviews;

  static VendorRatingSummaryDto fromJson(Map<String, dynamic> j) =>
      VendorRatingSummaryDto(
        vendor: MaskedVendorDto.fromJson(
            (j['vendor'] as Map<String, dynamic>?) ?? const {}),
        reviews: ((j['reviews'] as List?) ?? const [])
            .map((e) => VendorRatingReviewDto.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
      );
}

class VendorRatingReviewDto {
  const VendorRatingReviewDto({
    required this.id,
    required this.rating,
    this.comment,
    this.publishedAt,
    required this.reviewerLabel,
  });

  final String id;
  final int rating;
  final String? comment;
  final DateTime? publishedAt;
  final String reviewerLabel;

  static VendorRatingReviewDto fromJson(Map<String, dynamic> j) =>
      VendorRatingReviewDto(
        id: j['id'] as String,
        rating: j['rating'] as int? ?? 0,
        comment: j['comment'] as String?,
        publishedAt: j['publishedAt'] == null
            ? null
            : DateTime.parse(j['publishedAt'] as String),
        reviewerLabel: j['reviewerLabel'] as String? ?? '',
      );
}
