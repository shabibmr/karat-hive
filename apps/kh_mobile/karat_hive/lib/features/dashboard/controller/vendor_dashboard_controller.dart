import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/dashboard_repository.dart';

/// VEN-S05. Thin passthrough for now — the real counts arrive with the
/// marketplace modules; this keeps the screen honest about loading/error/data.
final vendorDashboardControllerProvider =
    Provider.autoDispose<AsyncValue<VendorDashboard>>((ref) {
  return ref.watch(vendorDashboardProvider);
});
