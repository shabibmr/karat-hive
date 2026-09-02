import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/onboarding_repository.dart';

/// VEN-S03 status source. Re-read on foreground / pull-to-refresh; the router
/// reacts to lifecycle transitions via the session provider.
final vendorMeProvider = FutureProvider.autoDispose<VendorMe>((ref) async {
  final r = await ref.watch(onboardingRepositoryProvider).vendorMe();
  return r.when(ok: (v) => v, err: (f) => throw f);
});

final vendorDocumentsProvider =
    FutureProvider.autoDispose<List<VendorDocument>>((ref) async {
  final r = await ref.watch(onboardingRepositoryProvider).documents();
  return r.when(ok: (v) => v, err: (f) => throw f);
});
