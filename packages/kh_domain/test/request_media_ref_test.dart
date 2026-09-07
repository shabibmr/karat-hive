import 'package:kh_domain/kh_domain.dart';
import 'package:test/test.dart';

void main() {
  group('RequestMediaRef', () {
    test('parses from full JSON map', () {
      final media = RequestMediaRef.fromJson({
        'id': 'med-1',
        'key': 'requests/req-1/a.jpg',
        'contentType': 'image/png',
        'displayOrder': 2,
        'thumbnailUrl': 'https://cdn.example/thumb.jpg',
        'displayUrl': 'https://cdn.example/full.jpg',
      });

      expect(media.id, 'med-1');
      expect(media.key, 'requests/req-1/a.jpg');
      expect(media.contentType, 'image/png');
      expect(media.displayOrder, 2);
      expect(media.thumbnailUrl, 'https://cdn.example/thumb.jpg');
      expect(media.displayUrl, 'https://cdn.example/full.jpg');
    });

    test('applies defaults when optional fields are absent', () {
      final media = RequestMediaRef.fromJson({});

      expect(media.id, '');
      expect(media.key, '');
      expect(media.contentType, 'image/jpeg');
      expect(media.displayOrder, 0);
      expect(media.thumbnailUrl, isNull);
      expect(media.displayUrl, isNull);
    });

    test('serializes to JSON', () {
      const media = RequestMediaRef(
        id: 'med-2',
        key: 'k',
        contentType: 'image/jpeg',
        displayOrder: 1,
        displayUrl: 'https://cdn.example/x.jpg',
      );

      expect(media.toJson(), {
        'id': 'med-2',
        'key': 'k',
        'contentType': 'image/jpeg',
        'displayOrder': 1,
        'thumbnailUrl': null,
        'displayUrl': 'https://cdn.example/x.jpg',
      });
    });

    test('copyWith and value equality', () {
      const a = RequestMediaRef(id: '1', key: 'a', contentType: 'image/jpeg');
      const b = RequestMediaRef(id: '1', key: 'a', contentType: 'image/jpeg');
      final c = a.copyWith(key: 'b');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(c.key, 'b');
      expect(a.key, 'a');
      expect(a, isNot(equals(c)));
    });
  });
}
