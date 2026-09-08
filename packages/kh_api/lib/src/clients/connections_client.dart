import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../paged.dart';

class ConnectionsClient {
  const ConnectionsClient(this._client);
  final KhApiClient _client;

  // --- Vendor methods (CP-4) ---

  Future<Result<PagedResult<ConnectionForVendor>>> listMine({
    String? state,
    String? cursor,
    int limit = 20,
  }) =>
      listMineForVendor(state: state, cursor: cursor, limit: limit);

  Future<Result<PagedResult<ConnectionForVendor>>> listMineForVendor({
    String? state,
    String? cursor,
    int limit = 20,
  }) async {
    final r = await _client.send(
      'GET',
      '/v1/me/connections',
      query: {
        'limit': limit.toString(),
        if (state != null) 'state': state,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      },
      unwrapData: false,
    );

    return r.when(
      ok: (raw) => Ok(parsePagedEnvelope(raw, ConnectionForVendor.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<ConnectionForVendor>> get(String connectionId) async {
    final r = await _client.send('GET', '/v1/connections/$connectionId');
    return r.when(
      ok: (d) => Ok(ConnectionForVendor.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<ConnectionForVendor>> closeForVendor(
    String connectionId, {
    String? reason,
  }) async {
    final r = await _client.send(
      'POST',
      '/v1/connections/$connectionId/close',
      body: {
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );
    return r.when(
      ok: (d) => Ok(ConnectionForVendor.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  // --- Customer methods (CM-Track C) ---

  Future<Result<PagedResult<ConnectionForCustomer>>> listMineForCustomer({
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

  Future<Result<ConnectionForCustomer>> close(
    String id, {
    String? reason,
  }) async {
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

  // --- Shared methods ---

  Future<Result<void>> recordContactEvent({
    String? connectionId,
    String? id,
    required String channel,
  }) async {
    final targetId = connectionId ?? id;
    if (targetId == null) {
      return const Err(ValidationFailure(message: 'Missing connectionId for recordContactEvent'));
    }
    final r = await _client.send(
      'POST',
      '/v1/connections/$targetId/contact-events',
      body: {'channel': channel},
    );
    return r.when(ok: (_) => const Ok(null), err: Err.new);
  }
}
