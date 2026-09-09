import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/api/json_parse.dart';

void main() {
  group('TR-S1-12 Envelope Normalization & Regression Tests', () {
    late Dio dio;
    late ApiClient client;

    setUp(() {
      dio = Dio();
      client = ApiClient(dio: dio, baseUrl: 'http://test.local');
    });

    test('unwraps single-wrapped entity ({ data: entity })', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': {
                    'id': 'ent-1',
                    'name': 'Standard Entity',
                  },
                },
              ),
            );
          },
        ),
      );

      final result = await client.get('/v1/entity/1');
      expect(result, isA<Map<String, dynamic>>());
      expect(result['id'], 'ent-1');
      expect(result['name'], 'Standard Entity');

      final unwrapped = unwrapEntity(result);
      expect(unwrapped['id'], 'ent-1');
    });

    test('unwraps double-wrapped entity ({ data: { data: entity } })', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': {
                    'data': {
                      'id': 'ent-double-1',
                      'title': 'Double Wrapped Entity',
                      'user': {
                        'id': 'usr-1',
                        'email': 'admin@karathive.ae',
                      },
                    },
                  },
                },
              ),
            );
          },
        ),
      );

      final result = await client.get('/v1/entity/double');
      expect(result, isA<Map<String, dynamic>>());
      expect(result['id'], 'ent-double-1');
      expect(result['title'], 'Double Wrapped Entity');

      final unwrapped = unwrapEntity(result);
      expect(unwrapped['id'], 'ent-double-1');
      expect(asMap(unwrapped['user'])['email'], 'admin@karathive.ae');
    });

    test('unwraps double-wrapped list in getCollection', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': {
                    'data': [
                      {'id': 'item-1', 'title': 'First'},
                      {'id': 'item-2', 'title': 'Second'},
                    ],
                    'nextCursor': 'cursor-page-2',
                  },
                  'meta': {
                    'serverTime': '2026-09-09T00:00:00.000Z',
                  },
                },
              ),
            );
          },
        ),
      );

      final collection = await client.getCollection('/v1/items/double');
      expect(collection.items, hasLength(2));
      expect(collection.items.first['id'], 'item-1');
      expect(collection.items.last['id'], 'item-2');
      expect(collection.meta?['nextCursor'], 'cursor-page-2');
    });

    test('unwraps nested user/profile relation via unwrapEntity and asMap', () {
      final rawNested = {
        'data': {
          'id': 'prof-100',
          'vendorProfile': {
            'id': 'vp-100',
            'legalBusinessName': 'Jewels LLC',
            'user': {
              'id': 'usr-100',
              'displayName': 'Jewel Owner',
              'phone': '+971500000000',
            },
          },
        },
      };

      final unwrapped = unwrapEntity(rawNested);
      expect(unwrapped['id'], 'prof-100');

      final vendorProfile = asMap(unwrapped['vendorProfile']);
      expect(vendorProfile['legalBusinessName'], 'Jewels LLC');

      final user = asMap(vendorProfile['user']);
      expect(user['displayName'], 'Jewel Owner');
      expect(user['phone'], '+971500000000');
    });

    test('unwrapEntity returns empty map on non-map input', () {
      expect(unwrapEntity(null), isEmpty);
      expect(unwrapEntity('string'), isEmpty);
      expect(unwrapEntity(123), isEmpty);
      expect(unwrapEntity(<Object?>[]), isEmpty);
    });
  });
}
