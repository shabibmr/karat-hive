import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/api/server_time_provider.dart';

void main() {
  group('serverTimeProvider', () {
    test('initial state is null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(serverTimeProvider), isNull);
    });

    test('can be updated and emits new value to listeners', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final emissions = <DateTime?>[];
      container.listen(
        serverTimeProvider,
        (previous, next) => emissions.add(next),
        fireImmediately: true,
      );

      expect(emissions, [isNull]);

      final time = DateTime.utc(2026, 9, 9, 10, 0, 0);
      container.read(serverTimeProvider.notifier).state = time;

      expect(emissions, [isNull, time]);
      expect(container.read(serverTimeProvider), equals(time));
    });

    test('apiClientProvider synchronizes serverTimeProvider when response received', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': {'id': 'test-1'},
                  'meta': {
                    'serverTime': '2026-09-09T05:30:00.000Z',
                  },
                },
              ),
            );
          },
        ),
      );

      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWith((ref) {
            return ApiClient(
              baseUrl: 'http://localhost:3000',
              dio: dio,
              onServerTime: (serverTime) {
                ref.read(serverTimeProvider.notifier).state = serverTime;
              },
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(serverTimeProvider), isNull);

      final client = container.read(apiClientProvider);
      await client.get('/v1/test');

      expect(
        container.read(serverTimeProvider),
        equals(DateTime.parse('2026-09-09T05:30:00.000Z')),
      );
      expect(
        client.latestServerTime,
        equals(DateTime.parse('2026-09-09T05:30:00.000Z')),
      );
    });
  });
}
