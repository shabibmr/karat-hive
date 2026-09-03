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

  List<TaxonomyNode> categories = [
    const TaxonomyNode(
      id: 'cat-jewellery',
      nameEn: 'Jewellery',
      nameAr: 'مجوهرات',
      displayOrder: 1,
      isActive: true,
      children: [
        TaxonomyNode(
          id: 'cat-rings',
          parentId: 'cat-jewellery',
          nameEn: 'Rings',
          nameAr: 'خواتم',
          displayOrder: 1,
          isActive: false, // Inactive child for testing
        ),
      ],
    ),
  ];

  bool empty = false;
  bool failNext = false;
  String? lastDeactivatedId;

  @override
  Future<List<TaxonomyNode>> fetchCategories({bool includeInactive = true}) async {
    if (failNext) throw Exception('Category service unavailable');
    if (empty) return const [];
    return categories;
  }

  @override
  Future<List<TaxonomyNode>> fetchRegions({bool includeInactive = true}) async {
    return const [];
  }

  @override
  Future<TaxonomyNode> deactivateCategory(String id) async {
    lastDeactivatedId = id;
    categories = categories.map((c) {
      if (c.id == id) return c.copyWith(isActive: false);
      return c;
    }).toList();
    return categories.firstWhere((c) => c.id == id);
  }

  @override
  Future<TaxonomyNode> createCategory(CreateTaxonomyDto dto) async {
    final newNode = TaxonomyNode(
      id: 'cat-new-2',
      parentId: dto.parentId,
      nameEn: dto.nameEn,
      nameAr: dto.nameAr,
      displayOrder: dto.displayOrder,
      isActive: dto.isActive,
    );
    categories = [...categories, newNode];
    return newNode;
  }

  @override
  Future<TaxonomyNode> updateCategory(String id, UpdateTaxonomyDto dto) async {
    categories = categories.map((c) {
      if (c.id == id) {
        return c.copyWith(
          nameEn: dto.nameEn ?? c.nameEn,
          nameAr: dto.nameAr ?? c.nameAr,
        );
      }
      return c;
    }).toList();
    return categories.firstWhere((c) => c.id == id);
  }
}

void main() {
  late _FakeTaxonomyRepository fakeRepository;

  setUp(() {
    fakeRepository = _FakeTaxonomyRepository();
  });

  Widget createTaxonomyWidget({
    TaxonomyKind kind = TaxonomyKind.category,
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

  testWidgets('TaxonomyScreen renders category tree with Inactive text badge (accessibility §40/§56)',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTaxonomyWidget(initialShowInactive: true));
    await tester.pumpAndSettle();

    expect(find.text('Category Management'), findsOneWidget);
    expect(find.text('Jewellery'), findsOneWidget);
    expect(find.text('Rings'), findsOneWidget);

    // Inactive text badge is present for inactive 'Rings' node
    expect(find.byKey(const Key('inactive-badge-cat-rings')), findsOneWidget);
    expect(find.text('Inactive'), findsWidgets);
  });

  testWidgets('TaxonomyScreen renders empty state view (SH-FND-12) when list is empty',
      (tester) async {
    fakeRepository.empty = true;

    await tester.pumpWidget(createTaxonomyWidget());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('empty-view')), findsOneWidget);
    expect(find.text('No Categories Found'), findsOneWidget);
    expect(find.byKey(const Key('empty-state-cta-button')), findsOneWidget);
  });

  testWidgets('TaxonomyScreen renders error view (SH-FND-13) on fetch failure',
      (tester) async {
    fakeRepository.failNext = true;

    await tester.pumpWidget(createTaxonomyWidget());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('error-view')), findsOneWidget);
    expect(find.text('Category service unavailable'), findsOneWidget);
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

    // Select the root Jewellery node
    await tester.tap(find.byKey(const Key('taxonomy-node-cat-jewellery')));
    await tester.pumpAndSettle();

    // Verify "Deactivate" button exists and "Delete" does NOT exist
    expect(find.byKey(const Key('node-deactivate-button')), findsOneWidget);
    expect(find.text('Delete'), findsNothing);

    // Tap Deactivate
    await tester.tap(find.byKey(const Key('node-deactivate-button')));
    await tester.pumpAndSettle();

    // Verify SH-FND-15 confirmation dialog title and action
    expect(find.text('Deactivate Jewellery?'), findsOneWidget);
    expect(find.byKey(const Key('confirm-deactivate-button')), findsOneWidget);
    expect(find.text('Delete'), findsNothing);

    // Confirm deactivation
    await tester.tap(find.byKey(const Key('confirm-deactivate-button')));
    await tester.pumpAndSettle();

    expect(fakeRepository.lastDeactivatedId, 'cat-jewellery');
    // Success toast shown (SH-FND-17)
    expect(find.byKey(const Key('taxonomy-success-toast')), findsOneWidget);
  });
}
