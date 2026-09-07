class PlatformConfig {
  const PlatformConfig({
    this.requestLifetimeHours = 48,
    this.offerValidityHours = const [12, 24, 48],
    this.defaultOfferValidityHours = 24,
    this.bullionMinimumAed = '5000',
    this.maxConcurrentLiveRequests = 3,
    this.maxRequestImages = 5,
    this.maxOfferImages = 3,
    this.maxImageBytes = 0,
    this.acceptedImageTypes = const ['image/jpeg', 'image/png', 'image/webp'],
    this.karatList = const ['18', '21', '22', '24'],
    this.maxOfferRevisions = 3,
    this.requestExpiryWarningHours = 6,
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

  PlatformConfig copyWith({
    int? requestLifetimeHours,
    List<int>? offerValidityHours,
    int? defaultOfferValidityHours,
    String? bullionMinimumAed,
    int? maxConcurrentLiveRequests,
    int? maxRequestImages,
    int? maxOfferImages,
    int? maxImageBytes,
    List<String>? acceptedImageTypes,
    List<String>? karatList,
    int? maxOfferRevisions,
    int? requestExpiryWarningHours,
    String? termsUrl,
    String? privacyUrl,
    String? supportContactUrl,
    String? subscriptionContactUrl,
  }) {
    return PlatformConfig(
      requestLifetimeHours: requestLifetimeHours ?? this.requestLifetimeHours,
      offerValidityHours: offerValidityHours ?? this.offerValidityHours,
      defaultOfferValidityHours: defaultOfferValidityHours ?? this.defaultOfferValidityHours,
      bullionMinimumAed: bullionMinimumAed ?? this.bullionMinimumAed,
      maxConcurrentLiveRequests: maxConcurrentLiveRequests ?? this.maxConcurrentLiveRequests,
      maxRequestImages: maxRequestImages ?? this.maxRequestImages,
      maxOfferImages: maxOfferImages ?? this.maxOfferImages,
      maxImageBytes: maxImageBytes ?? this.maxImageBytes,
      acceptedImageTypes: acceptedImageTypes ?? this.acceptedImageTypes,
      karatList: karatList ?? this.karatList,
      maxOfferRevisions: maxOfferRevisions ?? this.maxOfferRevisions,
      requestExpiryWarningHours: requestExpiryWarningHours ?? this.requestExpiryWarningHours,
      termsUrl: termsUrl ?? this.termsUrl,
      privacyUrl: privacyUrl ?? this.privacyUrl,
      supportContactUrl: supportContactUrl ?? this.supportContactUrl,
      subscriptionContactUrl: subscriptionContactUrl ?? this.subscriptionContactUrl,
    );
  }

  static PlatformConfig fromJson(Map<String, dynamic> j) {
    final legal = (j['legal'] as Map<String, dynamic>?) ?? const {};
    final support = (j['support'] as Map<String, dynamic>?) ?? const {};

    List<int> parseOfferValidity(Object? raw) {
      if (raw is List && raw.isNotEmpty) {
        return raw.map((e) => int.tryParse(e.toString()) ?? 0).toList(growable: false);
      }
      return const [12, 24, 48];
    }

    List<String> parseKaratList(Object? raw) {
      if (raw is List && raw.isNotEmpty) {
        return raw.map((e) => e.toString()).toList(growable: false);
      }
      return const ['18', '21', '22', '24'];
    }

    List<String> parseAcceptedImageTypes(Object? raw) {
      if (raw is List && raw.isNotEmpty) {
        return raw.map((e) => e.toString()).toList(growable: false);
      }
      return const ['image/jpeg', 'image/png', 'image/webp'];
    }

    return PlatformConfig(
      requestLifetimeHours: (j['requestLifetimeHours'] as num?)?.toInt() ?? 48,
      offerValidityHours: parseOfferValidity(j['offerValidityHours']),
      defaultOfferValidityHours:
          (j['defaultOfferValidityHours'] as num?)?.toInt() ?? 24,
      bullionMinimumAed: j['bullionMinimumAed']?.toString() ?? '5000',
      maxConcurrentLiveRequests:
          (j['maxConcurrentLiveRequests'] as num?)?.toInt() ?? 3,
      maxRequestImages: (j['maxRequestImages'] as num?)?.toInt() ?? 5,
      maxOfferImages: (j['maxOfferImages'] as num?)?.toInt() ?? 3,
      maxImageBytes: (j['maxImageBytes'] as num?)?.toInt() ?? 0,
      acceptedImageTypes: parseAcceptedImageTypes(j['acceptedImageTypes']),
      karatList: parseKaratList(j['karatList'] ?? j['karats']),
      maxOfferRevisions: (j['maxOfferRevisions'] as num?)?.toInt() ?? 3,
      requestExpiryWarningHours:
          (j['requestExpiryWarningHours'] as num?)?.toInt() ?? 6,
      termsUrl: (j['termsUrl'] ?? legal['termsUrl']) as String?,
      privacyUrl: (j['privacyUrl'] ?? legal['privacyUrl']) as String?,
      supportContactUrl: (j['supportContactUrl'] ?? support['contactUrl']) as String?,
      subscriptionContactUrl: j['subscriptionContactUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'requestLifetimeHours': requestLifetimeHours,
        'offerValidityHours': offerValidityHours,
        'defaultOfferValidityHours': defaultOfferValidityHours,
        'bullionMinimumAed': bullionMinimumAed,
        'maxConcurrentLiveRequests': maxConcurrentLiveRequests,
        'maxRequestImages': maxRequestImages,
        'maxOfferImages': maxOfferImages,
        'maxImageBytes': maxImageBytes,
        'acceptedImageTypes': acceptedImageTypes,
        'karatList': karatList,
        'maxOfferRevisions': maxOfferRevisions,
        'requestExpiryWarningHours': requestExpiryWarningHours,
        if (termsUrl != null) 'termsUrl': termsUrl,
        if (privacyUrl != null) 'privacyUrl': privacyUrl,
        if (supportContactUrl != null) 'supportContactUrl': supportContactUrl,
        if (subscriptionContactUrl != null)
          'subscriptionContactUrl': subscriptionContactUrl,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlatformConfig &&
          runtimeType == other.runtimeType &&
          requestLifetimeHours == other.requestLifetimeHours &&
          defaultOfferValidityHours == other.defaultOfferValidityHours &&
          bullionMinimumAed == other.bullionMinimumAed &&
          maxConcurrentLiveRequests == other.maxConcurrentLiveRequests &&
          maxOfferRevisions == other.maxOfferRevisions &&
          requestExpiryWarningHours == other.requestExpiryWarningHours &&
          termsUrl == other.termsUrl &&
          privacyUrl == other.privacyUrl &&
          supportContactUrl == other.supportContactUrl &&
          subscriptionContactUrl == other.subscriptionContactUrl;

  @override
  int get hashCode => Object.hash(
        requestLifetimeHours,
        defaultOfferValidityHours,
        bullionMinimumAed,
        maxConcurrentLiveRequests,
        maxOfferRevisions,
        requestExpiryWarningHours,
        termsUrl,
        privacyUrl,
        supportContactUrl,
        subscriptionContactUrl,
      );
}
