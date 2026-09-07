class PlatformConfig {
  const PlatformConfig({
    required this.requestLifetimeHours,
    required this.offerValidityHours,
    required this.defaultOfferValidityHours,
    required this.bullionMinimumAed,
    required this.maxConcurrentLiveRequests,
    required this.maxRequestImages,
    required this.maxOfferImages,
    required this.maxImageBytes,
    required this.acceptedImageTypes,
    required this.karatList,
    required this.maxOfferRevisions,
    required this.requestExpiryWarningHours,
    this.termsUrl,
    this.privacyUrl,
    this.supportContactUrl,
    this.subscriptionContactUrl,
  });

  final int requestLifetimeHours;
  final List<int> offerValidityHours;
  final int defaultOfferValidityHours;
  final String bullionMinimumAed;
  final int maxConcurrentLiveRequests;
  final int maxRequestImages;
  final int maxOfferImages;
  final int maxImageBytes;
  final List<String> acceptedImageTypes;
  final List<String> karatList;
  final int maxOfferRevisions;
  final int requestExpiryWarningHours;
  final String? termsUrl;
  final String? privacyUrl;
  final String? supportContactUrl;
  final String? subscriptionContactUrl;

  static PlatformConfig fromJson(Map<String, dynamic> j) {
    List<int> ints(Object? raw) => (raw as List? ?? const [])
        .map((e) => (e as num).toInt())
        .toList(growable: false);
    List<String> strs(Object? raw) => (raw as List? ?? const [])
        .map((e) => e.toString())
        .toList(growable: false);

    return PlatformConfig(
      requestLifetimeHours: (j['requestLifetimeHours'] as num?)?.toInt() ?? 48,
      offerValidityHours: ints(j['offerValidityHours']),
      defaultOfferValidityHours:
          (j['defaultOfferValidityHours'] as num?)?.toInt() ?? 24,
      bullionMinimumAed: j['bullionMinimumAed']?.toString() ?? '500.00',
      maxConcurrentLiveRequests:
          (j['maxConcurrentLiveRequests'] as num?)?.toInt() ?? 10,
      maxRequestImages: (j['maxRequestImages'] as num?)?.toInt() ?? 5,
      maxOfferImages: (j['maxOfferImages'] as num?)?.toInt() ?? 3,
      maxImageBytes: (j['maxImageBytes'] as num?)?.toInt() ?? 0,
      acceptedImageTypes: strs(j['acceptedImageTypes']),
      karatList: strs(j['karatList']),
      maxOfferRevisions: (j['maxOfferRevisions'] as num?)?.toInt() ?? 3,
      requestExpiryWarningHours:
          (j['requestExpiryWarningHours'] as num?)?.toInt() ?? 6,
      termsUrl: j['termsUrl'] as String?,
      privacyUrl: j['privacyUrl'] as String?,
      supportContactUrl: j['supportContactUrl'] as String?,
      subscriptionContactUrl: j['subscriptionContactUrl'] as String?,
    );
  }
}
