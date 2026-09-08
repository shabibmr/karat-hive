import 'package:go_router/go_router.dart';

import 'presentation/stubs.dart';

final abuseRoutes = [
  GoRoute(
    path: '/customer/abuse',
    builder: (_, __) => const ReportAbuseScreen(),
  ),
];
