import 'package:freezed_annotation/freezed_annotation.dart';

part 'taxonomy.freezed.dart';
part 'taxonomy.g.dart';

/// Category / region flat node for vendor surfaces (CP2-F06 freezed pattern).
@freezed
abstract class TaxonomyNode with _$TaxonomyNode {
  const TaxonomyNode._();

  const factory TaxonomyNode({
    required String id,
    required String nameEn,
    required String nameAr,
  }) = _TaxonomyNode;

  String name(String locale) => locale == 'ar' ? nameAr : nameEn;

  factory TaxonomyNode.fromJson(Map<String, dynamic> json) =>
      _$TaxonomyNodeFromJson(json);
}
