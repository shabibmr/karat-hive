import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../request_manage/presentation/customer_copy.dart';
import '../controller/offer_detail_controller.dart';

/// CUS-S14 — Mark as Interested confirmation (CU-14).
class AcceptOfferScreen extends ConsumerWidget {
  const AcceptOfferScreen({super.key, required this.offerId});

  final String offerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(offerDetailProvider(offerId));
    final ui = ref.watch(acceptOfferProvider(offerId));
    final s = KhStrings.of(context);
    final tokens = context.tokens;

    ref.listen<AcceptOfferUiState>(acceptOfferProvider(offerId), (prev, next) {
      if (next.phase == AcceptPhase.succeeded &&
          next.connectionId != null &&
          next.connectionId!.isNotEmpty) {
        context.go('/customer/connections/${next.connectionId}');
      }
    });

    return Scaffold(
      key: const Key('accept-offer-screen'),
      appBar: AppBar(title: Text(s.s('cus.s14.title'))),
      body: detail.when(
        loading: () => const KhLoadingView(),
        error: (err, _) => KhErrorView(
          message: customerFailureMessage(
            err is Failure ? err : ServerFailure(message: err.toString()),
            s,
            'cus.s11.error',
          ),
          onRetry: () =>
              ref.read(offerDetailProvider(offerId).notifier).reload(),
          retryLabel: s.s('common.retry'),
        ),
        data: (bundle) {
          final offer = bundle.offer;
          return ListView(
            padding: EdgeInsets.all(tokens.space.md),
            children: [
              MaskedPartyLabel(party: offer.vendor),
              SizedBox(height: tokens.space.md),
              OfferTermsReadOnly(terms: offer.terms),
              SizedBox(height: tokens.space.lg),
              KhInlineError(message: s.s('cus.s14.warning')),
              SizedBox(height: tokens.space.md),
              Text(
                s.s('cus.s14.competitors'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: tokens.ink.withValues(alpha: 0.75),
                    ),
              ),
              if (ui.phase == AcceptPhase.timedOut) ...[
                SizedBox(height: tokens.space.lg),
                KhInlineError(message: s.s('cus.s14.timeout')),
                SizedBox(height: tokens.space.md),
                KhButton(
                  key: const Key('accept-check-status'),
                  label: s.s('common.checkStatus'),
                  onPressed: () => context.go('/customer/connections'),
                ),
              ],
              if (ui.phase == AcceptPhase.failed && ui.failure != null) ...[
                SizedBox(height: tokens.space.lg),
                KhInlineError(
                  message: customerFailureMessage(
                    ui.failure!,
                    s,
                    'cus.s11.error',
                  ),
                ),
              ],
              SizedBox(height: tokens.space.xl),
              KhButton(
                key: const Key('accept-confirm'),
                label: s.s('cus.s14.confirm'),
                busy: ui.phase == AcceptPhase.submitting,
                onPressed: ui.confirmLocked
                    ? null
                    : () => ref
                        .read(acceptOfferProvider(offerId).notifier)
                        .confirm(),
              ),
              SizedBox(height: tokens.space.sm),
              KhButton(
                key: const Key('accept-cancel'),
                label: s.s('common.cancel'),
                secondary: true,
                onPressed: ui.phase == AcceptPhase.submitting
                    ? null
                    : () => context.pop(),
              ),
            ],
          );
        },
      ),
    );
  }
}
