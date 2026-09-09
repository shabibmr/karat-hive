import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_exception.dart';
import 'package:kh_admin/core/error/api_error_messages.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

void main() {
  late AppLocalizations l10nEn;
  late AppLocalizations l10nAr;

  setUpAll(() {
    l10nEn = lookupAppLocalizations(const Locale('en'));
    l10nAr = lookupAppLocalizations(const Locale('ar'));
  });

  group('resolveApiErrorCodeMessage', () {
    test('resolves ACCOUNT_LOCKED and LOCKED', () {
      expect(
        resolveApiErrorCodeMessage('ACCOUNT_LOCKED', l10nEn),
        l10nEn.errorAccountLocked,
      );
      expect(
        resolveApiErrorCodeMessage('locked', l10nEn),
        l10nEn.errorAccountLocked,
      );
    });

    test('resolves UNAUTHENTICATED, INVALID_CREDENTIALS, and UNAUTHORIZED', () {
      expect(
        resolveApiErrorCodeMessage('UNAUTHENTICATED', l10nEn),
        l10nEn.errorInvalidCredentials,
      );
      expect(
        resolveApiErrorCodeMessage('invalid_credentials', l10nEn),
        l10nEn.errorInvalidCredentials,
      );
      expect(
        resolveApiErrorCodeMessage('UNAUTHORIZED', l10nEn),
        l10nEn.errorInvalidCredentials,
      );
    });

    test('resolves network and server error codes', () {
      expect(
        resolveApiErrorCodeMessage('SERVICE_UNAVAILABLE', l10nEn),
        l10nEn.errorServerUnavailable,
      );
      expect(
        resolveApiErrorCodeMessage('CONNECTION_TIMEOUT', l10nEn),
        l10nEn.errorServerUnavailable,
      );
      expect(
        resolveApiErrorCodeMessage('NETWORK_ERROR', l10nEn),
        l10nEn.errorServerUnavailable,
      );
      expect(
        resolveApiErrorCodeMessage('TIMEOUT', l10nEn),
        l10nEn.errorServerUnavailable,
      );
    });

    test('returns null for unknown error codes', () {
      expect(resolveApiErrorCodeMessage('CUSTOM_CODE', l10nEn), isNull);
      expect(resolveApiErrorCodeMessage('', l10nEn), isNull);
    });

    test('uses fallback string when l10n is null', () {
      expect(
        resolveApiErrorCodeMessage('ACCOUNT_LOCKED', null),
        defaultAccountLockedMessage,
      );
      expect(
        resolveApiErrorCodeMessage('UNAUTHENTICATED', null),
        defaultInvalidCredentialsMessage,
      );
      expect(
        resolveApiErrorCodeMessage('SERVICE_UNAVAILABLE', null),
        defaultServerUnavailableMessage,
      );
    });
  });

  group('resolveApiStatusCodeMessage', () {
    test('resolves 423 to account locked', () {
      expect(
        resolveApiStatusCodeMessage(423, l10nEn),
        l10nEn.errorAccountLocked,
      );
    });

    test('resolves 401 to invalid credentials', () {
      expect(
        resolveApiStatusCodeMessage(401, l10nEn),
        l10nEn.errorInvalidCredentials,
      );
    });

    test('resolves 500..599 to server unavailable', () {
      expect(
        resolveApiStatusCodeMessage(500, l10nEn),
        l10nEn.errorServerUnavailable,
      );
      expect(
        resolveApiStatusCodeMessage(502, l10nEn),
        l10nEn.errorServerUnavailable,
      );
      expect(
        resolveApiStatusCodeMessage(503, l10nEn),
        l10nEn.errorServerUnavailable,
      );
      expect(
        resolveApiStatusCodeMessage(599, l10nEn),
        l10nEn.errorServerUnavailable,
      );
    });

    test('returns null for unmapped status codes', () {
      expect(resolveApiStatusCodeMessage(200, l10nEn), isNull);
      expect(resolveApiStatusCodeMessage(400, l10nEn), isNull);
      expect(resolveApiStatusCodeMessage(404, l10nEn), isNull);
      expect(resolveApiStatusCodeMessage(422, l10nEn), isNull);
    });

    test('uses fallback string when l10n is null', () {
      expect(
        resolveApiStatusCodeMessage(423, null),
        defaultAccountLockedMessage,
      );
      expect(
        resolveApiStatusCodeMessage(401, null),
        defaultInvalidCredentialsMessage,
      );
      expect(
        resolveApiStatusCodeMessage(503, null),
        defaultServerUnavailableMessage,
      );
    });
  });

  group('resolveApiErrorMessage with ApiException', () {
    test('resolves ACCOUNT_LOCKED code and status 423', () {
      const error = ApiException(
        statusCode: 423,
        code: 'ACCOUNT_LOCKED',
        message: 'Account locked message from backend',
      );

      expect(resolveApiErrorMessage(error, l10nEn), l10nEn.errorAccountLocked);
      expect(resolveApiErrorMessage(error, null), defaultAccountLockedMessage);
    });

    test('resolves UNAUTHENTICATED code and status 401', () {
      const error = ApiException(
        statusCode: 401,
        code: 'UNAUTHENTICATED',
        message: 'Invalid credentials message from backend',
      );

      expect(
        resolveApiErrorMessage(error, l10nEn),
        l10nEn.errorInvalidCredentials,
      );
      expect(
        resolveApiErrorMessage(error, null),
        defaultInvalidCredentialsMessage,
      );
    });

    test('resolves status 503 to server unavailable', () {
      const error = ApiException(
        statusCode: 503,
        code: 'SERVICE_UNAVAILABLE',
        message: 'Server temporarily unavailable',
      );

      expect(
        resolveApiErrorMessage(error, l10nEn),
        l10nEn.errorServerUnavailable,
      );
      expect(
        resolveApiErrorMessage(error, null),
        defaultServerUnavailableMessage,
      );
    });

    test('resolves status 500 with unmapped code to server unavailable', () {
      const error = ApiException(
        statusCode: 500,
        code: 'INTERNAL_ERROR',
        message: 'Internal server error occurred',
      );

      expect(
        resolveApiErrorMessage(error, l10nEn),
        l10nEn.errorServerUnavailable,
      );
    });

    test('preserves custom message for unmapped codes/statuses', () {
      const error = ApiException(
        statusCode: 422,
        code: 'VALIDATION_FAILED',
        message: 'Admin email domain is not permitted.',
      );

      expect(
        resolveApiErrorMessage(error, l10nEn),
        'Admin email domain is not permitted.',
      );
    });

    test('falls back to errorUnknown when message is empty', () {
      const error = ApiException(
        statusCode: 400,
        code: 'UNKNOWN',
        message: '',
      );

      expect(resolveApiErrorMessage(error, l10nEn), l10nEn.errorUnknown);
      expect(resolveApiErrorMessage(error, null), defaultUnknownErrorMessage);
    });
  });

  group('resolveApiErrorMessage with DioException', () {
    final reqOptions = RequestOptions(path: '/v1/test');

    test('resolves connection timeouts to server unavailable', () {
      final error = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.connectionTimeout,
      );

      expect(
        resolveApiErrorMessage(error, l10nEn),
        l10nEn.errorServerUnavailable,
      );
      expect(
        resolveApiErrorMessage(error, null),
        defaultServerUnavailableMessage,
      );
    });

    test('resolves send and receive timeouts to server unavailable', () {
      final sendErr = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.sendTimeout,
      );
      final receiveErr = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.receiveTimeout,
      );

      expect(
        resolveApiErrorMessage(sendErr, l10nEn),
        l10nEn.errorServerUnavailable,
      );
      expect(
        resolveApiErrorMessage(receiveErr, l10nEn),
        l10nEn.errorServerUnavailable,
      );
    });

    test('resolves connection error to server unavailable', () {
      final error = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.connectionError,
      );

      expect(
        resolveApiErrorMessage(error, l10nEn),
        l10nEn.errorServerUnavailable,
      );
    });

    test('resolves response error body containing ACCOUNT_LOCKED', () {
      final error = DioException(
        requestOptions: reqOptions,
        response: Response(
          requestOptions: reqOptions,
          statusCode: 400,
          data: {
            'error': {'code': 'ACCOUNT_LOCKED', 'message': 'Account locked'},
          },
        ),
      );

      expect(resolveApiErrorMessage(error, l10nEn), l10nEn.errorAccountLocked);
    });

    test('resolves response error body containing UNAUTHENTICATED', () {
      final error = DioException(
        requestOptions: reqOptions,
        response: Response(
          requestOptions: reqOptions,
          statusCode: 400,
          data: {
            'error': {'code': 'UNAUTHENTICATED', 'message': 'Bad password'},
          },
        ),
      );

      expect(
        resolveApiErrorMessage(error, l10nEn),
        l10nEn.errorInvalidCredentials,
      );
    });

    test('extracts custom response message from error body', () {
      final error = DioException(
        requestOptions: reqOptions,
        response: Response(
          requestOptions: reqOptions,
          statusCode: 422,
          data: {
            'error': {'code': 'INVALID_TOKEN', 'message': 'Session expired'},
          },
        ),
      );

      expect(resolveApiErrorMessage(error, l10nEn), 'Session expired');
    });

    test('resolves status code from response when body lacks known code', () {
      final error401 = DioException(
        requestOptions: reqOptions,
        response: Response(
          requestOptions: reqOptions,
          statusCode: 401,
        ),
      );
      final error423 = DioException(
        requestOptions: reqOptions,
        response: Response(
          requestOptions: reqOptions,
          statusCode: 423,
        ),
      );
      final error502 = DioException(
        requestOptions: reqOptions,
        response: Response(
          requestOptions: reqOptions,
          statusCode: 502,
        ),
      );

      expect(
        resolveApiErrorMessage(error401, l10nEn),
        l10nEn.errorInvalidCredentials,
      );
      expect(
        resolveApiErrorMessage(error423, l10nEn),
        l10nEn.errorAccountLocked,
      );
      expect(
        resolveApiErrorMessage(error502, l10nEn),
        l10nEn.errorServerUnavailable,
      );
    });
  });

  group('resolveApiErrorMessage with String and generic exceptions', () {
    test('resolves strings containing locked keywords', () {
      expect(
        resolveApiErrorMessage('account_locked', l10nEn),
        l10nEn.errorAccountLocked,
      );
      expect(
        resolveApiErrorMessage(
          Exception('User is currently locked out'),
          l10nEn,
        ),
        l10nEn.errorAccountLocked,
      );
    });

    test('resolves strings containing authentication keywords', () {
      expect(
        resolveApiErrorMessage('unauthenticated error', l10nEn),
        l10nEn.errorInvalidCredentials,
      );
      expect(
        resolveApiErrorMessage('invalid credentials provided', l10nEn),
        l10nEn.errorInvalidCredentials,
      );
    });

    test('resolves strings containing network or unavailable keywords', () {
      expect(
        resolveApiErrorMessage('Service unavailable', l10nEn),
        l10nEn.errorServerUnavailable,
      );
      expect(
        resolveApiErrorMessage('connection reset by peer', l10nEn),
        l10nEn.errorServerUnavailable,
      );
      expect(
        resolveApiErrorMessage('request timed out', l10nEn),
        l10nEn.errorServerUnavailable,
      );
    });

    test('falls back to errorUnknown for unrecognized errors', () {
      expect(
        resolveApiErrorMessage(Exception('unexpected random error'), l10nEn),
        l10nEn.errorUnknown,
      );
      expect(
        resolveApiErrorMessage(12345, null),
        defaultUnknownErrorMessage,
      );
    });
  });

  group('Arabic localization support', () {
    test('returns Arabic translation for errorAccountLocked', () {
      const error = ApiException(
        statusCode: 423,
        code: 'ACCOUNT_LOCKED',
        message: 'Account locked',
      );
      expect(resolveApiErrorMessage(error, l10nAr), l10nAr.errorAccountLocked);
    });

    test('returns Arabic translation for errorInvalidCredentials', () {
      const error = ApiException(
        statusCode: 401,
        code: 'UNAUTHENTICATED',
        message: 'Invalid credentials',
      );
      expect(
        resolveApiErrorMessage(error, l10nAr),
        l10nAr.errorInvalidCredentials,
      );
    });

    test('returns Arabic translation for errorServerUnavailable', () {
      const error = ApiException(
        statusCode: 503,
        code: 'SERVICE_UNAVAILABLE',
        message: 'Unavailable',
      );
      expect(
        resolveApiErrorMessage(error, l10nAr),
        l10nAr.errorServerUnavailable,
      );
    });
  });
}
