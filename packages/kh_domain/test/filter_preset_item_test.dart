import 'package:kh_domain/kh_domain.dart';
import 'package:test/test.dart';

void main() {
  group('FilterPresetItem', () {
    test('parses from full JSON map', () {
      final item = FilterPresetItem.fromJson({
        'id': 'fp-1',
        'name': 'Dubai buy',
        'filters': {'regionId': 'reg-1', 'direction': 'BUY'},
        'createdAt': '2026-09-01T10:00:00.000Z',
      });

      expect(item.id, 'fp-1');
      expect(item.name, 'Dubai buy');
      expect(item.filters, {'regionId': 'reg-1', 'direction': 'BUY'});
      expect(item.createdAt.toUtc(), DateTime.utc(2026, 9, 1, 10));
    });

    test('defaults filters to empty map when absent', () {
      final item = FilterPresetItem.fromJson({
        'id': 'fp-2',
        'name': 'Empty',
        'createdAt': '2026-09-01T00:00:00.000Z',
      });

      expect(item.filters, isEmpty);
    });

    test('falls back to DateTime.now when createdAt is invalid', () {
      final before = DateTime.now();
      final item = FilterPresetItem.fromJson({
        'id': 'fp-3',
        'name': 'Bad date',
        'createdAt': 'not-a-date',
      });
      final after = DateTime.now();

      expect(
        !item.createdAt.isBefore(before) && !item.createdAt.isAfter(after),
        isTrue,
      );
    });

    test('serializes to JSON', () {
      final item = FilterPresetItem(
        id: 'fp-4',
        name: 'Saved',
        filters: const {'state': 'PUBLISHED'},
        createdAt: DateTime.utc(2026, 9, 2),
      );

      expect(item.toJson(), {
        'id': 'fp-4',
        'name': 'Saved',
        'filters': {'state': 'PUBLISHED'},
        'createdAt': '2026-09-02T00:00:00.000Z',
      });
    });

    test('copyWith and value equality', () {
      final a = FilterPresetItem(
        id: '1',
        name: 'A',
        createdAt: DateTime.utc(2026, 1, 1),
      );
      final b = FilterPresetItem(
        id: '1',
        name: 'A',
        createdAt: DateTime.utc(2026, 1, 1),
      );
      final c = a.copyWith(name: 'B');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(c.name, 'B');
      expect(a, isNot(equals(c)));
    });
  });
}
