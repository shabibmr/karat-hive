import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/onboarding/repository/onboarding_repository.dart';
import 'package:karat_hive/features/request_feed/controller/request_feed_controller.dart';
import 'package:karat_hive/features/request_feed/presentation/request_filters_sheet.dart';
import 'package:karat_hive/features/request_feed/repository/request_feed_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

const _categories = [
  TaxonomyNode(
    id: 'cat-ornaments',
    nameEn: 'Ornaments',
    nameAr: 'زينة',
    children: [
      TaxonomyNode(id: 'cat-ring', nameEn: 'Rings', nameAr: 'خواتم'),
    ],
  ),
];

const _regions = [
  TaxonomyNode(
    id: 'reg-dubai',
    nameEn: 'Dubai',
    nameAr: 'دبي',
    children: [
      TaxonomyNode(id: 'reg-dxb', nameEn: 'Deira', nameAr: 'ديرة'),
    ],
  ),
];

class _FakeRequestFeedRepository implements RequestFeedRepository {
  _FakeRequestFeedRepository({List<FilterPresetItem>? presets})
      : presets = List<FilterPresetItem>.of(presets ?? const []);

  final List<FilterPresetItem> presets;
  String? lastCreatedName;
  Map<String, dynamic>? lastCreatedFilters;
  final List<String> deletedPresetIds = [];

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
  }) async =>
      const Ok(PagedResult(items: []));

  @override
  Future<Result<VendorRequestItem>> getRequest(String id) async =>
      Err(const ServerFailure(message: 'unused'));

  @override
  Future<Result<void>> markViewed(String requestId) async => const Ok(null);

  @override
  Future<Result<List<FilterPresetItem>>> getFilterPresets() async => Ok(List.of(presets));

  @override
  Future<Result<FilterPresetItem>> createFilterPreset({
    required String name,
    required Map<String, dynamic> filters,
  }) async {
    lastCreatedName = name;
    lastCreatedFilters = filters;
    final item = FilterPresetItem(
      id: 'pre-${presets.length + 1}',
      name: name,
      filters: filters,
      createdAt: DateTime.utc(2026, 9, 7),
    );
    presets.add(item);
    return Ok(item);
  }

  @override
  Future<Result<FilterPresetItem>> updateFilterPreset(
    String id, {
    String? name,
    Map<String, dynamic>? filters,
  }) async =>
      Ok(FilterPresetItem(
        id: id,
        name: name ?? '',
        filters: filters ?? const {},
        createdAt: DateTime.utc(2026, 9, 7),
      ));

  @override
  Future<Result<void>> deleteFilterPreset(String id) async {
    deletedPresetIds.add(id);
    presets.removeWhere((p) => p.id == id);
    return const Ok(null);
  }

  @override
  Future<Result<VendorDashboard>> getDashboard() async =>
      Err(const ServerFailure(message: 'unused'));
}

Finder _sheetListView() => find.descendant(
      of: find.byType(RequestFiltersSheet),
      matching: find.byType(ListView),
    );

/// ListView builds lazily — drag until [finder] exists, then ensureVisible.
Future<void> _ensureVisible(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 30 && finder.evaluate().isEmpty; i++) {
    await tester.drag(_sheetListView(), const Offset(0, -200));
    await tester.pumpAndSettle();
  }
  expect(finder, findsWidgets);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<ProviderContainer> _openSheet(
  WidgetTester tester, {
  required _FakeRequestFeedRepository repo,
  RequestFiltersState initialFilters = const RequestFiltersState(),
}) async {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final container = ProviderContainer(
    overrides: [
      requestFeedRepositoryProvider.overrideWithValue(repo),
      categoriesProvider.overrideWith((ref) async => _categories),
      regionsProvider.overrideWith((ref) async => _regions),
    ],
  );
  // Keep autoDispose filters alive across sheet open/close so Apply sticks.
  final filtersSub = container.listen(requestFiltersProvider, (_, __) {});
  container.read(requestFiltersProvider.notifier).state = initialFilters;
  addTearDown(() {
    filtersSub.close();
    container.dispose();
  });

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: KhStrings.delegates,
        supportedLocales: KhStrings.supportedLocales,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const Key('open-filters'),
                  onPressed: () => RequestFiltersSheet.show(context),
                  child: const Text('Open Filters'),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('open-filters')));
  await tester.pumpAndSettle();
  expect(find.text('Filter Requests'), findsOneWidget);
  return container;
}

void main() {
  group('RequestFiltersSheet (VEN-S07)', () {
    testWidgets('opens sheet with sort options and empty presets copy', (tester) async {
      final repo = _FakeRequestFeedRepository();
      await _openSheet(tester, repo: repo);

      expect(find.text('Newest'), findsOneWidget);
      expect(find.text('Expiring Soon'), findsOneWidget);
      expect(find.text('Highest Value'), findsOneWidget);
      expect(find.text('Fewest Offers'), findsOneWidget);
      expect(find.text('Apply Filters'), findsOneWidget);
      expect(find.text('Reset All'), findsNothing);

      await _ensureVisible(tester, find.text('Include already responded requests'));
      expect(find.text('Include already responded requests'), findsOneWidget);

      await _ensureVisible(tester, find.text('No saved presets yet.'));
      expect(find.text('No saved presets yet.'), findsOneWidget);
    });

    testWidgets('changing sort, request type, purity and includeResponded then apply updates provider',
        (tester) async {
      final repo = _FakeRequestFeedRepository();
      final container = await _openSheet(tester, repo: repo);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Expiring Soon'));
      await tester.pumpAndSettle();
      expect(find.text('Reset All'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Bullion'));
      await tester.pumpAndSettle();

      await _ensureVisible(tester, find.widgetWithText(ChoiceChip, '22K'));
      await tester.tap(find.widgetWithText(ChoiceChip, '22K'));
      await tester.pumpAndSettle();

      await _ensureVisible(tester, find.text('Include already responded requests'));
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      expect(find.text('Filter Requests'), findsNothing);
      final applied = container.read(requestFiltersProvider);
      expect(applied.sort, 'EXPIRING');
      expect(applied.requestType, 'BULLION');
      expect(applied.purityKarat, '22');
      expect(applied.includeResponded, isTrue);
      expect(applied.hasActiveFilters, isTrue);
    });

    testWidgets('Reset All clears draft filters before apply', (tester) async {
      final repo = _FakeRequestFeedRepository();
      final container = await _openSheet(
        tester,
        repo: repo,
        initialFilters: const RequestFiltersState(
          sort: 'HIGHEST_VALUE',
          requestType: 'FIND_ORNAMENT',
          includeResponded: true,
        ),
      );

      expect(find.text('Reset All'), findsOneWidget);
      await tester.tap(find.text('Reset All'));
      await tester.pumpAndSettle();
      expect(find.text('Reset All'), findsNothing);

      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      final applied = container.read(requestFiltersProvider);
      expect(applied.sort, 'NEWEST');
      expect(applied.requestType, isNull);
      expect(applied.includeResponded, isFalse);
      expect(applied.hasActiveFilters, isFalse);
    });

    testWidgets('budget fields update draft and serialize on apply', (tester) async {
      final repo = _FakeRequestFeedRepository();
      final container = await _openSheet(tester, repo: repo);

      await _ensureVisible(tester, find.byKey(const Key('filter-min-budget')));
      await tester.enterText(find.byKey(const Key('filter-min-budget')), '1000');
      await tester.enterText(find.byKey(const Key('filter-max-budget')), '5000');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      final applied = container.read(requestFiltersProvider);
      expect(applied.minBudget, 1000);
      expect(applied.maxBudget, 5000);
      expect(applied.toFilterMap()['minBudget'], 1000);
      expect(applied.toFilterMap()['maxBudget'], 5000);
    });

    testWidgets('save / apply / delete preset flows', (tester) async {
      final existing = FilterPresetItem(
        id: 'pre-existing',
        name: 'Dubai Rings',
        filters: const {
          'sort': 'FEWEST_OFFERS',
          'requestType': 'FIND_ORNAMENT',
          'purityKarat': '22',
          'includeResponded': true,
        },
        createdAt: DateTime.utc(2026, 9, 1),
      );
      final repo = _FakeRequestFeedRepository(presets: [existing]);
      final container = await _openSheet(tester, repo: repo);

      await _ensureVisible(tester, find.text('Dubai Rings'));
      await tester.tap(find.widgetWithText(InputChip, 'Dubai Rings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      final applied = container.read(requestFiltersProvider);
      expect(applied.activePresetId, 'pre-existing');
      expect(applied.activePresetName, 'Dubai Rings');
      expect(applied.sort, 'FEWEST_OFFERS');
      expect(applied.requestType, 'FIND_ORNAMENT');
      expect(applied.purityKarat, '22');
      expect(applied.includeResponded, isTrue);

      await tester.tap(find.byKey(const Key('open-filters')));
      await tester.pumpAndSettle();

      await _ensureVisible(tester, find.text('Save current filters as preset'));
      await tester.tap(find.text('Save current filters as preset'));
      await tester.pumpAndSettle();

      expect(find.text('Save Filter Preset'), findsOneWidget);
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'Saved From Sheet',
      );
      await tester.tap(find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Save'),
      ));
      await tester.pumpAndSettle();

      expect(repo.lastCreatedName, 'Saved From Sheet');
      expect(repo.lastCreatedFilters?['requestType'], 'FIND_ORNAMENT');
      await _ensureVisible(tester, find.text('Saved From Sheet'));
      expect(find.text('Saved From Sheet'), findsOneWidget);

      final dubaiChip = find.widgetWithText(InputChip, 'Dubai Rings');
      await _ensureVisible(tester, dubaiChip);
      // InputChip delete control uses the platform "Delete" tooltip.
      await tester.tap(find.descendant(
        of: dubaiChip,
        matching: find.byTooltip('Delete'),
      ));
      await tester.pumpAndSettle();

      expect(repo.deletedPresetIds, contains('pre-existing'));
      expect(find.text('Dubai Rings'), findsNothing);
    });
  });
}
