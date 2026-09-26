import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kh_core/kh_core.dart';

part 'common_dtos.freezed.dart';
part 'common_dtos.g.dart';

/// Cursor-paged list result. Mirrors the backend `{ data, meta.nextCursor }`
/// envelope (Architecture-Frontend §9.6). Generic wrapper, not a wire DTO
/// itself — stays a plain class (freezed doesn't fit a runtime-generic
/// `fromJson` converter callback like [from]).
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



Map<String, dynamic> _normalizeRegionSummaryJson(Map<String, dynamic> json) => {
      ...json,
      'nameEn': json['nameEn'] as String? ?? '',
      'nameAr': json['nameAr'] as String? ?? '',
      'isActive': json['isActive'] as bool? ?? true,
      'displayOrder': json['displayOrder'] as int? ?? 0,
    };

/// `request.presenter.ts` `RegionSummary`.
@freezed
abstract class RegionSummaryDto with _$RegionSummaryDto {
  const factory RegionSummaryDto({
    required String id,
    required String nameEn,
    required String nameAr,
    required bool isActive,
    required int displayOrder,
  }) = _RegionSummaryDto;

  factory RegionSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$RegionSummaryDtoFromJson(_normalizeRegionSummaryJson(json));
}

Map<String, dynamic> _normalizeRatingSummaryJson(Map<String, dynamic> json) => {
      'average': (json['average'] ?? '0.0').toString(),
      'count': json['count'] as int? ?? 0,
      'distribution': ((json['distribution'] as Map?) ?? const {})
          .map((k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0)),
      'limitedHistory': json['limitedHistory'] as bool? ?? false,
    };

/// String-encoded rating summary used across the marketplace presenters
/// (`average` is a decimal string here, unlike the profile rating on
/// `GET /v1/me`).
@freezed
abstract class RatingSummaryDto with _$RatingSummaryDto {
  const factory RatingSummaryDto({
    required String average,
    required int count,
    @Default(<String, int>{}) Map<String, int> distribution,
    @Default(false) bool limitedHistory,
  }) = _RatingSummaryDto;

  factory RatingSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$RatingSummaryDtoFromJson(_normalizeRatingSummaryJson(json));
}

Map<String, dynamic> _normalizeOfferTermsJson(Map<String, dynamic> json) => {
      'offeredPrice': (json['offeredPrice'] ?? '0').toString(),
      'makingCharges': json['makingCharges']?.toString(),
      'ratePerGram': json['ratePerGram']?.toString(),
      'deliveryTimeframe': json['deliveryTimeframe'] as String?,
      'warrantyTerms': json['warrantyTerms'] as String?,
      'vendorNote': json['vendorNote'] as String?,
      'validityHours': json['validityHours'] as int? ?? 0,
    };

/// `offer.presenter.ts` `OfferTermsDto` (also nested in the customer request
/// presenter and the connection presenter).
@freezed
abstract class OfferTermsDto with _$OfferTermsDto {
  const factory OfferTermsDto({
    required String offeredPrice,
    String? makingCharges,
    String? ratePerGram,
    String? deliveryTimeframe,
    String? warrantyTerms,
    String? vendorNote,
    required int validityHours,
  }) = _OfferTermsDto;

  factory OfferTermsDto.fromJson(Map<String, dynamic> json) =>
      _$OfferTermsDtoFromJson(_normalizeOfferTermsJson(json));
}

Map<String, dynamic> _normalizeMediaRefJson(Map<String, dynamic> json) => {
      'id': json['id'] as String? ?? '',
      'key': json['key'] as String? ?? '',
      'displayOrder': json['displayOrder'] as int? ?? 0,
      'state': json['state'] as String?,
      'purpose': json['purpose'] as String?,
      'contentType': json['contentType'] as String?,
      'byteSize': json['byteSize'] as int?,
    };

/// `request.presenter.ts` `RequestMediaRef` / `offer.presenter.ts`
/// `OfferMediaDto`. Offer media only carries id/key/displayOrder; request media
/// adds state/purpose/contentType/byteSize.
@freezed
abstract class MediaRefDto with _$MediaRefDto {
  const factory MediaRefDto({
    required String id,
    required String key,
    required int displayOrder,
    String? state,
    String? purpose,
    String? contentType,
    int? byteSize,
  }) = _MediaRefDto;

  factory MediaRefDto.fromJson(Map<String, dynamic> json) =>
      _$MediaRefDtoFromJson(_normalizeMediaRefJson(json));
}

List<MediaRefDto> mediaListFromJson(dynamic raw) => ((raw as List?) ?? const [])
    .map((e) => MediaRefDto.fromJson(e as Map<String, dynamic>))
    .toList(growable: false);
