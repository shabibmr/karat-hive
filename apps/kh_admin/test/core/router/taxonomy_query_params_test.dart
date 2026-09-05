import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/router/taxonomy_query_params.dart';

void main() {
  test('TaxonomyQueryParams parses from Uri correctly', () {
    final uri = Uri.parse('/taxonomy/categories?selected=cat-123&showInactive=true');
    final params = TaxonomyQueryParams.fromUri(uri);

    expect(params.selectedId, 'cat-123');
    expect(params.showInactive, isTrue);
  });

  test('TaxonomyQueryParams serializes to query map', () {
    const params = TaxonomyQueryParams(
      selectedId: 'reg-456',
      showInactive: true,
    );
    final map = params.toQueryParameters();

    expect(map['selected'], 'reg-456');
    expect(map['showInactive'], 'true');
  });

  test('TaxonomyQueryParams handles missing parameters cleanly', () {
    final uri = Uri.parse('/taxonomy/categories');
    final params = TaxonomyQueryParams.fromUri(uri);

    expect(params.selectedId, isNull);
    expect(params.showInactive, isFalse);
    expect(params.toQueryParameters().isEmpty, isTrue);
  });

  test('TaxonomyQueryParams copyWith preserves and clears fields', () {
    const params = TaxonomyQueryParams(
      selectedId: 'node-1',
      showInactive: false,
    );

    final updated = params.copyWith(showInactive: true);
    expect(updated.selectedId, 'node-1');
    expect(updated.showInactive, isTrue);

    final cleared = updated.copyWith(clearSelected: true);
    expect(cleared.selectedId, isNull);
    expect(cleared.showInactive, isTrue);
  });
}
