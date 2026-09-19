import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../../app/di.dart';
import '../controller/revise_offer_controller.dart';

/// VEN-S10 — Revise / withdraw a pending Offer.
class ReviseOfferScreen extends ConsumerWidget {
  const ReviseOfferScreen({super.key, required this.offerId});

  final String offerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviseOfferControllerProvider(offerId));
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final clock = ref.watch(serverClockProvider);

    ref.listen(reviseOfferControllerProvider(offerId), (prev, next) {
      if (next is ReviseOfferSucceeded && context.mounted) {
        context.go('/vendor/offers');
      }
    });

    return Scaffold(
      key: const Key('revise-offer-screen'),
      appBar: AppBar(
        title: Text(l10n?.reviseOfferTitle ?? 'Revise Offer'),
      ),
      body: switch (state) {
        ReviseOfferLoading() || ReviseOfferSucceeded() =>
          const Center(child: CircularProgressIndicator()),
        ReviseOfferFailed(:final failure) => KhErrorView(
            message: failure.message ??
                (l10n?.couldNotLoadOffer ?? 'Could not load offer.'),
            onRetry: () =>
                ref.invalidate(reviseOfferControllerProvider(offerId)),
          ),
        ReviseOfferReady(
          :final offer,
          :final config,
          :final draft,
          :final submitting,
          :final withdrawing,
          :final failure,
        ) =>
          ListView(
            padding: EdgeInsets.all(tokens.space.md),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n?.offerCurrentTerms ?? 'Current terms',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  KhStatusChip(
                    key: const Key('offer-seen-status-chip'),
                    label: offer.isSeenByCustomer
                        ? 'Seen by Customer'
                        : 'Not Seen Yet',
                    tone: offer.isSeenByCustomer
                        ? KhStatusTone.accent
                        : KhStatusTone.neutral,
                    compact: true,
                  ),
                ],
              ),
              SizedBox(height: tokens.space.sm),
              OfferTermsReadOnly(
                terms: offer.terms,
                expiresAt: offer.expiresAt,
              ),
              SizedBox(height: tokens.space.md),
              if (offer.canReviseAt(clock.now())) ...[
                Builder(
                  builder: (context) {
                    final remaining = offer.revisionTimeRemaining(clock.now());
                    final mins = remaining.inMinutes;
                    final secs = remaining.inSeconds % 60;
                    return Text(
                      '1 revision allowed before customer views (closes in ${mins}m ${secs}s)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: tokens.gold,
                            fontWeight: FontWeight.w600,
                          ),
                    );
                  },
                ),
                SizedBox(height: tokens.space.lg),
                Text(
                  l10n?.offerNewTerms ?? 'New terms',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: tokens.space.sm),
                OfferTermsForm(
                  draft: draft,
                  validityOptions: config.offerValidityHours,
                  requestExpiresAt: offer.requestSummary?.expiresAt,
                  now: clock.now(),
                  showMediaHint: false,
                  onChanged: () => ref
                      .read(reviseOfferControllerProvider(offerId).notifier)
                      .touch(),
                ),
              ] else ...[
                Container(
                  padding: EdgeInsets.all(tokens.space.md),
                  decoration: BoxDecoration(
                    color: tokens.ink.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(tokens.radius.md),
                  ),
                  child: Text(
                    _ineligibilityReason(offer),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: tokens.ink.withValues(alpha: 0.7),
                        ),
                  ),
                ),
              ],
              if (failure != null) ...[
                SizedBox(height: tokens.space.md),
                KhInlineError(
                  message: failure.message ?? failure.code ?? 'Error',
                ),
              ],
              SizedBox(height: tokens.space.lg),
              if (offer.canReviseAt(clock.now()))
                KhButton(
                  key: const Key('revise-offer-button'),
                  label: submitting
                      ? (l10n?.commonSubmitting ?? 'Submitting…')
                      : (l10n?.reviseOfferAction ?? 'Save revision'),
                  onPressed: submitting || withdrawing
                      ? null
                      : () => ref
                          .read(reviseOfferControllerProvider(offerId).notifier)
                          .revise(),
                ),
              if (offer.canWithdraw) ...[
                SizedBox(height: tokens.space.md),
                KhButton(
                  key: const Key('withdraw-offer-button'),
                  label: withdrawing
                      ? (l10n?.commonSubmitting ?? 'Submitting…')
                      : (l10n?.withdrawOfferAction ?? 'Withdraw Offer'),
                  onPressed: submitting || withdrawing
                      ? null
                      : () async {
                          final confirmed = await showKhConfirmDialog(
                            context,
                            title: l10n?.withdrawOfferConfirmTitle ??
                                'Withdraw this Offer?',
                            body: l10n?.withdrawOfferConfirmBody ??
                                'You can submit a new Offer afterwards if the Request is still open.',
                            confirmLabel: l10n?.withdrawOfferAction ?? 'Withdraw',
                            cancelLabel: l10n?.commonCancel ?? 'Cancel',
                          );
                          if (confirmed == true && context.mounted) {
                            await ref
                                .read(
                                  reviseOfferControllerProvider(offerId)
                                      .notifier,
                                )
                                .withdraw();
                          }
                        },
                ),
              ],
            ],
          ),
      },
    );
  }

  String _ineligibilityReason(OfferForVendor offer) {
    if (offer.isSeenByCustomer) {
      return 'The customer has already viewed this offer. Revisions are no longer permitted.';
    }
    if (offer.revisionCount >= kMaxOfferRevisions) {
      return 'Maximum revision limit reached (1 revision max).';
    }
    return 'Revision window has expired (allowed within 5 minutes of response only).';
  }
}
