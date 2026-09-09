import 'package:flutter/foundation.dart';

/// Callback signature for log output destinations.
typedef KhLogOutput = void Function(String message);

/// Redacting logger for Karat Hive Admin.
///
/// Automatically redacts Bearer tokens, Authorization header values,
/// email addresses, and phone/mobile numbers before emitting log entries.
class KhLogger {
  const KhLogger({KhLogOutput? output}) : _output = output;

  final KhLogOutput? _output;

  /// Log a debug-level message.
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _log('DEBUG', message, error, stackTrace);
  }

  /// Log an info-level message.
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _log('INFO', message, error, stackTrace);
  }

  /// Log a warning-level message.
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log('WARNING', message, error, stackTrace);
  }

  /// Log an error-level message.
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message, error, stackTrace);
  }

  void _emit(String message) {
    final out = _output;
    if (out != null) {
      out(message);
    } else {
      debugPrint(message);
    }
  }

  void _log(String level, String message, Object? error, StackTrace? stackTrace) {
    final buffer = StringBuffer('[$level] $message');
    if (error != null) {
      buffer.write(' | Error: $error');
    }
    if (stackTrace != null) {
      buffer.write('\n$stackTrace');
    }
    final redacted = redact(buffer.toString());
    _emit(redacted);
  }

  /// Redacts Bearer tokens, Authorization header values, email addresses,
  /// and phone numbers from [input], replacing them with `[REDACTED]`.
  static String redact(String input) {
    if (input.isEmpty) return input;
    var sanitized = input;

    // 1. Authorization header values
    sanitized = sanitized.replaceAllMapped(_authHeaderRegex, (match) {
      return '${match.group(1)}[REDACTED]';
    });

    // 2. Standalone Bearer tokens
    sanitized = sanitized.replaceAllMapped(_bearerTokenRegex, (match) {
      return '${match.group(1)}[REDACTED]';
    });

    // 3. Other token parameters (e.g. access_token=xyz, idToken: xyz)
    sanitized = sanitized.replaceAllMapped(_tokenParamRegex, (match) {
      return '${match.group(1)}[REDACTED]';
    });

    // 4. Email addresses
    sanitized = sanitized.replaceAll(_emailRegex, '[REDACTED]');

    // 5. Phone numbers
    sanitized = sanitized.replaceAll(_intlPhoneRegex, '[REDACTED]');
    sanitized = sanitized.replaceAll(_usParenPhoneRegex, '[REDACTED]');
    sanitized = sanitized.replaceAll(_separatedPhoneRegex, '[REDACTED]');
    sanitized = sanitized.replaceAll(_tenDigitPhoneRegex, '[REDACTED]');
    sanitized = sanitized.replaceAll(_splitMobileRegex, '[REDACTED]');
    sanitized = sanitized.replaceAllMapped(_prefixedPhoneRegex, (match) {
      return '${match.group(1)}[REDACTED]';
    });

    return sanitized;
  }

  // Matches "Authorization: Bearer xyz", "Authorization: Basic xyz", or "Authorization: xyz"
  static final RegExp _authHeaderRegex = RegExp(
    r'''\b(authorization\s*[:=]\s*(?:[A-Za-z]+\s+)?)(?!\[REDACTED\])[^\s,;"']+''',
    caseSensitive: false,
  );

  // Matches "Bearer <token>"
  static final RegExp _bearerTokenRegex = RegExp(
    r'''\b(Bearer\s+)(?!\[REDACTED\])[^\s,;"']+''',
    caseSensitive: false,
  );

  // Matches token field assignments e.g. access_token: xyz, idToken=xyz
  static final RegExp _tokenParamRegex = RegExp(
    r'''\b((?:access_token|refresh_token|id_token|idToken|auth_token)\s*[:=]\s*["']?)(?!\[REDACTED\])[^\s,;"'}]+''',
    caseSensitive: false,
  );

  // Matches email addresses
  static final RegExp _emailRegex = RegExp(
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b',
  );

  // Matches international phone numbers starting with +, e.g. +1-555-123-4567, +919876543210
  static final RegExp _intlPhoneRegex = RegExp(
    r'\+(?:[0-9][-.\s()]?){9,14}[0-9]\b',
  );

  // Matches US/standard format with parentheses, e.g. (555) 123-4567
  static final RegExp _usParenPhoneRegex = RegExp(
    r'(?<!\w)\(\d{3}\)[-.\s]?\d{3}[-.\s]?\d{4}\b',
  );

  // Matches separated 10-digit numbers, e.g. 555-123-4567, 555.123.4567, 555 123 4567
  static final RegExp _separatedPhoneRegex = RegExp(
    r'(?<!\w)\d{3}[-.\s]\d{3}[-.\s]\d{4}\b',
  );

  // Matches 10-digit mobile numbers starting with 6, 7, 8, or 9 (common in India/Asia), e.g. 9876543210
  static final RegExp _tenDigitPhoneRegex = RegExp(
    r'(?<!\w)[6-9]\d{9}\b',
  );

  // Matches 5-5 split mobile numbers, e.g. 98765 43210, 98765-43210
  static final RegExp _splitMobileRegex = RegExp(
    r'(?<!\w)[6-9]\d{4}[-\s]\d{5}\b',
  );

  // Matches prefixed phone / mobile numbers, e.g. "phone: +12345678", "mobile: 9876543210"
  static final RegExp _prefixedPhoneRegex = RegExp(
    r'\b((?:phone|mobile|tel|cell)(?:\s*(?:number|no)?\s*[:=]\s*|\s+))(\+?[0-9\s\-().]{7,15})\b',
    caseSensitive: false,
  );
}
