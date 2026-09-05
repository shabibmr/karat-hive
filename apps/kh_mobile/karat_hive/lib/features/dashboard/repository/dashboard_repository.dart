import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../onboarding/repository/onboarding_repository.dart';

final vendorDashboardProvider =
    FutureProvider.autoDispose<VendorDashboard>((ref) async {
  final r = await ref.watch(onboardingRepositoryProvider).dashboard();
  return r.when(ok: (v) => v, err: (f) => throw f);
});
