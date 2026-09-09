import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/router/query_params_codec.dart';

class _TestFilters {
  const _TestFilters({this.query = '', this.status});
  final String query;
  final String? status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TestFilters &&
          other.query == query &&
          other.status == status;

  @override
  int get hashCode => Object.hash(query, status);
}

class _TestCodec extends QueryParamsCodec<_TestFilters> {
  const _TestCodec();

  @override
  _TestFilters decodeFilters(Map<String, String> query) {
    return _TestFilters(
      query: query['q'] ?? '',
      status: query['status'],
    );
  }

  @override
  Map<String, String> encodeFilters(_TestFilters filters) {
    final map = <String, String>{};
    if (filters.query.isNotEmpty) map['q'] = filters.query;
    if (filters.status != null) map['status'] = filters.status!;
    return map;
  }
}

void main() {
  const codec = _TestCodec();

  group('QueryParamsCodec', () {
    test('round-trips full list state (filters + cursor + selectedId)', () {
      const state = ListUrlState<_TestFilters>(
        filters: _TestFilters(query: 'gold', status: 'ACTIVE'),
        cursor: 'cur_123',
        selectedId: 'sel_999',
      );

      final encoded = codec.encode(state);
      expect(encoded, {
        'q': 'gold',
        'status': 'ACTIVE',
        'cursor': 'cur_123',
        'selected': 'sel_999',
      });

      final decoded = codec.decode(encoded);
      expect(decoded, equals(state));
      expect(decoded.cursor, 'cur_123');
      expect(decoded.selectedId, 'sel_999');
      expect(decoded.filters.query, 'gold');
      expect(decoded.filters.status, 'ACTIVE');
    });

    test('encodes empty map when state has default filters and no cursor/selectedId', () {
      const state = ListUrlState<_TestFilters>(
        filters: _TestFilters(),
      );

      final encoded = codec.encode(state);
      expect(encoded, isEmpty);

      final decoded = codec.decode(encoded);
      expect(decoded.cursor, isNull);
      expect(decoded.selectedId, isNull);
      expect(decoded.filters.query, '');
      expect(decoded.filters.status, isNull);
    });

    test('decodes selectedId from selectedId fallback if selected is missing', () {
      final query = <String, String>{
        'q': 'ring',
        'selectedId': 'id_abc',
      };

      final decoded = codec.decode(query);
      expect(decoded.selectedId, 'id_abc');
      expect(decoded.filters.query, 'ring');
    });

    test('round-trips via Uri', () {
      final uri = Uri.parse('https://admin.karathive.com/list?q=test&cursor=c1&selected=s1');
      final decoded = codec.fromUri(uri);

      expect(decoded.filters.query, 'test');
      expect(decoded.cursor, 'c1');
      expect(decoded.selectedId, 's1');

      final reEncoded = codec.encode(decoded);
      expect(reEncoded['q'], 'test');
      expect(reEncoded['cursor'], 'c1');
      expect(reEncoded['selected'], 's1');
    });

    test('copyWith allows selective mutation and clearing', () {
      const state = ListUrlState<_TestFilters>(
        filters: _TestFilters(query: 'ring'),
        cursor: 'cur1',
        selectedId: 'sel1',
      );

      final cleared = state.copyWith(clearCursor: true, clearSelected: true);
      expect(cleared.cursor, isNull);
      expect(cleared.selectedId, isNull);
      expect(cleared.filters.query, 'ring');
    });
  });
}
