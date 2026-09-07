import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/di.dart';

class ConnectionsRepository {
  const ConnectionsRepository(this._api);
  final KhApi _api;

  Future<Result<PagedResult<ConnectionForCustomer>>> listMine({
    String? state,
    String? cursor,
  }) =>
      _api.connections.listMine(state: state, cursor: cursor);

  Future<Result<ConnectionForCustomer>> getById(String id) =>
      _api.connections.getById(id);

  Future<Result<ConnectionForCustomer>> close(String id, {String? reason}) =>
      _api.connections.close(id, reason: reason);

  Future<Result<void>> recordContactEvent(
    String id, {
    required String channel,
  }) =>
      _api.connections.recordContactEvent(id, channel: channel);
}

final connectionsRepositoryProvider = Provider<ConnectionsRepository>(
  (ref) => ConnectionsRepository(ref.watch(khApiProvider)),
);
