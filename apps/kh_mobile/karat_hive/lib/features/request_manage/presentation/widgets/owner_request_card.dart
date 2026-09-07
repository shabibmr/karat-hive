import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../customer_copy.dart';

/// CU-01 — owner-centric live Request row. Unread marker only if the payload
/// includes [RequestForCustomer.unreadOfferCount] (SAM-GAP-1).
class OwnerRequestCard extends StatelessWidget {
  const OwnerRequestCard({
    super.key,
    required this.request,
    required this.onOpen,
    this.onViewOffers,
  });

  final RequestForCustomer request;
  final VoidCallback onOpen;
  final VoidCallback? onViewOffers;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final s = KhStrings.of(context);
    final theme = Theme.of(context);
    final unread = request.unreadOfferCount;
    final thumb = request.media.isEmpty
        ? null
        : (request.media.first.thumbnailUrl ?? request.media.first.displayUrl);

    return Card(
      key: Key('owner-request-card-${request.id}'),
      margin: EdgeInsets.only(bottom: tokens.space.md),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (thumb != null && thumb.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(tokens.radius.sm),
                      child: Image.network(
                        thumb,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _ThumbPlaceholder(tokens: tokens),
                      ),
                    )
                  else
                    _ThumbPlaceholder(tokens: tokens),
                  SizedBox(width: tokens.space.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          requestTypeLabel(s, request.requestType),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (request.reference != null) ...[
                          SizedBox(height: tokens.space.xs),
                          Text(
                            request.reference!,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: tokens.ink.withValues(alpha: 0.55),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                        SizedBox(height: tokens.space.xs),
                        Row(
                          children: [
                            KhStatusChip(
                              label: requestStateLabel(s, request.state),
                              tone: requestStateTone(request.state),
                              compact: true,
                            ),
                            SizedBox(width: tokens.space.sm),
                            Text(
                              request.direction.wire,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: tokens.ink.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (unread != null && unread > 0)
                    KhBadge(count: unread),
                ],
              ),
              SizedBox(height: tokens.space.md),
              Row(
                children: [
                  Text(
                    '${s.s('cus.s10.offers')}: ${request.offerCount}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const Spacer(),
                  if (request.expiresAt != null)
                    ExpiryCountdown(expiresAt: request.expiresAt!),
                ],
              ),
              if (onViewOffers != null && request.offerCount > 0) ...[
                SizedBox(height: tokens.space.sm),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    key: Key('view-offers-${request.id}'),
                    onPressed: onViewOffers,
                    child: Text(s.s('cus.home.viewOffers')),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder({required this.tokens});
  final KhTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: tokens.gold.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(tokens.radius.sm),
      ),
      child: Icon(Icons.diamond_outlined, color: tokens.gold),
    );
  }
}
