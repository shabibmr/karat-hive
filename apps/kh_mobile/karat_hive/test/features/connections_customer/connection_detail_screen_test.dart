import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karat_hive/app/di.dart';
import 'package:karat_hive/core/firebase/firebase_analytics_service.dart';
import 'package:karat_hive/features/connections_customer/presentation/connection_detail_screen.dart';
import 'package:karat_hive/features/connections_customer/repository/connections_repository.dart';
import 'package:karat_hive/features/reviews/repository/reviews_repository.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

class _FakeTokenStorage extends TokenStorage {
  @override
  Future<SessionTokens?> read() async => null;
}

/// Avoids constructing FirebaseAnalytics.instance in widget tests.
class _FakeAnalytics implements FirebaseAnalyticsService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {}
}

class _FakeReviewsRepository implements ReviewsRepository {
  _FakeReviewsRepository({this.authoredConnectionIds = const {}});

  final Set<String> authoredConnectionIds;

  @override
  Future<Result<Review>> create({
    required String connectionId,
    required int rating,
    String? comment,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> flag(String id) async => const Ok(null);

  @override
  Future<Result<PagedResult<Review>>> list({
    ReviewListRole? role,
    String? cursor,
    int limit = 20,
  }) async {
    final items = authoredConnectionIds
        .map(
          (id) => Review(
            id: 'rev-$id',
            connectionId: id,
            authorType: PartyRole.customer,
            rating: 5,
            state: ReviewState.pendingModeration,
            editableUntil: DateTime.now().add(const Duration(days: 14)),
            createdAt: DateTime.now(),
          ),
        )
        .toList();
    return Ok(PagedResult(items: items));
  }

  @override
  Future<Result<Review>> patch(String id, {int? rating, String? comment}) =>
      throw UnimplementedError();

  @override
  Future<Result<Review>> respond(String id, {required String response}) =>
      throw UnimplementedError();

  @override
  Future<Result<Review>> withdraw(String id) => throw UnimplementedError();

  @override
  Future<Result<VendorPerformanceDto>> getPerformance() =>
      throw UnimplementedError();
}

class _FakeConnectionsRepository implements ConnectionsRepository {
  _FakeConnectionsRepository({required this.connection});

  ConnectionForCustomer connection;
  int closeCallCount = 0;

  @override
  Future<Result<PagedResult<ConnectionForCustomer>>> listMine({
    String? state,
    String? cursor,
  }) async =>
      Ok(PagedResult(items: [connection]));

  @override
  Future<Result<ConnectionForCustomer>> getById(String id) async =>
      Ok(connection);

  @override
  Future<Result<ConnectionForCustomer>> close(String id, {String? reason}) async {
    closeCallCount++;
    connection = ConnectionForCustomer.fromJson({
      ...connection.toJson(),
      'id': id,
      'state': 'CLOSED',
      'closedAt': DateTime.now().toIso8601String(),
      'closedBy': 'CUSTOMER',
    });
    return Ok(connection);
  }

  @override
  Future<Result<void>> recordContactEvent(
    String id, {
    required String channel,
  }) async =>
      const Ok(null);
}

ConnectionForCustomer _createConnection({
  String id = 'conn-1',
  String? logoUrl,
}) {
  return ConnectionForCustomer.fromJson({
    'id': id,

    'state': 'ACTIVE',
    'identityRevealedAt': '2026-09-01T12:00:00.000Z',
    'vendor': {
      'tradingName': 'Al Baraka Gold',
      'mobileNumber': '+971509998877',
      if (logoUrl != null) 'logoUrl': logoUrl,
    },
    'talk': {
      'available': true,
      'waUrl': 'https://wa.me/971509998877?text=Hello',
      'phone': '+971509998877',
      'callUrl': 'tel:+971509998877',
    },
  });
}

Widget _host(
  ConnectionsRepository repo,
  String connectionId, {
  ReviewsRepository? reviewsRepo,
  void Function(Uri uri)? onReviewRouteVisited,
  void Function(Uri uri)? onConnectionsListVisited,
}) {
  final router = GoRouter(
    initialLocation: '/customer/connections/$connectionId',
    routes: [
      GoRoute(
        path: '/customer/connections',
        builder: (context, state) {
          onConnectionsListVisited?.call(state.uri);
          return const Scaffold(body: Text('Customer Connections List'));
        },
        routes: [
          GoRoute(
            path: ':connectionId',
            builder: (context, state) => ConnectionDetailScreen(
              connectionId: state.pathParameters['connectionId']!,
            ),
            routes: [
              GoRoute(
                path: 'review',
                builder: (context, state) {
                  onReviewRouteVisited?.call(state.uri);
                  return Scaffold(
                    body: Text(
                      'Customer Review Destination connectionId=${state.pathParameters['connectionId']}',
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    retry: (_, _) => null,
    overrides: [
      connectionsRepositoryProvider.overrideWithValue(repo),
      reviewsRepositoryProvider.overrideWithValue(
        reviewsRepo ?? _FakeReviewsRepository(),
      ),
      tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
      firebaseAnalyticsServiceProvider.overrideWithValue(_FakeAnalytics()),
    ],
    child: MaterialApp.router(
      theme: khTheme(),
      localizationsDelegates: KhStrings.delegates,
      supportedLocales: KhStrings.supportedLocales,
      routerConfig: router,
    ),
  );
}

Future<void> _confirmClose(WidgetTester tester) async {
  final closeButtonFinder = find.byKey(const Key('close-connection-button'));
  expect(closeButtonFinder, findsOneWidget);
  await tester.ensureVisible(closeButtonFinder);
  await tester.tap(closeButtonFinder);
  await tester.pumpAndSettle();

  final confirmButtonFinder = find.descendant(
    of: find.byType(KhConfirmDialog),
    matching: find.widgetWithText(KhButton, 'Close Connection'),
  );
  expect(confirmButtonFinder, findsOneWidget);
  await tester.tap(confirmButtonFinder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('CUS-S15 shows the vendor logo avatar when logoUrl is present (Phase 4)',
      (tester) async {
    final repo = _FakeConnectionsRepository(
      connection: _createConnection(logoUrl: '/v1/media/logo-key-abc'),
    );

    await tester.pumpWidget(_host(repo, 'conn-1'));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('connection-vendor-logo')), findsOneWidget);
    expect(find.text('Al Baraka Gold'), findsOneWidget);
  });

  testWidgets('CUS-S15 shows no logo avatar when the vendor has none', (tester) async {
    final repo = _FakeConnectionsRepository(connection: _createConnection());

    await tester.pumpWidget(_host(repo, 'conn-1'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('connection-vendor-logo')), findsNothing);
    expect(find.text('Al Baraka Gold'), findsOneWidget);
  });

  testWidgets(
    'closing connection with no review goes to leave-review',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = _FakeConnectionsRepository(
        connection: _createConnection(id: 'conn-close-test'),
      );
      Uri? visitedUri;

      await tester.pumpWidget(
        _host(
          repo,
          'conn-close-test',
          onReviewRouteVisited: (uri) => visitedUri = uri,
        ),
      );
      await tester.pumpAndSettle();
      await _confirmClose(tester);

      expect(repo.closeCallCount, 1);
      expect(visitedUri, isNotNull);
      expect(visitedUri!.path, '/customer/connections/conn-close-test/review');
      expect(
        find.text('Customer Review Destination connectionId=conn-close-test'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'closing connection after review goes to connections list',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = _FakeConnectionsRepository(
        connection: _createConnection(id: 'conn-close-reviewed'),
      );
      Uri? listUri;

      await tester.pumpWidget(
        _host(
          repo,
          'conn-close-reviewed',
          reviewsRepo: _FakeReviewsRepository(
            authoredConnectionIds: {'conn-close-reviewed'},
          ),
          onConnectionsListVisited: (uri) => listUri = uri,
        ),
      );
      await tester.pumpAndSettle();
      await _confirmClose(tester);

      expect(repo.closeCallCount, 1);
      expect(listUri, isNotNull);
      expect(listUri!.path, '/customer/connections');
      expect(find.text('Customer Connections List'), findsOneWidget);
    },
  );

  testWidgets(
    'closing connection with myReview on detail goes to connections list',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final withReview = ConnectionForCustomer.fromJson({
        ..._createConnection(id: 'conn-my-review').toJson(),
        'myReview': {
          'id': 'rev-1',
          'connectionId': 'conn-my-review',
          'authorType': 'CUSTOMER',
          'rating': 4,
          'state': 'PENDING_MODERATION',
          'editableUntil': '2026-12-01T00:00:00.000Z',
          'createdAt': '2026-09-01T00:00:00.000Z',
        },
      });
      final repo = _FakeConnectionsRepository(connection: withReview);
      Uri? listUri;

      await tester.pumpWidget(
        _host(
          repo,
          'conn-my-review',
          // AUTHOR list empty — myReview alone must still skip leave-review.
          reviewsRepo: _FakeReviewsRepository(),
          onConnectionsListVisited: (uri) => listUri = uri,
        ),
      );
      await tester.pumpAndSettle();
      await _confirmClose(tester);

      expect(listUri!.path, '/customer/connections');
      expect(find.text('Customer Connections List'), findsOneWidget);
    },
  );
}
