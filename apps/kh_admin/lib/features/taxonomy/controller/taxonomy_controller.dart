import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/features/taxonomy/model/taxonomy_dto.dart';
import 'package:kh_admin/features/taxonomy/model/taxonomy_kind.dart';
import 'package:kh_admin/features/taxonomy/model/taxonomy_node.dart';
import 'package:kh_admin/features/taxonomy/repository/taxonomy_repository.dart';

/// Riverpod [FamilyAsyncNotifier] managing taxonomy tree state for Categories and Regions.
/// Supports optimistic updates, rollback on network failure, and cache invalidation (AD-FE-09).
class TaxonomyController
    extends FamilyAsyncNotifier<List<TaxonomyNode>, TaxonomyKind> {
  @override
  Future<List<TaxonomyNode>> build(TaxonomyKind arg) async {
    final repository = ref.watch(taxonomyRepositoryProvider);
    return repository.fetchTree(arg, includeInactive: true);
  }

  /// Explicit cache invalidation and reload from backend.
  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(taxonomyRepositoryProvider);
      return repository.fetchTree(arg, includeInactive: true);
    });
  }

  /// Creates a new taxonomy node with optimistic state insertion and cache invalidation.
  Future<TaxonomyNode> createNode(CreateTaxonomyDto dto) async {
    final previousState = state;
    final repository = ref.read(taxonomyRepositoryProvider);

    // Optimistic insert if current state has data
    if (state.hasValue) {
      final optimisticNode = TaxonomyNode(
        id: 'optimistic-${DateTime.now().millisecondsSinceEpoch}',
        nameEn: dto.nameEn,
        nameAr: dto.nameAr,
        icon: dto.icon,
        displayOrder: dto.displayOrder,
        isActive: dto.isActive,
      );
      state = AsyncValue.data(_insertIntoList(state.value!, optimisticNode));
    }

    try {
      final created = await repository.createNode(arg, dto);
      // Invalidate and reload authoritative server state
      await reload();
      return created;
    } on Object catch (e, st) {
      // Rollback optimistic update on error
      state = previousState;
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Updates an existing taxonomy node with optimistic in-memory update and reload.
  Future<TaxonomyNode> updateNode(String id, UpdateTaxonomyDto dto) async {
    final previousState = state;
    final repository = ref.read(taxonomyRepositoryProvider);

    // Optimistic in-place update
    if (state.hasValue) {
      state = AsyncValue.data(
        _updateInList(state.value!, id, (node) {
          return node.copyWith(
            nameEn: dto.nameEn ?? node.nameEn,
            nameAr: dto.nameAr ?? node.nameAr,
            icon: dto.icon ?? node.icon,
            displayOrder: dto.displayOrder ?? node.displayOrder,
            isActive: dto.isActive ?? node.isActive,
          );
        }),
      );
    }

    try {
      final updated = await repository.updateNode(arg, id, dto);
      await reload();
      return updated;
    } on Object catch (e, st) {
      state = previousState;
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Deactivates a taxonomy node (no delete per SAM-GAP-9) with optimistic update and reload.
  Future<TaxonomyNode> deactivateNode(String id) async {
    final previousState = state;
    final repository = ref.read(taxonomyRepositoryProvider);

    // Optimistic deactivation
    if (state.hasValue) {
      state = AsyncValue.data(
        _updateInList(state.value!, id, (node) {
          return node.copyWith(isActive: false);
        }),
      );
    }

    try {
      final deactivated = await repository.deactivateNode(arg, id);
      await reload();
      return deactivated;
    } on Object catch (e, st) {
      state = previousState;
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Helper to insert a node into the flat list, keeping it sorted.
  static List<TaxonomyNode> _insertIntoList(
    List<TaxonomyNode> list,
    TaxonomyNode newNode,
  ) {
    final updated = [...list, newNode];
    _sortList(updated);
    return updated;
  }

  /// Helper to update a node in the flat list.
  static List<TaxonomyNode> _updateInList(
    List<TaxonomyNode> list,
    String targetId,
    TaxonomyNode Function(TaxonomyNode) updateFn,
  ) {
    final updated = list.map((node) {
      if (node.id == targetId) {
        return updateFn(node);
      }
      return node;
    }).toList();
    _sortList(updated);
    return updated;
  }

  /// Sorts nodes by displayOrder asc, then nameEn asc.
  static void _sortList(List<TaxonomyNode> nodes) {
    nodes.sort((a, b) {
      final orderCmp = a.displayOrder.compareTo(b.displayOrder);
      if (orderCmp != 0) return orderCmp;
      return a.nameEn.compareTo(b.nameEn);
    });
  }
}

/// Provider family for [TaxonomyController] keyed by [TaxonomyKind].
final AsyncNotifierProviderFamily<TaxonomyController, List<TaxonomyNode>,
        TaxonomyKind> taxonomyControllerProvider =
    AsyncNotifierProvider.family<TaxonomyController, List<TaxonomyNode>,
        TaxonomyKind>(
  TaxonomyController.new,
);
