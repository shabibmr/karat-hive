import 'package:go_router/go_router.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import 'presentation/report_abuse_screen.dart';

/// Customer report abuse (CUS-S22) — path `/customer/abuse`.
final abuseRoutes = [
  GoRoute(
    path: '/customer/abuse',
    builder: (context, state) => ReportAbuseScreen(
      entityType: state.uri.queryParameters['entityType'],
      entityId: state.uri.queryParameters['entityId'],
      entityReference: state.uri.queryParameters['reference'] ??
          state.uri.queryParameters['entityReference'],
      reporterRole: UserRole.customer,
      categories: kCustomerAbuseCategories,
    ),
  ),
];

/// Vendor report abuse (VEN-S21) — path `/vendor/abuse` and `/abuse/new`.
/// Prefill from S08/S13 is wired in CP5-B05.3.
final vendorAbuseRoutes = [
  GoRoute(
    path: '/vendor/abuse',
    builder: (context, state) => VendorReportAbuseScreen(
      entityType: state.uri.queryParameters['entityType'] ??
          state.uri.queryParameters['targetType'],
      entityId: state.uri.queryParameters['entityId'] ??
          state.uri.queryParameters['targetId'],
      entityReference: state.uri.queryParameters['reference'] ??
          state.uri.queryParameters['entityReference'],
    ),
  ),
  GoRoute(
    path: '/abuse/new',
    builder: (context, state) => VendorReportAbuseScreen(
      entityType: state.uri.queryParameters['targetType'] ??
          state.uri.queryParameters['entityType'],
      entityId: state.uri.queryParameters['targetId'] ??
          state.uri.queryParameters['entityId'],
      entityReference: state.uri.queryParameters['reference'] ??
          state.uri.queryParameters['entityReference'],
    ),
  ),
];
