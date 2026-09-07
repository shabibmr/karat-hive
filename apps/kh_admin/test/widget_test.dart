import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/auth/auth_models.dart';
import 'package:kh_admin/core/auth/auth_repository.dart';
import 'package:kh_admin/core/auth/dev_auth.dart';
import 'package:kh_admin/core/auth/session_controller.dart';
import 'package:kh_admin/core/auth/session_state.dart';
import 'package:kh_admin/core/auth/token_storage.dart';
import 'package:kh_admin/core/design/theme/kh_colors.dart';
import 'package:kh_admin/features/dashboard/model/dashboard_stats.dart';
import 'package:kh_admin/features/dashboard/repository/dashboard_repository.dart';
import 'package:kh_admin/main.dart';

class _FakeTokenStorage extends TokenStorage {
  @override
  Future<SessionTokens?> loadTokens() async => null;
  @override
  Future<void> saveTokens(SessionTokens tokens) async {}
  @override
  Future<void> clearTokens() async {}
}

class _FakeDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardStats> fetchStats() async {
    return const DashboardStats(
      totalCustomers: 100,
      totalVendors: 20,
      pendingVerificationVendors: 2,
      activeRequests: 50,
      activeOffers: 120,
      activeConnections: 30,
    );
  }
}

/// Stands in for the backend during the dev auto-login test: a real
/// `POST /v1/auth/login/password` round trip, minus the network.
class _SeededAdminAuthRepository extends AuthRepository {
  _SeededAdminAuthRepository() : super(ApiClient());

  @override
  Future<SessionBundle> login(String email, String password) async {
    return const SessionBundle(
      tokens: SessionTokens(
        accessToken: 'dev-access',
        accessExpiresAt: '2026-12-31T23:59:59Z',
        refreshToken: 'dev-refresh',
        refreshExpiresAt: '2026-12-31T23:59:59Z',
      ),
      user: AdminUser(
        userId: 'seed-admin',
        userType: 'ADMIN',
        email: 'admin@karathive.ae',
        displayName: 'Platform Admin',
      ),
    );
  }
}

void main() {
  testWidgets('KhAdminApp boots cleanly and renders login for unauthenticated visitor',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
          dashboardRepositoryProvider
              .overrideWithValue(_FakeDashboardRepository()),
        ],
        child: const KhAdminApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Karat Hive branding renders on login screen
    expect(find.text('KARAT HIVE'), findsOneWidget);
    expect(find.text('Administrative Portal'), findsOneWidget);
  });

  testWidgets('KhAdminApp shell renders on desktop (>= 1280px) when authenticated',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
          dashboardRepositoryProvider
              .overrideWithValue(_FakeDashboardRepository()),
          sessionControllerProvider.overrideWith(
            (ref) => _AuthenticatedSessionController(),
          ),
        ],
        child: const KhAdminApp(),
      ),
    );

    await tester.pumpAndSettle();

    // On desktop viewport, fixed sidebar and top bar render
    expect(find.text('Karat Hive Portal'), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Super Admin'), findsOneWidget);
  });

  testWidgets('KhAdminApp shell renders navigation drawer when < 1280px',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
          dashboardRepositoryProvider
              .overrideWithValue(_FakeDashboardRepository()),
          sessionControllerProvider.overrideWith(
            (ref) => _AuthenticatedSessionController(),
          ),
        ],
        child: const KhAdminApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Hamburger button is visible
    expect(find.byIcon(Icons.menu), findsOneWidget);

    // Open drawer
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Drawer is now open and sidebar contents appear
    expect(find.text('Karat Hive Portal'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
  });

  test('Design tokens expose sapphire/gold/cream palette correctly', () {
    const colors = KhColors.dark;
    expect(colors.sapphire900.toARGB32(), 0xFF0A1128);
    expect(colors.gold400.toARGB32(), 0xFFD4AF37);
    expect(colors.cream100.toARGB32(), 0xFFFDFBF7);
    expect(colors.goldPrimary.toARGB32(), 0xFFD4AF37);
    expect(colors.backgroundPrimary.toARGB32(), 0xFF0A1128);
  });

  testWidgets(
      'dev auto-login lands on the dashboard shell with the Categories nav item',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
          dashboardRepositoryProvider
              .overrideWithValue(_FakeDashboardRepository()),
          authRepositoryProvider
              .overrideWithValue(_SeededAdminAuthRepository()),
          devAuthConfigProvider.overrideWithValue(
            const DevAuthConfig(
              autoLogin: true,
              email: 'admin@karathive.ae',
              password: 'AdminSecret123!',
            ),
          ),
        ],
        child: const KhAdminApp(),
      ),
    );

    await tester.pumpAndSettle();

    // The login screen must never appear.
    expect(find.text('Administrative Portal'), findsNothing);

    // We land inside the shell, on the dashboard, with Categories reachable.
    expect(find.text('Karat Hive Portal'), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Categories'), findsOneWidget);

    // The bypass is always visible so it cannot ship unnoticed.
    expect(find.byKey(const Key('dev-autologin-badge')), findsOneWidget);
  });
}

class _AuthenticatedSessionController extends StateNotifier<SessionState>
    implements SessionController {
  _AuthenticatedSessionController()
      : super(
          const SessionState(
            status: SessionStatus.authenticated,
            tokens: SessionTokens(
              accessToken: 'test-access-token',
              accessExpiresAt: '2026-12-31T23:59:59Z',
              refreshToken: 'test-refresh-token',
              refreshExpiresAt: '2026-12-31T23:59:59Z',
            ),
            admin: AdminUser(
              userId: 'admin-1',
              userType: 'ADMIN',
              email: 'admin@karathive.ae',
              displayName: 'Super Admin',
            ),
          ),
        );

  @override
  Future<void> init() async {}

  @override
  Future<void> login(String email, String password) async {}

  @override
  Future<void> loginWithPassword(String email, String password) async {}

  @override
  Future<void> logout() async {
    state = const SessionState(status: SessionStatus.unauthenticated);
  }

  @override
  Future<bool> silentRefresh() async => true;
}
