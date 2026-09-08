import 'common_dtos.dart';
import 'offer_dtos.dart';

/// `request.presenter.ts` `RequestForCustomer` (= `RequestBaseDto` + customer
/// extras). Backs `CUS-S02`, `CUS-S10`, `CUS-S17`.
///
/// `unreadOfferCount` is `SAM-GAP-1` / `CBG-01` — see the backend-gap list;
/// it is nullable here until the presenter aggregate lands.
class CustomerRequestDto {
  const CustomerRequestDto({
    required this.id,
    this.reference,
    required this.requestType,
    required this.direction,
    required this.state,
    required this.category,
    required this.region,
    this.notes,
    this.weightGrams,
    required this.weightIsApproximate,
    this.purityKarat,
    this.ornamentType,
    this.condition,
    this.denominationGrams,
    this.quantity,
    this.mintOrRefiner,
    this.budgetMin,
    this.budgetMax,
    required this.budgetIsFlexible,
    this.indicativeValue,
    this.publishedAt,
    this.expiresAt,
    required this.offerCount,
    this.unreadOfferCount,
    this.media = const [],
    required this.createdAt,
    required this.updatedAt,
    this.gemstones,
    this.cancellationReason,
    this.acceptedOfferId,
    this.connectionId,
    this.offers,
  });

  final String id;
  final String? reference;
  final String requestType;
  final String direction;
  final String state;
  final CategorySummaryDto category;
  final RegionSummaryDto region;
  final String? notes;
  final String? weightGrams;
  final bool weightIsApproximate;
  final String? purityKarat;
  final String? ornamentType;
  final String? condition;
  final String? denominationGrams;
  final int? quantity;
  final String? mintOrRefiner;
  final String? budgetMin;
  final String? budgetMax;
  final bool budgetIsFlexible;
  final String? indicativeValue;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final int offerCount;
  final int? unreadOfferCount;
  final List<MediaRefDto> media;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? gemstones;
  final String? cancellationReason;
  final String? acceptedOfferId;

  /// Deep-link target for `CUS-S10` → `CUS-S15` when `state == ACCEPTED`
  /// (`SAM-GAP-3`).
  final String? connectionId;

  /// Nested only on `GET /v1/requests/:id` (owner presenter).
  final List<CustomerOfferDto>? offers;

  static DateTime? _d(dynamic v) =>
      v == null ? null : DateTime.parse(v as String);

  static CustomerRequestDto fromJson(Map<String, dynamic> j) => CustomerRequestDto(
        id: j['id'] as String,
        reference: j['reference'] as String?,
        requestType: j['requestType'] as String? ?? '',
        direction: j['direction'] as String? ?? '',
        state: j['state'] as String? ?? '',
        category: CategorySummaryDto.fromJson(
            (j['category'] as Map<String, dynamic>?) ?? const {}),
        region: RegionSummaryDto.fromJson(
            (j['region'] as Map<String, dynamic>?) ?? const {}),
        notes: j['notes'] as String?,
        weightGrams: j['weightGrams']?.toString(),
        weightIsApproximate: j['weightIsApproximate'] as bool? ?? false,
        purityKarat: j['purityKarat'] as String?,
        ornamentType: j['ornamentType'] as String?,
        condition: j['condition'] as String?,
        denominationGrams: j['denominationGrams']?.toString(),
        quantity: j['quantity'] as int?,
        mintOrRefiner: j['mintOrRefiner'] as String?,
        budgetMin: j['budgetMin']?.toString(),
        budgetMax: j['budgetMax']?.toString(),
        budgetIsFlexible: j['budgetIsFlexible'] as bool? ?? false,
        indicativeValue: j['indicativeValue']?.toString(),
        publishedAt: _d(j['publishedAt']),
        expiresAt: _d(j['expiresAt']),
        offerCount: j['offerCount'] as int? ?? 0,
        unreadOfferCount: j['unreadOfferCount'] as int?,
        media: mediaListFromJson(j['media']),
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
        gemstones: j['gemstones'] as Map<String, dynamic>?,
        cancellationReason: j['cancellationReason'] as String?,
        acceptedOfferId: j['acceptedOfferId'] as String?,
        connectionId: j['connectionId'] as String?,
        offers: j['offers'] == null
            ? null
            : ((j['offers'] as List)
                .map((e) => CustomerOfferDto.fromJson(e as Map<String, dynamic>))
                .toList(growable: false)),
      );
}

/// Request-create / update payload — mirrors `createRequestSchema` in
/// `request.controller.ts`. All fields optional; the backend validates per
/// `requestType`.
class RequestDraftInput {
  const RequestDraftInput({
    this.requestType,
    this.direction,
    this.categoryId,
    this.regionId,
    this.notes,
    this.weightGrams,
    this.weightIsApproximate,
    this.purityKarat,
    this.ornamentType,
    this.condition,
    this.denominationGrams,
    this.quantity,
    this.mintOrRefiner,
    this.budgetMin,
    this.budgetMax,
    this.budgetIsFlexible,
    this.gemstones,
    this.mediaKeys,
  });

  final String? requestType;
  final String? direction;
  final String? categoryId;
  final String? regionId;
  final String? notes;
  final Object? weightGrams;
  final bool? weightIsApproximate;
  final String? purityKarat;
  final String? ornamentType;
  final String? condition;
  final Object? denominationGrams;
  final int? quantity;
  final String? mintOrRefiner;
  final Object? budgetMin;
  final Object? budgetMax;
  final bool? budgetIsFlexible;
  final Map<String, dynamic>? gemstones;
  final List<String>? mediaKeys;

  Map<String, dynamic> toJson() => {
        if (requestType != null) 'requestType': requestType,
        if (direction != null) 'direction': direction,
        if (categoryId != null) 'categoryId': categoryId,
        if (regionId != null) 'regionId': regionId,
        if (notes != null) 'notes': notes,
        if (weightGrams != null) 'weightGrams': weightGrams,
        if (weightIsApproximate != null)
          'weightIsApproximate': weightIsApproximate,
        if (purityKarat != null) 'purityKarat': purityKarat,
        if (ornamentType != null) 'ornamentType': ornamentType,
        if (condition != null) 'condition': condition,
        if (denominationGrams != null) 'denominationGrams': denominationGrams,
        if (quantity != null) 'quantity': quantity,
        if (mintOrRefiner != null) 'mintOrRefiner': mintOrRefiner,
        if (budgetMin != null) 'budgetMin': budgetMin,
        if (budgetMax != null) 'budgetMax': budgetMax,
        if (budgetIsFlexible != null) 'budgetIsFlexible': budgetIsFlexible,
        if (gemstones != null) 'gemstones': gemstones,
        if (mediaKeys != null) 'mediaKeys': mediaKeys,
      };
}
