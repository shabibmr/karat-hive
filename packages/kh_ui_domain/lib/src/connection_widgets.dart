import 'package:flutter/material.dart' hide ConnectionState;
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

import 'package:kh_ui_domain/src/money_display.dart';
import 'package:kh_ui_domain/src/relative_time_label.dart';

KhStatusTone connectionStateTone(ConnectionState state) => switch (state) {
      ConnectionState.active => KhStatusTone.success,
      ConnectionState.closed => KhStatusTone.neutral,
      ConnectionState.unknown => KhStatusTone.neutral,
    };

String connectionStateLabel(ConnectionState state, AppLocalizations? l10n) =>
    switch (state) {
      ConnectionState.active => l10n?.connectionStateActive ?? 'Active',
      ConnectionState.closed => l10n?.connectionStateClosed ?? 'Closed',
      ConnectionState.unknown => l10n?.connectionStateUnknown ?? 'Unknown',
    };

/// SH-CON-01 — Connection summary row (counterparty, ref, price, date, state).
class ConnectionSummaryRow extends StatelessWidget {
  const ConnectionSummaryRow({
    super.key,
    required this.connectionId,
    required this.counterpartyName,
    required this.state,
    this.requestReference,
    this.offeredPrice,
    this.connectedAt,
    this.onTap,
    this.onTalk,
  });

  final String connectionId;
  final String counterpartyName;
  final ConnectionState state;
  final String? requestReference;
  final String? offeredPrice;
  final DateTime? connectedAt;
  final VoidCallback? onTap;

  /// Talk shortcut — Active rows only. Parent supplies the callback.
  final VoidCallback? onTalk;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final price = double.tryParse(offeredPrice ?? '');
    final talkEnabled = onTalk != null && state == ConnectionState.active;

    return Card(
      key: Key('connection-summary-$connectionId'),
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.ink.withValues(alpha: 0.12)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      counterpartyName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  KhStatusChip(
                    label: connectionStateLabel(state, l10n),
                    tone: connectionStateTone(state),
                    compact: true,
                  ),
                ],
              ),
              if (requestReference != null && requestReference!.isNotEmpty) ...[
                SizedBox(height: tokens.space.xs),
                Text(
                  requestReference!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.ink.withValues(alpha: 0.7),
                  ),
                ),
              ],
              if (price != null) ...[
                SizedBox(height: tokens.space.sm),
                MoneyDisplay(amount: price, highlight: true),
              ],
              Row(
                children: [
                  if (connectedAt != null)
                    Expanded(
                      child: RelativeTimeLabel(at: connectedAt!),
                    )
                  else
                    const Spacer(),
                  if (talkEnabled)
                    TextButton.icon(
                      key: Key('connection-talk-shortcut-$connectionId'),
                      onPressed: onTalk,
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: Text(l10n?.connectionTalk ?? 'Talk'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// SH-CON-02 — Talk (WhatsApp) button.
///
/// Opens the server-supplied [TalkPayload.waUrl] via [onTalk]. Never builds a
/// `wa.me` link from raw digits.
class TalkButton extends StatelessWidget {
  const TalkButton({
    super.key,
    required this.talk,
    required this.onTalk,
    this.label,
    this.fallback,
  });

  final TalkPayload talk;
  final VoidCallback onTalk;
  final String? label;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!talk.canOpenWhatsApp) {
      return fallback ??
          KhInlineError(
            message: l10n?.connectionWhatsAppMissing ??
                'WhatsApp is not available. Copy the number or call instead.',
          );
    }

    return KhButton(
      key: const Key('talk-button'),
      label: label ?? l10n?.connectionTalk ?? 'Talk',
      onPressed: onTalk,
    );
  }
}

/// SH-CON-03 — tap-to-call with copy fallback.
///
/// Uses the server [callUrl]. Does not invent a `tel:` URL from digits.
class TapToCallControl extends StatelessWidget {
  const TapToCallControl({
    super.key,
    required this.mobileNumber,
    this.callUrl,
    this.onCall,
    this.copyLabel,
    this.callLabel,
    this.copiedMessage,
  });

  final String mobileNumber;
  final String? callUrl;
  final VoidCallback? onCall;
  final String? copyLabel;
  final String? callLabel;
  final String? copiedMessage;

  bool get _canCall {
    final url = (callUrl ?? '').trim().toLowerCase();
    return onCall != null && url.startsWith('tel:');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      key: const Key('tap-to-call'),
      children: [
        Expanded(
          child: Text(mobileNumber, overflow: TextOverflow.ellipsis),
        ),
        KhCopyControl(
          value: mobileNumber,
          tooltip: copyLabel ?? l10n?.connectionCopyNumber ?? 'Copy number',
          copiedMessage: copiedMessage ?? l10n?.connectionCopied ?? 'Copied',
          compact: true,
        ),
        IconButton(
          key: const Key('tap-to-call-button'),
          tooltip: callLabel ?? l10n?.connectionCall ?? 'Call',
          onPressed: _canCall ? onCall : null,
          icon: const Icon(Icons.phone_outlined),
        ),
      ],
    );
  }
}

/// SH-CON-04 — Close Connection action (confirm lives in the screen).
class CloseConnectionButton extends StatelessWidget {
  const CloseConnectionButton({
    super.key,
    required this.onPressed,
    this.label,
    this.busy = false,
  });

  final VoidCallback? onPressed;
  final String? label;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return KhButton(
      key: const Key('close-connection-button'),
      label: label ?? l10n?.connectionClose ?? 'Close Connection',
      destructive: true,
      busy: busy,
      onPressed: onPressed,
    );
  }
}

/// SH-CON-04 — read-only banner when the Connection is closed.
class ConnectionClosedBanner extends StatelessWidget {
  const ConnectionClosedBanner({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);
    return Container(
      key: const Key('connection-closed-banner'),
      width: double.infinity,
      padding: EdgeInsets.all(tokens.space.md),
      decoration: BoxDecoration(
        color: tokens.ink.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(tokens.radius.md),
      ),
      child: Text(
        message ??
            (l10n?.connectionClosedBanner ??
                'This Connection is closed. Details remain available.'),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
