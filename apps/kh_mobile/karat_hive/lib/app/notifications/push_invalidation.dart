import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/connections/controller/connection_detail_controller.dart'
    as vendor_conn_detail;
import '../../features/connections/controller/connections_controller.dart'
    as vendor_conn;
import '../../features/connections_customer/controller/connections_controller.dart'
    as customer_conn;
import '../../features/notifications/controller/notifications_controller.dart';
import '../../features/offers_customer/controller/offer_detail_controller.dart';
import '../../features/offers_customer/controller/offers_list_controller.dart';
import '../../features/offers_vendor/controller/my_offers_controller.dart';
import '../../features/onboarding/controller/vendor_me_controller.dart';
import '../../features/profile_settings/controller/business_profile_controller.dart';
import '../../features/request_feed/controller/request_detail_controller.dart';
import '../../features/request_feed/controller/request_feed_controller.dart';
import '../../features/request_manage/controller/customer_home_controller.dart';
import '../../features/request_manage/controller/owner_request_detail_controller.dart';
import '../../features/reviews/controller/my_reviews_controller.dart';

/// Domains a data-carrying push may touch (Architecture-Frontend §9.5 / §13.2).
enum PushInvalidationTarget {
  notifications,
  requestFeed,
  requestDetail,
  myOffers,
  customerHome,
  ownerRequestDetail,
  offersList,
  offerDetail,
  connectionsVendor,
  connectionDetailVendor,
  connectionsCustomer,
  connectionDetailCustomer,
  vendorMe,
  vendorDocuments,
  vendorProfile,
  myReviews,
}

/// Parsed invalidation plan from FCM `data` (`deepLink`, `type`).
class PushInvalidationPlan {
  const PushInvalidationPlan({
    required this.targets,
    this.requestId,
    this.offerId,
    this.connectionId,
  });

  final Set<PushInvalidationTarget> targets;
  final String? requestId;
  final String? offerId;
  final String? connectionId;

  static final RegExp _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  /// Always refreshes the in-app centre; scopes domain providers from
  /// Async-Contract §7.2 `deepLink` (and falls back to `type` prefixes).
  factory PushInvalidationPlan.fromData(Map<String, dynamic> data) {
    final targets = <PushInvalidationTarget>{
      PushInvalidationTarget.notifications,
    };

    String? requestId;
    String? offerId;
    String? connectionId;

    final deepLink = _string(data, 'deepLink') ?? _string(data, 'deep_link');
    if (deepLink != null) {
      final parsed = _parseDeepLink(deepLink);
      targets.addAll(parsed.targets);
      requestId = parsed.requestId;
      offerId = parsed.offerId;
      connectionId = parsed.connectionId;
    } else {
      final type = _string(data, 'type');
      if (type != null) {
        targets.addAll(_targetsForType(type));
      }
    }

    return PushInvalidationPlan(
      targets: targets,
      requestId: requestId,
      offerId: offerId,
      connectionId: connectionId,
    );
  }

  /// Applies this plan via [ref.invalidate]. Safe when providers are unwatched.
  void apply(Ref ref) {
    for (final target in targets) {
      switch (target) {
        case PushInvalidationTarget.notifications:
          ref.invalidate(notificationsControllerProvider);
        case PushInvalidationTarget.requestFeed:
          ref.invalidate(requestFeedControllerProvider);
        case PushInvalidationTarget.requestDetail:
          if (requestId != null) {
            ref.invalidate(requestDetailProvider(requestId!));
          } else {
            ref.invalidate(requestDetailProvider);
          }
        case PushInvalidationTarget.myOffers:
          ref.invalidate(myOffersControllerProvider);
        case PushInvalidationTarget.customerHome:
          ref.invalidate(customerHomeControllerProvider);
        case PushInvalidationTarget.ownerRequestDetail:
          if (requestId != null) {
            ref.invalidate(ownerRequestDetailProvider(requestId!));
          } else {
            ref.invalidate(ownerRequestDetailProvider);
          }
        case PushInvalidationTarget.offersList:
          if (requestId != null) {
            ref.invalidate(offersListControllerProvider(requestId!));
          } else {
            ref.invalidate(offersListControllerProvider);
          }
        case PushInvalidationTarget.offerDetail:
          if (offerId != null) {
            ref.invalidate(offerDetailProvider(offerId!));
          } else {
            ref.invalidate(offerDetailProvider);
          }
        case PushInvalidationTarget.connectionsVendor:
          ref.invalidate(vendor_conn.connectionsControllerProvider);
        case PushInvalidationTarget.connectionDetailVendor:
          if (connectionId != null) {
            ref.invalidate(
              vendor_conn_detail.connectionDetailProvider(connectionId!),
            );
          } else {
            ref.invalidate(vendor_conn_detail.connectionDetailProvider);
          }
        case PushInvalidationTarget.connectionsCustomer:
          ref.invalidate(customer_conn.connectionsListProvider);
        case PushInvalidationTarget.connectionDetailCustomer:
          if (connectionId != null) {
            ref.invalidate(
              customer_conn.connectionDetailProvider(connectionId!),
            );
          } else {
            ref.invalidate(customer_conn.connectionDetailProvider);
          }
        case PushInvalidationTarget.vendorMe:
          ref.invalidate(vendorMeProvider);
        case PushInvalidationTarget.vendorDocuments:
          ref.invalidate(vendorDocumentsProvider);
        case PushInvalidationTarget.vendorProfile:
          ref.invalidate(vendorProfileProvider);
        case PushInvalidationTarget.myReviews:
          ref.invalidate(myReviewsControllerProvider);
      }
    }
  }

  static String? _string(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static bool _isId(String value) => _uuid.hasMatch(value);

  static PushInvalidationPlan _parseDeepLink(String raw) {
    final targets = <PushInvalidationTarget>{};
    String? requestId;
    String? offerId;
    String? connectionId;

    final uri = Uri.tryParse(raw.trim());
    if (uri == null || uri.hasScheme || uri.hasAuthority) {
      return PushInvalidationPlan(targets: targets);
    }

    var path = uri.path;
    if (path.isEmpty) return PushInvalidationPlan(targets: targets);
    if (!path.startsWith('/')) path = '/$path';
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    final segments = path.split('/')..removeWhere((s) => s.isEmpty);
    if (segments.isEmpty) return PushInvalidationPlan(targets: targets);

    if (segments.length >= 2 &&
        segments[0] == 'me' &&
        segments[1] == 'vendor') {
      targets.addAll({
        PushInvalidationTarget.vendorMe,
        PushInvalidationTarget.vendorProfile,
      });
      if (segments.length >= 3 && segments[2] == 'documents') {
        targets.add(PushInvalidationTarget.vendorDocuments);
      }
      return PushInvalidationPlan(targets: targets);
    }

    if (segments[0] == 'requests') {
      targets.addAll({
        PushInvalidationTarget.requestFeed,
        PushInvalidationTarget.myOffers,
        PushInvalidationTarget.customerHome,
      });
      if (segments.length >= 2 && _isId(segments[1])) {
        requestId = segments[1];
        targets.addAll({
          PushInvalidationTarget.requestDetail,
          PushInvalidationTarget.ownerRequestDetail,
        });
        if (segments.length >= 3 && segments[2] == 'offers') {
          targets.add(PushInvalidationTarget.offersList);
        }
      }
      return PushInvalidationPlan(targets: targets, requestId: requestId);
    }

    if (segments[0] == 'offers') {
      targets.addAll({
        PushInvalidationTarget.myOffers,
        PushInvalidationTarget.customerHome,
      });
      if (segments.length >= 2 && _isId(segments[1])) {
        offerId = segments[1];
        targets.add(PushInvalidationTarget.offerDetail);
      }
      return PushInvalidationPlan(targets: targets, offerId: offerId);
    }

    if (segments[0] == 'connections') {
      targets.addAll({
        PushInvalidationTarget.connectionsVendor,
        PushInvalidationTarget.connectionsCustomer,
      });
      if (segments.length >= 2 && _isId(segments[1])) {
        connectionId = segments[1];
        targets.addAll({
          PushInvalidationTarget.connectionDetailVendor,
          PushInvalidationTarget.connectionDetailCustomer,
        });
        if (segments.length >= 3 && segments[2] == 'review') {
          targets.add(PushInvalidationTarget.myReviews);
        }
      }
      return PushInvalidationPlan(
        targets: targets,
        connectionId: connectionId,
      );
    }

    return PushInvalidationPlan(targets: targets);
  }

  static Set<PushInvalidationTarget> _targetsForType(String type) {
    final t = type.toLowerCase();
    if (t.startsWith('request.')) {
      return {
        PushInvalidationTarget.requestFeed,
        PushInvalidationTarget.myOffers,
        PushInvalidationTarget.customerHome,
      };
    }
    if (t.startsWith('offer.')) {
      return {
        PushInvalidationTarget.myOffers,
        PushInvalidationTarget.customerHome,
        PushInvalidationTarget.offersList,
        if (t == 'offer.accepted') ...{
          PushInvalidationTarget.connectionsVendor,
          PushInvalidationTarget.connectionsCustomer,
        },
      };
    }
    if (t.startsWith('connection.') || t.startsWith('review.')) {
      return {
        PushInvalidationTarget.connectionsVendor,
        PushInvalidationTarget.connectionsCustomer,
        PushInvalidationTarget.myReviews,
      };
    }
    if (t.startsWith('vendor.')) {
      return {
        PushInvalidationTarget.vendorMe,
        PushInvalidationTarget.vendorProfile,
        PushInvalidationTarget.vendorDocuments,
      };
    }
    return {};
  }
}
