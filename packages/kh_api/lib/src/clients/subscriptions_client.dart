import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

class SubscriptionsClient {
  const SubscriptionsClient(this._client);
  final KhApiClient _client;

  Future<Result<List<VendorSubscriptionItem>>> getSubscriptions() async {
    final r = await _client.send('GET', '/v1/me/subscriptions');
    return r.when(
      ok: (d) {
        final list = (d as List?) ??
            (d is Map ? (d['data'] as List?) : null) ??
            const [];
        return Ok(list
            .map((e) => VendorSubscriptionItem.fromJson(e as Map<String, dynamic>))
            .toList(growable: false));
      },
      err: Err.new,
    );
  }
}
