import 'party.dart';
import 'request.dart';

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

class OfferTerms {
  const OfferTerms({
    required this.offeredPrice,
    required this.validityHours,
    this.makingCharges,
    this.ratePerGram,
    this.deliveryTimeframe,
    this.warrantyTerms,
    this.vendorNote,
    this.media = const [],
  });

  final String offeredPrice;
  final String? makingCharges;
  final String? ratePerGram;
  final String? deliveryTimeframe;
  final String? warrantyTerms;
  final String? vendorNote;
  final int validityHours;
  final List<MediaRef> media;

  static OfferTerms fromJson(Map<String, dynamic> j, {List<MediaRef>? media}) {
    final nestedMedia = j['media'] as List?;
    return OfferTerms(
      offeredPrice: j['offeredPrice']?.toString() ?? '',
      makingCharges: j['makingCharges']?.toString(),
      ratePerGram: j['ratePerGram']?.toString(),
      deliveryTimeframe: j['deliveryTimeframe'] as String?,
      warrantyTerms: j['warrantyTerms'] as String?,
      vendorNote: j['vendorNote'] as String?,
      validityHours: (j['validityHours'] as num?)?.toInt() ?? 0,
      media: media ??
          (nestedMedia ?? const [])
              .map((e) => MediaRef.fromJson(
                    e is Map<String, dynamic>
                        ? e
                        : Map<String, dynamic>.from(e as Map),
                  ))
              .toList(growable: false),
    );
  }
}

DateTime? _dt(Object? raw) {
  if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
  return null;
}

Map<String, dynamic> _map(Object? raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return const {};
}

/// Customer Offer presenter. Counterparty is [MaskedParty] only (BR-006).
class OfferForCustomer {
  const OfferForCustomer({
    required this.id,
    required this.requestId,
    required this.state,
    required this.terms,
    required this.vendor,
    required this.submittedAt,
    required this.expiresAt,
    required this.revisionCount,
    this.decidedAt,
    this.viewedByCustomerAt,
  });

  final String id;
  final String requestId;
  final OfferState state;
  final OfferTerms terms;
  final MaskedParty vendor;
  final DateTime submittedAt;
  final DateTime expiresAt;
  final DateTime? decidedAt;
  final int revisionCount;
  final DateTime? viewedByCustomerAt;

  static OfferForCustomer fromJson(Map<String, dynamic> j) {
    final mediaRaw = j['media'] as List?;
    final media = (mediaRaw ?? const [])
        .map((e) => MediaRef.fromJson(_map(e)))
        .toList(growable: false);
    return OfferForCustomer(
      id: j['id'] as String,
      requestId: j['requestId'] as String,
      state: OfferState.parse(j['state'] as String?),
      terms: OfferTerms.fromJson(_map(j['terms']), media: media),
      vendor: MaskedParty.fromJson(_map(j['vendor']), role: PartyRole.vendor),
      submittedAt: _dt(j['submittedAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      expiresAt: _dt(j['expiresAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      decidedAt: _dt(j['decidedAt']),
      revisionCount: (j['revisionCount'] as num?)?.toInt() ?? 0,
      viewedByCustomerAt: _dt(j['viewedByCustomerAt']),
    );
  }
}

/// Server-enforced max revisions per Offer (`OFFER_REVISION_LIMIT`).
const int kMaxOfferRevisions = 3;

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

/// Parent Request summary on a Vendor Offer (masked Customer label only).
class OfferRequestSummary {
  const OfferRequestSummary({
    required this.id,
    required this.requestType,
    required this.direction,
    required this.customerLabel,
    this.reference,
    this.categoryId,
    this.categoryName,
    this.regionId,
    this.regionName,
    this.purityKarat,
    this.weightGrams,
    this.budgetMax,
    this.expiresAt,
  });

  final String id;
  final String? reference;
  final RequestType requestType;
  final Direction direction;
  final String customerLabel;
  final String? categoryId;
  final String? categoryName;
  final String? regionId;
  final String? regionName;
  final String? purityKarat;
  final String? weightGrams;
  final String? budgetMax;
  final DateTime? expiresAt;

  static OfferRequestSummary fromJson(Map<String, dynamic> j) {
    final category = _map(j['category']);
    final region = _map(j['region']);
    return OfferRequestSummary(
      id: j['id'] as String? ?? '',
      reference: j['reference'] as String?,
      requestType: RequestType.parse(j['requestType'] as String?),
      direction: Direction.parse(j['direction'] as String?),
      customerLabel: j['customerLabel'] as String? ?? 'Customer',
      categoryId: category['id'] as String? ?? j['categoryId'] as String?,
      categoryName: category['nameEn'] as String? ?? j['categoryName'] as String?,
      regionId: region['id'] as String? ?? j['regionId'] as String?,
      regionName: region['nameEn'] as String? ?? j['regionName'] as String?,
      purityKarat: j['purityKarat']?.toString(),
      weightGrams: j['weightGrams']?.toString(),
      budgetMax: j['budgetMax']?.toString(),
      expiresAt: _dt(j['expiresAt']),
    );
  }
}

/// Vendor's own Offer presenter. Never carries competitor price/identity (BR-008).
class OfferForVendor {
  const OfferForVendor({
    required this.id,
    required this.requestId,
    required this.state,
    required this.terms,
    required this.submittedAt,
    required this.expiresAt,
    required this.revisionCount,
    this.decidedAt,
    this.requestSummary,
    this.declineReason,
    this.awardedElsewhere = false,
    this.connectionId,
  });

  final String id;
  final String requestId;
  final OfferState state;
  final OfferTerms terms;
  final DateTime submittedAt;
  final DateTime expiresAt;
  final DateTime? decidedAt;
  final int revisionCount;
  final OfferRequestSummary? requestSummary;
  final OfferDeclineReason? declineReason;
  final bool awardedElsewhere;

  /// Present when this Offer produced a Connection. Absent → UI keeps the
  /// disabled copy rather than inventing a path (CP4-B05).
  final String? connectionId;

  int get revisionsRemaining =>
      (kMaxOfferRevisions - revisionCount).clamp(0, kMaxOfferRevisions);

  bool get canRevise => state == OfferState.pending && revisionsRemaining > 0;

  bool get canWithdraw => state == OfferState.pending;

  static OfferForVendor fromJson(Map<String, dynamic> j) {
    final mediaRaw = j['media'] as List?;
    final media = (mediaRaw ?? const [])
        .map((e) => MediaRef.fromJson(_map(e)))
        .toList(growable: false);
    final summaryRaw = j['requestSummary'];
    final declineRaw = j['declineReason'] as String?;
    return OfferForVendor(
      id: j['id'] as String,
      requestId: j['requestId'] as String,
      state: OfferState.parse(j['state'] as String?),
      terms: OfferTerms.fromJson(_map(j['terms']), media: media),
      submittedAt:
          _dt(j['submittedAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      expiresAt: _dt(j['expiresAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      decidedAt: _dt(j['decidedAt']),
      revisionCount: (j['revisionCount'] as num?)?.toInt() ?? 0,
      requestSummary: summaryRaw is Map
          ? OfferRequestSummary.fromJson(_map(summaryRaw))
          : null,
      declineReason:
          declineRaw == null ? null : OfferDeclineReason.parse(declineRaw),
      awardedElsewhere: j['awardedElsewhere'] as bool? ?? false,
      connectionId: j['connectionId'] as String?,
    );
  }
}

/// Body for submit / revise Offer.
class OfferTermsInput {
  const OfferTermsInput({
    required this.offeredPrice,
    required this.validityHours,
    this.makingCharges,
    this.ratePerGram,
    this.deliveryTimeframe,
    this.warrantyTerms,
    this.vendorNote,
    this.mediaKeys = const [],
  });

  final String offeredPrice;
  final int validityHours;
  final String? makingCharges;
  final String? ratePerGram;
  final String? deliveryTimeframe;
  final String? warrantyTerms;
  final String? vendorNote;
  final List<String> mediaKeys;

  Map<String, dynamic> toJson({bool includeMediaKeys = true}) => {
        'offeredPrice': offeredPrice,
        'validityHours': validityHours,
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
