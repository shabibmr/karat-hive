import 'package:freezed_annotation/freezed_annotation.dart';

part 'taxonomy_node.freezed.dart';
part 'taxonomy_node.g.dart';

/// Freezed model representing a self-referential 2-level taxonomy tree node.
/// Mirrors backend `TaxonomyNode` and Prisma `Category`/`Region`.
@freezed
class TaxonomyNode with _$TaxonomyNode {
  const factory TaxonomyNode({
    required String id,
    String? parentId,
    required String nameEn,
    required String nameAr,
    String? icon,
    @Default(0) int displayOrder,
    @Default(true) bool isActive,
    @Default(<TaxonomyNode>[]) List<TaxonomyNode> children,
  }) = _TaxonomyNode;

  factory TaxonomyNode.fromJson(Map<String, dynamic> json) =>
      _$TaxonomyNodeFromJson(json);
}
