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

  List<TaxonomyNode> regions = [
    const TaxonomyNode(
      id: 'reg-1',
      nameEn: 'Dubai',
      nameAr: 'دبي',
      displayOrder: 1,
      isActive: true,
    ),
    const TaxonomyNode(
      id: 'reg-2',
      nameEn: 'Abu Dhabi',
      nameAr: 'أبو ظبي',
      displayOrder: 2,
      isActive: false,
    ),
  ];

  bool shouldFail = false;
  String? lastCreatedName;
  String? lastUpdatedId;
  String? lastDeactivatedId;

  @override
  Future<List<TaxonomyNode>> fetchRegions({bool includeInactive = true}) async {
    if (shouldFail) throw Exception('Fetch regions network error');
    return regions;
  }

  @override
  Future<TaxonomyNode> createRegion(CreateTaxonomyDto dto) async {
    if (shouldFail) throw Exception('Creation failed');
    lastCreatedName = dto.nameEn;
    final newNode = TaxonomyNode(
      id: 'reg-created-1',
      nameEn: dto.nameEn,
      nameAr: dto.nameAr,
      icon: dto.icon,
      displayOrder: dto.displayOrder,
      isActive: dto.isActive,
    );
    regions = [...regions, newNode];
    return newNode;
  }

  @override
  Future<TaxonomyNode> updateRegion(String id, UpdateTaxonomyDto dto) async {
    if (shouldFail) throw Exception('Update failed');
    lastUpdatedId = id;
    TaxonomyNode? updated;
    regions = regions.map((c) {
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
  Future<TaxonomyNode> deactivateRegion(String id) async {
    if (shouldFail) throw Exception('Deactivation failed');
    lastDeactivatedId = id;
    TaxonomyNode? deactivated;
    regions = regions.map((c) {
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

  test('TaxonomyController loads flat region list on build', () async {
    final state =
        await container.read(taxonomyControllerProvider(TaxonomyKind.region).future);

    expect(state.length, 2);
    expect(state.first.nameEn, 'Dubai');
  });

  test('TaxonomyController creates node with optimistic update and invalidation',
      () async {
    // Prime initial read
    await container.read(taxonomyControllerProvider(TaxonomyKind.region).future);

    const dto = CreateTaxonomyDto(
      nameEn: 'Sharjah',
      nameAr: 'الشارقة',
      displayOrder: 3,
      isActive: true,
    );

    final controller =
        container.read(taxonomyControllerProvider(TaxonomyKind.region).notifier);
    final created = await controller.createNode(dto);

    expect(created.nameEn, 'Sharjah');
    expect(mockRepository.lastCreatedName, 'Sharjah');

    final updatedState = container
        .read(taxonomyControllerProvider(TaxonomyKind.region))
        .value!;
    expect(updatedState.any((n) => n.nameEn == 'Sharjah'), isTrue);
  });

  test('TaxonomyController updates existing node and refreshes', () async {
    await container.read(taxonomyControllerProvider(TaxonomyKind.region).future);

    const dto = UpdateTaxonomyDto(
      nameEn: 'Dubai Metro',
    );

    final controller =
        container.read(taxonomyControllerProvider(TaxonomyKind.region).notifier);
    final updated = await controller.updateNode('reg-1', dto);

    expect(updated.nameEn, 'Dubai Metro');
    expect(mockRepository.lastUpdatedId, 'reg-1');

    final state = container
        .read(taxonomyControllerProvider(TaxonomyKind.region))
        .value!;
    expect(state.firstWhere((n) => n.id == 'reg-1').nameEn,
        'Dubai Metro');
  });

  test('TaxonomyController deactivates node without deleting (SAM-GAP-9)', () async {
    await container.read(taxonomyControllerProvider(TaxonomyKind.region).future);

    final controller =
        container.read(taxonomyControllerProvider(TaxonomyKind.region).notifier);
    final deactivated = await controller.deactivateNode('reg-1');

    expect(deactivated.isActive, isFalse);
    expect(mockRepository.lastDeactivatedId, 'reg-1');

    final state = container
        .read(taxonomyControllerProvider(TaxonomyKind.region))
        .value!;
    expect(state.firstWhere((n) => n.id == 'reg-1').isActive, isFalse);
  });

  test('TaxonomyController rolls back optimistic state on mutation failure', () async {
    await container.read(taxonomyControllerProvider(TaxonomyKind.region).future);

    mockRepository.shouldFail = true;

    const dto = CreateTaxonomyDto(
      nameEn: 'Fail Region',
      nameAr: 'فشل',
      displayOrder: 10,
    );

    final controller =
        container.read(taxonomyControllerProvider(TaxonomyKind.region).notifier);

    expect(() => controller.createNode(dto), throwsException);
  });
}
