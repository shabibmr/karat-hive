import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../paged.dart';

class ConnectionsClient {
  const ConnectionsClient(this._client);
  final KhApiClient _client;

  Future<Result<PagedResult<ConnectionForCustomer>>> listMine({
    String? state,
    String? cursor,
    int limit = 20,
  }) async {
    final r = await _client.send(
      'GET',
      '/v1/me/connections',
      query: {
        if (state != null) 'state': state,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': limit.toString(),
      },
      unwrapData: false,
    );
    return r.when(
      ok: (raw) => Ok(parsePagedEnvelope(raw, ConnectionForCustomer.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<ConnectionForCustomer>> getById(String id) async {
    final r = await _client.send('GET', '/v1/connections/$id');
    return r.when(
      ok: (d) => Ok(ConnectionForCustomer.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<ConnectionForCustomer>> close(String id, {String? reason}) async {
    final r = await _client.send(
      'POST',
      '/v1/connections/$id/close',
      body: {if (reason != null) 'reason': reason},
    );
    return r.when(
      ok: (d) => Ok(ConnectionForCustomer.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<void>> recordContactEvent(
    String id, {
    required String channel,
  }) async {
    final r = await _client.send(
      'POST',
      '/v1/connections/$id/contact-events',
      body: {'channel': channel},
    );
    return r.when(ok: (_) => const Ok(null), err: Err.new);
  }
}
