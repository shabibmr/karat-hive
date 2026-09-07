import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../../app/platform/open_url.dart';
import '../controller/connections_controller.dart';
import '../repository/connections_repository.dart';

/// VEN-S12 — Connections list. Active first, then Closed.
class ConnectionsScreen extends ConsumerStatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  ConsumerState<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends ConsumerState<ConnectionsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(connectionsControllerProvider.notifier).loadNextPage();
    }
  }

  Future<void> _talkShortcut(ConnectionForVendor conn) async {
    if (!conn.talk.canOpenWhatsApp) return;
    final opened = await openExternalUrl(conn.talk.waUrl);
    if (opened) {
      await ref.read(connectionsRepositoryProvider).recordContactEvent(
            connectionId: conn.id,
            channel: 'WHATSAPP',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(connectionsControllerProvider);
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;

    return Scaffold(
      key: const Key('connections-screen'),
      appBar: AppBar(
        title: Text(l10n?.connectionsTitle ?? 'Connections'),
      ),
      body: ValueListenableBuilder<PagedListState<ConnectionForVendor>>(
        valueListenable: controller,
        builder: (context, listState, _) {
          if (listState.status == PagedListStatus.loadingFirstPage) {
            return const Center(child: CircularProgressIndicator());
          }
          if (listState.status == PagedListStatus.error &&
              listState.items.isEmpty) {
            return KhErrorView(
              message: switch (listState.error) {
                final Failure f => f.message ??
                    (l10n?.couldNotLoadConnections ??
                        'Could not load Connections.'),
                _ => l10n?.couldNotLoadConnections ??
                    'Could not load Connections.',
              },
              onRetry: () =>
                  ref.read(connectionsControllerProvider.notifier).retry(),
            );
          }
          if (listState.items.isEmpty) {
            return KhEmptyView(
              message: l10n?.connectionsEmptyBody ??
                  'No Connections yet. Accepted Offers appear here.',
            );
          }

          final active = listState.items
              .where((c) => c.state == ConnectionState.active)
              .toList(growable: false);
          final closed = listState.items
              .where((c) => c.state != ConnectionState.active)
              .toList(growable: false);

          return KhPullToRefresh(
            onRefresh: () =>
                ref.read(connectionsControllerProvider.notifier).refresh(),
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.all(tokens.space.md),
              children: [
                if (active.isNotEmpty) ...[
                  KhSectionHeader(
                    title: l10n?.connectionSectionActive ?? 'Active',
                  ),
                  SizedBox(height: tokens.space.sm),
                  ...active.map(
                    (conn) => Padding(
                      padding: EdgeInsets.only(bottom: tokens.space.sm),
                      child: ConnectionSummaryRow(
                        connectionId: conn.id,
                        counterpartyName: conn.customer.displayName,
                        state: conn.state,
                        requestReference: conn.request?.reference,
                        offeredPrice: conn.acceptedOffer?.terms.offeredPrice,
                        connectedAt: conn.connectedAt,
                        onTalk: conn.talk.canOpenWhatsApp
                            ? () => _talkShortcut(conn)
                            : null,
                        onTap: () =>
                            context.push('/vendor/connections/${conn.id}'),
                      ),
                    ),
                  ),
                ],
                if (closed.isNotEmpty) ...[
                  if (active.isNotEmpty) SizedBox(height: tokens.space.md),
                  KhSectionHeader(
                    title: l10n?.connectionSectionClosed ?? 'Closed',
                  ),
                  SizedBox(height: tokens.space.sm),
                  ...closed.map(
                    (conn) => Padding(
                      padding: EdgeInsets.only(bottom: tokens.space.sm),
                      child: ConnectionSummaryRow(
                        connectionId: conn.id,
                        counterpartyName: conn.customer.displayName,
                        state: conn.state,
                        requestReference: conn.request?.reference,
                        offeredPrice: conn.acceptedOffer?.terms.offeredPrice,
                        connectedAt: conn.connectedAt,
                        onTap: () =>
                            context.push('/vendor/connections/${conn.id}'),
                      ),
                    ),
                  ),
                ],
                if (listState.hasMore)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
