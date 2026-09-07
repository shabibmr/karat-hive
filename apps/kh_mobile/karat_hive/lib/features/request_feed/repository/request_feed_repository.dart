import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/di.dart';

final requestFeedRepositoryProvider = Provider<RequestFeedRepository>((ref) {
  return RequestFeedRepository(ref.watch(khApiProvider));
});

class RequestFeedRepository {
  const RequestFeedRepository(this._api);
  final KhApi _api;

  Future<Result<PagedResult<VendorRequestItem>>> getMatches({
    String? cursor,
    int limit = 20,
    String? sort,
    String? requestType,
    String? categoryId,
    String? regionId,
    double? minBudget,
    double? maxBudget,
    String? purityKarat,
    bool? includeResponded,
    String? presetId,
  }) =>
      _api.matches.getMatches(
        cursor: cursor,
        limit: limit,
        sort: sort,
        requestType: requestType,
        categoryId: categoryId,
        regionId: regionId,
        minBudget: minBudget,
        maxBudget: maxBudget,
        purityKarat: purityKarat,
        includeResponded: includeResponded,
        presetId: presetId,
      );

  Future<Result<VendorRequestItem>> getRequest(String id) =>
      _api.requests.getRequest(id);

  Future<Result<void>> markViewed(String requestId) =>
      _api.matches.markViewed(requestId);

  Future<Result<List<FilterPresetItem>>> getFilterPresets() =>
      _api.filterPresets.list();

  Future<Result<FilterPresetItem>> createFilterPreset({
    required String name,
    required Map<String, dynamic> filters,
  }) =>
      _api.filterPresets.create(name: name, filters: filters);

  Future<Result<FilterPresetItem>> updateFilterPreset(
    String id, {
    String? name,
    Map<String, dynamic>? filters,
  }) =>
      _api.filterPresets.update(id, name: name, filters: filters);

  Future<Result<void>> deleteFilterPreset(String id) =>
      _api.filterPresets.delete(id);

  Future<Result<VendorDashboard>> getDashboard() =>
      _api.dashboardClient.getDashboard();
}
