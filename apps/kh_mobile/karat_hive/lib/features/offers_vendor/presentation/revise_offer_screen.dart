import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
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
              Text(
                l10n?.offerCurrentTerms ?? 'Current terms',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: tokens.space.sm),
              OfferTermsReadOnly(
                terms: offer.terms,
                expiresAt: offer.expiresAt,
              ),
              SizedBox(height: tokens.space.md),
              Text(
                l10n?.offerRevisionsRemaining(offer.revisionsRemaining) ??
                    '${offer.revisionsRemaining} revision(s) remaining',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: tokens.space.lg),
              if (offer.canRevise) ...[
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
              ],
              if (failure != null) ...[
                SizedBox(height: tokens.space.md),
                KhInlineError(
                  message: failure.message ?? failure.code ?? 'Error',
                ),
              ],
              SizedBox(height: tokens.space.lg),
              if (offer.canRevise)
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
}
