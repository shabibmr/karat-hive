import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../request_manage/presentation/customer_copy.dart';
import '../controller/offer_detail_controller.dart';

/// CUS-S13 — Offer detail + masked vendor rating (CU-20).
class OfferDetailScreen extends ConsumerStatefulWidget {
  const OfferDetailScreen({super.key, required this.offerId});

  final String offerId;

  @override
  ConsumerState<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends ConsumerState<OfferDetailScreen> {
  bool _declining = false;

  @override
  Widget build(BuildContext context) {
    final offerId = widget.offerId;
    final async = ref.watch(offerDetailProvider(offerId));
    final s = KhStrings.of(context);
    final tokens = context.tokens;

    return Scaffold(
      key: const Key('offer-detail-screen'),
      appBar: AppBar(
        title: Text(s.s('cus.s13.title')),
        actions: [
          IconButton(
            key: const Key('offer-report'),
            tooltip: s.s('cus.s13.report'),
            onPressed: () => context.push(
              '/customer/abuse?entityType=OFFER&entityId=$offerId',
            ),
            icon: const Icon(Icons.flag_outlined),
          ),
        ],
      ),
      body: async.when(
        loading: () => const KhLoadingView(),
        error: (err, _) => KhErrorView(
          message: customerFailureMessage(
            err,
            s,
            'cus.s11.error',
          ),
          onRetry: () =>
              ref.read(offerDetailProvider(offerId).notifier).reload(),
          retryLabel: s.s('common.retry'),
        ),
        data: (bundle) {
          final offer = bundle.offer;
          final rating = bundle.rating;
          final pending = offer.state == OfferState.pending;
          final galleryImages = offer.terms.media
              .map((m) => GalleryImage(
                    url: m.displayUrl ?? m.thumbnailUrl ?? '',
                    contentType:
                        m.contentType.isEmpty ? 'image/jpeg' : m.contentType,
                  ))
              .where((g) => g.url.isNotEmpty)
              .toList(growable: false);

          return ListView(
            padding: EdgeInsets.all(tokens.space.md),
            children: [
              Row(
                children: [
                  Expanded(child: MaskedPartyLabel(party: offer.vendor)),
                  KhStatusChip(
                    label: offerStateLabel(
                      offer.state,
                      AppLocalizations.of(context),
                    ),
                    tone: offerStateTone(offer.state),
                    compact: true,
                  ),
                ],
              ),
              SizedBox(height: tokens.space.md),
              OfferTermsReadOnly(
                terms: offer.terms,
                expiresAt: offer.expiresAt,
              ),
              if (galleryImages.isNotEmpty) ...[
                SizedBox(height: tokens.space.md),
                KhImageGallery(images: galleryImages),
              ],
              if (rating != null) ...[
                SizedBox(height: tokens.space.lg),
                Text(
                  s.s('cus.s13.ratings'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: tokens.space.sm),
                TrustSignalBadge(
                  rating: rating.summary,
                  dealCount: offer.vendor.dealCount,
                ),
                SizedBox(height: tokens.space.sm),
                RatingSummaryView(
                  summary: rating.summary,
                  limitedHistoryLabel: s.s('cus.s13.newVendor'),
                ),
                if (rating.excerpts.isNotEmpty) ...[
                  SizedBox(height: tokens.space.md),
                  for (final excerpt in rating.excerpts)
                    Padding(
                      padding: EdgeInsets.only(bottom: tokens.space.sm),
                      child: ReviewListItem(
                        abbreviatedAuthor: excerpt.abbreviatedName.isEmpty
                            ? '—'
                            : excerpt.abbreviatedName,
                        rating: excerpt.rating.clamp(1, 5),
                        dateLabel: '',
                        comment: excerpt.comment,
                      ),
                    ),
                ],
              ],
              SizedBox(height: tokens.space.xl),
              if (pending) ...[
                KhButton(
                  key: const Key('offer-mark-interested'),
                  label: s.s('cus.s13.markInterested'),
                  onPressed: _declining
                      ? null
                      : () => context.push('/customer/offers/$offerId/accept'),
                ),
                SizedBox(height: tokens.space.sm),
                KhButton(
                  key: const Key('offer-decline'),
                  label: s.s('cus.s13.decline'),
                  secondary: true,
                  busy: _declining,
                  onPressed: _declining ? null : () => _decline(context, ref, s),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _decline(
    BuildContext context,
    WidgetRef ref,
    KhStrings s,
  ) async {
    String? reason = OfferDeclineReason.priceTooHigh.wire;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: Text(s.s('cus.s13.decline')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final r in const [
                    OfferDeclineReason.priceTooHigh,
                    OfferDeclineReason.termsUnsuitable,
                    OfferDeclineReason.noLongerRequired,
                    OfferDeclineReason.other,
                  ])
                    ListTile(
                      dense: true,
                      title: Text(s.s('cus.decline.${r.wire}')),
                      leading: Icon(
                        reason == r.wire
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                      ),
                      onTap: () => setLocal(() => reason = r.wire),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(s.s('common.cancel')),
                ),
                TextButton(
                  key: const Key('confirm-decline-offer'),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(s.s('cus.s13.decline')),
                ),
              ],
            );
          },
        );
      },
    );
    if (confirmed != true || !context.mounted || _declining) return;
    setState(() => _declining = true);
    final res = await ref
        .read(offerDetailProvider(widget.offerId).notifier)
        .decline(reason: reason);
    if (!context.mounted) return;
    res.when(
      ok: (_) {
        ref.invalidate(offerDetailProvider(widget.offerId));
        context.pop();
      },
      err: (f) {
        setState(() => _declining = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              customerFailureMessage(f, s, 'cus.s11.error'),
            ),
          ),
        );
      },
    );
  }
}
