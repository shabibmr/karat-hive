/// Identifies the administrative taxonomy vertical (ADM-S14 Categories vs ADM-S15 Regions).
enum TaxonomyKind {
  category,
  region;

  String get pathSegment => this == TaxonomyKind.category ? 'categories' : 'regions';
  String get displayName => this == TaxonomyKind.category ? 'Categories' : 'Regions';
  String get singularName => this == TaxonomyKind.category ? 'Category' : 'Region';
}
