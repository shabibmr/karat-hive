import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

import 'clock.dart';
import 'failure.dart';
import 'result.dart';
import 'token_storage.dart';

typedef TokenGetter = Future<String?> Function();
typedef TokenRefreshHandler = Future<bool> Function();
typedef RefreshCallback = Future<SessionTokens?> Function(String refreshToken);

/// Dio wrapper implementing the interceptor chain from Architecture-Frontend §9.2:
/// correlation id, bearer auth + single-flight refresh, locale, idempotency key,
/// server-time sync, and envelope → [Failure] mapping.
class KhApiClient {
  KhApiClient({
    required String baseUrl,
    required this.tokenStorage,
    required this.serverClock,
    this.localeCode = 'en',
    RefreshCallback? onRefresh,
    TokenGetter? tokenGetter,
    TokenRefreshHandler? onTokenRefresh,
    Dio? dio,
  })  : _onRefresh = onRefresh,
        _tokenGetter = tokenGetter,
        _onTokenRefresh = onTokenRefresh,
        dio = dio ?? Dio() {
    this.dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 20)
      ..validateStatus = (_) => true;
    this.dio.interceptors.add(_ChainInterceptor(this));
  }

  final Dio dio;
  final TokenStorage tokenStorage;
  final ServerClock serverClock;
  String localeCode;
  final RefreshCallback? _onRefresh;
  final TokenGetter? _tokenGetter;
  final TokenRefreshHandler? _onTokenRefresh;

  Future<void>? _refreshing;

  /// Returns the current active token, prioritizing [tokenGetter] (e.g. Firebase ID token)
  /// before falling back to [tokenStorage] (session tokens).
  Future<String?> getActiveToken() async {
    if (_tokenGetter != null) {
      final token = await _tokenGetter();
      if (token != null && token.isNotEmpty) return token;
    }
    final tokens = await tokenStorage.read();
    return tokens?.accessToken;
  }

  /// GET/POST/PATCH/PUT/DELETE returning the unwrapped `data` payload or a [Failure].
  Future<Result<dynamic>> send(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool revealAuth = true,
    bool unwrapData = true,
  }) async {
    try {
      final response = await dio.request<dynamic>(
        path,
        data: body,
        queryParameters: query,
        options: Options(method: method, extra: {'kh.revealAuth': revealAuth}),
      );
      return _mapResponse(response, unwrapData: unwrapData);
    } on DioException catch (e) {
      return Err(_mapDioError(e));
    }
  }

  Result<dynamic> _mapResponse(Response<dynamic> response, {bool unwrapData = true}) {
    final status = response.statusCode ?? 0;
    final data = response.data;
    if (status >= 200 && status < 300) {
      if (unwrapData && data is Map && data.containsKey('data')) {
        return Ok(data['data']);
      }
      return Ok(data);
    }
    return Err(_mapEnvelopeError(status, data));
  }

  Failure _mapEnvelopeError(int status, dynamic data) {
    String? code;
    String? message;
    final fieldErrors = <String, String>{};
    if (data is Map && data['error'] is Map) {
      final err = data['error'] as Map;
      code = err['code'] as String?;
      message = err['message'] as String?;
      for (final d in (err['details'] as List? ?? const [])) {
        if (d is Map && d['path'] != null) {
          fieldErrors[d['path'].toString()] = (d['message'] ?? '').toString();
        }
      }
    }
    return switch (status) {
      401 => UnauthorisedFailure(code: code, message: message),
      403 => ForbiddenFailure(code: code, message: message),
      404 => NotFoundFailure(code: code, message: message),
      409 => ConflictFailure(code: code, message: message),
      422 || 400 => ValidationFailure(code: code, message: message, fieldErrors: fieldErrors),
      423 || 429 => RateLimitedFailure(code: code, message: message),
      503 => const MaintenanceFailure(),
      _ => ServerFailure(code: code, message: message),
    };
  }

  Failure _mapDioError(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const TimeoutFailure(),
      DioExceptionType.connectionError => const NetworkFailure(),
      _ => e.response != null
          ? _mapEnvelopeError(e.response!.statusCode ?? 500, e.response!.data)
          : const NetworkFailure(),
    };
  }

  Future<bool> _tryRefresh() async {
    if (_onTokenRefresh != null) {
      return _onTokenRefresh();
    }
    final cb = _onRefresh;
    if (cb == null) return false;
    _refreshing ??= () async {
      final current = await tokenStorage.read();
      if (current == null) return;
      final next = await cb(current.refreshToken);
      if (next != null) await tokenStorage.save(next);
    }()
        .whenComplete(() => _refreshing = null);
    await _refreshing;
    return (await tokenStorage.read()) != null;
  }
}

class _ChainInterceptor extends Interceptor {
  _ChainInterceptor(this._client);
  final KhApiClient _client;
  final _rand = Random();

  bool _isMutating(String method) =>
      const {'POST', 'PATCH', 'PUT', 'DELETE'}.contains(method.toUpperCase());

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['x-request-id'] = _uuid();
    options.headers['accept-language'] = _client.localeCode;
    if (_isMutating(options.method)) {
      options.headers.putIfAbsent('idempotency-key', _uuid);
    }
    final token = await _client.getActiveToken();
    if (token != null && token.isNotEmpty) {
      options.headers['authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final data = response.data;
    if (data is Map && data['meta'] is Map && data['meta']['serverTime'] != null) {
      final t = DateTime.tryParse(data['meta']['serverTime'].toString());
      if (t != null) _client.serverClock.syncFrom(t.toUtc());
    }
    handler.next(response);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final res = err.response;
    final alreadyRetried = err.requestOptions.extra['kh.retried'] == true;
    if (res?.statusCode == 401 && !alreadyRetried) {
      final ok = await _client._tryRefresh();
      if (ok) {
        final opts = err.requestOptions;
        opts.extra['kh.retried'] = true;
        final token = await _client.getActiveToken();
        if (token != null && token.isNotEmpty) {
          opts.headers['authorization'] = 'Bearer $token';
        }
        try {
          final retry = await _client.dio.fetch<dynamic>(opts);
          return handler.resolve(retry);
        } on DioException catch (e) {
          return handler.next(e);
        }
      }
    }
    handler.next(err);
  }

  String _uuid() {
    final bytes = List<int>.generate(16, (_) => _rand.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
