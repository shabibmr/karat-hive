import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/di.dart';

final connectionsRepositoryProvider = Provider<ConnectionsRepository>((ref) {
  return ConnectionsRepository(ref.watch(khApiProvider));
});

class ConnectionsRepository {
  const ConnectionsRepository(this._api);
  final KhApi _api;

  Future<Result<PagedResult<ConnectionForVendor>>> listMine({
    String? state,
    String? cursor,
  }) =>
      _api.connections.listMine(state: state, cursor: cursor);

  Future<Result<ConnectionForVendor>> get(String connectionId) =>
      _api.connections.get(connectionId);

  Future<Result<ConnectionForVendor>> close(String connectionId) =>
      _api.connections.close(connectionId);

  Future<Result<void>> recordContactEvent({
    required String connectionId,
    required String channel,
  }) =>
      _api.connections.recordContactEvent(
        connectionId: connectionId,
        channel: channel,
      );
}
