import 'package:freezed_annotation/freezed_annotation.dart';

import 'common_dtos.dart';
import 'offer_dtos.dart';

part 'request_dtos.freezed.dart';
part 'request_dtos.g.dart';

Map<String, dynamic> _normalizeCustomerRequestJson(Map<String, dynamic> json) => {
      ...json,
      'id': json['id'] as String,
      'requestType': json['requestType'] as String? ?? '',
      'direction': json['direction'] as String? ?? '',
      'state': json['state'] as String? ?? '',
      'region': (json['region'] as Map<String, dynamic>?) ?? const {},
      'weightGrams': json['weightGrams']?.toString(),
      'weightIsApproximate': json['weightIsApproximate'] as bool? ?? false,
      'denominationGrams': json['denominationGrams']?.toString(),
      'budgetMin': json['budgetMin']?.toString(),
      'budgetMax': json['budgetMax']?.toString(),
      'budgetIsFlexible': json['budgetIsFlexible'] as bool? ?? false,
      'indicativeValue': json['indicativeValue']?.toString(),
      'offerCount': json['offerCount'] as int? ?? 0,
      'media': (json['media'] as List?) ?? const [],
      'gemstones': json['gemstones'] as Map<String, dynamic>?,
    };

/// `request.presenter.ts` `RequestForCustomer` (= `RequestBaseDto` + customer
/// extras). Backs `CUS-S02`, `CUS-S10`, `CUS-S17`.
///
/// `unreadOfferCount` is `SAM-GAP-1` / `CBG-01` — see the backend-gap list;
/// it is nullable here until the presenter aggregate lands.
@freezed
abstract class CustomerRequestDto with _$CustomerRequestDto {
  const factory CustomerRequestDto({
    required String id,
    String? reference,
    required String requestType,
    required String direction,
    required String state,
    required RegionSummaryDto region,
    String? notes,
    String? weightGrams,
    required bool weightIsApproximate,
    String? purityKarat,
    String? ornamentType,
    String? condition,
    String? denominationGrams,
    int? quantity,
    String? mintOrRefiner,
    String? budgetMin,
    String? budgetMax,
    required bool budgetIsFlexible,
    String? indicativeValue,
    DateTime? publishedAt,
    DateTime? expiresAt,
    required int offerCount,
    int? unreadOfferCount,
    @Default(<MediaRefDto>[]) List<MediaRefDto> media,
    required DateTime createdAt,
    required DateTime updatedAt,
    Map<String, dynamic>? gemstones,
    String? cancellationReason,
    String? acceptedOfferId,
    // Deep-link target for `CUS-S10` → `CUS-S15` when `state == ACCEPTED` (`SAM-GAP-3`).
    String? connectionId,
    // Nested only on `GET /v1/requests/:id` (owner presenter).
    List<CustomerOfferDto>? offers,
  }) = _CustomerRequestDto;

  factory CustomerRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CustomerRequestDtoFromJson(_normalizeCustomerRequestJson(json));
}

/// Request-create / update payload — mirrors `createRequestSchema` in
/// `request.controller.ts`. All fields optional; the backend validates per
/// `requestType`. Omits null fields on [toJson] (`@JsonKey(includeIfNull:
/// false)` on every field) to match the original hand-written
/// partial-payload behaviour.
@freezed
abstract class RequestDraftInput with _$RequestDraftInput {
  const factory RequestDraftInput({
    @JsonKey(includeIfNull: false) String? requestType,
    @JsonKey(includeIfNull: false) String? direction,
    @JsonKey(includeIfNull: false) String? regionId,
    @JsonKey(includeIfNull: false) String? notes,
    @JsonKey(includeIfNull: false) Object? weightGrams,
    @JsonKey(includeIfNull: false) bool? weightIsApproximate,
    @JsonKey(includeIfNull: false) String? purityKarat,
    @JsonKey(includeIfNull: false) String? ornamentType,
    @JsonKey(includeIfNull: false) String? condition,
    @JsonKey(includeIfNull: false) Object? denominationGrams,
    @JsonKey(includeIfNull: false) int? quantity,
    @JsonKey(includeIfNull: false) String? mintOrRefiner,
    @JsonKey(includeIfNull: false) Object? budgetMin,
    @JsonKey(includeIfNull: false) Object? budgetMax,
    @JsonKey(includeIfNull: false) bool? budgetIsFlexible,
    @JsonKey(includeIfNull: false) Map<String, dynamic>? gemstones,
    @JsonKey(includeIfNull: false) List<String>? mediaKeys,
  }) = _RequestDraftInput;

  factory RequestDraftInput.fromJson(Map<String, dynamic> json) =>
      _$RequestDraftInputFromJson(json);
}
