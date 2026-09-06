import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

class RequestsClient {
  const RequestsClient(this._client);
  final KhApiClient _client;

  Future<Result<VendorRequestItem>> getRequest(String id) async {
    final r = await _client.send('GET', '/v1/requests/$id');
    return r.when(
      ok: (d) => Ok(VendorRequestItem.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }
}
