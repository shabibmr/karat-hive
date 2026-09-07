import 'party.dart';
import 'request_media_ref.dart';

export 'request_media_ref.dart';

/// Represents a vendor-facing request item in the feed or detail screen.
/// Customer identity is strictly masked per BR-006 / AD-FE-07.
class VendorRequestItem {
  const VendorRequestItem({
    required this.id,
    this.reference,
    required this.requestType,
    required this.direction,
    required this.state,
    required this.categoryId,
    this.categoryName,
    required this.regionId,
    this.regionName,
    this.weightGrams,
    this.weightIsApproximate = false,
    this.purityKarat,
    this.budgetMin,
    this.budgetMax,
    this.budgetIsFlexible = false,
    this.notes,
    this.publishedAt,
    this.expiresAt,
    this.offerCount = 0,
    this.viewedAt,
    this.hasResponded = false,
    required this.customer,
    this.media = const [],
  });

  final String id;
  final String? reference;
  final String requestType;
  final String direction;
  final String state;
  final String categoryId;
  final String? categoryName;
  final String regionId;
  final String? regionName;
  final double? weightGrams;
  final bool weightIsApproximate;
  final String? purityKarat;
  final double? budgetMin;
  final double? budgetMax;
  final bool budgetIsFlexible;
  final String? notes;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final int offerCount;
  final DateTime? viewedAt;
  final bool hasResponded;
  final MaskedParty customer;
  final List<RequestMediaRef> media;

  bool get isViewed => viewedAt != null;

  static VendorRequestItem fromJson(Map<String, dynamic> j) {
    DateTime? parseDate(dynamic v) =>
        v != null ? DateTime.tryParse(v.toString()) : null;
    double? parseDouble(dynamic v) =>
        v != null ? double.tryParse(v.toString()) : null;

    final customerJson = (j['customer'] as Map<String, dynamic>?) ?? {};
    final mediaList = (j['media'] as List?) ?? const [];

    return VendorRequestItem(
      id: j['id'] as String,
      reference: j['reference'] as String?,
      requestType: j['requestType'] as String? ?? 'FIND_ORNAMENT',
      direction: j['direction'] as String? ?? 'BUY',
      state: j['state'] as String? ?? 'PUBLISHED',
      categoryId: j['categoryId'] as String? ?? '',
      categoryName: (j['category'] as Map<String, dynamic>?)?['nameEn'] as String?,
      regionId: j['regionId'] as String? ?? '',
      regionName: (j['region'] as Map<String, dynamic>?)?['nameEn'] as String?,
      weightGrams: parseDouble(j['weightGrams']),
      weightIsApproximate: j['weightIsApproximate'] as bool? ?? false,
      purityKarat: j['purityKarat']?.toString(),
      budgetMin: parseDouble(j['budgetMin']),
      budgetMax: parseDouble(j['budgetMax']),
      budgetIsFlexible: j['budgetIsFlexible'] as bool? ?? false,
      notes: j['notes'] as String?,
      publishedAt: parseDate(j['publishedAt']),
      expiresAt: parseDate(j['expiresAt']),
      offerCount: j['offerCount'] as int? ?? 0,
      viewedAt: parseDate(j['viewedAt']),
      hasResponded: j['hasResponded'] as bool? ?? false,
      customer: MaskedParty.fromJson(customerJson),
      media: mediaList
          .map((m) => RequestMediaRef.fromJson(m as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class FilterPresetItem {
  const FilterPresetItem({
    required this.id,
    required this.name,
    required this.filters,
    required this.createdAt,
  });

  final String id;
  final String name;
  final Map<String, dynamic> filters;
  final DateTime createdAt;

  static FilterPresetItem fromJson(Map<String, dynamic> j) => FilterPresetItem(
        id: j['id'] as String,
        name: j['name'] as String,
        filters: (j['filters'] as Map<String, dynamic>?) ?? const {},
        createdAt: DateTime.tryParse(j['createdAt'].toString()) ?? DateTime.now(),
      );
}

class VendorSubscriptionItem {
  const VendorSubscriptionItem({
    required this.requestType,
    required this.state,
    required this.priceAed,
    this.periodStart,
    this.periodEnd,
    this.graceEndsAt,
    this.renewalDate,
    required this.canOffer,
  });

  final String requestType;
  final String state;
  final String priceAed;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final DateTime? graceEndsAt;
  final DateTime? renewalDate;
  final bool canOffer;

  static VendorSubscriptionItem fromJson(Map<String, dynamic> j) {
    DateTime? parseDate(dynamic v) =>
        v != null ? DateTime.tryParse(v.toString()) : null;

    return VendorSubscriptionItem(
      requestType: j['requestType'] as String,
      state: j['state'] as String,
      priceAed: j['priceAed']?.toString() ?? '0.00',
      periodStart: parseDate(j['periodStart']),
      periodEnd: parseDate(j['periodEnd']),
      graceEndsAt: parseDate(j['graceEndsAt']),
      renewalDate: parseDate(j['renewalDate']),
      canOffer: j['canOffer'] as bool? ?? false,
    );
  }
}

class PlatformConfig {
  const PlatformConfig({
    required this.requestLifetimeHours,
    required this.offerValidityHours,
    required this.defaultOfferValidityHours,
    required this.bullionMinimumAed,
    required this.maxConcurrentLiveRequests,
    required this.maxOfferRevisions,
    required this.requestExpiryWarningHours,
    required this.karatList,
    required this.supportContactUrl,
    required this.subscriptionContactUrl,
    required this.termsUrl,
    required this.privacyUrl,
  });

  final int requestLifetimeHours;
  final List<int> offerValidityHours;
  final int defaultOfferValidityHours;
  final String bullionMinimumAed;
  final int maxConcurrentLiveRequests;
  final int maxOfferRevisions;
  final int requestExpiryWarningHours;
  final List<String> karatList;
  final String supportContactUrl;
  final String subscriptionContactUrl;
  final String termsUrl;
  final String privacyUrl;

  static PlatformConfig fromJson(Map<String, dynamic> j) {
    final legal = (j['legal'] as Map<String, dynamic>?) ?? const {};
    final support = (j['support'] as Map<String, dynamic>?) ?? const {};
    return PlatformConfig(
      requestLifetimeHours: j['requestLifetimeHours'] as int? ?? 48,
      offerValidityHours: ((j['offerValidityHours'] as List?) ?? [12, 24, 48])
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .toList(growable: false),
      defaultOfferValidityHours: j['defaultOfferValidityHours'] as int? ?? 24,
      bullionMinimumAed: j['bullionMinimumAed']?.toString() ?? '5000',
      maxConcurrentLiveRequests: j['maxConcurrentLiveRequests'] as int? ?? 3,
      maxOfferRevisions: j['maxOfferRevisions'] as int? ?? 3,
      requestExpiryWarningHours: j['requestExpiryWarningHours'] as int? ?? 6,
      karatList: ((j['karatList'] ?? j['karats']) as List?)
              ?.map((e) => e.toString())
              .toList(growable: false) ??
          const ['18', '21', '22', '24'],
      supportContactUrl: j['supportContactUrl'] as String? ??
          support['contactUrl'] as String? ??
          'https://karathive.ae/support',
      subscriptionContactUrl: j['subscriptionContactUrl'] as String? ??
          'https://karathive.ae/subscriptions',
      termsUrl: legal['termsUrl'] as String? ?? 'https://karathive.ae/terms',
      privacyUrl: legal['privacyUrl'] as String? ?? 'https://karathive.ae/privacy',
    );
  }
}
