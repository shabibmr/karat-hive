import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/taxonomy/model/taxonomy_dto.dart';
import 'package:kh_admin/features/taxonomy/model/taxonomy_kind.dart';
import 'package:kh_admin/features/taxonomy/repository/taxonomy_repository.dart';

void main() {
  Map<String, dynamic> rawNode({
    required String id,
    String? parentId,
    String nameEn = 'Gold Bars',
    String nameAr = 'سبائك ذهب',
    bool isActive = true,
  }) {
    return {
      'id': id,
      'parentId': parentId,
      'nameEn': nameEn,
      'nameAr': nameAr,
      'displayOrder': 0,
      'isActive': isActive,
      'children': <dynamic>[],
    };
  }

  /// Records the last write body/path seen so tests can assert on it.
  late List<RequestOptions> seen;

  ApiClient buildClient() {
    seen = [];
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          seen.add(options);
          final path = options.path;

          if (options.method == 'GET' &&
              (path == '/v1/admin/categories' || path == '/v1/admin/regions')) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': {
                    'data': [
                      rawNode(id: '${path.contains('categories') ? 'cat' : 'reg'}-1'),
                      rawNode(id: '${path.contains('categories') ? 'cat' : 'reg'}-2', isActive: false),
                    ],
                    'nextCursor': null,
                  },
                  'meta': {'requestId': 'req-1'},
                },
              ),
            );
          }

          // create / update / deactivate all return a single entity envelope.
          final id = RegExp(r'/(cat|reg)-[0-9]+').firstMatch(path)?.group(0)?.substring(1) ?? 'cat-new';
          return handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'data': rawNode(
                  id: id,
                  nameEn: (options.data as Map?)?['nameEn'] as String? ?? 'Gold Bars',
                  isActive: !path.endsWith('/deactivate'),
                ),
                'meta': {'requestId': 'req-2'},
              },
            ),
          );
        },
      ),
    );
    return ApiClient(baseUrl: 'http://localhost:3000', dio: dio);
  }

  late TaxonomyRepository repository;

  setUp(() => repository = TaxonomyRepository(buildClient()));

  group('TR-S7-06 · TaxonomyRepository', () {
    test('fetchCategories unwraps the double-wrapped list and maps nodes', () async {
      final nodes = await repository.fetchCategories();

      expect(nodes, hasLength(2));
      expect(nodes.first.id, 'cat-1');
      expect(nodes.first.nameEn, 'Gold Bars');
      expect(nodes[1].isActive, isFalse);
      expect(seen.single.queryParameters['includeInactive'], 'true');
    });

    test('fetchRegions passes includeInactive=false through', () async {
      await repository.fetchRegions(includeInactive: false);
      expect(seen.single.queryParameters['includeInactive'], 'false');
    });

    test('createCategory posts the DTO and returns the created node', () async {
      final node = await repository.createCategory(
        const CreateTaxonomyDto(nameEn: 'Coins', nameAr: 'عملات'),
      );

      expect(node.nameEn, 'Coins');
      expect(seen.single.method, 'POST');
      expect(seen.single.path, '/v1/admin/categories');
      expect((seen.single.data as Map)['nameEn'], 'Coins');
    });

    test('updateRegion strips null fields from the PATCH payload', () async {
      await repository.updateRegion('reg-1', const UpdateTaxonomyDto(nameEn: 'Dubai'));

      final body = seen.single.data as Map;
      expect(seen.single.method, 'PATCH');
      expect(body['nameEn'], 'Dubai');
      expect(body.containsKey('nameAr'), isFalse);
    });

    test('deactivateCategory hits the deactivate route', () async {
      final node = await repository.deactivateCategory('cat-2');

      expect(seen.single.path, '/v1/admin/categories/cat-2/deactivate');
      expect(node.isActive, isFalse);
    });

    test('generic fetchTree dispatches by kind', () async {
      await repository.fetchTree(TaxonomyKind.region);
      expect(seen.single.path, '/v1/admin/regions');
    });

    test('generic deactivateNode dispatches by kind', () async {
      await repository.deactivateNode(TaxonomyKind.category, 'cat-9');
      expect(seen.single.path, '/v1/admin/categories/cat-9/deactivate');
    });
  });
}
