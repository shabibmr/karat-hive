import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/api/api_exception.dart';
import 'package:kh_admin/features/settings/model/platform_setting_item.dart';
import 'package:kh_admin/features/settings/repository/platform_settings_repository.dart';

void main() {
  Map<String, dynamic> rawSettingRow({
    required String key,
    required dynamic value,
    required String dataType,
    String? description,
    Map<String, dynamic>? allowedRange,
    bool requiresSuperAdmin = false,
    String? lastChangedByAdminId,
    String? updatedAt,
  }) {
    return {
      'key': key,
      'value': value,
      'dataType': dataType,
      'description': description,
      'allowedRange': allowedRange,
      'requiresSuperAdmin': requiresSuperAdmin,
      'lastChangedByAdminId': lastChangedByAdminId,
      'updatedAt': updatedAt ?? '2026-09-01T10:00:00.000Z',
    };
  }

  ApiClient buildMockClient({
    void Function(RequestOptions)? onPatch,
    int patchStatusCode = 200,
    dynamic patchResponseData,
  }) {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final path = options.path;

          if (path == '/v1/admin/settings') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': [
                    rawSettingRow(
                      key: 'request.lifetime_hours',
                      value: 48,
                      dataType: 'number',
                      description: 'Request lifetime in hours before expiration.',
                      allowedRange: {'min': 1, 'max': 168},
                    ),
                    rawSettingRow(
                      key: 'offer.validity_hours_options',
                      value: [12, 24, 48],
                      dataType: 'number[]',
                      description: 'Discrete validity options for offers.',
                    ),
                    rawSettingRow(
                      key: 'offer.default_validity_hours',
                      value: 24,
                      dataType: 'number',
                      description: 'Default validity for offers in hours.',
                    ),
                    rawSettingRow(
                      key: 'bullion.minimum_value_aed',
                      value: 500,
                      dataType: 'money',
                      allowedRange: {'min': 100},
                    ),
                    rawSettingRow(
                      key: 'media.image.max_bytes',
                      value: 5242880,
                      dataType: 'number',
                      allowedRange: {'min': 1024, 'max': 20971520},
                    ),
                    rawSettingRow(
                      key: 'goldRates.endUserDisplay',
                      value: false,
                      dataType: 'boolean',
                      requiresSuperAdmin: true,
                    ),
                  ],
                },
              ),
            );
          }

          if (path.startsWith('/v1/admin/settings/')) {
            onPatch?.call(options);
            if (patchStatusCode >= 400) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: patchStatusCode,
                  data: patchResponseData ??
                      {
                        'error': {
                          'code': 'SETTING_OUT_OF_RANGE',
                          'message': 'Value is outside allowed range.',
                        }
                      },
                ),
              );
            }
            final key = path.substring('/v1/admin/settings/'.length);
            final reqData = options.data as Map<String, dynamic>?;
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': rawSettingRow(
                    key: key,
                    value: reqData?['value'],
                    dataType: 'number',
                  ),
                },
              ),
            );
          }

          return handler.next(options);
        },
      ),
    );
    return ApiClient(dio: dio);
  }

  group('PlatformSettingsRepository', () {
    test('fetches settings and parses items, ranges, and categories correctly',
        () async {
      final client = buildMockClient();
      final repository = PlatformSettingsRepository(client);

      final settings = await repository.fetchSettings();

      expect(settings.length, 6);

      final lifetime =
          settings.firstWhere((s) => s.key == 'request.lifetime_hours');
      expect(lifetime.value, 48);
      expect(lifetime.dataType, 'number');
      expect(lifetime.allowedRange?.min, 1);
      expect(lifetime.allowedRange?.max, 168);
      expect(lifetime.category, SettingCategory.lifecycle);
      expect(lifetime.requiresSuperAdmin, false);

      final offerOptions =
          settings.firstWhere((s) => s.key == 'offer.validity_hours_options');
      expect(offerOptions.value, [12, 24, 48]);
      expect(offerOptions.category, SettingCategory.lifecycle);
      expect(offerOptions.isOfferValidityPendingDecision, true);

      final offerDefault =
          settings.firstWhere((s) => s.key == 'offer.default_validity_hours');
      expect(offerDefault.value, 24);
      expect(offerDefault.isOfferValidityPendingDecision, true);
      expect(offerDefault.allowedRange?.enumValues, ['12', '24', '48']);
      expect(
        offerDefault.validateOfferValidity(72),
        contains('12, 24, or 48'),
      );
      expect(offerDefault.validateOfferValidity(24), isNull);
      expect(
        offerOptions.validateOfferValidity([12, 24, 72]),
        contains('Do not invent 72'),
      );
      expect(offerOptions.validateOfferValidity([12, 24, 48]), isNull);

      final bullion =
          settings.firstWhere((s) => s.key == 'bullion.minimum_value_aed');
      expect(bullion.category, SettingCategory.limits);

      final media =
          settings.firstWhere((s) => s.key == 'media.image.max_bytes');
      expect(media.category, SettingCategory.media);

      final goldDisplay =
          settings.firstWhere((s) => s.key == 'goldRates.endUserDisplay');
      expect(goldDisplay.category, SettingCategory.security);
      expect(goldDisplay.requiresSuperAdmin, true);
    });

    test('updates setting with PATCH request including confirmation flag',
        () async {
      RequestOptions? captured;
      final client = buildMockClient(onPatch: (opt) => captured = opt);
      final repository = PlatformSettingsRepository(client);

      final updated = await repository.updateSetting(
        'request.lifetime_hours',
        72,
        confirm: true,
      );

      expect(captured, isNotNull);
      expect(captured!.method, 'PATCH');
      expect(captured!.path, '/v1/admin/settings/request.lifetime_hours');
      expect(captured!.data, {'value': 72, 'confirm': true});
      expect(updated.key, 'request.lifetime_hours');
      expect(updated.value, 72);
    });

    test('throws ApiException when backend returns SETTING_OUT_OF_RANGE error',
        () async {
      final client = buildMockClient(
        patchStatusCode: 400,
        patchResponseData: {
          'error': {
            'code': 'SETTING_OUT_OF_RANGE',
            'message': 'Supplied value exceeds allowed range maximum of 168.',
          }
        },
      );
      final repository = PlatformSettingsRepository(client);

      expect(
        () => repository.updateSetting('request.lifetime_hours', 500),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', 'SETTING_OUT_OF_RANGE')
              .having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });
  });
}
