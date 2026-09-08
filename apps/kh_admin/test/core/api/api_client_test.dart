import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/api/api_exception.dart';

void main() {
  late Dio dio;
  late ApiClient apiClient;
  bool refreshCalled = false;
  String? currentToken = 'initial-token';

  setUp(() {
    dio = Dio();
    refreshCalled = false;
    currentToken = 'initial-token';

    // Use an interceptor to mock responses directly in Dio
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path == '/v1/success') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': {'id': '123', 'name': 'Gold Bars'},
                  'meta': {'requestId': 'req-1', 'serverTime': '2026-09-04T00:00:00Z'},
                },
              ),
            );
          }

          if (options.path == '/v1/error') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 422,
                data: {
                  'error': {
                    'code': 'VALIDATION_FAILED',
                    'message': 'Name cannot be empty',
                    'details': [
                      {'path': 'nameEn', 'message': 'Required'},
                    ],
                  },
                  'meta': {'requestId': 'req-err'},
                },
              ),
            );
          }

          if (options.path == '/v1/collection') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': [
                    {'id': '1'},
                    {'id': '2'},
                  ],
                  'meta': {
                    'requestId': 'req-col',
                    'nextCursor': 'cursor-2',
                  },
                },
              ),
            );
          }

          if (options.path == '/v1/collection-legacy') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': {
                    'data': [
                      {'id': 'legacy-1'},
                    ],
                    'nextCursor': 'legacy-cursor',
                  },
                  'meta': {'nextCursor': null},
                },
              ),
            );
          }

          if (options.path == '/v1/protected') {
            final auth = options.headers['Authorization'] as String?;
            if (auth == 'Bearer refreshed-token') {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'data': {'secret': 'unlocked'},
                  },
                ),
              );
            }
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 401,
                data: {
                  'error': {
                    'code': 'UNAUTHENTICATED',
                    'message': 'Token expired',
                  },
                },
              ),
            );
          }

          return handler.next(options);
        },
      ),
    );

    apiClient = ApiClient(
      baseUrl: 'http://localhost:3000',
      dio: dio,
      tokenGetter: () async => currentToken,
      onUnauthorized: () async {
        refreshCalled = true;
        currentToken = 'refreshed-token';
        return true;
      },
    );
  });

  test('ApiClient unwraps { data, meta } success envelope', () async {
    final res = await apiClient.get('/v1/success');
    expect(res, isA<Map<String, dynamic>>());
    expect(res['id'], '123');
    expect(res['name'], 'Gold Bars');
  });

  test('ApiClient maps error envelope to typed ApiException', () async {
    try {
      await apiClient.get('/v1/error');
      fail('Should have thrown ApiException');
    } on ApiException catch (e) {
      expect(e.statusCode, 422);
      expect(e.code, 'VALIDATION_FAILED');
      expect(e.message, 'Name cannot be empty');
      expect(e.requestId, 'req-err');
      expect(e.details.length, 1);
    }
  });

  test('getCollection reads { data: [...], meta.nextCursor }', () async {
    final page = await apiClient.getCollection('/v1/collection');
    expect(page.items.map((e) => (e as Map)['id']), ['1', '2']);
    expect(page.meta?['nextCursor'], 'cursor-2');
  });

  test('getCollection falls back to the old double-wrapped list envelope', () async {
    final page = await apiClient.getCollection('/v1/collection-legacy');
    expect(page.items.map((e) => (e as Map)['id']), ['legacy-1']);
    expect(page.meta?['nextCursor'], 'legacy-cursor');
  });

  test('ApiClient triggers onUnauthorized and retries with refreshed token on 401',
      () async {
    final res = await apiClient.get('/v1/protected');
    expect(refreshCalled, isTrue);
    expect(res, isA<Map<String, dynamic>>());
    expect(res['secret'], 'unlocked');
  });
}
