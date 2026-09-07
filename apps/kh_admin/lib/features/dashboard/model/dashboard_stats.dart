/// Platform statistics model returned by `GET /v1/admin/dashboard` (ADM-S02).
class DashboardStats {
  const DashboardStats({
    required this.totalCustomers,
    required this.totalVendors,
    required this.pendingVerificationVendors,
    required this.activeRequests,
    required this.activeOffers,
    required this.activeConnections,
  });

  final int totalCustomers;
  final int totalVendors;
  final int pendingVerificationVendors;
  final int activeRequests;
  final int activeOffers;
  final int activeConnections;

  const DashboardStats.zero()
      : totalCustomers = 0,
        totalVendors = 0,
        pendingVerificationVendors = 0,
        activeRequests = 0,
        activeOffers = 0,
        activeConnections = 0;

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    // Gracefully unwrap nested envelope `{ data: { ... } }` if present
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return DashboardStats(
      totalCustomers: parseInt(data['totalCustomers']),
      totalVendors: parseInt(data['totalVendors']),
      pendingVerificationVendors: parseInt(data['pendingVerificationVendors']),
      activeRequests: parseInt(data['activeRequests']),
      activeOffers: parseInt(data['activeOffers']),
      activeConnections: parseInt(data['activeConnections']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCustomers': totalCustomers,
      'totalVendors': totalVendors,
      'pendingVerificationVendors': pendingVerificationVendors,
      'activeRequests': activeRequests,
      'activeOffers': activeOffers,
      'activeConnections': activeConnections,
    };
  }

  DashboardStats copyWith({
    int? totalCustomers,
    int? totalVendors,
    int? pendingVerificationVendors,
    int? activeRequests,
    int? activeOffers,
    int? activeConnections,
  }) {
    return DashboardStats(
      totalCustomers: totalCustomers ?? this.totalCustomers,
      totalVendors: totalVendors ?? this.totalVendors,
      pendingVerificationVendors:
          pendingVerificationVendors ?? this.pendingVerificationVendors,
      activeRequests: activeRequests ?? this.activeRequests,
      activeOffers: activeOffers ?? this.activeOffers,
      activeConnections: activeConnections ?? this.activeConnections,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardStats &&
          runtimeType == other.runtimeType &&
          totalCustomers == other.totalCustomers &&
          totalVendors == other.totalVendors &&
          pendingVerificationVendors == other.pendingVerificationVendors &&
          activeRequests == other.activeRequests &&
          activeOffers == other.activeOffers &&
          activeConnections == other.activeConnections;

  @override
  int get hashCode => Object.hash(
        totalCustomers,
        totalVendors,
        pendingVerificationVendors,
        activeRequests,
        activeOffers,
        activeConnections,
      );

  @override
  String toString() =>
      'DashboardStats(customers: $totalCustomers, vendors: $totalVendors, pendingVerification: $pendingVerificationVendors, requests: $activeRequests, offers: $activeOffers, connections: $activeConnections)';
}
