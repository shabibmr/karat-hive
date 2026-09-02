class VendorDashboard {
  const VendorDashboard({
    required this.newRequests,
    required this.pendingOffers,
    required this.activeConnections,
    required this.ratingAverage,
    required this.reviewCount,
  });

  final int newRequests;
  final int pendingOffers;
  final int activeConnections;
  final double? ratingAverage;
  final int reviewCount;

  static VendorDashboard fromJson(Map<String, dynamic> j) {
    int c(String k) => (j[k] as Map<String, dynamic>?)?['count'] as int? ?? 0;
    final rating = j['rating'] as Map<String, dynamic>? ?? const {};
    return VendorDashboard(
      newRequests: c('newRequests'),
      pendingOffers: c('pendingOffers'),
      activeConnections: c('activeConnections'),
      ratingAverage: (rating['average'] as num?)?.toDouble(),
      reviewCount: rating['reviewCount'] as int? ?? 0,
    );
  }
}
