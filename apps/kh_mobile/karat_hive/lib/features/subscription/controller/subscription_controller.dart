import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/subscription_repository.dart';

class SubscriptionsListController
    extends AutoDisposeAsyncNotifier<List<VendorSubscriptionItem>> {
  @override
  Future<List<VendorSubscriptionItem>> build() async {
    final repo = ref.watch(subscriptionRepositoryProvider);
    final r = await repo.getSubscriptions();
    return r.when(ok: (list) => list, err: (f) => throw f);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(subscriptionRepositoryProvider);
      final r = await repo.getSubscriptions();
      return r.when(ok: (list) => list, err: (f) => throw f);
    });
  }
}

final subscriptionsListProvider = AsyncNotifierProvider.autoDispose<
    SubscriptionsListController, List<VendorSubscriptionItem>>(
  SubscriptionsListController.new,
);

class PlatformConfigController
    extends AutoDisposeAsyncNotifier<PlatformConfig> {
  @override
  Future<PlatformConfig> build() async {
    final repo = ref.watch(subscriptionRepositoryProvider);
    final r = await repo.getPlatformConfig();
    return r.when(ok: (cfg) => cfg, err: (f) => throw f);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(subscriptionRepositoryProvider);
      final r = await repo.getPlatformConfig();
      return r.when(ok: (cfg) => cfg, err: (f) => throw f);
    });
  }
}

final platformConfigProvider =
    AsyncNotifierProvider.autoDispose<PlatformConfigController, PlatformConfig>(
  PlatformConfigController.new,
);
