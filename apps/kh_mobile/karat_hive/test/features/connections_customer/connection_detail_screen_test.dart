import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karat_hive/features/connections_customer/presentation/connection_detail_screen.dart';
import 'package:karat_hive/features/connections_customer/repository/connections_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

class _FakeConnectionsRepository implements ConnectionsRepository {
  _FakeConnectionsRepository({required this.connection});

  ConnectionForCustomer connection;

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
  Future<Result<ConnectionForCustomer>> close(String id, {String? reason}) async =>
      Ok(connection);

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

Widget _host(ConnectionsRepository repo, String connectionId) {
  final router = GoRouter(
    initialLocation: '/customer/connections/$connectionId',
    routes: [
      GoRoute(
        path: '/customer/connections/:connectionId',
        builder: (context, state) => ConnectionDetailScreen(
          connectionId: state.pathParameters['connectionId']!,
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      connectionsRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp.router(
      theme: khTheme(),
      localizationsDelegates: KhStrings.delegates,
      supportedLocales: KhStrings.supportedLocales,
      routerConfig: router,
    ),
  );
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
}
