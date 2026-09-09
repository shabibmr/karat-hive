import 'package:dio/dio.dart';
import 'package:kh_admin/core/api/api_exception.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// Default fallback message when account is locked and l10n is unavailable.
const String defaultAccountLockedMessage =
    'Your administrative account has been temporarily locked due to consecutive failed login attempts. Please wait 30 minutes or contact security.';

/// Default fallback message when credentials are invalid and l10n is unavailable.
const String defaultInvalidCredentialsMessage =
    'Invalid administrative credentials. Please check your email and password.';

/// Default fallback message when the server is unavailable and l10n is unavailable.
const String defaultServerUnavailableMessage =
    'Administrative service unavailable. Please check your connection and try again.';

/// Default fallback message when an unexpected error occurs and l10n is unavailable.
const String defaultUnknownErrorMessage =
    'An unexpected error occurred. Please try again.';

/// Resolves a localized error message for a known backend API error code string.
///
/// Returns null if the code is not recognized.
String? resolveApiErrorCodeMessage(String code, AppLocalizations? l10n) {
  final normalized = code.trim().toUpperCase();
  switch (normalized) {
    case 'ACCOUNT_LOCKED':
    case 'LOCKED':
      return l10n?.errorAccountLocked ?? defaultAccountLockedMessage;
    case 'UNAUTHENTICATED':
    case 'INVALID_CREDENTIALS':
    case 'UNAUTHORIZED':
      return l10n?.errorInvalidCredentials ?? defaultInvalidCredentialsMessage;
    case 'SERVICE_UNAVAILABLE':
    case 'CONNECTION_TIMEOUT':
    case 'NETWORK_ERROR':
    case 'TIMEOUT':
      return l10n?.errorServerUnavailable ?? defaultServerUnavailableMessage;
    default:
      return null;
  }
}

/// Resolves a localized error message for an HTTP status code.
///
/// Returns null if the status code is not mapped to a specific user-facing message.
String? resolveApiStatusCodeMessage(int statusCode, AppLocalizations? l10n) {
  if (statusCode == 423) {
    return l10n?.errorAccountLocked ?? defaultAccountLockedMessage;
  }
  if (statusCode == 401) {
    return l10n?.errorInvalidCredentials ?? defaultInvalidCredentialsMessage;
  }
  if (statusCode >= 500 && statusCode < 600) {
    return l10n?.errorServerUnavailable ?? defaultServerUnavailableMessage;
  }
  return null;
}

/// Pure helper function mapping exceptions and API errors to human-readable localized messages.
///
/// Maps [ApiException], [DioException], HTTP status codes (401, 423, 500..599),
/// error codes (`ACCOUNT_LOCKED`, `UNAUTHENTICATED`), and network timeouts.
/// Falls back to [AppLocalizations.errorUnknown] or [defaultUnknownErrorMessage].
String resolveApiErrorMessage(Object error, AppLocalizations? l10n) {
  if (error is ApiException) {
    final codeMsg = resolveApiErrorCodeMessage(error.code, l10n);
    if (codeMsg != null) {
      return codeMsg;
    }
    final statusMsg = resolveApiStatusCodeMessage(error.statusCode, l10n);
    if (statusMsg != null) {
      return statusMsg;
    }
    if (error.message.isNotEmpty) {
      return error.message;
    }
    return l10n?.errorUnknown ?? defaultUnknownErrorMessage;
  }

  if (error is DioException) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return l10n?.errorServerUnavailable ?? defaultServerUnavailableMessage;
    }

    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic> &&
        responseData['error'] is Map<String, dynamic>) {
      final err = responseData['error'] as Map<String, dynamic>;
      final code = err['code']?.toString();
      if (code != null) {
        final codeMsg = resolveApiErrorCodeMessage(code, l10n);
        if (codeMsg != null) {
          return codeMsg;
        }
      }
      final message = err['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    final statusCode = error.response?.statusCode;
    if (statusCode != null) {
      final statusMsg = resolveApiStatusCodeMessage(statusCode, l10n);
      if (statusMsg != null) {
        return statusMsg;
      }
    }
  }

  final errorString = error.toString().toLowerCase();
  if (errorString.contains('account_locked') || errorString.contains('locked')) {
    return l10n?.errorAccountLocked ?? defaultAccountLockedMessage;
  }
  if (errorString.contains('unauthenticated') ||
      errorString.contains('invalid credentials') ||
      errorString.contains('invalid_credentials')) {
    return l10n?.errorInvalidCredentials ?? defaultInvalidCredentialsMessage;
  }
  if (errorString.contains('unavailable') ||
      errorString.contains('connection') ||
      errorString.contains('timeout') ||
      errorString.contains('timed out') ||
      errorString.contains('time out') ||
      errorString.contains('network')) {
    return l10n?.errorServerUnavailable ?? defaultServerUnavailableMessage;
  }

  return l10n?.errorUnknown ?? defaultUnknownErrorMessage;
}
