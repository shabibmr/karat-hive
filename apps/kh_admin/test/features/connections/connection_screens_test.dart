import 'dart:async';

import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/connections/model/connection_detail.dart';
import 'package:kh_admin/features/connections/model/connection_enums.dart';
import 'package:kh_admin/features/connections/model/connection_list_filters.dart';
import 'package:kh_admin/features/connections/model/connection_list_item.dart';
import 'package:kh_admin/features/connections/model/connection_list_page.dart';
import 'package:kh_admin/features/connections/presentation/connection_detail_screen.dart';
import 'package:kh_admin/features/connections/presentation/connection_list_screen.dart';
import 'package:kh_admin/features/connections/repository/connection_repository.dart';

class _FakeConnectionRepository extends ConnectionRepository {
  _FakeConnectionRepository() : super(ApiClient());

  bool empty = false;
  bool failNext = false;
  Completer<ConnectionListPage>? listDelay;
  String? closedConnectionId;
  String? closedReason;
  String? addedNote;

  @override
  Future<ConnectionListPage> fetchConnections({
    ConnectionListFilters filters = const ConnectionListFilters(),
    String? cursor,
    int limit = ConnectionRepository.defaultPageSize,
  }) async {
    if (listDelay != null) {
      return listDelay!.future;
    }
    if (failNext) throw Exception('Connections service unavailable');
    if (empty) return const ConnectionListPage(items: []);

    return ConnectionListPage(
      items: [
        ConnectionListItem(
          id: 'conn-1',
          requestId: 'req-1',
          offerId: 'off-1',
          requestType: 'FIND_ORNAMENT',
          customerName: 'Fatima Al Mansoori',
          vendorName: 'Damani Jewellers LLC',
          agreedPriceAed: 18500.0,
          state: ConnectionState.active,
          createdAt: DateTime.now().subtract(const Duration(hours: 50)),
          contactEventsCount: 0,
          lastContactAt: null,
          hasNoContact48h: true,
        ),
      ],
      hasMore: false,
    );
  }

  @override
  Future<ConnectionDetail> fetchConnectionDetail(String connectionId) async {
    if (failNext) throw Exception('Connections service unavailable');

    return ConnectionDetail(
      id: connectionId,
      state: closedConnectionId == connectionId ? ConnectionState.closed : ConnectionState.active,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      identityRevealedAt: DateTime.now().subtract(const Duration(days: 2)),
      customer: const ConnectionCustomerInfo(
        id: 'cust-1',
        displayName: 'Fatima Al Mansoori',
        email: 'fatima@example.ae',
        mobileNumber: '+971501234567',
      ),
      vendor: const ConnectionVendorInfo(
        id: 'ven-1',
        legalBusinessName: 'Damani Jewellers LLC',
        tradingName: 'Damani Dubai',
        email: 'contact@damani.ae',
        mobileNumber: '+97145551234',
        rating: 4.9,
      ),
      request: const ConnectionRequestSummary(
        id: 'req-1',
        reference: 'KH-RQ-001',
        requestType: 'FIND_ORNAMENT',
        description: 'Need gold necklace for wedding',
        indicativeValue: 20000.0,
        purityKarat: 'K22',
        weightGrams: 50.0,
      ),
      offer: const ConnectionOfferSummary(
        id: 'off-1',
        reference: 'KH-OF-001',
        agreedPriceAed: 18500.0,
        validityHours: 24,
        deliveryTimeframe: '3 business days',
        warrantyTerms: 'Lifetime guarantee',
        vendorNote: 'Gift box included',
      ),
      contactEvents: [
        ConnectionContactEvent(
          id: 'ce-1',
          channel: 'WHATSAPP',
          initiatedBy: 'CUSTOMER',
          occurredAt: DateTime.now().subtract(const Duration(hours: 10)),
        ),
      ],
      adminNotes: [
        ConnectionAdminNote(
          id: 'note-1',
          author: 'Platform Admin',
          text: 'Verified manually by compliance.',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ],
    );
  }

  @override
  Future<void> closeConnection(String connectionId, {required String reasonText}) async {
    closedConnectionId = connectionId;
    closedReason = reasonText;
  }

  @override
  Future<ConnectionAdminNote> createAdminNote(String connectionId, String text) async {
    addedNote = text;
    return ConnectionAdminNote(
      id: 'note-new',
      author: 'Platform Admin',
      text: text,
      createdAt: DateTime.now(),
    );
  }
}

void main() {
  late _FakeConnectionRepository fakeRepository;

  setUp(() {
    fakeRepository = _FakeConnectionRepository();
  });

  Widget createTestWidget(Widget child, {String initialLocation = '/'}) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(body: child),
        ),
        GoRoute(
          path: '/connections/:id',
          builder: (context, state) => Scaffold(
            body: Text('Connection Detail ${state.pathParameters['id']}'),
          ),
        ),
        GoRoute(
          path: '/connections',
          builder: (context, state) => const Scaffold(
            body: Text('Back at Connections List'),
          ),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        connectionRepositoryProvider.overrideWithValue(fakeRepository),
      ],
      child: MaterialApp.router(
        theme: buildKhAdminTheme(),
        routerConfig: router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
      ),
    );
  }

  group('ConnectionListScreen (ADM-S12)', () {
    testWidgets('shows loading indicator while connections are in flight', (tester) async {
      fakeRepository.listDelay = Completer<ConnectionListPage>();

      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(const ConnectionListScreen()));
      await tester.pump();

      expect(find.byKey(const Key('connection-list-loading')), findsOneWidget);

      fakeRepository.listDelay!.complete(const ConnectionListPage(items: []));
      await tester.pumpAndSettle();
    });

    testWidgets('renders header, state chips, table with row and SLA warning', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(const ConnectionListScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Connections'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);

      expect(find.text('Fatima Al Mansoori'), findsOneWidget);
      expect(find.text('Damani Jewellers LLC'), findsOneWidget);
      expect(find.text('No contact > 48h'), findsWidgets);

      await tester.tap(find.text('Fatima Al Mansoori'));
      await tester.pumpAndSettle();

      expect(find.text('Connection Detail conn-1'), findsOneWidget);
    });

    testWidgets('renders empty view when no connections match', (tester) async {
      fakeRepository.empty = true;

      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(const ConnectionListScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const Key('connection-empty-view')), findsOneWidget);
    });

    testWidgets('renders error view with retry button on failure', (tester) async {
      fakeRepository.failNext = true;

      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(const ConnectionListScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const Key('connection-error-view')), findsOneWidget);
      expect(find.byKey(const Key('connection-error-retry')), findsOneWidget);
    });
  });

  group('ConnectionDetailScreen (ADM-S13)', () {
    testWidgets('renders details, request card, offer card, events, notes, and close modal', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestWidget(const ConnectionDetailScreen(connectionId: 'conn-100')),
      );
      await tester.pumpAndSettle();

      expect(find.text('CONNECTION #CONN-100'), findsOneWidget);
      expect(find.text('Fatima Al Mansoori ↔ Damani Jewellers LLC'), findsOneWidget);
      expect(find.text('Originating Request'), findsOneWidget);
      expect(find.text('Accepted Offer Terms'), findsOneWidget);
      expect(find.text('Contact Initiation Events'), findsOneWidget);
      expect(find.text('Internal Admin Notes'), findsOneWidget);
      expect(find.text('Verified manually by compliance.'), findsOneWidget);

      // Verify close modal opens and validates
      expect(find.byKey(const Key('close-connection-button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('close-connection-button')));
      await tester.pumpAndSettle();

      expect(find.text('Close Connection'), findsWidgets);
      expect(find.byKey(const Key('close-connection-dialog-confirm')), findsOneWidget);

      // Confirm with empty reason -> validation error
      await tester.tap(find.byKey(const Key('close-connection-dialog-confirm')));
      await tester.pumpAndSettle();
      expect(find.text('Please provide a reason for closing'), findsOneWidget);

      // Enter valid reason and submit
      await tester.enterText(
        find.byKey(const Key('close-connection-reason-input')),
        'Introduction aborted due to stock unavailability.',
      );
      await tester.tap(find.byKey(const Key('close-connection-dialog-confirm')));
      await tester.pumpAndSettle();

      expect(fakeRepository.closedConnectionId, 'conn-100');
      expect(fakeRepository.closedReason, 'Introduction aborted due to stock unavailability.');
    });

    testWidgets('renders error view on detail fetch failure', (tester) async {
      fakeRepository.failNext = true;

      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestWidget(const ConnectionDetailScreen(connectionId: 'conn-100')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('connection-detail-error')), findsOneWidget);
    });
  });
}
