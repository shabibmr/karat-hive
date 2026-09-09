import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

/// SH-ID-03 — Rating summary (average 1 dp, count, star distribution,
/// limited-history notice when count < 3 / [RatingSummary.limitedHistory]).
///
/// Accepts [RatingSummary] only. Completed-connection count belongs on
/// [TrustSignalBadge] (SH-ID-07); compose both at the screen when needed.
class RatingSummaryView extends StatelessWidget {
  const RatingSummaryView({
    super.key,
    required this.summary,
    this.limitedHistoryLabel,
    this.showDistribution = true,
  });

  final RatingSummary summary;

  /// Overrides `cus.s13.newVendor` / English default.
  final String? limitedHistoryLabel;

  /// When false, hides the 5→1 distribution bars (header + notice only).
  final bool showDistribution;

  static const List<int> _starLevels = [5, 4, 3, 2, 1];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final limited = summary.limitedHistory;
    final averageText = localizeDigits(summary.averageString, locale);
    final countText = localizeDigits('${summary.count}', locale);
    final reviewsLabel = summary.count == 1
        ? '$countText review'
        : '$countText reviews';
    final notice = limitedHistoryLabel ??
        KhStrings.of(context).s('cus.s13.newVendor');

    return Card(
      key: const Key('rating-summary'),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            if (limited) ...[
              _LimitedHistoryBanner(message: notice, tokens: tokens),
              SizedBox(height: tokens.space.sm),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!limited) ...[
                  Text(
                    key: const Key('rating-summary-average'),
                    averageText,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: tokens.gold,
                      height: 1,
                    ),
                  ),
                  SizedBox(width: tokens.space.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!limited)
                        _StarRow(
                          average: summary.average,
                          color: tokens.gold,
                        ),
                      if (!limited) SizedBox(height: tokens.space.xs),
                      Text(
                        key: const Key('rating-summary-count'),
                        summary.count == 0
                            ? (AppLocalizations.of(context)?.dashboardNoReviews ??
                                'No reviews yet')
                            : reviewsLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: tokens.ink.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (showDistribution && summary.count > 0) ...[
              SizedBox(height: tokens.space.md),
              _DistributionBars(
                distribution: summary.distribution,
                total: summary.count,
                tokens: tokens,
                locale: locale,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LimitedHistoryBanner extends StatelessWidget {
  const _LimitedHistoryBanner({
    required this.message,
    required this.tokens,
  });

  final String message;
  final KhTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('rating-summary-limited'),
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space.sm,
        vertical: tokens.space.sm,
      ),
      decoration: BoxDecoration(
        color: tokens.warning.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(tokens.radius.sm),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: tokens.ink.withValues(alpha: 0.75)),
          SizedBox(width: tokens.space.xs),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: tokens.ink.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.average, required this.color});

  final double average;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final filled = average.round().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 18,
            color: color,
          ),
      ],
    );
  }
}

class _DistributionBars extends StatelessWidget {
  const _DistributionBars({
    required this.distribution,
    required this.total,
    required this.tokens,
    required this.locale,
  });

  final Map<String, int> distribution;
  final int total;
  final KhTokens tokens;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final maxCount = RatingSummaryView._starLevels
        .map((s) => distribution['$s'] ?? 0)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final denom = maxCount > 0 ? maxCount : (total > 0 ? total : 1);

    return Column(
      key: const Key('rating-summary-distribution'),
      children: [
        for (final stars in RatingSummaryView._starLevels) ...[
          _DistributionRow(
            stars: stars,
            count: distribution['$stars'] ?? 0,
            fraction: (distribution['$stars'] ?? 0) / denom,
            tokens: tokens,
            locale: locale,
          ),
          if (stars != 1) SizedBox(height: tokens.space.xs),
        ],
      ],
    );
  }
}

class _DistributionRow extends StatelessWidget {
  const _DistributionRow({
    required this.stars,
    required this.count,
    required this.fraction,
    required this.tokens,
    required this.locale,
  });

  final int stars;
  final int count;
  final double fraction;
  final KhTokens tokens;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final label = localizeDigits('$stars', locale);
    final countLabel = localizeDigits('$count', locale);

    return Row(
      children: [
        SizedBox(
          width: 14,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: tokens.ink.withValues(alpha: 0.75),
            ),
            textAlign: TextAlign.end,
          ),
        ),
        SizedBox(width: tokens.space.xs),
        Icon(Icons.star_rounded, size: 12, color: tokens.gold),
        SizedBox(width: tokens.space.sm),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radius.sm),
            child: LinearProgressIndicator(
              value: fraction.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: tokens.ink.withValues(alpha: 0.08),
              color: tokens.gold,
            ),
          ),
        ),
        SizedBox(width: tokens.space.sm),
        SizedBox(
          width: 28,
          child: Text(
            countLabel,
            style: TextStyle(
              fontSize: 11,
              color: tokens.ink.withValues(alpha: 0.65),
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
