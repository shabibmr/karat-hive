import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/api/json_parse.dart';
import 'package:kh_admin/features/taxonomy/model/taxonomy_dto.dart';
import 'package:kh_admin/features/taxonomy/model/taxonomy_kind.dart';
import 'package:kh_admin/features/taxonomy/model/taxonomy_node.dart';

/// Typed repository wrapping [ApiClient] for the 8 Admin Taxonomy endpoints:
/// - GET /v1/admin/categories
/// - POST /v1/admin/categories
/// - PATCH /v1/admin/categories/:id
/// - POST /v1/admin/categories/:id/deactivate
/// - GET /v1/admin/regions
/// - POST /v1/admin/regions
/// - PATCH /v1/admin/regions/:id
/// - POST /v1/admin/regions/:id/deactivate
class TaxonomyRepository {
  TaxonomyRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Fetches the Category taxonomy tree.
  Future<List<TaxonomyNode>> fetchCategories({bool includeInactive = true}) async {
    final response = await _apiClient.getCollection(
      '/v1/admin/categories',
      queryParameters: {'includeInactive': includeInactive.toString()},
    );
    return response.items
        .whereType<Map<String, dynamic>>()
        .map(TaxonomyNode.fromJson)
        .toList();
  }

  /// Creates a new Category node.
  Future<TaxonomyNode> createCategory(CreateTaxonomyDto dto) async {
    final response = await _apiClient.post(
      '/v1/admin/categories',
      data: dto.toJson(),
    );
    return TaxonomyNode.fromJson(unwrapEntity(response));
  }

  /// Updates an existing Category node.
  Future<TaxonomyNode> updateCategory(String id, UpdateTaxonomyDto dto) async {
    final payload = dto.toJson()..removeWhere((_, v) => v == null);
    final response = await _apiClient.patch(
      '/v1/admin/categories/$id',
      data: payload,
    );
    return TaxonomyNode.fromJson(unwrapEntity(response));
  }

  /// Deactivates a Category node (preserves historical associations; no hard delete per SAM-GAP-9).
  Future<TaxonomyNode> deactivateCategory(String id) async {
    final response = await _apiClient.post(
      '/v1/admin/categories/$id/deactivate',
    );
    return TaxonomyNode.fromJson(unwrapEntity(response));
  }

  /// Fetches the Region taxonomy tree.
  Future<List<TaxonomyNode>> fetchRegions({bool includeInactive = true}) async {
    final response = await _apiClient.getCollection(
      '/v1/admin/regions',
      queryParameters: {'includeInactive': includeInactive.toString()},
    );
    return response.items
        .whereType<Map<String, dynamic>>()
        .map(TaxonomyNode.fromJson)
        .toList();
  }

  /// Creates a new Region node.
  Future<TaxonomyNode> createRegion(CreateTaxonomyDto dto) async {
    final response = await _apiClient.post(
      '/v1/admin/regions',
      data: dto.toJson(),
    );
    return TaxonomyNode.fromJson(unwrapEntity(response));
  }

  /// Updates an existing Region node.
  Future<TaxonomyNode> updateRegion(String id, UpdateTaxonomyDto dto) async {
    final payload = dto.toJson()..removeWhere((_, v) => v == null);
    final response = await _apiClient.patch(
      '/v1/admin/regions/$id',
      data: payload,
    );
    return TaxonomyNode.fromJson(unwrapEntity(response));
  }

  /// Deactivates a Region node (preserves historical associations; no hard delete per SAM-GAP-9).
  Future<TaxonomyNode> deactivateRegion(String id) async {
    final response = await _apiClient.post(
      '/v1/admin/regions/$id/deactivate',
    );
    return TaxonomyNode.fromJson(unwrapEntity(response));
  }

  /// Generic vertical-unified fetch by [TaxonomyKind].
  Future<List<TaxonomyNode>> fetchTree(
    TaxonomyKind kind, {
    bool includeInactive = true,
  }) {
    switch (kind) {
      case TaxonomyKind.category:
        return fetchCategories(includeInactive: includeInactive);
      case TaxonomyKind.region:
        return fetchRegions(includeInactive: includeInactive);
    }
  }

  /// Generic vertical-unified create by [TaxonomyKind].
  Future<TaxonomyNode> createNode(TaxonomyKind kind, CreateTaxonomyDto dto) {
    switch (kind) {
      case TaxonomyKind.category:
        return createCategory(dto);
      case TaxonomyKind.region:
        return createRegion(dto);
    }
  }

  /// Generic vertical-unified update by [TaxonomyKind].
  Future<TaxonomyNode> updateNode(
    TaxonomyKind kind,
    String id,
    UpdateTaxonomyDto dto,
  ) {
    switch (kind) {
      case TaxonomyKind.category:
        return updateCategory(id, dto);
      case TaxonomyKind.region:
        return updateRegion(id, dto);
    }
  }

  /// Generic vertical-unified deactivate by [TaxonomyKind].
  Future<TaxonomyNode> deactivateNode(TaxonomyKind kind, String id) {
    switch (kind) {
      case TaxonomyKind.category:
        return deactivateCategory(id);
      case TaxonomyKind.region:
        return deactivateRegion(id);
    }
  }
}

/// Provider for [TaxonomyRepository].
final Provider<TaxonomyRepository> taxonomyRepositoryProvider =
    Provider<TaxonomyRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TaxonomyRepository(apiClient);
});
