import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/auth/session_controller.dart';
import 'package:kh_admin/core/auth/token_storage.dart';
import 'package:kh_admin/core/api/api_exception.dart';
import 'package:kh_admin/core/api/server_time_provider.dart';

/// Default base URL read from `--dart-define=KH_API_BASE`, defaulting to `http://localhost:3000`.
const String khApiBase = String.fromEnvironment(
  'KH_API_BASE',
  defaultValue: 'http://localhost:3000',
);

typedef TokenGetter = Future<String?> Function();
typedef RefreshHandler = Future<bool> Function();
typedef ServerTimeCallback = void Function(DateTime serverTime);

/// Typed API client wrapping Dio.
/// Handles `{ data, meta }` response unwrapping, bearer token injection,
/// single-flight 401 silent token refresh, and maps backend error envelopes to [ApiException].
class ApiClient {
  ApiClient({
    String baseUrl = khApiBase,
    Dio? dio,
    TokenGetter? tokenGetter,
    RefreshHandler? onUnauthorized,
    ServerTimeCallback? onServerTime,
  })  : _tokenGetter = tokenGetter,
        _onUnauthorized = onUnauthorized,
        _onServerTime = onServerTime,
        _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 25),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
      },
      validateStatus: (status) => true,
    );
  }

  final Dio _dio;
  final TokenGetter? _tokenGetter;
  final RefreshHandler? _onUnauthorized;
  final ServerTimeCallback? _onServerTime;

  DateTime? _latestServerTime;
  static DateTime? _staticLatestServerTime;

  Dio get rawDio => _dio;

  /// Returns the most recently captured server timestamp from response envelopes.
  DateTime? get latestServerTime => _latestServerTime;

  /// Returns the latest server timestamp captured across any [ApiClient] instance.
  static DateTime? get staticLatestServerTime => _staticLatestServerTime;

  /// Resets the static server time tracker (e.g. for testing).
  static void resetStaticServerTime() => _staticLatestServerTime = null;

  /// Records or updates the latest captured server time.
  void recordServerTime(DateTime serverTime) {
    _latestServerTime = serverTime;
    _staticLatestServerTime = serverTime;
    _onServerTime?.call(serverTime);
  }

  /// Performs a GET request and unwraps the `{ data }` payload.
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _send('GET', path, queryParameters: queryParameters, options: options);
  }

  /// Performs a POST request and unwraps the `{ data }` payload.
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _send(
      'POST',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Performs a PATCH request and unwraps the `{ data }` payload.
  Future<dynamic> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _send(
      'PATCH',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Performs a PUT request and unwraps the `{ data }` payload.
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _send(
      'PUT',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Performs a DELETE request and unwraps the `{ data }` payload.
  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _send(
      'DELETE',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// GET for cursor-paginated admin collections, preserving `meta.nextCursor`.
  Future<({List<dynamic> items, Map<String, dynamic>? meta})> getCollection(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final body = await _send(
      'GET',
      path,
      queryParameters: queryParameters,
      unwrapData: false,
    );

    if (body is List) {
      return (items: body, meta: null);
    }

    if (body is Map<String, dynamic>) {
      var data = body['data'];
      final meta = body['meta'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(body['meta'] as Map<String, dynamic>)
          : <String, dynamic>{};

      // Canonical admin list envelope: `{ data: [...], meta: { nextCursor } }`.
      // Fallback: pre-ADM-C-70 double-wrap `{ data: { data, nextCursor }, meta }`.
      if (data is Map<String, dynamic>) {
        if (data['nextCursor'] != null && meta['nextCursor'] == null) {
          meta['nextCursor'] = data['nextCursor'];
        }
        data = data['data'];
      }

      final items = data is List ? data : const <dynamic>[];
      return (items: items, meta: meta.isEmpty ? null : meta);
    }

    return (items: const <dynamic>[], meta: null);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool isRetry = false,
    bool unwrapData = true,
  }) async {
    final headers = Map<String, dynamic>.from(options?.headers ?? {});

    // Attach Bearer token if not already explicitly provided
    if (_tokenGetter != null && !headers.containsKey('Authorization')) {
      final token = await _tokenGetter();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final requestOptions = (options ?? Options()).copyWith(
      method: method,
      headers: headers,
    );

    Response<dynamic> response;
    try {
      response = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        response = e.response!;
      } else {
        throw ApiException(
          statusCode: 0,
          code: e.type == DioExceptionType.connectionTimeout
              ? 'CONNECTION_TIMEOUT'
              : 'NETWORK_ERROR',
          message: e.message ?? 'Network connection error',
        );
      }
    }

    _inspectServerTime(response.data);

    final status = response.statusCode ?? 0;

    // Handle 401 with silent one-shot refresh (except on auth endpoints)
    if (status == 401 && !isRetry && !path.startsWith('/v1/auth/')) {
      if (_onUnauthorized != null) {
        final refreshed = await _onUnauthorized();
        if (refreshed) {
          // Retry the request once with new token
          return _send(
            method,
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            isRetry: true,
          );
        }
      }
    }

    // Success range: 200..299
    if (status >= 200 && status < 300) {
      final body = response.data;
      if (!unwrapData) {
        return body;
      }
      if (body is Map<String, dynamic> && body.containsKey('data')) {
        return body['data'];
      }
      return body;
    }

    // Error response handling
    throw _parseErrorEnvelope(status, response.data);
  }

  void _inspectServerTime(dynamic body) {
    if (body is! Map) return;

    dynamic rawServerTime;
    final meta = body['meta'];
    if (meta is Map && meta['serverTime'] != null) {
      rawServerTime = meta['serverTime'];
    } else if (body['serverTime'] != null) {
      rawServerTime = body['serverTime'];
    } else if (body['meta.serverTime'] != null) {
      rawServerTime = body['meta.serverTime'];
    }

    if (rawServerTime == null) return;

    DateTime? parsed;
    if (rawServerTime is DateTime) {
      parsed = rawServerTime;
    } else {
      parsed = DateTime.tryParse(rawServerTime.toString());
    }

    if (parsed != null) {
      recordServerTime(parsed);
    }
  }

  ApiException _parseErrorEnvelope(int status, dynamic body) {
    if (body is Map<String, dynamic>) {
      final err = body['error'];
      final meta = body['meta'] as Map<String, dynamic>?;
      final requestId = meta?['requestId']?.toString();

      if (err is Map<String, dynamic>) {
        return ApiException(
          statusCode: status,
          code: err['code']?.toString() ?? 'HTTP_$status',
          message: err['message']?.toString() ?? 'Request failed ($status)',
          details: err['details'] is List ? err['details'] as List : const [],
          requestId: requestId,
        );
      }
    }

    return ApiException(
      statusCode: status,
      code: 'HTTP_$status',
      message: 'Request failed with status $status',
    );
  }
}

/// Provider for [ApiClient] wired with session tokens, silent 401 refresh handler,
/// and server timestamp sync.
final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiClient(
    // G2-A14: domain calls use the Karat Hive access token only.
    tokenGetter: () async {
      final session = ref.read(sessionControllerProvider);
      return session.tokens?.accessToken ?? await tokenStorage.getAccessToken();
    },
    onUnauthorized: () async {
      return ref.read(sessionControllerProvider.notifier).silentRefresh();
    },
    onServerTime: (serverTime) {
      ref.read(serverTimeProvider.notifier).state = serverTime;
    },
  );
});
