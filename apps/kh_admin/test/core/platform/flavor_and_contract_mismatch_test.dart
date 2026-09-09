import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/api/api_exception.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/platform/flavor.dart';
import 'package:kh_admin/features/contract_version/presentation/contract_mismatch_screen.dart';

void main() {
  group('FlavorConfig (TR-S4-15, TR-S4-16)', () {
    test('parses flavor strings correctly', () {
      expect(AppFlavor.fromString('dev'), AppFlavor.dev);
      expect(AppFlavor.fromString('development'), AppFlavor.dev);
      expect(AppFlavor.fromString('staging'), AppFlavor.staging);
      expect(AppFlavor.fromString('prod'), AppFlavor.prod);
      expect(AppFlavor.fromString('production'), AppFlavor.prod);
      expect(AppFlavor.fromString(null), AppFlavor.dev);
      expect(AppFlavor.fromString('unknown'), AppFlavor.dev);
    });

    test('dev and staging allow non-https base URLs', () {
      const devConfig = FlavorConfig(
        flavor: AppFlavor.dev,
        apiBaseUrl: 'http://localhost:3000',
      );
      expect(() => devConfig.validate(), returnsNormally);

      const stagingConfig = FlavorConfig(
        flavor: AppFlavor.staging,
        apiBaseUrl: 'http://staging-internal:3000',
      );
      expect(() => stagingConfig.validate(), returnsNormally);
    });

    test('prod rejects non-HTTPS base with clear StateError (TR-S4-16)', () {
      const insecureProd = FlavorConfig(
        flavor: AppFlavor.prod,
        apiBaseUrl: 'http://api.karathive.ae',
      );

      expect(
        () => insecureProd.validate(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Production environment requires a secure HTTPS apiBaseUrl'),
          ),
        ),
      );
    });

    test('prod accepts secure HTTPS base URL', () {
      const secureProd = FlavorConfig(
        flavor: AppFlavor.prod,
        apiBaseUrl: 'https://api.karathive.ae',
      );
      expect(() => secureProd.validate(), returnsNormally);
    });
  });

  group('Contract Mismatch / HTTP 426 (TR-S4-17)', () {
    test('ApiClient triggers onContractMismatch on HTTP 426', () async {
      final dio = Dio();
      dio.httpClientAdapter = _Mock426Adapter();

      bool contractMismatchTriggered = false;
      final client = ApiClient(
        dio: dio,
        baseUrl: 'https://test.karathive.ae',
        onContractMismatch: () {
          contractMismatchTriggered = true;
        },
      );

      await expectLater(
        client.get('/v1/test'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 426),
        ),
      );

      expect(contractMismatchTriggered, isTrue);
    });

    testWidgets('ContractMismatchScreen renders upgrade required details and reload action',
        (tester) async {
      bool reloadClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildKhAdminTheme(),
          home: ContractMismatchScreen(
            onReload: () {
              reloadClicked = true;
            },
          ),
        ),
      );

      expect(find.text('Portal Upgrade Required'), findsOneWidget);
      expect(find.text('HTTP 426 — Contract Version Mismatch'), findsOneWidget);
      expect(find.byKey(const Key('contract-mismatch-reload-button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('contract-mismatch-reload-button')));
      await tester.pump();

      expect(reloadClicked, isTrue);
    });
  });
}

class _Mock426Adapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"error":{"code":"CONTRACT_VERSION_MISMATCH","message":"Upgrade required"}}',
      426,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
