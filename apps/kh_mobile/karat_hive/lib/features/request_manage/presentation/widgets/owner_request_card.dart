import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../../../app/di.dart';
import '../customer_copy.dart';

/// Customer summary card (K01 / `Card-mock.png`): thumb + media count, short
/// meta, estimated-value panel, one filled View Details (`ctaFill`). No Message.
class OwnerRequestCard extends ConsumerWidget {
  const OwnerRequestCard({
    super.key,
    required this.request,
    required this.onOpen,
  });

  final RequestForCustomer request;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final s = KhStrings.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final unread = request.unreadOfferCount;
    final env = ref.watch(envProvider);
    final thumb = request.media.isEmpty
        ? null
        : env.resolveUrl(
            request.media.first.thumbnailUrl ?? request.media.first.displayUrl,
          );
    final mediaCount = request.media.length;
    final meta = _shortMeta(context, s, request, locale);
    final valueLine = _valueLine(s, request, locale);

    return Card(
      key: Key('owner-request-card-${request.id}'),
      margin: EdgeInsets.only(bottom: tokens.space.md),
      elevation: 0,
      color: tokens.paper,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.inkHairline),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MediaThumb(
                  tokens: tokens,
                  thumbUrl: thumb,
                  contentType: request.media.isEmpty
                      ? null
                      : request.media.first.contentType,
                  mediaCount: mediaCount,
                ),
                SizedBox(width: tokens.space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meta,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: tokens.ink,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: tokens.space.xs),
                      Row(
                        children: [
                          KhStatusChip(
                            label: requestStateLabel(s, request.state),
                            tone: requestStateTone(request.state),
                            compact: true,
                          ),
                          if (unread != null && unread > 0) ...[
                            SizedBox(width: tokens.space.sm),
                            KhBadge(count: unread),
                          ],
                          const Spacer(),
                          if (request.expiresAt != null)
                            ExpiryCountdown(expiresAt: request.expiresAt!),
                        ],
                      ),
                      if (request.offerCount > 0) ...[
                        SizedBox(height: tokens.space.xs),
                        Text(
                          '${s.s('cus.s10.offers')}: ${request.offerCount}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: tokens.ink.withValues(alpha: 0.7),
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (valueLine != null) ...[
              SizedBox(height: tokens.space.md),
              Container(
                key: Key('owner-request-value-${request.id}'),
                padding: EdgeInsets.all(tokens.space.md),
                decoration: BoxDecoration(
                  color: tokens.formSurface,
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.s('cus.card.estimatedValue'),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: tokens.ink.withValues(alpha: 0.62),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: tokens.space.xs),
                    Text(
                      valueLine,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: tokens.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: tokens.space.md),
            KhButton(
              key: Key('owner-request-view-details-${request.id}'),
              label: s.s('cus.card.viewDetails'),
              onPressed: onOpen,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaThumb extends StatelessWidget {
  const _MediaThumb({
    required this.tokens,
    required this.thumbUrl,
    required this.contentType,
    required this.mediaCount,
  });

  final KhTokens tokens;
  final String? thumbUrl;
  final String? contentType;
  final int mediaCount;

  @override
  Widget build(BuildContext context) {
    const size = 72.0;
    final child = thumbUrl != null && thumbUrl!.isNotEmpty
        ? KhNetworkImage(
            url: thumbUrl!,
            contentType: contentType ?? 'image/jpeg',
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(),
          )
        : _placeholder();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radius.sm),
            child: child,
          ),
          if (mediaCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                key: const Key('owner-request-media-count'),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tokens.ink,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$mediaCount',
                  style: TextStyle(
                    color: tokens.paper,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 72,
      height: 72,
      color: tokens.gold.withValues(alpha: 0.16),
      child: Icon(Icons.diamond_outlined, color: tokens.gold),
    );
  }
}

String _shortMeta(
  BuildContext context,
  KhStrings s,
  RequestForCustomer request,
  String locale,
) {
  final parts = <String>[];

  if (request.purityKarat != null && request.purityKarat != Karat.unknown) {
    parts.add(request.purityKarat!.wire);
  }

  final typeBit = switch (request.requestType) {
    RequestType.goldCoin => s.s('service.card.coins'),
    RequestType.goldBullion => s.s('service.card.bullion'),
    RequestType.sellOldGold => s.s('service.card.sellGold'),
    RequestType.findOrnament => request.ornamentType != null &&
            request.ornamentType != OrnamentType.unknown
        ? _titleCase(request.ornamentType!.wire)
        : s.s('service.card.ornament'),
    RequestType.unknown => request.displayTitle(
        fallback: requestTypeLabel(s, request.requestType),
      ),
  };
  parts.add(typeBit);

  final weightRaw = request.weightGrams ?? request.denominationGrams;
  final weightNum = weightRaw == null ? null : num.tryParse(weightRaw);
  if (weightNum != null && weightNum > 0) {
    parts.add(WeightFormatter.grams(weightNum, locale: locale));
  }

  final conditionLabel = _conditionLabel(s, request.condition);
  if (conditionLabel != null) parts.add(conditionLabel);

  if (parts.length >= 2) return parts.join(' · ');
  return request.displayTitle(
    fallback: requestTypeLabel(s, request.requestType),
  );
}

String? _valueLine(KhStrings s, RequestForCustomer request, String locale) {
  final indicative = request.indicativeValue?.trim();
  if (indicative != null && indicative.isNotEmpty) {
    final asNum = num.tryParse(indicative);
    if (asNum != null) return MoneyFormatter.aed(asNum, locale: locale);
    return indicative;
  }

  final min = parseMoney(request.budgetMin);
  final max = parseMoney(request.budgetMax);
  if (min != null && max != null) {
    return '${MoneyFormatter.aed(min, locale: locale)} - '
        '${MoneyFormatter.aed(max, locale: locale)}';
  }
  if (min != null) return MoneyFormatter.aed(min, locale: locale);
  if (max != null) return MoneyFormatter.aed(max, locale: locale);
  return null;
}

String? _conditionLabel(KhStrings s, ItemCondition? condition) {
  if (condition == null || condition == ItemCondition.unknown) return null;
  return switch (condition) {
    ItemCondition.brandNew => s.s('create.condition.new'),
    ItemCondition.likeNew => s.s('create.condition.likeNew'),
    ItemCondition.used => s.s('create.condition.used'),
    ItemCondition.damaged => s.s('create.condition.damaged'),
    ItemCondition.unknown => null,
  };
}

String _titleCase(String wire) {
  if (wire.isEmpty) return wire;
  final lower = wire.toLowerCase();
  return '${lower[0].toUpperCase()}${lower.substring(1)}';
}
