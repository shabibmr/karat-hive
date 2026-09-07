// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_dashboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VendorDashboard _$VendorDashboardFromJson(Map<String, dynamic> json) =>
    _VendorDashboard(
      newRequests: (json['newRequests'] as num).toInt(),
      newRequestPreview:
          (json['newRequestPreview'] as List<dynamic>?)
              ?.map(
                (e) => VendorRequestItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <VendorRequestItem>[],
      pendingOffers: (json['pendingOffers'] as num).toInt(),
      pendingOffersExpiringWithin24h:
          (json['pendingOffersExpiringWithin24h'] as num?)?.toInt() ?? 0,
      activeConnections: (json['activeConnections'] as num).toInt(),
      activeConnectionsNoTalkCount:
          (json['activeConnectionsNoTalkCount'] as num?)?.toInt() ?? 0,
      ratingAverage: (json['ratingAverage'] as num?)?.toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      goldRates: json['goldRates'],
      subscriptions:
          (json['subscriptions'] as List<dynamic>?)
              ?.map(
                (e) =>
                    VendorSubscriptionItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <VendorSubscriptionItem>[],
    );

Map<String, dynamic> _$VendorDashboardToJson(_VendorDashboard instance) =>
    <String, dynamic>{
      'newRequests': instance.newRequests,
      'newRequestPreview': instance.newRequestPreview,
      'pendingOffers': instance.pendingOffers,
      'pendingOffersExpiringWithin24h': instance.pendingOffersExpiringWithin24h,
      'activeConnections': instance.activeConnections,
      'activeConnectionsNoTalkCount': instance.activeConnectionsNoTalkCount,
      'ratingAverage': instance.ratingAverage,
      'reviewCount': instance.reviewCount,
      'goldRates': instance.goldRates,
      'subscriptions': instance.subscriptions,
    };
