import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/api/api_exception.dart';
import 'package:kh_admin/features/admin_users/model/admin_user_enums.dart';
import 'package:kh_admin/features/admin_users/model/admin_user_filters.dart';
import 'package:kh_admin/features/admin_users/repository/admin_user_repository.dart';

void main() {
  Map<String, dynamic> rawAdminProfileRow({
    required String id,
    required String userId,
    required String displayName,
    required String email,
    String accountState = 'ACTIVE',
  }) {
    return {
      'id': id,
      'userId': userId,
      'displayName': displayName,
      'createdAt': '2026-09-01T10:00:00.000Z',
      'updatedAt': '2026-09-01T10:00:00.000Z',
      'user': {
        'id': userId,
        'email': email,
        'accountState': accountState,
        'createdAt': '2026-09-01T10:00:00.000Z',
      },
    };
  }

  ApiClient buildClient({
    void Function(RequestOptions)? onPostCreate,
    void Function(RequestOptions)? onPostSuspend,
    void Function(RequestOptions)? onPostRevoke,
    bool simulateRevokeConflict = false,
  }) {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final path = options.path;

          if (options.method == 'GET' && path == '/v1/admin/admins') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': [
                    rawAdminProfileRow(
                      id: 'prof-1',
                      userId: 'usr-1',
                      displayName: 'Sarah Connor',
                      email: 'sarah@karathive.ae',
                      accountState: 'ACTIVE',
                    ),
                    rawAdminProfileRow(
                      id: 'prof-2',
                      userId: 'usr-2',
                      displayName: 'John Wick',
                      email: 'john@karathive.ae',
                      accountState: 'SUSPENDED',
                    ),
                    rawAdminProfileRow(
                      id: 'prof-3',
                      userId: 'usr-3',
                      displayName: 'Kyle Reese',
                      email: 'kyle@karathive.ae',
                      accountState: 'DEACTIVATED',
                    ),
                  ],
                },
              ),
            );
          }

          if (options.method == 'POST' && path == '/v1/admin/admins') {
            onPostCreate?.call(options);
            final body = options.data as Map<String, dynamic>;
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'data': {
                    'profile': {
                      'id': 'prof-new',
                      'userId': 'usr-new',
                      'displayName': body['displayName'],
                      'createdAt': '2026-09-02T12:00:00.000Z',
                    },
                    'user': {
                      'id': 'usr-new',
                      'email': body['email'],
                      'accountState': 'ACTIVE',
                      'createdAt': '2026-09-02T12:00:00.000Z',
                    },
                  },
                },
              ),
            );
          }

          if (options.method == 'POST' && path.endsWith('/suspend')) {
            onPostSuspend?.call(options);
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'data': {'status': 'SUSPENDED'}},
              ),
            );
          }

          if (options.method == 'POST' && path.endsWith('/revoke')) {
            onPostRevoke?.call(options);
            if (simulateRevokeConflict) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 409,
                  data: {
                    'error': {
                      'code': 'CONFLICT',
                      'message': 'Cannot revoke the last remaining active admin account',
                    },
                  },
                ),
              );
            }
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'data': {'status': 'DEACTIVATED'}},
              ),
            );
          }

          return handler.next(options);
        },
      ),
    );

    return ApiClient(dio: dio);
  }

  group('AdminUserRepository', () {
    test('fetchAdmins normalizes profiles and maps enums accurately', () async {
      final repo = AdminUserRepository(buildClient());
      final list = await repo.fetchAdmins();

      expect(list.length, 3);

      final first = list.first;
      expect(first.id, 'prof-1');
      expect(first.userId, 'usr-1');
      expect(first.displayName, 'Sarah Connor');
      expect(first.email, 'sarah@karathive.ae');
      expect(first.accountState, AdminAccountState.active);
      expect(first.accountState.label, 'Active');
      expect(first.accountState.tone.name, 'success');

      final second = list[1];
      expect(second.displayName, 'John Wick');
      expect(second.accountState, AdminAccountState.suspended);
      expect(second.accountState.label, 'Suspended');
      expect(second.accountState.tone.name, 'pending');

      final third = list[2];
      expect(third.displayName, 'Kyle Reese');
      expect(third.accountState, AdminAccountState.deactivated);
      expect(third.accountState.label, 'Revoked');
      expect(third.accountState.tone.name, 'error');
    });

    test('fetchAdmins filters by state and search query', () async {
      final repo = AdminUserRepository(buildClient());

      final activeOnly = await repo.fetchAdmins(
        filters: const AdminUserFilters(state: AdminAccountState.active),
      );
      expect(activeOnly.length, 1);
      expect(activeOnly.first.displayName, 'Sarah Connor');

      final queryMatches = await repo.fetchAdmins(
        filters: const AdminUserFilters(query: 'wick'),
      );
      expect(queryMatches.length, 1);
      expect(queryMatches.first.displayName, 'John Wick');

      final noMatches = await repo.fetchAdmins(
        filters: const AdminUserFilters(query: 'nonexistent'),
      );
      expect(noMatches, isEmpty);
    });

    test('createAdmin sends email and displayName with NO role selector payload', () async {
      RequestOptions? recordedOptions;
      final repo = AdminUserRepository(
        buildClient(
          onPostCreate: (opts) => recordedOptions = opts,
        ),
      );

      final newItem = await repo.createAdmin(
        email: 'newadmin@karathive.ae',
        displayName: 'New Admin',
      );

      expect(recordedOptions, isNotNull);
      expect(recordedOptions!.path, '/v1/admin/admins');
      expect(recordedOptions!.method, 'POST');

      final body = recordedOptions!.data as Map<String, dynamic>;
      expect(body['email'], 'newadmin@karathive.ae');
      expect(body['displayName'], 'New Admin');
      // Constraint verification: NO role field (SAM-GAP-13, AD-API-03)
      expect(body.containsKey('role'), isFalse);

      expect(newItem.id, 'prof-new');
      expect(newItem.displayName, 'New Admin');
      expect(newItem.email, 'newadmin@karathive.ae');
      expect(newItem.accountState, AdminAccountState.active);
    });

    test('suspendAdmin calls POST /v1/admin/admins/:id/suspend', () async {
      RequestOptions? recordedOptions;
      final repo = AdminUserRepository(
        buildClient(
          onPostSuspend: (opts) => recordedOptions = opts,
        ),
      );

      await repo.suspendAdmin('prof-1');

      expect(recordedOptions, isNotNull);
      expect(recordedOptions!.path, '/v1/admin/admins/prof-1/suspend');
      expect(recordedOptions!.method, 'POST');
    });

    test('revokeAdmin calls POST /v1/admin/admins/:id/revoke', () async {
      RequestOptions? recordedOptions;
      final repo = AdminUserRepository(
        buildClient(
          onPostRevoke: (opts) => recordedOptions = opts,
        ),
      );

      await repo.revokeAdmin('prof-1');

      expect(recordedOptions, isNotNull);
      expect(recordedOptions!.path, '/v1/admin/admins/prof-1/revoke');
      expect(recordedOptions!.method, 'POST');
    });

    test('revokeAdmin throws ApiException on 409 Conflict protecting last admin', () async {
      final repo = AdminUserRepository(
        buildClient(simulateRevokeConflict: true),
      );

      expect(
        () => repo.revokeAdmin('prof-last'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 409)),
      );
    });
  });
}
