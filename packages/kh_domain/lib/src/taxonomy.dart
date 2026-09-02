class TaxonomyNode {
  const TaxonomyNode({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.children = const [],
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final List<TaxonomyNode> children;

  String name(String locale) => locale == 'ar' ? nameAr : nameEn;

  static TaxonomyNode fromJson(Map<String, dynamic> j) => TaxonomyNode(
        id: j['id'] as String,
        nameEn: j['nameEn'] as String,
        nameAr: j['nameAr'] as String,
        children: ((j['children'] as List?) ?? const [])
            .map((c) => TaxonomyNode.fromJson(c as Map<String, dynamic>))
            .toList(growable: false),
      );
}
