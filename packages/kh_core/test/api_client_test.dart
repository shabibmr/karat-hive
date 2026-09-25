import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_core/kh_core.dart';

class MockHttpAdapter implements HttpClientAdapter {
  MockHttpAdapter(this.handler);
  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      handler(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(Object data, {int status = 200}) =>
    ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

class MemoryTokenStorage implements TokenStorage {
  SessionTokens? _tokens;
  @override
  Future<SessionTokens?> read() async => _tokens;
  @override
  Future<void> save(SessionTokens tokens) async => _tokens = tokens;
  @override
  Future<void> clear() async => _tokens = null;
}

void main() {
  late MemoryTokenStorage tokens;
  late ServerClock clock;

  setUp(() {
    tokens = MemoryTokenStorage();
    clock = ServerClock();
  });

  KhApiClient createClient(
    Future<ResponseBody> Function(RequestOptions options) handler, {
    RefreshCallback? onRefresh,
  }) {
    final dio = Dio();
    dio.httpClientAdapter = MockHttpAdapter(handler);
    return KhApiClient(
      baseUrl: 'https://api.test',
      tokenStorage: tokens,
      serverClock: clock,
      dio: dio,
      onRefresh: onRefresh,
    );
  }

  test('401 on regular endpoint refreshes token and retries successfully', () async {
    await tokens.save(
      SessionTokens(
        accessToken: 'expired-access',
        refreshToken: 'valid-refresh',
        accessExpiresAt: DateTime.now().add(const Duration(hours: 1)),
        refreshExpiresAt: DateTime.now().add(const Duration(days: 7)),
      ),
    );

    var calls = 0;
    var refreshCalled = false;
    late KhApiClient client;

    client = createClient(
      (opts) async {
        calls++;
        if (opts.path == '/v1/customer/requests/1/publish') {
          if (opts.headers['authorization'] == 'Bearer expired-access') {
            return jsonBody(
              {
                'error': {
                  'code': 'UNAUTHENTICATED',
                  'message': 'Sign in to continue.',
                },
                'meta': {'requestId': 'r1', 'serverTime': '2026-09-25T16:35:57.774Z'},
              },
              status: 401,
            );
          }
          if (opts.headers['authorization'] == 'Bearer fresh-access') {
            return jsonBody({
              'data': {'id': '1', 'state': 'PUBLISHED'},
              'meta': {'requestId': 'r2'},
            });
          }
        }
        throw UnimplementedError(opts.path);
      },
      onRefresh: (rt) async {
        refreshCalled = true;
        expect(rt, 'valid-refresh');
        return SessionTokens(
          accessToken: 'fresh-access',
          refreshToken: 'fresh-refresh',
          accessExpiresAt: DateTime.now().add(const Duration(hours: 1)),
          refreshExpiresAt: DateTime.now().add(const Duration(days: 7)),
        );
      },
    );

    final res = await client.send('POST', '/v1/customer/requests/1/publish');
    expect(res.isOk, isTrue);
    expect(refreshCalled, isTrue);
    expect(calls, 2);
    expect((await tokens.read())?.accessToken, 'fresh-access');
  });

  test('401 on /v1/auth/refresh does not deadlock and clears token storage', () async {
    await tokens.save(
      SessionTokens(
        accessToken: 'expired-access',
        refreshToken: 'expired-refresh',
        accessExpiresAt: DateTime.now().add(const Duration(hours: 1)),
        refreshExpiresAt: DateTime.now().add(const Duration(days: 7)),
      ),
    );

    var refreshAttempts = 0;
    late KhApiClient client;

    client = createClient(
      (opts) async {
        if (opts.path == '/v1/auth/refresh') {
          refreshAttempts++;
          return jsonBody(
            {
              'error': {
                'code': 'UNAUTHENTICATED',
                'message': 'Sign in to continue.',
              },
              'meta': {'requestId': 'r-refresh'},
            },
            status: 401,
          );
        }
        if (opts.path == '/v1/customer/requests/1/publish') {
          return jsonBody(
            {
              'error': {
                'code': 'UNAUTHENTICATED',
                'message': 'Sign in to continue.',
              },
              'meta': {'requestId': 'r-publish'},
            },
            status: 401,
          );
        }
        throw UnimplementedError(opts.path);
      },
      onRefresh: (rt) async {
        // Calling client.send for refresh as KhApi does:
        final r = await client.send('POST', '/v1/auth/refresh', body: {'refreshToken': rt});
        return r.when(
          ok: (data) {
            final map = data as Map<String, dynamic>;
            return SessionTokens(
              accessToken: map['accessToken'] as String,
              refreshToken: map['refreshToken'] as String,
              accessExpiresAt: DateTime.parse(map['accessExpiresAt'] as String),
              refreshExpiresAt: DateTime.parse(map['refreshExpiresAt'] as String),
            );
          },
          err: (_) => null,
        );
      },
    );

    // This should NOT hang / deadlock, but return UnauthorisedFailure
    final res = await client.send('POST', '/v1/customer/requests/1/publish');
    expect(res.isErr, isTrue);
    expect(res.failureOrNull, isA<UnauthorisedFailure>());
    expect(refreshAttempts, 1);
    expect(await tokens.read(), isNull);
  });
}
