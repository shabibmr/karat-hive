import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karat_hive/features/connections/presentation/connection_detail_screen.dart';
import 'package:karat_hive/features/connections/repository/connections_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

class _FakeConnectionsRepository implements ConnectionsRepository {
  _FakeConnectionsRepository({required this.connection});

  ConnectionForVendor connection;
  int closeCallCount = 0;
  String? lastClosedId;

  @override
  Future<Result<PagedResult<ConnectionForVendor>>> listMine({
    String? state,
    String? cursor,
  }) async {
    return Ok(PagedResult(items: [connection]));
  }

  @override
  Future<Result<ConnectionForVendor>> get(String connectionId) async {
    return Ok(connection);
  }

  @override
  Future<Result<ConnectionForVendor>> close(String connectionId) async {
    closeCallCount++;
    lastClosedId = connectionId;
    connection = ConnectionForVendor.fromJson({
      'id': connectionId,
      'state': 'CLOSED',
      'identityRevealedAt': connection.identityRevealedAt.toIso8601String(),
      'closedAt': DateTime.now().toIso8601String(),
      'closedBy': 'VENDOR',
      'customer': {
        'displayName': connection.customer.displayName,
        'phone': connection.customer.mobile.e164,
      },
      'talk': {
        'available': false,
        'waUrl': '',
        'phone': connection.customer.mobile.e164,
        'callUrl': '',
      },
    });
    return Ok(connection);
  }

  @override
  Future<Result<void>> recordContactEvent({
    required String connectionId,
    required String channel,
  }) async =>
      const Ok(null);
}

ConnectionForVendor _createConnection({
  String id = 'conn-101',
  ConnectionState state = ConnectionState.active,
}) {
  return ConnectionForVendor.fromJson({
    'id': id,
    'state': state == ConnectionState.closed ? 'CLOSED' : 'ACTIVE',
    'identityRevealedAt': '2026-09-01T12:00:00.000Z',
    'customer': {
      'displayName': 'Fatima Al Zahra',
      'phone': '+971501234567',
    },
    'talk': {
      'available': state == ConnectionState.active,
      'waUrl': 'https://wa.me/971501234567?text=Hello',
      'phone': '+971501234567',
      'callUrl': 'tel:+971501234567',
    },
    'request': {
      'id': 'req-1',
      'reference': 'KH-RQ-24A1',
      'requestType': 'FIND_ORNAMENT',
      'direction': 'BUY',
    },
    'offer': {
      'id': 'off-1',
      'offeredPrice': '12500.00',
    },
  });
}

GoRouter _buildRouter({
  required String initialLocation,
  void Function(Uri uri)? onReviewRouteVisited,
  void Function(Uri uri)? onAbuseRouteVisited,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/vendor/connections/:connectionId',
        builder: (context, state) => ConnectionDetailScreen(
          connectionId: state.pathParameters['connectionId']!,
        ),
      ),
      GoRoute(
        path: '/vendor/connections/:connectionId/review',
        builder: (context, state) {
          onReviewRouteVisited?.call(state.uri);
          return Scaffold(
            body: Text(
              'Review Destination connectionId=${state.pathParameters['connectionId']}',
            ),
          );
        },
      ),
      GoRoute(
        path: '/abuse/new',
        builder: (context, state) {
          onAbuseRouteVisited?.call(state.uri);
          return Scaffold(
            body: Text(
              'Abuse Destination targetType=${state.uri.queryParameters['targetType']}&targetId=${state.uri.queryParameters['targetId']}',
            ),
          );
        },
      ),
    ],
  );
}

void main() {
  testWidgets(
    'tapping Leave feedback navigates / pushes /vendor/connections/:id/review when active',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = _FakeConnectionsRepository(
        connection: _createConnection(id: 'conn-101', state: ConnectionState.active),
      );

      Uri? visitedUri;
      final router = _buildRouter(
        initialLocation: '/vendor/connections/conn-101',
        onReviewRouteVisited: (uri) => visitedUri = uri,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectionsRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp.router(
            theme: khTheme(),
            localizationsDelegates: KhStrings.delegates,
            supportedLocales: KhStrings.supportedLocales,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final leaveFeedbackFinder = find.byKey(const Key('connection-leave-feedback'));
      expect(leaveFeedbackFinder, findsOneWidget);

      await tester.ensureVisible(leaveFeedbackFinder);
      await tester.tap(leaveFeedbackFinder);
      await tester.pumpAndSettle();

      expect(visitedUri, isNotNull);
      expect(visitedUri!.path, '/vendor/connections/conn-101/review');
      expect(find.text('Review Destination connectionId=conn-101'), findsOneWidget);
    },
  );

  testWidgets(
    'Leave feedback button is visible and active when connection is closed',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = _FakeConnectionsRepository(
        connection: _createConnection(id: 'conn-closed', state: ConnectionState.closed),
      );

      Uri? visitedUri;
      final router = _buildRouter(
        initialLocation: '/vendor/connections/conn-closed',
        onReviewRouteVisited: (uri) => visitedUri = uri,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectionsRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp.router(
            theme: khTheme(),
            localizationsDelegates: KhStrings.delegates,
            supportedLocales: KhStrings.supportedLocales,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Banner should be displayed, Close button should not exist
      expect(find.byKey(const Key('connection-closed-banner')), findsOneWidget);
      expect(find.byKey(const Key('close-connection-button')), findsNothing);

      final leaveFeedbackFinder = find.byKey(const Key('connection-leave-feedback'));
      expect(leaveFeedbackFinder, findsOneWidget);

      await tester.ensureVisible(leaveFeedbackFinder);
      await tester.tap(leaveFeedbackFinder);
      await tester.pumpAndSettle();

      expect(visitedUri, isNotNull);
      expect(visitedUri!.path, '/vendor/connections/conn-closed/review');
      expect(find.text('Review Destination connectionId=conn-closed'), findsOneWidget);
    },
  );

  testWidgets(
    'closing connection succeeds and provides review navigation',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = _FakeConnectionsRepository(
        connection: _createConnection(id: 'conn-close-test', state: ConnectionState.active),
      );

      Uri? visitedUri;
      final router = _buildRouter(
        initialLocation: '/vendor/connections/conn-close-test',
        onReviewRouteVisited: (uri) => visitedUri = uri,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectionsRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp.router(
            theme: khTheme(),
            localizationsDelegates: KhStrings.delegates,
            supportedLocales: KhStrings.supportedLocales,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final closeButtonFinder = find.byKey(const Key('close-connection-button'));
      expect(closeButtonFinder, findsOneWidget);

      await tester.ensureVisible(closeButtonFinder);
      await tester.tap(closeButtonFinder);
      await tester.pumpAndSettle();

      // Confirmation dialog should be visible
      expect(find.byType(KhConfirmDialog), findsOneWidget);

      // Tap confirm button ("Close Connection") inside dialog
      final confirmButtonFinder = find.descendant(
        of: find.byType(KhConfirmDialog),
        matching: find.widgetWithText(KhButton, 'Close Connection'),
      );
      expect(confirmButtonFinder, findsOneWidget);

      await tester.tap(confirmButtonFinder);
      await tester.pumpAndSettle();

      // Verify repository close was invoked
      expect(repo.closeCallCount, 1);
      expect(repo.lastClosedId, 'conn-close-test');

      // Verify navigated to review screen
      expect(visitedUri, isNotNull);
      expect(visitedUri!.path, '/vendor/connections/conn-close-test/review');
      expect(find.text('Review Destination connectionId=conn-close-test'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping Report button navigates to /abuse/new?targetType=CONNECTION&targetId=... when active',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = _FakeConnectionsRepository(
        connection: _createConnection(id: 'conn-101', state: ConnectionState.active),
      );

      Uri? visitedUri;
      final router = _buildRouter(
        initialLocation: '/vendor/connections/conn-101',
        onAbuseRouteVisited: (uri) => visitedUri = uri,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectionsRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp.router(
            theme: khTheme(),
            localizationsDelegates: KhStrings.delegates,
            supportedLocales: KhStrings.supportedLocales,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final reportButtonFinder = find.widgetWithText(TextButton, 'Report');
      expect(reportButtonFinder, findsOneWidget);

      await tester.ensureVisible(reportButtonFinder);
      await tester.tap(reportButtonFinder);
      await tester.pumpAndSettle();

      expect(visitedUri, isNotNull);
      expect(visitedUri!.path, '/abuse/new');
      expect(visitedUri!.queryParameters['targetType'], 'CONNECTION');
      expect(visitedUri!.queryParameters['targetId'], 'conn-101');
      expect(
        find.text('Abuse Destination targetType=CONNECTION&targetId=conn-101'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'tapping Report button navigates to /abuse/new?targetType=CONNECTION&targetId=... when closed',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = _FakeConnectionsRepository(
        connection: _createConnection(id: 'conn-closed', state: ConnectionState.closed),
      );

      Uri? visitedUri;
      final router = _buildRouter(
        initialLocation: '/vendor/connections/conn-closed',
        onAbuseRouteVisited: (uri) => visitedUri = uri,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectionsRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp.router(
            theme: khTheme(),
            localizationsDelegates: KhStrings.delegates,
            supportedLocales: KhStrings.supportedLocales,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final reportButtonFinder = find.widgetWithText(TextButton, 'Report');
      expect(reportButtonFinder, findsOneWidget);

      await tester.ensureVisible(reportButtonFinder);
      await tester.tap(reportButtonFinder);
      await tester.pumpAndSettle();

      expect(visitedUri, isNotNull);
      expect(visitedUri!.path, '/abuse/new');
      expect(visitedUri!.queryParameters['targetType'], 'CONNECTION');
      expect(visitedUri!.queryParameters['targetId'], 'conn-closed');
      expect(
        find.text('Abuse Destination targetType=CONNECTION&targetId=conn-closed'),
        findsOneWidget,
      );
    },
  );
}
