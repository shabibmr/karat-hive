import 'package:freezed_annotation/freezed_annotation.dart';

part 'taxonomy.freezed.dart';
part 'taxonomy.g.dart';

Map<String, dynamic> _normalizeTaxonomyNodeJson(Map<String, dynamic> json) {
  return {
    ...json,
    'children': ((json['children'] as List?) ?? const [])
        .whereType<Map>()
        .map((c) => Map<String, dynamic>.from(c))
        .toList(growable: false),
  };
}

/// Category / region tree node for vendor surfaces (CP2-F06 freezed pattern).
@freezed
abstract class TaxonomyNode with _$TaxonomyNode {
  const TaxonomyNode._();

  const factory TaxonomyNode({
    required String id,
    required String nameEn,
    required String nameAr,
    @Default(<TaxonomyNode>[]) List<TaxonomyNode> children,
  }) = _TaxonomyNode;

  String name(String locale) => locale == 'ar' ? nameAr : nameEn;

  factory TaxonomyNode.fromJson(Map<String, dynamic> json) =>
      _$TaxonomyNodeFromJson(_normalizeTaxonomyNodeJson(json));
}
