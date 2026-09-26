import 'package:freezed_annotation/freezed_annotation.dart';

import 'party.dart';
import 'request.dart';

part 'offer.freezed.dart';
part 'offer.g.dart';

enum OfferState {
  pending,
  accepted,
  rejected,
  expired,
  withdrawn,
  withdrawnBySystem,
  unknown;

  static OfferState parse(String? raw) => switch (raw) {
        'PENDING' => pending,
        'ACCEPTED' => accepted,
        'REJECTED' => rejected,
        'EXPIRED' => expired,
        'WITHDRAWN' => withdrawn,
        'WITHDRAWN_BY_SYSTEM' => withdrawnBySystem,
        _ => unknown,
      };

  String get wire => switch (this) {
        pending => 'PENDING',
        accepted => 'ACCEPTED',
        rejected => 'REJECTED',
        expired => 'EXPIRED',
        withdrawn => 'WITHDRAWN',
        withdrawnBySystem => 'WITHDRAWN_BY_SYSTEM',
        unknown => 'UNKNOWN',
      };
}

class _OfferStateConverter implements JsonConverter<OfferState, String?> {
  const _OfferStateConverter();

  @override
  OfferState fromJson(String? json) => OfferState.parse(json);

  @override
  String toJson(OfferState object) => object.wire;
}

Map<String, dynamic> _map(Object? raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return const {};
}

DateTime? _dt(Object? raw) {
  if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
  return null;
}

OfferTerms _offerTermsFromJson(Object? raw) => OfferTerms.fromJson(_map(raw));

Map<String, dynamic> _offerTermsToJson(OfferTerms terms) => terms.toJson();

Map<String, dynamic> _normalizeOfferTermsJson(Map<String, dynamic> json) {
  final nestedMedia = json['media'] as List?;
  return {
    'offeredPrice': json['offeredPrice']?.toString() ?? '',
    'weightGrams': json['weightGrams']?.toString() ?? '',
    'purityKarat': json['purityKarat']?.toString() ?? '',
    'makingCharges': json['makingCharges']?.toString(),
    'ratePerGram': json['ratePerGram']?.toString(),
    'deliveryTimeframe': json['deliveryTimeframe'] as String?,
    'warrantyTerms': json['warrantyTerms'] as String?,
    'vendorNote': json['vendorNote'] as String?,
    'media': (nestedMedia ?? const [])
        .map((e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map))
        .toList(growable: false),
  };
}

@freezed
abstract class OfferTerms with _$OfferTerms {
  const factory OfferTerms({
    required String offeredPrice,
    required String weightGrams,
    required String purityKarat,
    String? makingCharges,
    String? ratePerGram,
    String? deliveryTimeframe,
    String? warrantyTerms,
    String? vendorNote,
    @Default(<MediaRef>[]) List<MediaRef> media,
  }) = _OfferTerms;

  factory OfferTerms.fromJson(Map<String, dynamic> json) =>
      _$OfferTermsFromJson(_normalizeOfferTermsJson(json));
}

/// Parses [json] into [OfferTerms]; [media], when supplied, overrides any
/// nested `media` in [json] — matches the pre-freezed manual constructor's
/// override behaviour used when the parent Offer has already parsed a shared
/// media list.
OfferTerms _offerTermsFromJsonWithMedia(
  Map<String, dynamic> json, {
  List<MediaRef>? media,
}) {
  final parsed = OfferTerms.fromJson(json);
  return media != null ? parsed.copyWith(media: media) : parsed;
}

Map<String, dynamic> _normalizeOfferForCustomerJson(Map<String, dynamic> json) {
  final mediaRaw = json['media'] as List?;
  final media = (mediaRaw ?? const [])
      .map((e) => MediaRef.fromJson(_map(e)))
      .toList(growable: false);
  return {
    ...json,
    'state': json['state']?.toString(),
    'terms': _offerTermsFromJsonWithMedia(_map(json['terms']), media: media).toJson(),
    'vendor': MaskedParty.fromJson(_map(json['vendor']), role: PartyRole.vendor).toJson(),
    'submittedAt':
        (_dt(json['submittedAt']) ?? DateTime.fromMillisecondsSinceEpoch(0))
            .toIso8601String(),
    'expiresAt': (_dt(json['expiresAt']) ?? DateTime.fromMillisecondsSinceEpoch(0))
        .toIso8601String(),
    'decidedAt': _dt(json['decidedAt'])?.toIso8601String(),
    'revisionCount': (json['revisionCount'] as num?)?.toInt() ?? 0,
    'viewedByCustomerAt': _dt(json['viewedByCustomerAt'])?.toIso8601String(),
    'viewedByCustomerAtPresent': json.containsKey('viewedByCustomerAt'),
  };
}

/// Customer Offer presenter. Counterparty is [MaskedParty] only (BR-006).
@freezed
abstract class OfferForCustomer with _$OfferForCustomer {
  const factory OfferForCustomer({
    required String id,
    required String requestId,
    @_OfferStateConverter() required OfferState state,
    @JsonKey(fromJson: _offerTermsFromJson, toJson: _offerTermsToJson)
    required OfferTerms terms,
    required MaskedParty vendor,
    required DateTime submittedAt,
    required DateTime expiresAt,
    required int revisionCount,
    DateTime? decidedAt,
    DateTime? viewedByCustomerAt,

    /// Wire included `viewedByCustomerAt` (SAM-GAP-1). Absent → UI hides unread.
    @Default(false) bool viewedByCustomerAtPresent,
  }) = _OfferForCustomer;

  factory OfferForCustomer.fromJson(Map<String, dynamic> json) =>
      _$OfferForCustomerFromJson(_normalizeOfferForCustomerJson(json));
}

/// Pre-accept Vendor rating sheet (`FR-CUS-031`). No business identity.
Map<String, dynamic> _normalizeReviewExcerptJson(Map<String, dynamic> json) => {
      'abbreviatedName': (json['abbreviatedName'] ??
              json['authorDisplayName'] ??
              json['reviewer'] ??
              '') as String,
      'rating': (json['rating'] as num?)?.toInt() ?? 0,
      'comment': json['comment'] as String?,
    };

@freezed
abstract class ReviewExcerpt with _$ReviewExcerpt {
  const factory ReviewExcerpt({
    required String abbreviatedName,
    required int rating,
    String? comment,
  }) = _ReviewExcerpt;

  factory ReviewExcerpt.fromJson(Map<String, dynamic> json) =>
      _$ReviewExcerptFromJson(_normalizeReviewExcerptJson(json));
}

RatingSummary _ratingSummaryFromJson(Object? raw) =>
    RatingSummary.fromJson(raw) ?? const RatingSummary.score(0);

Map<String, dynamic> _ratingSummaryToJson(RatingSummary summary) =>
    summary.toJson();

Map<String, dynamic> _normalizeVendorRatingDetailJson(
    Map<String, dynamic> json) {
  final excerptsRaw = json['excerpts'] ?? json['reviews'] ?? json['recentReviews'];
  final excerpts = <Map<String, dynamic>>[];
  if (excerptsRaw is List) {
    for (final e in excerptsRaw.take(10)) {
      excerpts.add(_map(e));
    }
  }
  final summaryJson = json['summary'] ?? json['rating'] ?? json;
  return {
    'summary': summaryJson,
    'excerpts': excerpts,
  };
}

@freezed
abstract class VendorRatingDetail with _$VendorRatingDetail {
  const VendorRatingDetail._();

  const factory VendorRatingDetail({
    @JsonKey(fromJson: _ratingSummaryFromJson, toJson: _ratingSummaryToJson)
    required RatingSummary summary,
    @Default(<ReviewExcerpt>[]) List<ReviewExcerpt> excerpts,
  }) = _VendorRatingDetail;

  factory VendorRatingDetail.fromJson(Map<String, dynamic> json) =>
      _$VendorRatingDetailFromJson(_normalizeVendorRatingDetailJson(json));

  bool get limitedHistory => summary.limitedHistory;
}

/// Server-enforced max revisions per Offer (`OFFER_REVISION_LIMIT` / `FR-VEN-014`).
const int kMaxOfferRevisions = 0;

enum OfferDeclineReason {
  priceTooHigh,
  termsUnsuitable,
  noLongerRequired,
  other,
  unknown;

  static OfferDeclineReason parse(String? raw) => switch (raw) {
        'PRICE_TOO_HIGH' => priceTooHigh,
        'TERMS_UNSUITABLE' => termsUnsuitable,
        'NO_LONGER_REQUIRED' => noLongerRequired,
        'OTHER' => other,
        _ => unknown,
      };

  String get wire => switch (this) {
        priceTooHigh => 'PRICE_TOO_HIGH',
        termsUnsuitable => 'TERMS_UNSUITABLE',
        noLongerRequired => 'NO_LONGER_REQUIRED',
        other => 'OTHER',
        unknown => 'UNKNOWN',
      };
}

class _NullableOfferDeclineReasonConverter
    implements JsonConverter<OfferDeclineReason?, String?> {
  const _NullableOfferDeclineReasonConverter();

  @override
  OfferDeclineReason? fromJson(String? json) =>
      json == null ? null : OfferDeclineReason.parse(json);

  @override
  String? toJson(OfferDeclineReason? object) => object?.wire;
}

class _RequestTypeConverter implements JsonConverter<RequestType, String?> {
  const _RequestTypeConverter();

  @override
  RequestType fromJson(String? json) => RequestType.parse(json);

  @override
  String toJson(RequestType object) => object.wire;
}

class _DirectionConverter implements JsonConverter<Direction, String?> {
  const _DirectionConverter();

  @override
  Direction fromJson(String? json) => Direction.parse(json);

  @override
  String toJson(Direction object) => object.wire;
}

/// Parent Request summary on a Vendor Offer (masked Customer label only).
Map<String, dynamic> _normalizeOfferRequestSummaryJson(
    Map<String, dynamic> json) {
  final region = _map(json['region']);
  return {
    'id': json['id'] as String? ?? '',
    'reference': json['reference'] as String?,
    'requestType': json['requestType']?.toString(),
    'direction': json['direction']?.toString(),
    'customerLabel': json['customerLabel'] as String? ?? 'Customer',
    'regionId': region['id'] as String? ?? json['regionId'] as String?,
    'regionName': region['nameEn'] as String? ?? json['regionName'] as String?,
    'purityKarat': json['purityKarat']?.toString(),
    'weightGrams': json['weightGrams']?.toString(),
    'budgetMax': json['budgetMax']?.toString(),
    'expiresAt': _dt(json['expiresAt'])?.toIso8601String(),
  };
}

@freezed
abstract class OfferRequestSummary with _$OfferRequestSummary {
  const factory OfferRequestSummary({
    required String id,
    @_RequestTypeConverter() required RequestType requestType,
    @_DirectionConverter() required Direction direction,
    required String customerLabel,
    String? reference,
    String? regionId,
    String? regionName,
    String? purityKarat,
    String? weightGrams,
    String? budgetMax,
    DateTime? expiresAt,
  }) = _OfferRequestSummary;

  factory OfferRequestSummary.fromJson(Map<String, dynamic> json) =>
      _$OfferRequestSummaryFromJson(_normalizeOfferRequestSummaryJson(json));
}

Map<String, dynamic> _normalizeOfferForVendorJson(Map<String, dynamic> json) {
  final mediaRaw = json['media'] as List?;
  final media = (mediaRaw ?? const [])
      .map((e) => MediaRef.fromJson(_map(e)))
      .toList(growable: false);
  final summaryRaw = json['requestSummary'];
  return {
    ...json,
    'state': json['state']?.toString(),
    'terms': _offerTermsFromJsonWithMedia(_map(json['terms']), media: media).toJson(),
    'submittedAt':
        (_dt(json['submittedAt']) ?? DateTime.fromMillisecondsSinceEpoch(0))
            .toIso8601String(),
    'expiresAt': (_dt(json['expiresAt']) ?? DateTime.fromMillisecondsSinceEpoch(0))
        .toIso8601String(),
    'decidedAt': _dt(json['decidedAt'])?.toIso8601String(),
    'viewedByCustomerAt': _dt(json['viewedByCustomerAt'])?.toIso8601String(),
    'revisionCount': (json['revisionCount'] as num?)?.toInt() ?? 0,
    'requestSummary': summaryRaw is Map ? _map(summaryRaw) : null,
    'declineReason': json['declineReason'] as String?,
    'awardedElsewhere': json['awardedElsewhere'] as bool? ?? false,
  };
}

/// Vendor's own Offer presenter. Never carries competitor price/identity (BR-008).
@freezed
abstract class OfferForVendor with _$OfferForVendor {
  const OfferForVendor._();

  const factory OfferForVendor({
    required String id,
    required String requestId,
    @_OfferStateConverter() required OfferState state,
    @JsonKey(fromJson: _offerTermsFromJson, toJson: _offerTermsToJson)
    required OfferTerms terms,
    required DateTime submittedAt,
    required DateTime expiresAt,
    required int revisionCount,
    DateTime? decidedAt,
    DateTime? viewedByCustomerAt,
    OfferRequestSummary? requestSummary,
    @_NullableOfferDeclineReasonConverter() OfferDeclineReason? declineReason,
    @Default(false) bool awardedElsewhere,

    /// Present when this Offer produced a Connection. Absent → UI keeps the
    /// disabled copy rather than inventing a path (CP4-B05).
    String? connectionId,
  }) = _OfferForVendor;

  factory OfferForVendor.fromJson(Map<String, dynamic> json) =>
      _$OfferForVendorFromJson(_normalizeOfferForVendorJson(json));

  int get revisionsRemaining => 0;

  bool get isSeenByCustomer => viewedByCustomerAt != null;

  bool canReviseAt(DateTime now) => false;

  bool get canRevise => false;

  Duration revisionTimeRemaining(DateTime now) => Duration.zero;

  bool get canWithdraw => state == OfferState.pending;
}

/// Body for submit / revise Offer.
@freezed
abstract class OfferTermsInput with _$OfferTermsInput {
  const OfferTermsInput._();

  const factory OfferTermsInput({
    required String offeredPrice,
    required String weightGrams,
    required String purityKarat,
    String? makingCharges,
    String? ratePerGram,
    String? deliveryTimeframe,
    String? warrantyTerms,
    String? vendorNote,
    @Default(<String>[]) List<String> mediaKeys,
  }) = _OfferTermsInput;

  Map<String, dynamic> toJson({bool includeMediaKeys = true}) => {
        'offeredPrice': offeredPrice,
        'weightGrams': weightGrams,
        'purityKarat': purityKarat,
        if (makingCharges != null && makingCharges!.isNotEmpty)
          'makingCharges': makingCharges,
        if (ratePerGram != null && ratePerGram!.isNotEmpty)
          'ratePerGram': ratePerGram,
        if (deliveryTimeframe != null && deliveryTimeframe!.isNotEmpty)
          'deliveryTimeframe': deliveryTimeframe,
        if (warrantyTerms != null && warrantyTerms!.isNotEmpty)
          'warrantyTerms': warrantyTerms,
        if (vendorNote != null && vendorNote!.isNotEmpty) 'vendorNote': vendorNote,
        if (includeMediaKeys && mediaKeys.isNotEmpty) 'mediaKeys': mediaKeys,
      };
}
