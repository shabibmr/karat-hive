import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/di.dart';

final requestManageRepositoryProvider = Provider<RequestManageRepository>((ref) {
  return RequestManageRepository(ref.watch(khApiProvider));
});

class RequestManageRepository {
  const RequestManageRepository(this._api);
  final KhApi _api;

  Future<Result<PagedResult<RequestForCustomer>>> listMine({
    String? cursor,
    int limit = 20,
    List<String>? state,
    String? requestType,
    String? direction,
    String? q,
    String? from,
    String? to,
  }) =>
      _api.requests.listMine(
        cursor: cursor,
        limit: limit,
        state: state,
        requestType: requestType,
        direction: direction,
        q: q,
        from: from,
        to: to,
      );

  Future<Result<RequestForCustomer>> getMine(String id) =>
      _api.requests.getMine(id);

  Future<Result<RequestForCustomer>> patchMine(
    String id, {
    String? notes,
    String? budgetMin,
    String? budgetMax,
    bool? budgetIsFlexible,
    List<String>? mediaKeys,
  }) =>
      _api.requests.patchMine(
        id,
        notes: notes,
        budgetMin: budgetMin,
        budgetMax: budgetMax,
        budgetIsFlexible: budgetIsFlexible,
        mediaKeys: mediaKeys,
      );

  Future<Result<RequestForCustomer>> cancel(String id, {String? reason}) =>
      _api.requests.cancel(id, reason: reason);
}
