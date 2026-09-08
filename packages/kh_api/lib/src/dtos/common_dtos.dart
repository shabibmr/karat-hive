import 'package:kh_core/kh_core.dart';

/// Cursor-paged list result. Mirrors the backend `{ data, meta.nextCursor }`
/// envelope (Architecture-Frontend §9.6).
class Paged<T> {
  const Paged({required this.items, this.nextCursor});

  final List<T> items;
  final String? nextCursor;

  static Paged<T> from<T>(
    KhListPayload payload,
    T Function(Map<String, dynamic>) fromJson,
  ) =>
      Paged<T>(
        items: payload.items
            .map((e) => fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        nextCursor: payload.nextCursor,
      );
}

/// `request.presenter.ts` `CategorySummary`.
class CategorySummaryDto {
  const CategorySummaryDto({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.parentId,
    required this.isActive,
    required this.displayOrder,
    this.icon,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String? parentId;
  final bool isActive;
  final int displayOrder;
  final String? icon;

  static CategorySummaryDto fromJson(Map<String, dynamic> j) => CategorySummaryDto(
        id: j['id'] as String,
        nameEn: j['nameEn'] as String? ?? '',
        nameAr: j['nameAr'] as String? ?? '',
        parentId: j['parentId'] as String?,
        isActive: j['isActive'] as bool? ?? true,
        displayOrder: j['displayOrder'] as int? ?? 0,
        icon: j['icon'] as String?,
      );
}

/// `request.presenter.ts` `RegionSummary`.
class RegionSummaryDto {
  const RegionSummaryDto({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.parentId,
    required this.isActive,
    required this.displayOrder,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String? parentId;
  final bool isActive;
  final int displayOrder;

  static RegionSummaryDto fromJson(Map<String, dynamic> j) => RegionSummaryDto(
        id: j['id'] as String,
        nameEn: j['nameEn'] as String? ?? '',
        nameAr: j['nameAr'] as String? ?? '',
        parentId: j['parentId'] as String?,
        isActive: j['isActive'] as bool? ?? true,
        displayOrder: j['displayOrder'] as int? ?? 0,
      );
}

/// String-encoded rating summary used across the marketplace presenters
/// (`average` is a decimal string here, unlike the profile rating on
/// `GET /v1/me`).
class RatingSummaryDto {
  const RatingSummaryDto({
    required this.average,
    required this.count,
    this.distribution = const {},
    this.limitedHistory = false,
  });

  final String average;
  final int count;
  final Map<String, int> distribution;
  final bool limitedHistory;

  static RatingSummaryDto? fromJson(Map<String, dynamic>? j) => j == null
      ? null
      : RatingSummaryDto(
          average: (j['average'] ?? '0.0').toString(),
          count: j['count'] as int? ?? 0,
          distribution: ((j['distribution'] as Map?) ?? const {})
              .map((k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0)),
          limitedHistory: j['limitedHistory'] as bool? ?? false,
        );
}

/// `offer.presenter.ts` `OfferTermsDto` (also nested in the customer request
/// presenter and the connection presenter).
class OfferTermsDto {
  const OfferTermsDto({
    required this.offeredPrice,
    this.makingCharges,
    this.ratePerGram,
    this.deliveryTimeframe,
    this.warrantyTerms,
    this.vendorNote,
    required this.validityHours,
  });

  final String offeredPrice;
  final String? makingCharges;
  final String? ratePerGram;
  final String? deliveryTimeframe;
  final String? warrantyTerms;
  final String? vendorNote;
  final int validityHours;

  static OfferTermsDto fromJson(Map<String, dynamic> j) => OfferTermsDto(
        offeredPrice: (j['offeredPrice'] ?? '0').toString(),
        makingCharges: j['makingCharges']?.toString(),
        ratePerGram: j['ratePerGram']?.toString(),
        deliveryTimeframe: j['deliveryTimeframe'] as String?,
        warrantyTerms: j['warrantyTerms'] as String?,
        vendorNote: j['vendorNote'] as String?,
        validityHours: j['validityHours'] as int? ?? 0,
      );
}

/// `request.presenter.ts` `RequestMediaRef` / `offer.presenter.ts`
/// `OfferMediaDto`. Offer media only carries id/key/displayOrder; request media
/// adds state/purpose/contentType/byteSize.
class MediaRefDto {
  const MediaRefDto({
    required this.id,
    required this.key,
    required this.displayOrder,
    this.state,
    this.purpose,
    this.contentType,
    this.byteSize,
  });

  final String id;
  final String key;
  final int displayOrder;
  final String? state;
  final String? purpose;
  final String? contentType;
  final int? byteSize;

  static MediaRefDto fromJson(Map<String, dynamic> j) => MediaRefDto(
        id: j['id'] as String? ?? '',
        key: j['key'] as String? ?? '',
        displayOrder: j['displayOrder'] as int? ?? 0,
        state: j['state'] as String?,
        purpose: j['purpose'] as String?,
        contentType: j['contentType'] as String?,
        byteSize: j['byteSize'] as int?,
      );
}

List<MediaRefDto> mediaListFromJson(dynamic raw) => ((raw as List?) ?? const [])
    .map((e) => MediaRefDto.fromJson(e as Map<String, dynamic>))
    .toList(growable: false);
