import 'package:freezed_annotation/freezed_annotation.dart';

part 'taxonomy_node.freezed.dart';
part 'taxonomy_node.g.dart';

/// Freezed model representing a flat, single-level taxonomy node.
/// Mirrors backend `TaxonomyNode` and Prisma `Category`/`Region`.
@freezed
class TaxonomyNode with _$TaxonomyNode {
  const factory TaxonomyNode({
    required String id,
    required String nameEn,
    required String nameAr,
    String? icon,
    @Default(0) int displayOrder,
    @Default(true) bool isActive,
  }) = _TaxonomyNode;

  factory TaxonomyNode.fromJson(Map<String, dynamic> json) =>
      _$TaxonomyNodeFromJson(json);
}
