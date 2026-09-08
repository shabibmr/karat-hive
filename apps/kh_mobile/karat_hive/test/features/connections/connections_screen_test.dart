import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/connections/presentation/connections_screen.dart';
import 'package:karat_hive/features/connections/repository/connections_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

class FakeConnectionsRepository implements ConnectionsRepository {
  FakeConnectionsRepository({this.items = const [], this.error});

  final List<ConnectionForVendor> items;
  final Failure? error;

  @override
  Future<Result<PagedResult<ConnectionForVendor>>> listMine({
    String? state,
    String? cursor,
  }) async {
    if (error != null) return Err(error!);
    return Ok(PagedResult(items: items));
  }

  @override
  Future<Result<ConnectionForVendor>> get(String connectionId) async {
    if (error != null) return Err(error!);
    return Ok(items.first);
  }

  @override
  Future<Result<ConnectionForVendor>> close(String connectionId) async {
    return Err(const ConflictFailure(code: 'CONNECTION_CLOSED'));
  }

  @override
  Future<Result<void>> recordContactEvent({
    required String connectionId,
    required String channel,
  }) async =>
      const Ok(null);

  @override
  Future<Result<PagedResult<ConnectionForCustomer>>> listMineForCustomer({
    String? state,
    String? cursor,
  }) async =>
      const Ok(PagedResult.empty());

  @override
  Future<Result<ConnectionForCustomer>> getById(String id) async =>
      const Err(NotFoundFailure());

  @override
  Future<Result<ConnectionForCustomer>> closeCustomer(
    String id, {
    String? reason,
  }) async =>
      const Err(ConflictFailure(code: 'CONNECTION_CLOSED'));
}

Widget _host({
  required FakeConnectionsRepository repo,
}) {
  return ProviderScope(
    overrides: [
      connectionsRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp(
      theme: khTheme(),
      localizationsDelegates: KhStrings.delegates,
      supportedLocales: KhStrings.supportedLocales,
      home: const ConnectionsScreen(),
    ),
  );
}

void main() {
  testWidgets('VEN-S12 empty state', (tester) async {
    await tester.pumpWidget(
      _host(repo: FakeConnectionsRepository(items: const [])),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('connections-screen')), findsOneWidget);
    expect(find.byKey(const Key('empty-view')), findsOneWidget);
    expect(find.textContaining('No Connections yet'), findsOneWidget);
  });

  testWidgets('VEN-S12 error state with retry', (tester) async {
    await tester.pumpWidget(
      _host(
        repo: FakeConnectionsRepository(
          error: const NetworkFailure(message: 'offline'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('error-view')), findsOneWidget);
    expect(find.text('offline'), findsOneWidget);
  });
}
