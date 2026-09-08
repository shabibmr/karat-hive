import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../controller/offers_list_controller.dart';
import '../../request_manage/controller/owner_request_detail_controller.dart';
import '../../request_manage/presentation/customer_copy.dart';

/// CUS-S12 — client composition of 2–4 Offers (CU-13).
class OfferComparisonScreen extends ConsumerWidget {
  const OfferComparisonScreen({
    super.key,
    required this.requestId,
    required this.offerIds,
  });

  final String requestId;
  final List<String> offerIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = KhStrings.of(context);
    final tokens = context.tokens;
    final list = ref.watch(offersListControllerProvider(requestId));
    final direction = ref.watch(ownerRequestDetailProvider(requestId)).maybeWhen(
          data: (d) => d.request.direction,
          orElse: () => Direction.buy,
        );

    return Scaffold(
      key: const Key('offer-comparison-screen'),
      appBar: AppBar(title: Text(s.s('cus.s12.title'))),
      body: ValueListenableBuilder(
        valueListenable: list,
        builder: (context, state, _) {
          final selected = state.items
              .where((o) => offerIds.contains(o.id))
              .toList(growable: false);
          if (selected.length < 2 || selected.length > 4) {
            return KhEmptyView(message: s.s('cus.s12.needTwo'));
          }

          num parsePrice(OfferForCustomer o) =>
              num.tryParse(o.terms.offeredPrice) ?? 0;
          final prices = selected.map(parsePrice).toList();
          final bestPrice = direction == Direction.sell
              ? prices.reduce((a, b) => a > b ? a : b)
              : prices.reduce((a, b) => a < b ? a : b);

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(tokens.space.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final offer in selected)
                  SizedBox(
                    width: 220,
                    child: _CompareColumn(
                      offer: offer,
                      isBestPrice: parsePrice(offer) == bestPrice,
                      delta: parsePrice(offer) - bestPrice,
                      onAccept: () => context.push(
                        '/customer/offers/${offer.id}/accept',
                      ),
                      onDetail: () =>
                          context.push('/customer/offers/${offer.id}'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CompareColumn extends StatelessWidget {
  const _CompareColumn({
    required this.offer,
    required this.isBestPrice,
    required this.delta,
    required this.onAccept,
    required this.onDetail,
  });

  final OfferForCustomer offer;
  final bool isBestPrice;
  final num delta;
  final VoidCallback onAccept;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final s = KhStrings.of(context);
    final price = num.tryParse(offer.terms.offeredPrice) ?? 0;
    final making = num.tryParse(offer.terms.makingCharges ?? '');

    return Card(
      key: Key('compare-col-${offer.id}'),
      margin: EdgeInsets.only(end: tokens.space.md),
      color: isBestPrice ? tokens.gold.withValues(alpha: 0.12) : null,
      child: Padding(
        padding: EdgeInsets.all(tokens.space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MaskedPartyLabel(party: offer.vendor, compact: true),
            SizedBox(height: tokens.space.md),
            MoneyDisplay(amount: price, highlight: isBestPrice, delta: delta == 0 ? null : delta),
            if (making != null) ...[
              SizedBox(height: tokens.space.sm),
              Text(s.s('cus.s13.making'), style: Theme.of(context).textTheme.labelSmall),
              MoneyDisplay(amount: making),
            ],
            if (offer.terms.deliveryTimeframe != null) ...[
              SizedBox(height: tokens.space.sm),
              Text(s.s('cus.s13.delivery'), style: Theme.of(context).textTheme.labelSmall),
              Text(offer.terms.deliveryTimeframe!),
            ],
            if (offer.terms.warrantyTerms != null) ...[
              SizedBox(height: tokens.space.sm),
              Text(s.s('cus.s13.warranty'), style: Theme.of(context).textTheme.labelSmall),
              Text(offer.terms.warrantyTerms!),
            ],
            SizedBox(height: tokens.space.md),
            KhButton(
              label: s.s('cus.s13.markInterested'),
              onPressed: onAccept,
            ),
            SizedBox(height: tokens.space.sm),
            KhButton(
              label: s.s('cus.s13.title'),
              secondary: true,
              onPressed: onDetail,
            ),
          ],
        ),
      ),
    );
  }
}
