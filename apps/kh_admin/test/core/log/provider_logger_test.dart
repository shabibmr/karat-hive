import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/log/kh_logger.dart';
import 'package:kh_admin/core/log/provider_logger.dart';

void main() {
  group('ProviderLogger', () {
    test('instantiates with default logger', () {
      const observer = ProviderLogger();
      expect(observer, isA<ProviderObserver>());
    });

    test('failing provider logs a redacted error line through KhLogger', () {
      final emitted = <String>[];
      final logger = KhLogger(output: emitted.add);
      final observer = ProviderLogger(logger: logger);

      final failingProvider = Provider<String>((ref) {
        throw Exception(
          'Failed fetching data for user test@example.com with Bearer secret-token-xyz-123',
        );
      });

      final container = ProviderContainer(observers: [observer]);
      addTearDown(container.dispose);

      expect(
        () => container.read(failingProvider),
        throwsA(isA<Exception>()),
      );

      expect(emitted, hasLength(1));
      final log = emitted.first;
      expect(log, startsWith('[ERROR]'));
      expect(log, contains('[REDACTED]'));
      expect(log, isNot(contains('test@example.com')));
      expect(log, isNot(contains('secret-token-xyz-123')));
      expect(log, isNot(contains('Bearer secret-token-xyz-123')));
    });

    test('failing named provider logs provider name and redacted details', () {
      final emitted = <String>[];
      final logger = KhLogger(output: emitted.add);
      final observer = ProviderLogger(logger: logger);

      final namedProvider = Provider<int>(
        (ref) => throw StateError('Vendor phone +1-555-123-4567 lookup error'),
        name: 'vendorLookupProvider',
      );

      final container = ProviderContainer(observers: [observer]);
      addTearDown(container.dispose);

      expect(
        () => container.read(namedProvider),
        throwsA(isA<StateError>()),
      );

      expect(emitted, hasLength(1));
      final log = emitted.first;
      expect(log, contains('vendorLookupProvider'));
      expect(log, contains('[REDACTED]'));
      expect(log, isNot(contains('+1-555-123-4567')));
    });
  });
}
