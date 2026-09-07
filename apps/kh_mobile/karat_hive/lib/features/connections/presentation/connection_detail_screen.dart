import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../../app/platform/open_url.dart';
import '../controller/connection_detail_controller.dart';
import '../controller/connections_controller.dart';

/// VEN-S13 — Connection detail (revealed Customer, Talk, close).
class ConnectionDetailScreen extends ConsumerWidget {
  const ConnectionDetailScreen({super.key, required this.connectionId});

  final String connectionId;

  Future<void> _talk(
    BuildContext context,
    WidgetRef ref,
    ConnectionForVendor conn,
    AppLocalizations? l10n,
  ) async {
    if (!conn.talk.canOpenWhatsApp) return;
    final opened = await openExternalUrl(conn.talk.waUrl);
    if (opened) {
      await ref
          .read(connectionDetailProvider(connectionId).notifier)
          .recordContactEvent('WHATSAPP');
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n?.connectionCouldNotOpenTalk ?? 'Could not open WhatsApp.',
        ),
      ),
    );
  }

  Future<void> _call(
    BuildContext context,
    WidgetRef ref,
    ConnectionForVendor conn,
  ) async {
    if (!conn.talk.canCall) return;
    final opened = await openExternalUrl(conn.talk.callUrl);
    if (opened) {
      await ref
          .read(connectionDetailProvider(connectionId).notifier)
          .recordContactEvent('PHONE');
    }
  }

  Future<void> _close(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations? l10n,
  ) async {
    final confirmed = await showKhConfirmDialog(
      context,
      title: l10n?.connectionCloseConfirmTitle ?? 'Close this Connection?',
      body: l10n?.connectionCloseConfirmBody ??
          'Details stay available. Reviews open in Check-Point 5.',
      confirmLabel: l10n?.connectionClose ?? 'Close Connection',
      cancelLabel: l10n?.commonCancel ?? 'Cancel',
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    final res = await ref
        .read(connectionDetailProvider(connectionId).notifier)
        .close();
    if (!context.mounted) return;
    res.when(
      ok: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.connectionReviewsCp5 ?? 'Reviews open in Check-Point 5',
            ),
          ),
        );
        ref.invalidate(connectionsControllerProvider);
        context.go('/vendor/connections');
      },
      err: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failure.message ??
                  (l10n?.couldNotLoadConnection ??
                      'Could not load this Connection.'),
            ),
          ),
        );
      },
    );
  }

  void _cp5Snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(connectionDetailProvider(connectionId));
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;

    return Scaffold(
      key: const Key('connection-detail-screen'),
      appBar: AppBar(
        title: Text(l10n?.connectionDetailTitle ?? 'Connection'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => KhErrorView(
          message: switch (err) {
            final Failure f => f.message ??
                (l10n?.couldNotLoadConnection ??
                    'Could not load this Connection.'),
            _ => l10n?.couldNotLoadConnection ??
                'Could not load this Connection.',
          },
          onRetry: () =>
              ref.read(connectionDetailProvider(connectionId).notifier).reload(),
        ),
        data: (conn) {
          final closed = conn.state == ConnectionState.closed;
          return ListView(
            padding: EdgeInsets.all(tokens.space.md),
            children: [
              if (closed) ...[
                ConnectionClosedBanner(
                  message: l10n?.connectionClosedBanner,
                ),
                SizedBox(height: tokens.space.md),
              ],
              RevealedPartyCard(
                party: conn.customer,
                onCall: (!closed && conn.talk.canCall)
                    ? () => _call(context, ref, conn)
                    : null,
              ),
              SizedBox(height: tokens.space.md),
              if (!closed)
                TalkButton(
                  talk: conn.talk,
                  onTalk: () => _talk(context, ref, conn, l10n),
                  fallback: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      KhInlineError(
                        message: l10n?.connectionWhatsAppMissing ??
                            'WhatsApp is not available. Copy the number or call instead.',
                      ),
                      SizedBox(height: tokens.space.sm),
                      TapToCallControl(
                        mobileNumber: conn.customer.mobile.e164,
                        callUrl: conn.talk.callUrl,
                        onCall: conn.talk.canCall
                            ? () => _call(context, ref, conn)
                            : null,
                      ),
                    ],
                  ),
                ),
              SizedBox(height: tokens.space.lg),
              if (conn.request?.reference != null)
                Text(
                  conn.request!.reference!,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              SizedBox(height: tokens.space.sm),
              Text(
                l10n?.connectionAcceptedTerms ?? 'Accepted Offer terms',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: tokens.space.sm),
              if (conn.acceptedOffer != null)
                OfferTermsReadOnly(terms: conn.acceptedOffer!.terms),
              SizedBox(height: tokens.space.md),
              Text(
                '${l10n?.connectionIdentityRevealedAt ?? 'Identity revealed'} · ${conn.identityRevealedAt.toLocal()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.ink.withValues(alpha: 0.7),
                    ),
              ),
              if (!closed) ...[
                SizedBox(height: tokens.space.lg),
                CloseConnectionButton(
                  onPressed: () => _close(context, ref, l10n),
                ),
              ],
              SizedBox(height: tokens.space.md),
              TextButton(
                onPressed: () => _cp5Snack(
                  context,
                  l10n?.connectionReviewsCp5 ??
                      'Reviews open in Check-Point 5',
                ),
                child: Text(l10n?.connectionLeaveFeedback ?? 'Leave feedback'),
              ),
              TextButton(
                onPressed: () => _cp5Snack(
                  context,
                  l10n?.connectionReviewsCp5 ??
                      'Reviews open in Check-Point 5',
                ),
                child: Text(l10n?.connectionReport ?? 'Report'),
              ),
            ],
          );
        },
      ),
    );
  }
}
