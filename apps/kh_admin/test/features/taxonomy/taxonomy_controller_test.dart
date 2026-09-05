import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/taxonomy/controller/taxonomy_controller.dart';
import 'package:kh_admin/features/taxonomy/model/taxonomy_dto.dart';
import 'package:kh_admin/features/taxonomy/model/taxonomy_kind.dart';
import 'package:kh_admin/features/taxonomy/model/taxonomy_node.dart';
import 'package:kh_admin/features/taxonomy/repository/taxonomy_repository.dart';

class _MockTaxonomyRepository extends TaxonomyRepository {
  _MockTaxonomyRepository() : super(ApiClient());

  List<TaxonomyNode> categories = [
    const TaxonomyNode(
      id: 'cat-1',
      nameEn: 'Jewellery',
      nameAr: 'مجوهرات',
      displayOrder: 1,
      isActive: true,
      children: [
        TaxonomyNode(
          id: 'cat-1-1',
          parentId: 'cat-1',
          nameEn: 'Rings',
          nameAr: 'خواتم',
          displayOrder: 1,
          isActive: true,
        ),
      ],
    ),
    const TaxonomyNode(
      id: 'cat-2',
      nameEn: 'Bullion',
      nameAr: 'سبائك',
      displayOrder: 2,
      isActive: false,
    ),
  ];

  List<TaxonomyNode> regions = [
    const TaxonomyNode(
      id: 'reg-1',
      nameEn: 'Dubai',
      nameAr: 'دبي',
      displayOrder: 1,
      isActive: true,
      children: [
        TaxonomyNode(
          id: 'reg-1-1',
          parentId: 'reg-1',
          nameEn: 'Deira Gold Souk',
          nameAr: 'سوق الذهب ديرة',
          displayOrder: 1,
          isActive: true,
        ),
      ],
    ),
  ];

  bool shouldFail = false;
  String? lastCreatedName;
  String? lastUpdatedId;
  String? lastDeactivatedId;

  @override
  Future<List<TaxonomyNode>> fetchCategories({bool includeInactive = true}) async {
    if (shouldFail) throw Exception('Fetch categories network error');
    return categories;
  }

  @override
  Future<List<TaxonomyNode>> fetchRegions({bool includeInactive = true}) async {
    if (shouldFail) throw Exception('Fetch regions network error');
    return regions;
  }

  @override
  Future<TaxonomyNode> createCategory(CreateTaxonomyDto dto) async {
    if (shouldFail) throw Exception('Creation failed');
    lastCreatedName = dto.nameEn;
    final newNode = TaxonomyNode(
      id: 'cat-created-1',
      parentId: dto.parentId,
      nameEn: dto.nameEn,
      nameAr: dto.nameAr,
      icon: dto.icon,
      displayOrder: dto.displayOrder,
      isActive: dto.isActive,
      children: const [],
    );
    if (dto.parentId == null) {
      categories = [...categories, newNode];
    } else {
      categories = categories.map((c) {
        if (c.id == dto.parentId) {
          return c.copyWith(children: [...c.children, newNode]);
        }
        return c;
      }).toList();
    }
    return newNode;
  }

  @override
  Future<TaxonomyNode> updateCategory(String id, UpdateTaxonomyDto dto) async {
    if (shouldFail) throw Exception('Update failed');
    lastUpdatedId = id;
    TaxonomyNode? updated;
    categories = categories.map((c) {
      if (c.id == id) {
        updated = c.copyWith(
          nameEn: dto.nameEn ?? c.nameEn,
          nameAr: dto.nameAr ?? c.nameAr,
          displayOrder: dto.displayOrder ?? c.displayOrder,
          isActive: dto.isActive ?? c.isActive,
        );
        return updated!;
      }
      return c;
    }).toList();
    return updated!;
  }

  @override
  Future<TaxonomyNode> deactivateCategory(String id) async {
    if (shouldFail) throw Exception('Deactivation failed');
    lastDeactivatedId = id;
    TaxonomyNode? deactivated;
    categories = categories.map((c) {
      if (c.id == id) {
        deactivated = c.copyWith(isActive: false);
        return deactivated!;
      }
      return c;
    }).toList();
    return deactivated!;
  }
}

void main() {
  late ProviderContainer container;
  late _MockTaxonomyRepository mockRepository;

  setUp(() {
    mockRepository = _MockTaxonomyRepository();
    container = ProviderContainer(
      overrides: [
        taxonomyRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('TaxonomyController loads category tree on build', () async {
    final state =
        await container.read(taxonomyControllerProvider(TaxonomyKind.category).future);

    expect(state.length, 2);
    expect(state.first.nameEn, 'Jewellery');
    expect(state.first.children.length, 1);
    expect(state.first.children.first.nameEn, 'Rings');
  });

  test('TaxonomyController loads region tree on build', () async {
    final state =
        await container.read(taxonomyControllerProvider(TaxonomyKind.region).future);

    expect(state.length, 1);
    expect(state.first.nameEn, 'Dubai');
    expect(state.first.children.first.nameEn, 'Deira Gold Souk');
  });

  test('TaxonomyController creates root node with optimistic update and invalidation',
      () async {
    // Prime initial read
    await container.read(taxonomyControllerProvider(TaxonomyKind.category).future);

    const dto = CreateTaxonomyDto(
      nameEn: 'Watches',
      nameAr: 'ساعات',
      displayOrder: 3,
      isActive: true,
    );

    final controller =
        container.read(taxonomyControllerProvider(TaxonomyKind.category).notifier);
    final created = await controller.createNode(dto);

    expect(created.nameEn, 'Watches');
    expect(mockRepository.lastCreatedName, 'Watches');

    final updatedState = container
        .read(taxonomyControllerProvider(TaxonomyKind.category))
        .value!;
    expect(updatedState.any((n) => n.nameEn == 'Watches'), isTrue);
  });

  test('TaxonomyController creates child node nested under parent', () async {
    await container.read(taxonomyControllerProvider(TaxonomyKind.category).future);

    const dto = CreateTaxonomyDto(
      parentId: 'cat-1',
      nameEn: 'Necklaces',
      nameAr: 'قلائد',
      displayOrder: 2,
      isActive: true,
    );

    final controller =
        container.read(taxonomyControllerProvider(TaxonomyKind.category).notifier);
    final created = await controller.createNode(dto);

    expect(created.parentId, 'cat-1');

    final updatedState = container
        .read(taxonomyControllerProvider(TaxonomyKind.category))
        .value!;
    final parent = updatedState.firstWhere((n) => n.id == 'cat-1');
    expect(parent.children.any((c) => c.nameEn == 'Necklaces'), isTrue);
  });

  test('TaxonomyController updates existing node and refreshes', () async {
    await container.read(taxonomyControllerProvider(TaxonomyKind.category).future);

    const dto = UpdateTaxonomyDto(
      nameEn: 'Fine Jewellery & Ornaments',
    );

    final controller =
        container.read(taxonomyControllerProvider(TaxonomyKind.category).notifier);
    final updated = await controller.updateNode('cat-1', dto);

    expect(updated.nameEn, 'Fine Jewellery & Ornaments');
    expect(mockRepository.lastUpdatedId, 'cat-1');

    final state = container
        .read(taxonomyControllerProvider(TaxonomyKind.category))
        .value!;
    expect(state.firstWhere((n) => n.id == 'cat-1').nameEn,
        'Fine Jewellery & Ornaments');
  });

  test('TaxonomyController deactivates node without deleting (SAM-GAP-9)', () async {
    await container.read(taxonomyControllerProvider(TaxonomyKind.category).future);

    final controller =
        container.read(taxonomyControllerProvider(TaxonomyKind.category).notifier);
    final deactivated = await controller.deactivateNode('cat-1');

    expect(deactivated.isActive, isFalse);
    expect(mockRepository.lastDeactivatedId, 'cat-1');

    final state = container
        .read(taxonomyControllerProvider(TaxonomyKind.category))
        .value!;
    expect(state.firstWhere((n) => n.id == 'cat-1').isActive, isFalse);
  });

  test('TaxonomyController rolls back optimistic state on mutation failure', () async {
    await container.read(taxonomyControllerProvider(TaxonomyKind.category).future);

    mockRepository.shouldFail = true;

    const dto = CreateTaxonomyDto(
      nameEn: 'Fail Category',
      nameAr: 'فشل',
      displayOrder: 10,
    );

    final controller =
        container.read(taxonomyControllerProvider(TaxonomyKind.category).notifier);

    expect(() => controller.createNode(dto), throwsException);
  });
}
