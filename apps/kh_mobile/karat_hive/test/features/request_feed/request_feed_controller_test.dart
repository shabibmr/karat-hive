import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/request_feed/controller/request_feed_controller.dart';
import 'package:karat_hive/features/request_feed/repository/request_feed_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

class _SeededRequestFiltersController extends RequestFiltersController {
  _SeededRequestFiltersController(this._seed);

  final RequestFiltersState _seed;

  @override
  RequestFiltersState build() => _seed;
}

class _RecordingFeedRepository implements RequestFeedRepository {
  String? lastSort;
  String? lastRequestType;
  bool? lastIncludeResponded;
  String? lastPresetId;
  double? lastMinBudget;
  double? lastMaxBudget;

  @override
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
  }) async {
    lastSort = sort;
    lastRequestType = requestType;
    lastIncludeResponded = includeResponded;
    lastPresetId = presetId;
    lastMinBudget = minBudget;
    lastMaxBudget = maxBudget;
    return const Ok(PagedResult(items: []));
  }

  @override
  Future<Result<VendorRequestItem>> getRequest(String id) async =>
      Err(const ServerFailure(message: 'unused'));

  @override
  Future<Result<void>> markViewed(String requestId) async => const Ok(null);

  @override
  Future<Result<List<FilterPresetItem>>> getFilterPresets() async => const Ok([]);

  @override
  Future<Result<FilterPresetItem>> createFilterPreset({
    required String name,
    required Map<String, dynamic> filters,
  }) async =>
      Err(const ServerFailure(message: 'unused'));

  @override
  Future<Result<FilterPresetItem>> updateFilterPreset(
    String id, {
    String? name,
    Map<String, dynamic>? filters,
  }) async =>
      Err(const ServerFailure(message: 'unused'));

  @override
  Future<Result<void>> deleteFilterPreset(String id) async => const Ok(null);

  @override
  Future<Result<VendorDashboard>> getDashboard() async =>
      Err(const ServerFailure(message: 'unused'));
}

void main() {
  group('RequestFiltersState', () {
    test('default state has no active filters except NEWEST sort', () {
      const state = RequestFiltersState();
      expect(state.sort, 'NEWEST');
      expect(state.hasActiveFilters, isFalse);
      expect(state.activeFilterCount, 0);
      expect(state.toFilterMap(), isEmpty);
    });

    test('setting filters updates count and serialization correctly', () {
      var state = const RequestFiltersState();
      state = state.copyWith(
        requestType: 'FIND_ORNAMENT',
        categoryId: 'cat-ring',
        purityKarat: '22',
        sort: 'HIGHEST_VALUE',
        includeResponded: true,
      );

      expect(state.hasActiveFilters, isTrue);
      expect(state.activeFilterCount, 5);

      final map = state.toFilterMap();
      expect(map['sort'], 'HIGHEST_VALUE');
      expect(map['requestType'], 'FIND_ORNAMENT');
      expect(map['categoryId'], 'cat-ring');
      expect(map['purityKarat'], '22');
      expect(map['includeResponded'], isTrue);
    });

    test('clearing specific filters works as expected', () {
      var state = const RequestFiltersState(
        requestType: 'BULLION',
        categoryId: 'cat-bars',
      );

      expect(state.activeFilterCount, 2);

      state = state.copyWith(clearRequestType: true);
      expect(state.requestType, isNull);
      expect(state.categoryId, 'cat-bars');
      expect(state.activeFilterCount, 1);
    });

    test('includeResponded alone is an active filter and serializes', () {
      const state = RequestFiltersState(includeResponded: true);
      expect(state.hasActiveFilters, isTrue);
      expect(state.activeFilterCount, 1);
      expect(state.toFilterMap(), {'includeResponded': true});
    });

    test('budget range counts once and clears independently', () {
      var state = const RequestFiltersState(minBudget: 1000, maxBudget: 4000);
      expect(state.activeFilterCount, 1);
      expect(state.toFilterMap()['minBudget'], 1000);
      expect(state.toFilterMap()['maxBudget'], 4000);

      state = state.copyWith(clearMinBudget: true);
      expect(state.minBudget, isNull);
      expect(state.maxBudget, 4000);
      expect(state.activeFilterCount, 1);
    });

    test('clearActivePreset clears preset id and name', () {
      var state = const RequestFiltersState(
        activePresetId: 'pre-1',
        activePresetName: 'Dubai 22K',
        requestType: 'FIND_ORNAMENT',
      );
      expect(state.hasActiveFilters, isTrue);

      state = state.copyWith(clearActivePreset: true);
      expect(state.activePresetId, isNull);
      expect(state.activePresetName, isNull);
      expect(state.requestType, 'FIND_ORNAMENT');
    });
  });

  group('requestFeedControllerProvider', () {
    test('forwards active filters including includeResponded to repository', () async {
      final repo = _RecordingFeedRepository();
      final container = ProviderContainer(
        overrides: [
          requestFeedRepositoryProvider.overrideWithValue(repo),
          requestFiltersProvider.overrideWith(
            () => _SeededRequestFiltersController(
              const RequestFiltersState(
                sort: 'EXPIRING',
                requestType: 'BULLION',
                includeResponded: true,
                minBudget: 2000,
                maxBudget: 9000,
                activePresetId: 'pre-9',
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Keep autoDispose providers alive for the async first-page fetch.
      final sub = container.listen(requestFeedControllerProvider, (_, __) {});
      addTearDown(sub.close);

      final controller = container.read(requestFeedControllerProvider);
      for (var i = 0; i < 50 && controller.value.isLoading; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      expect(controller.value.isEmpty, isTrue);
      expect(repo.lastSort, 'EXPIRING');
      expect(repo.lastRequestType, 'BULLION');
      expect(repo.lastIncludeResponded, isTrue);
      expect(repo.lastMinBudget, 2000);
      expect(repo.lastMaxBudget, 9000);
      expect(repo.lastPresetId, 'pre-9');
    });
  });
}
