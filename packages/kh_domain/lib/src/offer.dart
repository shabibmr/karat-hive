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
