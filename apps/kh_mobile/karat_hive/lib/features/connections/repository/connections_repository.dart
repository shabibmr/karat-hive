import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/di.dart';

class ConnectionsRepository {
  const ConnectionsRepository(this._api);
  final KhApi _api;

  // --- Vendor methods (CP-4) ---

  Future<Result<PagedResult<ConnectionForVendor>>> listMine({
    String? state,
    String? cursor,
  }) =>
      _api.connections.listMine(state: state, cursor: cursor);

  Future<Result<ConnectionForVendor>> get(String connectionId) =>
      _api.connections.get(connectionId);

  Future<Result<ConnectionForVendor>> close(String connectionId) =>
      _api.connections.closeForVendor(connectionId);

  // --- Customer methods (CM-Track C) ---

  Future<Result<PagedResult<ConnectionForCustomer>>> listMineForCustomer({
    String? state,
    String? cursor,
  }) =>
      _api.connections.listMineForCustomer(state: state, cursor: cursor);

  Future<Result<ConnectionForCustomer>> getById(String id) =>
      _api.connections.getById(id);

  Future<Result<ConnectionForCustomer>> closeCustomer(
    String id, {
    String? reason,
  }) =>
      _api.connections.close(id, reason: reason);

  // --- Shared methods ---

  Future<Result<void>> recordContactEvent({
    required String connectionId,
    required String channel,
  }) =>
      _api.connections.recordContactEvent(
        connectionId: connectionId,
        channel: channel,
      );
}

final connectionsRepositoryProvider = Provider<ConnectionsRepository>(
  (ref) => ConnectionsRepository(ref.watch(khApiProvider)),
);
