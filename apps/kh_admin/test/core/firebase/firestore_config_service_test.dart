import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/firebase/firestore_config_service.dart';

void main() {
  group('Admin FirestoreConfigService.parseApiBaseUrlForFlavor', () {
    test('extracts flat key e.g. api_base_url_dev', () {
      final data = {
        'api_base_url_dev': 'https://dev.algoray.cloud/kh_api',
        'api_base_url_prod': 'https://algoray.cloud/kh_api',
      };

      expect(
        FirestoreConfigService.parseApiBaseUrlForFlavor(data, 'dev'),
        equals('https://dev.algoray.cloud/kh_api'),
      );
      expect(
        FirestoreConfigService.parseApiBaseUrlForFlavor(data, 'prod'),
        equals('https://algoray.cloud/kh_api'),
      );
      expect(
        FirestoreConfigService.parseApiBaseUrlForFlavor(data, 'staging'),
        isNull,
      );
    });

    test('extracts nested flavor map or string', () {
      final data = {
        'dev': 'https://dev.algoray.cloud/kh_api',
        'prod': {'api_base_url': 'https://algoray.cloud/kh_api'},
      };

      expect(
        FirestoreConfigService.parseApiBaseUrlForFlavor(data, 'dev'),
        equals('https://dev.algoray.cloud/kh_api'),
      );
      expect(
        FirestoreConfigService.parseApiBaseUrlForFlavor(data, 'prod'),
        equals('https://algoray.cloud/kh_api'),
      );
    });

    test('falls back to global api_base_url when specific flavor is absent', () {
      final data = {
        'api_base_url': 'https://fallback.algoray.cloud/kh_api',
      };

      expect(
        FirestoreConfigService.parseApiBaseUrlForFlavor(data, 'dev'),
        equals('https://fallback.algoray.cloud/kh_api'),
      );
    });
  });
}
