import 'package:flutter_test/flutter_test.dart';
import 'package:kh_core/kh_core.dart';

void main() {
  group('Env.resolveUrl', () {
    const prod = Env(flavor: Flavor.prod, apiBaseUrl: 'https://algoray.cloud/kh_api');

    test('keeps the base path prefix for server-relative paths', () {
      expect(
        prod.resolveUrl('/v1/media/abc.thumb'),
        'https://algoray.cloud/kh_api/v1/media/abc.thumb',
      );
    });

    test('tolerates a trailing slash on the base URL', () {
      expect(
        prod.copyWith(apiBaseUrl: 'https://algoray.cloud/kh_api/').resolveUrl('/v1/media/a'),
        'https://algoray.cloud/kh_api/v1/media/a',
      );
    });

    test('works with a base URL that has no path', () {
      expect(
        prod.copyWith(apiBaseUrl: 'http://10.0.2.2:3000').resolveUrl('/v1/media/a'),
        'http://10.0.2.2:3000/v1/media/a',
      );
    });

    test('passes absolute URLs through and maps null/empty to null', () {
      expect(prod.resolveUrl('https://cdn.example/x.png'), 'https://cdn.example/x.png');
      expect(prod.resolveUrl('blob:http://localhost/1'), 'blob:http://localhost/1');
      expect(prod.resolveUrl(null), isNull);
      expect(prod.resolveUrl(''), isNull);
    });
  });
}
