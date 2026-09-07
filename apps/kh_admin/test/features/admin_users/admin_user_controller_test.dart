import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/api/api_exception.dart';
import 'package:kh_admin/features/admin_users/controller/admin_user_controller.dart';
import 'package:kh_admin/features/admin_users/model/admin_user_enums.dart';
import 'package:kh_admin/features/admin_users/model/admin_user_filters.dart';
import 'package:kh_admin/features/admin_users/model/admin_user_item.dart';
import 'package:kh_admin/features/admin_users/repository/admin_user_repository.dart';

class _FakeAdminUserRepository extends AdminUserRepository {
  _FakeAdminUserRepository() : super(ApiClient());

  List<AdminUserItem> admins = [
    AdminUserItem(
      id: 'prof-1',
      userId: 'usr-1',
      displayName: 'Alice Admin',
      email: 'alice@karathive.ae',
      accountState: AdminAccountState.active,
      createdAt: DateTime(2026, 9, 1),
    ),
    AdminUserItem(
      id: 'prof-2',
      userId: 'usr-2',
      displayName: 'Bob Admin',
      email: 'bob@karathive.ae',
      accountState: AdminAccountState.suspended,
      createdAt: DateTime(2026, 9, 2),
    ),
    AdminUserItem(
      id: 'prof-3',
      userId: 'usr-3',
      displayName: 'Charlie Admin',
      email: 'charlie@karathive.ae',
      accountState: AdminAccountState.deactivated,
      createdAt: DateTime(2026, 9, 3),
    ),
  ];

  bool shouldFailFetch = false;
  bool shouldFailCreate = false;
  bool shouldFailSuspend = false;
  bool shouldFailRevokeConflict = false;

  String? lastCreatedEmail;
  String? lastCreatedDisplayName;
  String? lastSuspendedId;
  String? lastRevokedId;

  @override
  Future<List<AdminUserItem>> fetchAdmins({
    AdminUserFilters filters = const AdminUserFilters(),
  }) async {
    if (shouldFailFetch) throw Exception('Network timeout');
    return admins.where(filters.matches).toList();
  }

  @override
  Future<AdminUserItem> createAdmin({
    required String email,
    required String displayName,
  }) async {
    if (shouldFailCreate) throw Exception('Duplicate email');
    lastCreatedEmail = email;
    lastCreatedDisplayName = displayName;

    final created = AdminUserItem(
      id: 'prof-new',
      userId: 'usr-new',
      displayName: displayName,
      email: email,
      accountState: AdminAccountState.active,
      createdAt: DateTime.now(),
    );
    admins.add(created);
    return created;
  }

  @override
  Future<void> suspendAdmin(String id) async {
    if (shouldFailSuspend) throw Exception('Suspension failed');
    lastSuspendedId = id;
    final index = admins.indexWhere((a) => a.id == id);
    if (index != -1) {
      admins[index] = admins[index].copyWith(accountState: AdminAccountState.suspended);
    }
  }

  @override
  Future<void> revokeAdmin(String id) async {
    if (shouldFailRevokeConflict) {
      throw const ApiException(
        statusCode: 409,
        code: 'CONFLICT',
        message: 'Cannot revoke the last remaining active admin account',
      );
    }
    lastRevokedId = id;
    final index = admins.indexWhere((a) => a.id == id);
    if (index != -1) {
      admins[index] = admins[index].copyWith(accountState: AdminAccountState.deactivated);
    }
  }
}

void main() {
  group('AdminUserController', () {
    test('initial state loads admins and populates counts', () async {
      final repo = _FakeAdminUserRepository();
      final controller = AdminUserController(repo);

      // Initial constructor triggers loadAdmins
      await Future<void>.delayed(Duration.zero);

      final state = controller.state;
      expect(state.isLoading, isFalse);
      expect(state.admins.length, 3);
      expect(state.totalCount, 3);
      expect(state.activeCount, 1);
      expect(state.suspendedCount, 1);
      expect(state.revokedCount, 1);
      expect(state.errorMessage, isNull);
    });

    test('loadAdmins records error message on failure', () async {
      final repo = _FakeAdminUserRepository()..shouldFailFetch = true;
      final controller = AdminUserController(repo);

      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.admins, isEmpty);
      expect(controller.state.errorMessage, contains('Network timeout'));
    });

    test('setSearchQuery and setStateFilter dynamically update filteredAdmins', () async {
      final repo = _FakeAdminUserRepository();
      final controller = AdminUserController(repo);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.filteredAdmins.length, 3);

      controller.setSearchQuery('bob');
      expect(controller.state.filteredAdmins.length, 1);
      expect(controller.state.filteredAdmins.first.displayName, 'Bob Admin');

      controller.resetFilters();
      expect(controller.state.filteredAdmins.length, 3);

      controller.setStateFilter(AdminAccountState.active);
      expect(controller.state.filteredAdmins.length, 1);
      expect(controller.state.filteredAdmins.first.displayName, 'Alice Admin');

      controller.setStateFilter(null);
      expect(controller.state.filteredAdmins.length, 3);
    });

    test('provisionAdmin creates admin and reloads list', () async {
      final repo = _FakeAdminUserRepository();
      final controller = AdminUserController(repo);
      await Future<void>.delayed(Duration.zero);

      final success = await controller.provisionAdmin(
        email: 'diana@karathive.ae',
        displayName: 'Diana Admin',
      );

      expect(success, isTrue);
      expect(repo.lastCreatedEmail, 'diana@karathive.ae');
      expect(repo.lastCreatedDisplayName, 'Diana Admin');
      expect(controller.state.admins.length, 4);
      expect(controller.state.activeCount, 2);
      expect(controller.state.actionSuccessMessage, isNotNull);
    });

    test('provisionAdmin sets errorMessage on failure', () async {
      final repo = _FakeAdminUserRepository()..shouldFailCreate = true;
      final controller = AdminUserController(repo);
      await Future<void>.delayed(Duration.zero);

      final success = await controller.provisionAdmin(
        email: 'dup@karathive.ae',
        displayName: 'Duplicate',
      );

      expect(success, isFalse);
      expect(controller.state.errorMessage, contains('Duplicate email'));
    });

    test('suspendAdmin updates account state and refreshes list', () async {
      final repo = _FakeAdminUserRepository();
      final controller = AdminUserController(repo);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.activeCount, 1);
      expect(controller.state.suspendedCount, 1);

      final success = await controller.suspendAdmin('prof-1');
      expect(success, isTrue);
      expect(repo.lastSuspendedId, 'prof-1');
      expect(controller.state.activeCount, 0);
      expect(controller.state.suspendedCount, 2);
    });

    test('revokeAdmin deactivates admin account', () async {
      final repo = _FakeAdminUserRepository();
      final controller = AdminUserController(repo);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.revokedCount, 1);

      final success = await controller.revokeAdmin('prof-1');
      expect(success, isTrue);
      expect(repo.lastRevokedId, 'prof-1');
      expect(controller.state.activeCount, 0);
      expect(controller.state.revokedCount, 2);
    });

    test('revokeAdmin translates 409 conflict into last admin protection message', () async {
      final repo = _FakeAdminUserRepository()..shouldFailRevokeConflict = true;
      final controller = AdminUserController(repo);
      await Future<void>.delayed(Duration.zero);

      final success = await controller.revokeAdmin('prof-1');
      expect(success, isFalse);
      expect(
        controller.state.errorMessage,
        'Cannot revoke the last remaining active admin account.',
      );
    });
  });
}
