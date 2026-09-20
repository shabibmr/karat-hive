import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/auth/auth_models.dart';
import 'package:kh_admin/core/auth/session_controller.dart';
import 'package:kh_admin/core/auth/session_state.dart';
import 'package:kh_admin/core/auth/token_storage.dart';
import 'package:kh_admin/core/firebase/firebase_auth_service.dart';
import 'package:kh_admin/features/dashboard/model/dashboard_queue_item.dart';
import 'package:kh_admin/features/dashboard/model/dashboard_stats.dart';
import 'package:kh_admin/features/dashboard/repository/dashboard_repository.dart';
import 'package:kh_admin/features/reports/model/report_filters.dart';
import 'package:kh_admin/features/reports/model/report_name.dart';
import 'package:kh_admin/features/reports/model/report_result.dart';
import 'package:kh_admin/main.dart';

/// The bug: while the session was still resolving, the route guard returned
/// `null` (= allow), so the initial location `/` mounted the admin shell and
/// dashboard — firing their admin API calls — before anyone was signed in.
void main() {
  testWidgets(
    'un-resolved session parks on the splash screen, never the dashboard shell',
    (tester) async {
      final controller = _PendingSessionController();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
            dashboardRepositoryProvider
                .overrideWithValue(_ExplodingDashboardRepository()),
            sessionControllerProvider.overrideWith((ref) => controller),
          ],
          child: const KhAdminApp(),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('splash-screen')), findsOneWidget);
      expect(find.text('Karat Hive Portal'), findsNothing);

      controller.resolveUnauthenticated();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('splash-screen')), findsNothing);
      expect(find.byKey(const Key('login-google-button')), findsOneWidget);
    },
  );

  testWidgets('a resolved authenticated session reaches the shell', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = _PendingSessionController();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
          dashboardRepositoryProvider
              .overrideWithValue(_FakeDashboardRepository()),
          sessionControllerProvider.overrideWith((ref) => controller),
        ],
        child: const KhAdminApp(),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('splash-screen')), findsOneWidget);

    controller.resolveAuthenticated();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('splash-screen')), findsNothing);
    expect(find.text('Karat Hive Portal'), findsOneWidget);
  });
}

/// A controller that stays mid-bootstrap until the test says otherwise.
class _PendingSessionController extends StateNotifier<SessionState>
    implements SessionController {
  _PendingSessionController()
      : super(const SessionState(
          status: SessionStatus.loading,
          bootstrapped: false,
        ));

  void resolveUnauthenticated() {
    state = const SessionState(status: SessionStatus.unauthenticated);
  }

  void resolveAuthenticated() {
    state = SessionState(
      status: SessionStatus.authenticated,
      tokens: SessionTokens(
        accessToken: 'test-access-token',
        accessExpiresAt:
            DateTime.fromMillisecondsSinceEpoch(1798761599000, isUtc: true),
        refreshToken: 'test-refresh-token',
        refreshExpiresAt:
            DateTime.fromMillisecondsSinceEpoch(1798761599000, isUtc: true),
      ),
      admin: AdminUser(
        userId: 'admin-1',
        userType: 'ADMIN',
        email: 'admin@karathive.ae',
        displayName: 'Super Admin',
      ),
    );
  }

  @override
  Future<void> init() async {}
  @override
  Future<void> login(String email, String password) async {}
  @override
  Future<void> loginWithPassword(String email, String password) async {}
  @override
  Future<void> loginWithGoogle() async {}
  @override
  Future<void> loginWithGoogleIdToken(String idToken) async {}
  @override
  Future<void> onFirebaseReady(FirebaseAuthService? authService) async {}
  @override
  Future<void> logout({bool broadcast = true}) async {}
  @override
  Future<bool> silentRefresh() async => true;
}

class _FakeTokenStorage extends TokenStorage {
  @override
  Future<SessionTokens?> loadTokens() async => null;
  @override
  Future<void> saveTokens(SessionTokens tokens) async {}
  @override
  Future<void> clearTokens() async {}
}

/// Any call here means a protected screen mounted before the session resolved.
class _ExplodingDashboardRepository implements DashboardRepository {
  Never _fail() => fail('Dashboard data was fetched before the session resolved');

  @override
  Future<DashboardStats> fetchStats({DateTime? from, DateTime? to}) async =>
      _fail();
  @override
  Future<List<DashboardQueueItem>> fetchVerificationSnapshot() async => _fail();
  @override
  Future<List<DashboardQueueItem>> fetchAbuseSnapshot() async => _fail();
  @override
  Future<List<DashboardQueueItem>> fetchPendingReviewsSnapshot() async =>
      _fail();
  @override
  Future<ReportResult> fetchTrend(ReportFilters filters) async => _fail();
}

class _FakeDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardStats> fetchStats({DateTime? from, DateTime? to}) async {
    return const DashboardStats(
      totalCustomers: 100,
      totalVendors: 20,
      pendingVerificationVendors: 2,
      activeRequests: 50,
      activeOffers: 120,
      activeConnections: 30,
    );
  }

  @override
  Future<List<DashboardQueueItem>> fetchVerificationSnapshot() async => const [];
  @override
  Future<List<DashboardQueueItem>> fetchAbuseSnapshot() async => const [];
  @override
  Future<List<DashboardQueueItem>> fetchPendingReviewsSnapshot() async =>
      const [];
  @override
  Future<ReportResult> fetchTrend(ReportFilters filters) async => ReportResult(
        name: ReportName.requestVolume,
        generatedAt: DateTime.utc(2026, 9, 9),
      );
}
