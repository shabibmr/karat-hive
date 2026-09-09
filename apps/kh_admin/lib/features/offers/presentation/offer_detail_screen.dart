import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/features/offers/controller/offer_detail_controller.dart';
import 'package:kh_admin/features/offers/model/offer_enums.dart';
import 'package:kh_admin/features/offers/presentation/widgets/offer_commercial_terms_card.dart';
import 'package:kh_admin/features/offers/presentation/widgets/offer_detail_error_state.dart';
import 'package:kh_admin/features/offers/presentation/widgets/offer_detail_formatters.dart';
import 'package:kh_admin/features/offers/presentation/widgets/offer_internal_notes_card.dart';
import 'package:kh_admin/features/offers/presentation/widgets/offer_parent_request_card.dart';
import 'package:kh_admin/features/offers/presentation/widgets/offer_pricing_breakdown_card.dart';
import 'package:kh_admin/features/offers/presentation/widgets/offer_revisions_timeline_card.dart';
import 'package:kh_admin/features/offers/presentation/widgets/offer_state_transitions_card.dart';
import 'package:kh_admin/features/offers/presentation/widgets/offer_vendor_profile_card.dart';
import 'package:kh_admin/features/offers/presentation/widgets/offer_winning_offer_card.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// ADM-S11 · Offer detail — full offer terms, revisions, state history, and
/// unmasked parties.
///
/// Composition root only: each section lives in `presentation/widgets/`
/// (TR-S2-07). Screen state owns the internal-note field.
class OfferDetailScreen extends ConsumerStatefulWidget {
  const OfferDetailScreen({
    super.key,
    required this.offerId,
  });

  final String offerId;

  @override
  ConsumerState<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends ConsumerState<OfferDetailScreen> {
  final TextEditingController _noteController = TextEditingController();
  bool _isPostingNote = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handlePostNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPostingNote = true);
    try {
      await ref
          .read(offerDetailControllerProvider(widget.offerId).notifier)
          .addInternalNote(text);
      _noteController.clear();
    } finally {
      if (mounted) {
        setState(() => _isPostingNote = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);
    final asyncDetail =
        ref.watch(offerDetailControllerProvider(widget.offerId));

    return Material(
      color: kh.colors.backgroundSurface,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(kh.spacing.xl),
        child: asyncDetail.when(
          loading: () => const Center(
            key: Key('offer-detail-loading'),
            child: Padding(
              padding: EdgeInsets.all(64.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => OfferDetailErrorState(
            key: const Key('offer-detail-error'),
            message: err.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
            onRetry: () => ref
                .read(offerDetailControllerProvider(widget.offerId).notifier)
                .reload(),
          ),
          data: (detail) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  OutlinedButton.icon(
                    key: const Key('back-to-offers-button'),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/offers');
                      }
                    },
                    icon: const Icon(Icons.arrow_back, size: 16.0),
                    label: Text(
                      l10n?.offersDetailBack ?? 'Back to Offers',
                      style: const TextStyle(fontSize: 12.0),
                    ),
                  ),
                ],
              ),
              SizedBox(height: kh.spacing.md),
              KhScreenHeader(
                eyebrow: detail.reference != null && detail.reference!.isNotEmpty
                    ? (l10n?.offersDetailEyebrow(detail.reference!) ??
                        'OFFER ${detail.reference}')
                    : (l10n?.offersDetailEyebrow(detail.id) ??
                        'OFFER ${detail.id}'),
                heading: offerFormatPrice(detail.offeredPrice),
                supportingText: detail.expiresAt != null
                    ? (l10n?.offersDetailHeaderMetaExpires(
                          offerFormatDate(detail.submittedAt),
                          detail.validityHours ?? 24,
                          offerFormatDate(detail.expiresAt),
                        ) ??
                        'Submitted on ${offerFormatDate(detail.submittedAt)} · Validity ${detail.validityHours ?? 24}h (Expires ${offerFormatDate(detail.expiresAt)})')
                    : (l10n?.offersDetailHeaderMeta(
                          offerFormatDate(detail.submittedAt),
                          detail.validityHours ?? 24,
                        ) ??
                        'Submitted on ${offerFormatDate(detail.submittedAt)} · Validity ${detail.validityHours ?? 24}h'),
                trailing: KhStatusChip(
                  label: detail.state.displayName.toUpperCase(),
                  tone: detail.state.statusTone,
                ),
              ),
              SizedBox(height: kh.spacing.lg),
              if (detail.winningOfferId != null ||
                  (detail.state == OfferState.rejected &&
                      detail.winningOfferReference != null)) ...[
                OfferWinningOfferCard(
                  key: const Key('winning-offer-card'),
                  detail: detail,
                ),
                SizedBox(height: kh.spacing.lg),
              ],
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 960.0;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: OfferVendorProfileCard(vendor: detail.vendor),
                        ),
                        SizedBox(width: kh.spacing.lg),
                        Expanded(
                          child: OfferParentRequestCard(
                            request: detail.parentRequest,
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      OfferVendorProfileCard(vendor: detail.vendor),
                      SizedBox(height: kh.spacing.lg),
                      OfferParentRequestCard(request: detail.parentRequest),
                    ],
                  );
                },
              ),
              SizedBox(height: kh.spacing.lg),
              OfferPricingBreakdownCard(
                key: const Key('pricing-breakdown-card'),
                detail: detail,
              ),
              SizedBox(height: kh.spacing.lg),
              OfferCommercialTermsCard(detail: detail),
              SizedBox(height: kh.spacing.lg),
              OfferRevisionsTimelineCard(
                key: const Key('revisions-timeline-card'),
                revisions: detail.revisions,
              ),
              SizedBox(height: kh.spacing.lg),
              OfferStateTransitionsCard(
                key: const Key('state-transitions-card'),
                transitions: detail.stateTransitions,
                currentState: detail.state,
              ),
              SizedBox(height: kh.spacing.lg),
              OfferInternalNotesCard(
                notes: detail.internalNotes,
                controller: _noteController,
                isPosting: _isPostingNote,
                onPost: _handlePostNote,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
