import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/list/paginated.dart';
import 'package:kh_admin/features/admin_users/model/admin_user_enums.dart';
import 'package:kh_admin/features/admin_users/model/admin_user_filters.dart';
import 'package:kh_admin/features/admin_users/model/admin_user_item.dart';
import 'package:kh_admin/features/admin_users/presentation/admin_users_screen.dart';
import 'package:kh_admin/features/admin_users/repository/admin_user_repository.dart';

class _FakeAdminUserRepository extends AdminUserRepository {
  _FakeAdminUserRepository() : super(ApiClient());

  bool empty = false;
  bool failNext = false;
  Completer<Paginated<AdminUserItem>>? delay;

  @override
  Future<Paginated<AdminUserItem>> fetchAdmins({
    AdminUserFilters filters = const AdminUserFilters(),
    String? cursor,
    int limit = 20,
  }) async {
    if (delay != null) return delay!.future;
    if (failNext) throw Exception('Admin directory unavailable');
    if (empty) return const Paginated(items: []);
    final items = [
      AdminUserItem(
        id: 'prof-1',
        userId: 'usr-1',
        displayName: 'Sarah Connor',
        email: 'sarah@karathive.ae',
        accountState: AdminAccountState.active,
        createdAt: DateTime(2026, 9, 1),
      ),
    ].where(filters.matches).toList(growable: false);
    return Paginated(items: items);
  }

  @override
  Future<AdminUserItem> createAdmin({
    required String email,
    required String displayName,
  }) async {
    return AdminUserItem(
      id: 'prof-new',
      userId: 'usr-new',
      displayName: displayName,
      email: email,
      accountState: AdminAccountState.active,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> suspendAdmin(String id) async {}

  @override
  Future<void> revokeAdmin(String id) async {}
}

void main() {
  Widget buildTestableScreen({required AdminUserRepository repository}) {
    return ProviderScope(
      overrides: [
        adminUserRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: buildKhAdminTheme(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: const Scaffold(body: AdminUsersScreen()),
      ),
    );
  }

  group('AdminUsersScreen', () {
    testWidgets('renders header, metrics and admin rows', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestableScreen(repository: _FakeAdminUserRepository()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Admin Users'), findsWidgets);
      expect(find.text('TOTAL ADMINS'), findsOneWidget);
      expect(find.text('Sarah Connor'), findsOneWidget);
      expect(find.text('sarah@karathive.ae'), findsOneWidget);
      expect(find.textContaining('System Administrator'), findsNothing);
      expect(find.textContaining('Role'), findsNothing);
    });

    testWidgets('shows loading indicator while the directory is in flight',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeAdminUserRepository()
        ..delay = Completer<Paginated<AdminUserItem>>();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pump();

      expect(find.byKey(const Key('admin-list-loading')), findsOneWidget);

      repo.delay!.complete(const Paginated(items: []));
      await tester.pumpAndSettle();
    });

    testWidgets('shows empty state when no admins match', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeAdminUserRepository()..empty = true;
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('admin-list-empty')), findsOneWidget);
      expect(find.text('No admin users found'), findsOneWidget);
    });

    testWidgets('shows error state and retries on failure', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _FakeAdminUserRepository()..failNext = true;
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('admin-list-error')), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
