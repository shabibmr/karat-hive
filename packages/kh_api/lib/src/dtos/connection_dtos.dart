import 'package:freezed_annotation/freezed_annotation.dart';

import 'common_dtos.dart';

part 'connection_dtos.freezed.dart';
part 'connection_dtos.g.dart';

Map<String, dynamic> _normalizeTalkJson(Map<String, dynamic> json) => {
      'available': json['available'] as bool? ?? false,
      'waUrl': json['waUrl'] as String? ?? '',
      'phone': json['phone'] as String? ?? '',
      'callUrl': json['callUrl'] as String? ?? '',
    };

/// `connection.presenter.ts` `TalkDto` — the embedded WhatsApp / call deep-link
/// payload (`C-03`, SRS §7.2). `waUrl` is an outbound `wa.me` link only.
@freezed
abstract class TalkDto with _$TalkDto {
  const factory TalkDto({
    required bool available,
    required String waUrl,
    required String phone,
    required String callUrl,
  }) = _TalkDto;

  factory TalkDto.fromJson(Map<String, dynamic> json) =>
      _$TalkDtoFromJson(_normalizeTalkJson(json));
}

Map<String, dynamic> _normalizeRevealedVendorJson(Map<String, dynamic> json) => {
      ...json,
      'id': json['id'] as String? ?? '',
      'legalBusinessName': json['legalBusinessName'] as String? ?? '',
      'tradingName': json['tradingName'] as String? ?? '',
      'tradeLicenceNumber': json['tradeLicenceNumber'] as String? ?? '',
      'phone': json['phone'] as String? ?? '',
      'connectionCount': json['connectionCount'] as int? ?? 0,
      // 'region'/'rating' stay raw nullable maps — the generated fromJson
      // already null-checks then delegates to RegionSummaryDto/RatingSummaryDto.fromJson.
    };

/// The **revealed** vendor on a Customer's Connection (`connection.presenter.ts`
/// `ConnectionForCustomer.vendor`). Distinct from `MaskedVendorDto`: identity is
/// present because the payload is only reachable through an accepted Connection
/// the viewer is party to (`BR-007`, `AD-FE-07`).
@freezed
abstract class RevealedVendorDto with _$RevealedVendorDto {
  const factory RevealedVendorDto({
    required String id,
    required String legalBusinessName,
    required String tradingName,
    required String tradeLicenceNumber,
    required String phone,
    required int connectionCount,
    RegionSummaryDto? region,
    RatingSummaryDto? rating,
  }) = _RevealedVendorDto;

  factory RevealedVendorDto.fromJson(Map<String, dynamic> json) =>
      _$RevealedVendorDtoFromJson(_normalizeRevealedVendorJson(json));
}

Map<String, dynamic> _normalizeConnectionOfferJson(Map<String, dynamic> json) => {
      'id': json['id'] as String? ?? '',
      'offeredPrice': (json['offeredPrice'] ?? '0').toString(),
      'makingCharges': json['makingCharges']?.toString(),
      'ratePerGram': json['ratePerGram']?.toString(),
      'validityHours': json['validityHours'] as int? ?? 0,
      'deliveryTimeframe': json['deliveryTimeframe'] as String?,
      'warrantyTerms': json['warrantyTerms'] as String?,
      'vendorNote': json['vendorNote'] as String?,
    };

@freezed
abstract class ConnectionOfferDto with _$ConnectionOfferDto {
  const factory ConnectionOfferDto({
    required String id,
    required String offeredPrice,
    String? makingCharges,
    String? ratePerGram,
    required int validityHours,
    String? deliveryTimeframe,
    String? warrantyTerms,
    String? vendorNote,
  }) = _ConnectionOfferDto;

  factory ConnectionOfferDto.fromJson(Map<String, dynamic> json) =>
      _$ConnectionOfferDtoFromJson(_normalizeConnectionOfferJson(json));
}

Map<String, dynamic> _normalizeConnectionRequestRefJson(
        Map<String, dynamic> json) =>
    {
      ...json,
      'id': json['id'] as String? ?? '',
      'reference': json['reference'] as String?,
      'requestType': json['requestType'] as String? ?? '',
      'direction': json['direction'] as String? ?? '',
      // required-but-possibly-absent nested objects default to {} like the
      // original manual parser, then get auto-delegated to their own fromJson.
      'category': (json['category'] as Map<String, dynamic>?) ?? const {},
      'region': (json['region'] as Map<String, dynamic>?) ?? const {},
    };

@freezed
abstract class ConnectionRequestRefDto with _$ConnectionRequestRefDto {
  const factory ConnectionRequestRefDto({
    required String id,
    String? reference,
    required String requestType,
    required String direction,
    required CategorySummaryDto category,
    required RegionSummaryDto region,
  }) = _ConnectionRequestRefDto;

  factory ConnectionRequestRefDto.fromJson(Map<String, dynamic> json) =>
      _$ConnectionRequestRefDtoFromJson(
          _normalizeConnectionRequestRefJson(json));
}

Map<String, dynamic> _normalizeCustomerConnectionJson(
        Map<String, dynamic> json) =>
    {
      ...json,
      'id': json['id'] as String,
      'offerId': json['offerId'] as String? ?? '',
      'requestId': json['requestId'] as String? ?? '',
      'state': json['state'] as String? ?? '',
      'closedBy': json['closedBy'] as String?,
      'vendor': (json['vendor'] as Map<String, dynamic>?) ?? const {},
      'offer': (json['offer'] as Map<String, dynamic>?) ?? const {},
      'request': (json['request'] as Map<String, dynamic>?) ?? const {},
      'talk': (json['talk'] as Map<String, dynamic>?) ?? const {},
    };

/// `connection.presenter.ts` `ConnectionForCustomer`. Backs `CUS-S15`,
/// `CUS-S16`, `CUS-S18`.
@freezed
abstract class CustomerConnectionDto with _$CustomerConnectionDto {
  const factory CustomerConnectionDto({
    required String id,
    required String offerId,
    required String requestId,
    required String state,
    required DateTime identityRevealedAt,
    DateTime? closedAt,
    String? closedBy,
    required RevealedVendorDto vendor,
    required ConnectionOfferDto offer,
    required ConnectionRequestRefDto request,
    required TalkDto talk,
  }) = _CustomerConnectionDto;

  factory CustomerConnectionDto.fromJson(Map<String, dynamic> json) =>
      _$CustomerConnectionDtoFromJson(_normalizeCustomerConnectionJson(json));
}
