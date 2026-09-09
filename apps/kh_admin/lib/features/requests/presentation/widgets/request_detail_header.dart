import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/core/format/kh_formats.dart';
import 'package:kh_admin/features/requests/model/request_detail.dart';
import 'package:kh_admin/features/requests/presentation/widgets/request_detail_row.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// "Back to Requests" text button. Was `_buildBackButton`.
class RequestDetailBackButton extends StatelessWidget {
  const RequestDetailBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);
    return TextButton.icon(
      key: const Key('request-detail-back-button'),
      onPressed: () => context.go('/requests'),
      icon: const Icon(Icons.arrow_back, size: 18.0),
      label: Text(l10n?.requestsDetailBack ?? 'Back to Requests'),
      style: TextButton.styleFrom(
        foregroundColor: kh.colors.goldPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: kh.spacing.sm,
          vertical: kh.spacing.xs,
        ),
      ),
    );
  }
}

/// Reference chip + status chip + screen header. Was `_buildHeader`.
class RequestDetailHeader extends StatelessWidget {
  const RequestDetailHeader({super.key, required this.detail});

  final RequestDetail detail;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);
    final dateFormat = khDateTimeFormat;
    final heading = detail.ornamentType != null && detail.ornamentType!.isNotEmpty
        ? '${detail.purityKarat != null ? "${detail.purityKarat} " : ""}${detail.ornamentType}'
        : '${detail.requestType.label} (${detail.direction.label})';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: kh.spacing.sm,
                      vertical: kh.spacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: kh.colors.sapphire800,
                      borderRadius: kh.shapes.roundedSm,
                      border: Border.all(color: kh.colors.borderSubtle),
                    ),
                    child: Text(
                      detail.reference ??
                          (l10n?.requestsDetailNoReference ?? 'NO REFERENCE'),
                      style: kh.typography.caption.copyWith(
                        color: kh.colors.goldPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.0,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(width: kh.spacing.sm),
                  KhStatusChip(
                    label: detail.state.label,
                    tone: requestStateTone(detail.state),
                  ),
                ],
              ),
              SizedBox(height: kh.spacing.xs),
              KhScreenHeader(
                eyebrow: l10n?.requestsDetailEyebrow ?? 'REQUEST OVERSIGHT',
                heading: heading,
                supportingText: detail.publishedAt != null
                    ? (l10n?.requestsDetailPublishedAt(
                            dateFormat.format(detail.publishedAt!)) ??
                        'Published ${dateFormat.format(detail.publishedAt!)} GST')
                    : (detail.createdAt != null
                        ? (l10n?.requestsDetailCreatedAt(
                                dateFormat.format(detail.createdAt!)) ??
                            'Created ${dateFormat.format(detail.createdAt!)} GST')
                        : ''),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Red "removed by moderation" banner. Was `_buildRemovedNoticeBanner`.
class RequestRemovedNoticeBanner extends StatelessWidget {
  const RequestRemovedNoticeBanner({super.key, required this.detail});

  final RequestDetail detail;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);
    return Container(
      key: const Key('request-removed-banner'),
      padding: EdgeInsets.all(kh.spacing.md),
      decoration: BoxDecoration(
        color: kh.colors.error.withValues(alpha: 0.12),
        borderRadius: kh.shapes.roundedMd,
        border: Border.all(color: kh.colors.error.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.gavel, color: kh.colors.error, size: 24.0),
          SizedBox(width: kh.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.requestsDetailRemovedTitle ??
                      'REQUEST REMOVED BY PLATFORM MODERATION (FR-ADM-019)',
                  style: kh.typography.title.copyWith(
                    color: kh.colors.error,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.0,
                  ),
                ),
                SizedBox(height: kh.spacing.xxs),
                Text(
                  l10n?.requestsDetailRemovedReason(
                        detail.removalReasonCode ??
                            l10n.requestsDetailRemovedReasonCodeDefault,
                        detail.removalReasonText ??
                            l10n.requestsDetailRemovedReasonTextDefault,
                      ) ??
                      'Reason: ${detail.removalReasonCode ?? "POLICY_VIOLATION"} · ${detail.removalReasonText ?? "Violates platform trading guidelines"}',
                  style: kh.typography.bodySmall.copyWith(
                    color: kh.colors.textPrimary,
                    fontSize: 12.0,
                  ),
                ),
                if (detail.removalPolicyClause != null &&
                    detail.removalPolicyClause!.isNotEmpty) ...[
                  SizedBox(height: kh.spacing.xxs),
                  Text(
                    l10n?.requestsDetailRemovedPolicyClause(
                            detail.removalPolicyClause!) ??
                        'Policy clause cited: ${detail.removalPolicyClause}',
                    style: kh.typography.caption.copyWith(
                      color: kh.colors.textMuted,
                      fontSize: 11.0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Green "active connection established" banner. Was `_buildConnectionBanner`.
class RequestConnectionBanner extends StatelessWidget {
  const RequestConnectionBanner({super.key, required this.connection});

  final RequestConnectionSummary connection;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);
    final dateFormat = khDateTimeFormat;

    return Container(
      key: const Key('request-connection-banner'),
      padding: EdgeInsets.all(kh.spacing.md),
      decoration: BoxDecoration(
        color: kh.colors.success.withValues(alpha: 0.12),
        borderRadius: kh.shapes.roundedMd,
        border: Border.all(color: kh.colors.success.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.handshake, color: kh.colors.success, size: 28.0),
          SizedBox(width: kh.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l10n?.requestsDetailConnectionTitle ??
                          'ACTIVE CONNECTION ESTABLISHED',
                      style: kh.typography.title.copyWith(
                        color: kh.colors.success,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.0,
                      ),
                    ),
                    SizedBox(width: kh.spacing.sm),
                    KhStatusChip(
                      label: connection.state,
                      tone: KhStatusTone.success,
                      dense: true,
                    ),
                  ],
                ),
                SizedBox(height: kh.spacing.xxs),
                Text(
                  l10n?.requestsDetailConnectionParties(
                        connection.vendorName,
                        connection.customerName,
                      ) ??
                      'Accepted Vendor: ${connection.vendorName} · Customer: ${connection.customerName}',
                  style: kh.typography.bodySmall.copyWith(
                    color: kh.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.0,
                  ),
                ),
                Text(
                  l10n?.requestsDetailConnectionMeta(
                        dateFormat.format(connection.connectedAt),
                        connection.channel ??
                            l10n.requestsDetailConnectionChannelDefault,
                      ) ??
                      'Connected at: ${dateFormat.format(connection.connectedAt)} GST · Channel: ${connection.channel ?? "WHATSAPP"}',
                  style: kh.typography.caption.copyWith(
                    color: kh.colors.textSecondary,
                    fontSize: 11.0,
                  ),
                ),
              ],
            ),
          ),
          if (connection.whatsappUrl != null && connection.whatsappUrl!.isNotEmpty)
            OutlinedButton.icon(
              icon: const Icon(Icons.chat, size: 16.0),
              label:
                  Text(l10n?.requestsDetailWhatsappChannel ?? 'WhatsApp Channel'),
              onPressed: () {},
            ),
        ],
      ),
    );
  }
}

/// Centered error state with retry. Was `_buildErrorView`.
class RequestDetailErrorView extends StatelessWidget {
  const RequestDetailErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(kh.spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48.0, color: kh.colors.error),
            SizedBox(height: kh.spacing.md),
            Text(
              message,
              style: kh.typography.body.copyWith(
                color: kh.colors.error,
                fontSize: 14.0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: kh.spacing.md),
            OutlinedButton(
              key: const Key('request-detail-retry-button'),
              onPressed: onRetry,
              child: Text(l10n?.requestsDetailErrorRetry ?? 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
