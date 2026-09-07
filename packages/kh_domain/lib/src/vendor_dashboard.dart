import 'request_feed_models.dart';

class VendorDashboard {
  const VendorDashboard({
    required this.newRequests,
    this.newRequestPreview = const [],
    required this.pendingOffers,
    this.pendingOffersExpiringWithin24h = 0,
    required this.activeConnections,
    this.activeConnectionsNoTalkCount = 0,
    required this.ratingAverage,
    required this.reviewCount,
    this.goldRates,
    this.subscriptions = const [],
  });

  final int newRequests;
  final List<VendorRequestItem> newRequestPreview;
  final int pendingOffers;
  final int pendingOffersExpiringWithin24h;
  final int activeConnections;
  final int activeConnectionsNoTalkCount;
  final double? ratingAverage;
  final int reviewCount;
  final Object? goldRates;
  final List<VendorSubscriptionItem> subscriptions;

  static VendorDashboard fromJson(Map<String, dynamic> j) {
    Map<String, dynamic> section(String k) =>
        (j[k] as Map<String, dynamic>?) ?? const {};

    int countOf(String k) => section(k)['count'] as int? ?? 0;

    final newRequestsSection = section('newRequests');
    final pendingOffersSection = section('pendingOffers');
    final activeConnectionsSection = section('activeConnections');
    final rating = section('rating');

    final previewRaw = (newRequestsSection['preview'] as List?) ?? const [];
    final subsRaw = (j['subscriptions'] as List?) ?? const [];

    return VendorDashboard(
      newRequests: countOf('newRequests'),
      newRequestPreview: previewRaw
          .whereType<Map>()
          .map((e) => VendorRequestItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false),
      pendingOffers: countOf('pendingOffers'),
      pendingOffersExpiringWithin24h:
          pendingOffersSection['expiringWithin24h'] as int? ?? 0,
      activeConnections: countOf('activeConnections'),
      activeConnectionsNoTalkCount:
          activeConnectionsSection['noTalkCount'] as int? ?? 0,
      ratingAverage: (rating['average'] as num?)?.toDouble(),
      reviewCount: rating['reviewCount'] as int? ?? 0,
      goldRates: j['goldRates'],
      subscriptions: subsRaw.map((e) {
        if (e is Map) {
          return VendorSubscriptionItem.fromJson(Map<String, dynamic>.from(e));
        }
        // Legacy/test fixtures may pass bare request-type strings.
        return VendorSubscriptionItem(
          requestType: e.toString(),
          state: 'ACTIVE',
          priceAed: '0.00',
          canOffer: true,
        );
      }).toList(growable: false),
    );
  }
}
