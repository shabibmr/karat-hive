import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/di.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(ref.watch(khApiProvider));
});

class SubscriptionRepository {
  const SubscriptionRepository(this._api);
  final KhApi _api;

  Future<Result<List<VendorSubscriptionItem>>> getSubscriptions() =>
      _api.subscriptions.getSubscriptions();

  Future<Result<PlatformConfig>> getPlatformConfig() =>
      _api.platformConfig.getConfig();
}
