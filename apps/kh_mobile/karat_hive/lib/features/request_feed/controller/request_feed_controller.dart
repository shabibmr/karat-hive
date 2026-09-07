import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/request_feed_repository.dart';

class RequestFiltersState {
  const RequestFiltersState({
    this.sort = 'NEWEST',
    this.requestType,
    this.categoryId,
    this.regionId,
    this.purityKarat,
    this.minBudget,
    this.maxBudget,
    this.includeResponded = false,
    this.activePresetId,
    this.activePresetName,
  });

  final String sort; // NEWEST | EXPIRING | HIGHEST_VALUE | FEWEST_OFFERS
  final String? requestType;
  final String? categoryId;
  final String? regionId;
  final String? purityKarat;
  final double? minBudget;
  final double? maxBudget;
  final bool includeResponded;
  final String? activePresetId;
  final String? activePresetName;

  bool get hasActiveFilters =>
      requestType != null ||
      categoryId != null ||
      regionId != null ||
      purityKarat != null ||
      minBudget != null ||
      maxBudget != null ||
      includeResponded != false ||
      sort != 'NEWEST' ||
      activePresetId != null;

  int get activeFilterCount {
    var count = 0;
    if (requestType != null) count++;
    if (categoryId != null) count++;
    if (regionId != null) count++;
    if (purityKarat != null) count++;
    if (minBudget != null || maxBudget != null) count++;
    if (includeResponded) count++;
    if (sort != 'NEWEST') count++;
    return count;
  }

  RequestFiltersState copyWith({
    String? sort,
    String? requestType,
    bool clearRequestType = false,
    String? categoryId,
    bool clearCategoryId = false,
    String? regionId,
    bool clearRegionId = false,
    String? purityKarat,
    bool clearPurityKarat = false,
    double? minBudget,
    bool clearMinBudget = false,
    double? maxBudget,
    bool clearMaxBudget = false,
    bool? includeResponded,
    String? activePresetId,
    bool clearActivePreset = false,
    String? activePresetName,
  }) {
    return RequestFiltersState(
      sort: sort ?? this.sort,
      requestType: clearRequestType ? null : (requestType ?? this.requestType),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      regionId: clearRegionId ? null : (regionId ?? this.regionId),
      purityKarat: clearPurityKarat ? null : (purityKarat ?? this.purityKarat),
      minBudget: clearMinBudget ? null : (minBudget ?? this.minBudget),
      maxBudget: clearMaxBudget ? null : (maxBudget ?? this.maxBudget),
      includeResponded: includeResponded ?? this.includeResponded,
      activePresetId: clearActivePreset ? null : (activePresetId ?? this.activePresetId),
      activePresetName: clearActivePreset ? null : (activePresetName ?? this.activePresetName),
    );
  }

  Map<String, dynamic> toFilterMap() {
    return {
      if (sort != 'NEWEST') 'sort': sort,
      if (requestType != null) 'requestType': requestType,
      if (categoryId != null) 'categoryId': categoryId,
      if (regionId != null) 'regionId': regionId,
      if (purityKarat != null) 'purityKarat': purityKarat,
      if (minBudget != null) 'minBudget': minBudget,
      if (maxBudget != null) 'maxBudget': maxBudget,
      if (includeResponded) 'includeResponded': true,
    };
  }
}

class RequestFiltersController extends AutoDisposeNotifier<RequestFiltersState> {
  @override
  RequestFiltersState build() => const RequestFiltersState();

  void update(RequestFiltersState next) => state = next;

  void reset() => state = const RequestFiltersState();
}

final requestFiltersProvider =
    AutoDisposeNotifierProvider<RequestFiltersController, RequestFiltersState>(
  RequestFiltersController.new,
);

/// Owns the feed [PagedListController] and rebuilds it when filters change.
class RequestFeedController
    extends AutoDisposeNotifier<PagedListController<VendorRequestItem>> {
  @override
  PagedListController<VendorRequestItem> build() {
    final repo = ref.watch(requestFeedRepositoryProvider);
    final filters = ref.watch(requestFiltersProvider);

    final controller = PagedListController<VendorRequestItem>(
      itemKey: (item) => item.id,
      fetcher: (cursor) async {
        final res = await repo.getMatches(
          cursor: cursor,
          sort: filters.sort,
          requestType: filters.requestType,
          categoryId: filters.categoryId,
          regionId: filters.regionId,
          purityKarat: filters.purityKarat,
          minBudget: filters.minBudget,
          maxBudget: filters.maxBudget,
          includeResponded: filters.includeResponded,
          presetId: filters.activePresetId,
        );
        return res.when(
          ok: (page) => page,
          err: (failure) => throw failure,
        );
      },
    );

    ref.onDispose(controller.dispose);
    return controller;
  }

  Future<void> loadNextPage() => state.loadNextPage();

  Future<void> refresh() => state.refresh();

  Future<void> retry() => state.retry();
}

final requestFeedControllerProvider = AutoDisposeNotifierProvider<
    RequestFeedController, PagedListController<VendorRequestItem>>(
  RequestFeedController.new,
);

/// Server-cache list of saved filter presets (CP2-B02: cache stays FutureProvider).
final filterPresetsListProvider =
    FutureProvider.autoDispose<List<FilterPresetItem>>((ref) async {
  final repo = ref.watch(requestFeedRepositoryProvider);
  final res = await repo.getFilterPresets();
  return res.when(
    ok: (items) => items,
    err: (f) => throw f,
  );
});
