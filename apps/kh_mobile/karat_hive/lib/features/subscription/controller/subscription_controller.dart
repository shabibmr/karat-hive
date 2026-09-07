import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/subscription_repository.dart';

final subscriptionsListProvider =
    FutureProvider.autoDispose<List<VendorSubscriptionItem>>((ref) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  final r = await repo.getSubscriptions();
  return r.when(ok: (list) => list, err: (f) => throw f);
});

final platformConfigProvider =
    FutureProvider.autoDispose<PlatformConfig>((ref) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  final r = await repo.getPlatformConfig();
  return r.when(ok: (cfg) => cfg, err: (f) => throw f);
});
