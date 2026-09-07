import 'package:freezed_annotation/freezed_annotation.dart';

import 'vendor_request_item.dart';
import 'vendor_subscription_item.dart';

part 'vendor_dashboard.freezed.dart';
part 'vendor_dashboard.g.dart';

Map<String, dynamic> _normalizeVendorDashboardJson(Map<String, dynamic> json) {
  Map<String, dynamic> section(String k) =>
      (json[k] as Map<String, dynamic>?) ?? const {};

  int countOf(String k) => section(k)['count'] as int? ?? 0;

  final newRequestsSection = section('newRequests');
  final pendingOffersSection = section('pendingOffers');
  final activeConnectionsSection = section('activeConnections');
  final rating = section('rating');

  final previewRaw = (newRequestsSection['preview'] as List?) ?? const [];
  final subsRaw = (json['subscriptions'] as List?) ?? const [];

  final ratingAverage = rating['average'];
  return {
    'newRequests': countOf('newRequests'),
    'newRequestPreview': previewRaw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false),
    'pendingOffers': countOf('pendingOffers'),
    'pendingOffersExpiringWithin24h':
        pendingOffersSection['expiringWithin24h'] as int? ?? 0,
    'activeConnections': countOf('activeConnections'),
    'activeConnectionsNoTalkCount':
        activeConnectionsSection['noTalkCount'] as int? ?? 0,
    'ratingAverage': ratingAverage is num
        ? ratingAverage.toDouble()
        : double.tryParse(ratingAverage?.toString() ?? ''),
    'reviewCount': rating['reviewCount'] as int? ?? 0,
    'goldRates': json['goldRates'],
    'subscriptions': subsRaw.map((e) {
      if (e is Map) {
        return Map<String, dynamic>.from(e);
      }
      // Legacy/test fixtures may pass bare request-type strings.
      return <String, dynamic>{
        'requestType': e.toString(),
        'state': 'ACTIVE',
        'priceAed': '0.00',
        'canOffer': true,
      };
    }).toList(growable: false),
  };
}

/// Vendor home dashboard aggregates (CP2-F06 freezed pattern).
@freezed
abstract class VendorDashboard with _$VendorDashboard {
  const factory VendorDashboard({
    required int newRequests,
    @Default(<VendorRequestItem>[]) List<VendorRequestItem> newRequestPreview,
    required int pendingOffers,
    @Default(0) int pendingOffersExpiringWithin24h,
    required int activeConnections,
    @Default(0) int activeConnectionsNoTalkCount,
    double? ratingAverage,
    required int reviewCount,
    Object? goldRates,
    @Default(<VendorSubscriptionItem>[])
    List<VendorSubscriptionItem> subscriptions,
  }) = _VendorDashboard;

  factory VendorDashboard.fromJson(Map<String, dynamic> json) =>
      _$VendorDashboardFromJson(_normalizeVendorDashboardJson(json));
}
