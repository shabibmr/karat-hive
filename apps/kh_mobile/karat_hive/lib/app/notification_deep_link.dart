import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Maps Async-Contract §7.2 `notification.deep_link` values onto go_router
/// locations so navigation runs through [AppGuards.redirect] (§7.5 / §13.3).
///
/// Contract paths are role-agnostic (`/requests/{id}`, …). The mobile route
/// table is role-prefixed (`/vendor/…`, `/customer/…`); this resolver is the
/// only place that bridge is allowed.
abstract final class NotificationDeepLink {
  static final RegExp _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  /// Returns a go_router location, or `null` when the payload is empty,
  /// malformed, unknown, or not valid for [isVendor].
  static String? resolve(String deepLink, {required bool isVendor}) {
    final raw = deepLink.trim();
    if (raw.isEmpty) return null;

    final uri = Uri.tryParse(raw);
    if (uri == null) return null;
    // Deep links are path-only client routes — reject absolute URLs.
    if (uri.hasScheme || uri.hasAuthority) return null;

    var path = uri.path;
    if (path.isEmpty) return null;
    if (!path.startsWith('/')) path = '/$path';
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    final segments = path.split('/')..removeWhere((s) => s.isEmpty);
    if (segments.isEmpty) return null;

    if (isVendor) {
      return _resolveVendor(segments);
    }
    return _resolveCustomer(segments);
  }

  /// Resolves and navigates via [GoRouter.go] so the guard chain runs.
  /// No-ops when [resolve] returns null. Does **not** mark-read (CP5-B01.4).
  static void open(
    BuildContext context,
    String deepLink, {
    required bool isVendor,
  }) {
    final location = resolve(deepLink, isVendor: isVendor);
    if (location == null) return;
    GoRouter.of(context).go(location);
  }

  static String? _resolveVendor(List<String> segments) {
    // /me/vendor · /me/vendor/documents
    if (segments.length >= 2 && segments[0] == 'me' && segments[1] == 'vendor') {
      if (segments.length == 2) return '/vendor/profile';
      if (segments.length == 3 && segments[2] == 'documents') {
        return '/vendor/profile/documents';
      }
      return null;
    }

    // /requests/{id}
    if (segments.length == 2 && segments[0] == 'requests') {
      final id = segments[1];
      if (!_isId(id)) return null;
      return '/vendor/requests/$id';
    }

    // /offers/{id}
    if (segments.length == 2 && segments[0] == 'offers') {
      final id = segments[1];
      if (!_isId(id)) return null;
      return '/vendor/offers/$id';
    }

    // /connections/{id}
    if (segments.length == 2 && segments[0] == 'connections') {
      final id = segments[1];
      if (!_isId(id)) return null;
      return '/vendor/connections/$id';
    }

    return null;
  }

  static String? _resolveCustomer(List<String> segments) {
    // Vendor-only targets — never open in Customer mode.
    if (segments.length >= 2 && segments[0] == 'me' && segments[1] == 'vendor') {
      return null;
    }

    // /requests/{id} · /requests/{id}/offers
    if (segments.isNotEmpty && segments[0] == 'requests') {
      if (segments.length == 2) {
        final id = segments[1];
        if (!_isId(id)) return null;
        return '/customer/requests/$id';
      }
      if (segments.length == 3 && segments[2] == 'offers') {
        final id = segments[1];
        if (!_isId(id)) return null;
        return '/customer/requests/$id/offers';
      }
      return null;
    }

    // /offers/{id}
    if (segments.length == 2 && segments[0] == 'offers') {
      final id = segments[1];
      if (!_isId(id)) return null;
      return '/customer/offers/$id';
    }

    // /connections/{id}
    if (segments.length == 2 && segments[0] == 'connections') {
      final id = segments[1];
      if (!_isId(id)) return null;
      return '/customer/connections/$id';
    }

    return null;
  }

  static bool _isId(String value) => _uuid.hasMatch(value);
}
