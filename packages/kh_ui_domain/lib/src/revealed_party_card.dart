import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

import 'package:kh_ui_domain/src/masked_party_label.dart';

/// SH-ID-02 — revealed party card. Accepts [RevealedParty] only (AD-FE-07).
class RevealedPartyCard extends StatelessWidget {
  const RevealedPartyCard({
    super.key,
    required this.party,
    this.onCall,
    this.copyLabel,
    this.callLabel,
    this.copiedMessage,
  });

  final RevealedParty party;
  final VoidCallback? onCall;
  final String? copyLabel;
  final String? callLabel;
  final String? copiedMessage;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final mobile = party.mobile.e164;
    final regionName = party.region?.name(locale);

    return Card(
      key: const Key('revealed-party-card'),
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.ink.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              party.displayName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: tokens.space.xs),
            Row(
              children: [
                Expanded(
                  child: Text(
                    mobile,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                KhCopyControl(
                  value: mobile,
                  tooltip: copyLabel ?? l10n?.connectionCopyNumber ?? 'Copy number',
                  copiedMessage:
                      copiedMessage ?? l10n?.connectionCopied ?? 'Copied',
                  compact: true,
                ),
                if (onCall != null)
                  IconButton(
                    key: const Key('revealed-party-call'),
                    tooltip: callLabel ?? l10n?.connectionCall ?? 'Call',
                    icon: Icon(Icons.phone_outlined, color: tokens.ink),
                    onPressed: onCall,
                  ),
              ],
            ),
            if (regionName != null && regionName.isNotEmpty) ...[
              SizedBox(height: tokens.space.xs),
              Text(
                regionName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: tokens.ink.withValues(alpha: 0.7),
                ),
              ),
            ],
            if (party.rating != null || party.dealCount > 0) ...[
              SizedBox(height: tokens.space.sm),
              TrustSignalBadge(
                rating: party.rating,
                dealCount: party.dealCount,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
