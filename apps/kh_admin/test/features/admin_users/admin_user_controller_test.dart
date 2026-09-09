import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/api/api_exception.dart';
import 'package:kh_admin/core/list/paginated.dart';
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
  Future<Paginated<AdminUserItem>> fetchAdmins({
    AdminUserFilters filters = const AdminUserFilters(),
    String? cursor,
    int limit = 20,
  }) async {
    if (shouldFailFetch) throw Exception('Network timeout');
    final filtered = admins.where(filters.matches).toList();
    return Paginated<AdminUserItem>(
      items: filtered,
      totalCount: filtered.length,
    );
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

Future<void> _settle(ProviderContainer container) async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (!container.read(adminUserControllerProvider).isLoading) return;
  }
  fail('AdminUserController did not finish loading');
}

void main() {
  late ProviderContainer container;
  late _FakeAdminUserRepository repo;

  setUp(() {
    repo = _FakeAdminUserRepository();
    container = ProviderContainer(
      overrides: [
        adminUserRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('AdminUserController', () {
    test('initial state loads admins and populates counts', () async {
      await _settle(container);

      final state = container.read(adminUserControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.admins.length, 3);
      expect(state.totalCount, 3);
      expect(state.activeCount, 1);
      expect(state.suspendedCount, 1);
      expect(state.revokedCount, 1);
      expect(state.errorMessage, isNull);
    });

    test('loadAdmins records error message on failure', () async {
      repo.shouldFailFetch = true;
      final controller = container.read(adminUserControllerProvider.notifier);
      await controller.loadAdmins();

      final state = container.read(adminUserControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.admins, isEmpty);
      expect(state.errorMessage, contains('Network timeout'));
    });

    test('setSearchQuery and setStateFilter dynamically update filteredAdmins', () async {
      await _settle(container);

      final controller = container.read(adminUserControllerProvider.notifier);
      expect(container.read(adminUserControllerProvider).filteredAdmins.length, 3);

      controller.setSearchQuery('bob');
      await _settle(container);
      expect(container.read(adminUserControllerProvider).filteredAdmins.length, 1);
      expect(container.read(adminUserControllerProvider).filteredAdmins.first.displayName, 'Bob Admin');

      controller.resetFilters();
      await _settle(container);
      expect(container.read(adminUserControllerProvider).filteredAdmins.length, 3);

      controller.setStateFilter(AdminAccountState.active);
      await _settle(container);
      expect(container.read(adminUserControllerProvider).filteredAdmins.length, 1);
      expect(container.read(adminUserControllerProvider).filteredAdmins.first.displayName, 'Alice Admin');

      controller.setStateFilter(null);
      await _settle(container);
      expect(container.read(adminUserControllerProvider).filteredAdmins.length, 3);
    });

    test('provisionAdmin creates admin and reloads list', () async {
      await _settle(container);

      final controller = container.read(adminUserControllerProvider.notifier);
      final success = await controller.provisionAdmin(
        email: 'diana@karathive.ae',
        displayName: 'Diana Admin',
      );
      await _settle(container);

      expect(success, isTrue);
      expect(repo.lastCreatedEmail, 'diana@karathive.ae');
      expect(repo.lastCreatedDisplayName, 'Diana Admin');
      final state = container.read(adminUserControllerProvider);
      expect(state.admins.length, 4);
      expect(state.activeCount, 2);
    });

    test('provisionAdmin sets errorMessage on failure', () async {
      repo.shouldFailCreate = true;
      await _settle(container);

      final controller = container.read(adminUserControllerProvider.notifier);
      final success = await controller.provisionAdmin(
        email: 'dup@karathive.ae',
        displayName: 'Duplicate',
      );

      expect(success, isFalse);
      final state = container.read(adminUserControllerProvider);
      expect(state.errorMessage, contains('Duplicate email'));
    });

    test('suspendAdmin updates account state and refreshes list', () async {
      await _settle(container);

      final controller = container.read(adminUserControllerProvider.notifier);
      expect(container.read(adminUserControllerProvider).activeCount, 1);
      expect(container.read(adminUserControllerProvider).suspendedCount, 1);

      final success = await controller.suspendAdmin('prof-1');
      await _settle(container);

      expect(success, isTrue);
      expect(repo.lastSuspendedId, 'prof-1');
      final state = container.read(adminUserControllerProvider);
      expect(state.activeCount, 0);
      expect(state.suspendedCount, 2);
    });

    test('revokeAdmin deactivates admin account', () async {
      await _settle(container);

      final controller = container.read(adminUserControllerProvider.notifier);
      expect(container.read(adminUserControllerProvider).revokedCount, 1);

      final success = await controller.revokeAdmin('prof-1');
      await _settle(container);

      expect(success, isTrue);
      expect(repo.lastRevokedId, 'prof-1');
      final state = container.read(adminUserControllerProvider);
      expect(state.activeCount, 0);
      expect(state.revokedCount, 2);
    });

    test('revokeAdmin translates 409 conflict into last admin protection message', () async {
      repo.shouldFailRevokeConflict = true;
      await _settle(container);

      final controller = container.read(adminUserControllerProvider.notifier);
      final success = await controller.revokeAdmin('prof-1');

      expect(success, isFalse);
      final state = container.read(adminUserControllerProvider);
      expect(
        state.errorMessage,
        'Cannot revoke the last remaining active admin account.',
      );
    });
  });
}
