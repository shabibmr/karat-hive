import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/taxonomy/model/taxonomy_dto.dart';
import 'package:kh_admin/features/taxonomy/model/taxonomy_kind.dart';
import 'package:kh_admin/features/taxonomy/model/taxonomy_node.dart';
import 'package:kh_admin/features/taxonomy/presentation/taxonomy_screen.dart';
import 'package:kh_admin/features/taxonomy/repository/taxonomy_repository.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

class _FakeTaxonomyRepository extends TaxonomyRepository {
  _FakeTaxonomyRepository() : super(ApiClient());

  List<TaxonomyNode> regions = [
    const TaxonomyNode(
      id: 'reg-dubai',
      nameEn: 'Dubai',
      nameAr: 'دبي',
      displayOrder: 1,
      isActive: true,
    ),
    const TaxonomyNode(
      id: 'reg-sharjah',
      nameEn: 'Sharjah',
      nameAr: 'الشارقة',
      displayOrder: 2,
      isActive: false, // Inactive node for testing
    ),
  ];

  bool empty = false;
  bool failNext = false;
  String? lastDeactivatedId;

  @override
  Future<List<TaxonomyNode>> fetchRegions({bool includeInactive = true}) async {
    if (failNext) throw Exception('Region service unavailable');
    if (empty) return const [];
    return regions;
  }

  @override
  Future<TaxonomyNode> deactivateRegion(String id) async {
    lastDeactivatedId = id;
    regions = regions.map((c) {
      if (c.id == id) return c.copyWith(isActive: false);
      return c;
    }).toList();
    return regions.firstWhere((c) => c.id == id);
  }

  @override
  Future<TaxonomyNode> createRegion(CreateTaxonomyDto dto) async {
    final newNode = TaxonomyNode(
      id: 'reg-new-2',
      nameEn: dto.nameEn,
      nameAr: dto.nameAr,
      displayOrder: dto.displayOrder,
      isActive: dto.isActive,
    );
    regions = [...regions, newNode];
    return newNode;
  }

  @override
  Future<TaxonomyNode> updateRegion(String id, UpdateTaxonomyDto dto) async {
    regions = regions.map((c) {
      if (c.id == id) {
        return c.copyWith(
          nameEn: dto.nameEn ?? c.nameEn,
          nameAr: dto.nameAr ?? c.nameAr,
        );
      }
      return c;
    }).toList();
    return regions.firstWhere((c) => c.id == id);
  }
}

void main() {
  late _FakeTaxonomyRepository fakeRepository;

  setUp(() {
    fakeRepository = _FakeTaxonomyRepository();
  });

  Widget createTaxonomyWidget({
    TaxonomyKind kind = TaxonomyKind.region,
    bool initialShowInactive = false,
  }) {
    return ProviderScope(
      overrides: [
        taxonomyRepositoryProvider.overrideWithValue(fakeRepository),
      ],
      child: MaterialApp(
        theme: buildKhAdminTheme(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TaxonomyScreen(
            kind: kind,
            initialShowInactive: initialShowInactive,
          ),
        ),
      ),
    );
  }

  testWidgets('TaxonomyScreen renders region tree with Inactive text badge (accessibility §40/§56)',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTaxonomyWidget(initialShowInactive: true));
    await tester.pumpAndSettle();

    // ADM-S15 header: gold eyebrow above the mock's screen heading.
    expect(find.text('TAXONOMY CONFIG'), findsOneWidget);
    expect(find.text('Regions'), findsOneWidget);
    expect(find.text('Dubai'), findsOneWidget);
    expect(find.text('Sharjah'), findsOneWidget);

    // Inactive text badge is present for inactive 'Sharjah' node
    expect(find.byKey(const Key('inactive-badge-reg-sharjah')), findsOneWidget);
    expect(find.text('Inactive'), findsWidgets);
  });

  testWidgets('TaxonomyScreen renders empty state view (SH-FND-12) when list is empty',
      (tester) async {
    fakeRepository.empty = true;

    await tester.pumpWidget(createTaxonomyWidget());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('empty-view')), findsOneWidget);
    expect(find.text('No Regions Found'), findsOneWidget);
    expect(find.byKey(const Key('empty-state-cta-button')), findsOneWidget);
  });

  testWidgets('empty-state CTA mounts create-root NodeEditorPanel', (tester) async {
    fakeRepository.empty = true;
    await tester.pumpWidget(createTaxonomyWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('empty-state-cta-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('node-name-en-field')), findsOneWidget);
    expect(find.byKey(const Key('node-save-button')), findsOneWidget);
  });

  testWidgets('TaxonomyScreen renders error view (SH-FND-13) on fetch failure',
      (tester) async {
    fakeRepository.failNext = true;

    await tester.pumpWidget(createTaxonomyWidget());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('error-view')), findsOneWidget);
    expect(find.text('Region service unavailable'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('NodeEditorPanel deactivation triggers confirmation dialog and strictly NEVER uses word "Delete" (SAM-GAP-9)',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTaxonomyWidget());
    await tester.pumpAndSettle();

    // Select the root Dubai node
    await tester.tap(find.byKey(const Key('taxonomy-node-reg-dubai')));
    await tester.pumpAndSettle();

    // Verify "Deactivate" button exists and "Delete" does NOT exist
    expect(find.byKey(const Key('node-deactivate-button')), findsOneWidget);
    expect(find.text('Delete'), findsNothing);

    // Tap Deactivate
    await tester.tap(find.byKey(const Key('node-deactivate-button')));
    await tester.pumpAndSettle();

    // Verify SH-FND-15 confirmation dialog title and action
    expect(find.text('Deactivate Dubai?'), findsOneWidget);
    expect(find.byKey(const Key('confirm-deactivate-button')), findsOneWidget);
    expect(find.text('Delete'), findsNothing);

    // Confirm deactivation
    await tester.tap(find.byKey(const Key('confirm-deactivate-button')));
    await tester.pumpAndSettle();

    expect(fakeRepository.lastDeactivatedId, 'reg-dubai');
    // Success toast shown (SH-FND-17)
    expect(find.byKey(const Key('taxonomy-success-toast')), findsOneWidget);
  });
}
