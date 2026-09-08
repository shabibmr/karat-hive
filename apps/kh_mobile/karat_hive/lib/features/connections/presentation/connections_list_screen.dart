import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../../app/platform/open_url.dart';
import '../../../core/failure_copy.dart';
import '../controller/connections_controller.dart';
import '../repository/connections_repository.dart';

/// CUS-S16 — Connections list. ACTIVE first. Revealed Vendor name only.
class ConnectionsListScreen extends ConsumerWidget {
  const ConnectionsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(connectionsListProvider);
    final s = KhStrings.of(context);
    final tokens = context.tokens;

    return Scaffold(
      key: const Key('connections-list-screen'),
      appBar: AppBar(title: Text(s.s('connections.title'))),
      body: async.when(
        loading: () => const KhLoadingView(),
        error: (err, _) => KhErrorView(
          message: khFailureMessage(err, s.s('common.retry')),
          onRetry: () => ref.read(connectionsListProvider.notifier).reload(),
          retryLabel: s.s('common.retry'),
        ),
        data: (items) {
          if (items.isEmpty) {
            return KhPullToRefresh(
              onRefresh: () =>
                  ref.read(connectionsListProvider.notifier).reload(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: tokens.space.xl * 4),
                  KhEmptyView(message: s.s('connections.empty')),
                ],
              ),
            );
          }
          final active =
              items.where((c) => c.state == ConnectionState.active).toList();
          final closed =
              items.where((c) => c.state != ConnectionState.active).toList();
          return KhPullToRefresh(
            onRefresh: () =>
                ref.read(connectionsListProvider.notifier).reload(),
            child: ListView(
              padding: EdgeInsets.all(tokens.space.md),
              children: [
                if (active.isNotEmpty) ...[
                  KhSectionHeader(title: s.s('connections.active')),
                  SizedBox(height: tokens.space.sm),
                  for (final c in active) _ConnectionTile(connection: c),
                  SizedBox(height: tokens.space.lg),
                ],
                if (closed.isNotEmpty) ...[
                  KhSectionHeader(title: s.s('connections.closed')),
                  SizedBox(height: tokens.space.sm),
                  for (final c in closed) _ConnectionTile(connection: c),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ConnectionTile extends ConsumerWidget {
  const _ConnectionTile({required this.connection});

  final ConnectionForCustomer connection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = KhStrings.of(context);
    final tokens = context.tokens;
    final price = num.tryParse(connection.acceptedOffer?.terms.offeredPrice ?? '');
    final active = connection.state == ConnectionState.active;

    return Card(
      key: Key('connection-tile-${connection.id}'),
      margin: EdgeInsets.only(bottom: tokens.space.sm),
      child: InkWell(
        onTap: () => context.push('/customer/connections/${connection.id}'),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      connection.vendor.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  KhStatusChip(
                    label: connection.state.wire,
                    tone: active ? KhStatusTone.success : KhStatusTone.neutral,
                    compact: true,
                  ),
                ],
              ),
              if (connection.request?.reference != null) ...[
                SizedBox(height: tokens.space.xs),
                Text(
                  connection.request!.reference!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (price != null) ...[
                SizedBox(height: tokens.space.xs),
                MoneyDisplay(amount: price, highlight: true),
              ],
              if (active && connection.talk.available) ...[
                SizedBox(height: tokens.space.sm),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    key: Key('talk-shortcut-${connection.id}'),
                    onPressed: () async {
                      await ref
                          .read(connectionsRepositoryProvider)
                          .recordContactEvent(connectionId: connection.id, channel: 'WHATSAPP');
                      final url = connection.talk.waUrl;
                      if (url.isEmpty) return;
                      await openExternalUrl(url);
                    },
                    icon: const Icon(Icons.chat_outlined),
                    label: Text(s.s('connections.talk')),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
