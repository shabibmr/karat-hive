import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/log/kh_logger.dart';
import 'package:kh_admin/core/log/kh_logger_provider.dart';

void main() {
  group('KhLogger', () {
    test(
      'logging a message with an email address (test@example.com) and Bearer token (Bearer abc123def456) emits neither verbatim, but replaces them with [REDACTED]',
      () {
        final emitted = <String>[];
        final logger = KhLogger(output: emitted.add);

        logger.info('User test@example.com authenticated with Bearer abc123def456');

        expect(emitted, hasLength(1));
        final log = emitted.first;
        expect(log, isNot(contains('test@example.com')));
        expect(log, isNot(contains('abc123def456')));
        expect(log, isNot(contains('Bearer abc123def456')));
        expect(log, contains('[REDACTED]'));
      },
    );

    test('redacts Authorization header values', () {
      final emitted = <String>[];
      final logger = KhLogger(output: emitted.add);

      logger.debug('Authorization: Bearer secret-jwt-payload');
      logger.debug('authorization: Basic my-super-secret-key');
      logger.debug('Authorization: token-without-scheme');

      expect(emitted[0], isNot(contains('secret-jwt-payload')));
      expect(emitted[0], contains('Authorization: Bearer [REDACTED]'));
      expect(emitted[1], isNot(contains('my-super-secret-key')));
      expect(emitted[1], contains('authorization: Basic [REDACTED]'));
      expect(emitted[2], isNot(contains('token-without-scheme')));
      expect(emitted[2], contains('Authorization: [REDACTED]'));
    });

    test('redacts phone and mobile numbers across common formats', () {
      final emitted = <String>[];
      final logger = KhLogger(output: emitted.add);

      logger.warning('Call +1-555-123-4567 or 9876543210 or (555) 123-4567');

      final log = emitted.first;
      expect(log, isNot(contains('+1-555-123-4567')));
      expect(log, isNot(contains('9876543210')));
      expect(log, isNot(contains('(555) 123-4567')));
      expect(log, contains('[REDACTED]'));
    });

    test('supports all log levels (debug, info, warning, error)', () {
      final emitted = <String>[];
      final logger = KhLogger(output: emitted.add);

      logger.debug('debug message');
      logger.info('info message');
      logger.warning('warning message');
      logger.error('error message');

      expect(emitted[0], startsWith('[DEBUG] debug message'));
      expect(emitted[1], startsWith('[INFO] info message'));
      expect(emitted[2], startsWith('[WARNING] warning message'));
      expect(emitted[3], startsWith('[ERROR] error message'));
    });

    test('redacts sensitive data inside error objects and stack traces', () {
      final emitted = <String>[];
      final logger = KhLogger(output: emitted.add);

      logger.error(
        'Login failed',
        Exception('Failed to authenticate test@example.com with Bearer token999'),
      );

      final log = emitted.first;
      expect(log, isNot(contains('test@example.com')));
      expect(log, isNot(contains('token999')));
      expect(log, isNot(contains('Bearer token999')));
      expect(log, contains('[REDACTED]'));
    });

    test('does not redact normal non-PII text, timestamps, or identifiers', () {
      final emitted = <String>[];
      final logger = KhLogger(output: emitted.add);

      logger.info('Synced item order_99 at 2026-09-09T05:51:48Z with status 200');

      final log = emitted.first;
      expect(log, contains('order_99'));
      expect(log, contains('2026-09-09T05:51:48Z'));
      expect(log, contains('status 200'));
    });

    test('KhLogger.redact redacts PII and tokens directly', () {
      final redacted = KhLogger.redact(
        'Contact test@example.com or +919876543210 using Bearer myToken',
      );
      expect(redacted, isNot(contains('test@example.com')));
      expect(redacted, isNot(contains('+919876543210')));
      expect(redacted, isNot(contains('myToken')));
      expect(redacted, contains('[REDACTED]'));
    });

    test('khLoggerProvider supplies a KhLogger instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final logger = container.read(khLoggerProvider);
      expect(logger, isA<KhLogger>());
    });
  });
}
