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
    this.onTalk,
    this.copyLabel,
    this.callLabel,
    this.talkLabel,
    this.copiedMessage,
    this.photoUrl,
  });

  final RevealedParty party;
  final VoidCallback? onCall;
  final VoidCallback? onTalk;
  final String? copyLabel;
  final String? callLabel;
  final String? talkLabel;
  final String? copiedMessage;

  /// Absolute, already-resolved URL for [party]'s photo/logo (the caller
  /// resolves `party.photoUrl`, a server-relative path, against the app's
  /// API base URL — this package has no env config of its own).
  final String? photoUrl;

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _PartyAvatar(
                  displayName: party.displayName,
                  photoUrl: photoUrl,
                  goldColor: tokens.gold,
                ),
                SizedBox(width: tokens.space.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        party.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (regionName != null && regionName.isNotEmpty)
                        Text(
                          regionName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: tokens.ink.withValues(alpha: 0.65),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.space.md),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.space.sm,
                vertical: tokens.space.xs,
              ),
              decoration: BoxDecoration(
                color: tokens.ink.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(tokens.radius.sm),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.phone_iphone_outlined,
                    size: 18,
                    color: tokens.ink.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mobile,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  KhCopyControl(
                    value: mobile,
                    tooltip: copyLabel ?? l10n?.connectionCopyNumber ?? 'Copy number',
                    copiedMessage:
                        copiedMessage ?? l10n?.connectionCopied ?? 'Copied',
                    compact: true,
                  ),
                  if (onTalk != null)
                    IconButton(
                      key: const Key('revealed-party-talk'),
                      tooltip: talkLabel ?? 'WhatsApp',
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: Color(0xFF25D366),
                        size: 20,
                      ),
                      onPressed: onTalk,
                    ),
                  if (onCall != null)
                    IconButton(
                      key: const Key('revealed-party-call'),
                      tooltip: callLabel ?? l10n?.connectionCall ?? 'Call',
                      icon: Icon(
                        Icons.phone_outlined,
                        color: tokens.gold,
                        size: 20,
                      ),
                      onPressed: onCall,
                    ),
                ],
              ),
            ),
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

class _PartyAvatar extends StatelessWidget {
  const _PartyAvatar({
    required this.displayName,
    required this.photoUrl,
    required this.goldColor,
  });

  final String displayName;
  final String? photoUrl;
  final Color goldColor;

  @override
  Widget build(BuildContext context) {
    final initial =
        displayName.isNotEmpty ? displayName.substring(0, 1).toUpperCase() : 'C';

    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipOval(
        child: KhNetworkImage(
          url: photoUrl!,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => CircleAvatar(
            radius: 18,
            backgroundColor: goldColor.withValues(alpha: 0.15),
            child: Text(
              initial,
              style: TextStyle(fontWeight: FontWeight.bold, color: goldColor),
            ),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor: goldColor.withValues(alpha: 0.15),
      child: Text(
        initial,
        style: TextStyle(fontWeight: FontWeight.bold, color: goldColor),
      ),
    );
  }
}
