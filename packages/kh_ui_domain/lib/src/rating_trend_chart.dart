import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';

/// Single historical rating point representing an aggregate period.
class RatingTrendPoint {
  const RatingTrendPoint({
    required this.period,
    required this.average,
    required this.count,
  });

  /// Period identifier e.g. "2026-03" or month name.
  final String period;
  final double average;
  final int count;

  /// Formatted score string (1 decimal place).
  String get averageString => average.toStringAsFixed(1);

  factory RatingTrendPoint.fromJson(Map<String, dynamic> json) =>
      RatingTrendPoint(
        period: json['period'] as String? ?? '',
        average: (json['average'] as num?)?.toDouble() ?? 0.0,
        count: (json['count'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'period': period,
        'average': average,
        'count': count,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RatingTrendPoint &&
          runtimeType == other.runtimeType &&
          period == other.period &&
          average == other.average &&
          count == other.count;

  @override
  int get hashCode => Object.hash(period, average, count);

  @override
  String toString() =>
      'RatingTrendPoint(period: $period, average: $average, count: $count)';
}

/// Visual chart block displaying historical rating trends (CP6-B05.6 / FR-VEN-023).
///
/// Renders a clean bar / column chart with average score labels (1 dp),
/// period/month labels, and proportional bars on a 0.0 to 5.0 scale.
///
/// Supports LTR and RTL layouts (respecting `Directionality.of(context)`).
/// Handles empty data / insufficient history state gracefully by rendering an
/// insufficient history banner when [points] is empty, all counts are 0, or length < 2.
class RatingTrendChart extends StatelessWidget {
  const RatingTrendChart({
    super.key,
    required this.points,
    this.title,
    this.insufficientHistoryLabel,
    this.barWidth = 18.0,
    this.barHeight = 96.0,
  });

  /// Historical rating points to plot.
  final List<RatingTrendPoint> points;

  /// Optional chart title displayed above the bars.
  final String? title;

  /// Custom message shown when history is insufficient.
  /// Defaults to "Insufficient history for trend".
  final String? insufficientHistoryLabel;

  /// Width of each visual bar in logical pixels.
  final double barWidth;

  /// Height of the bar track in logical pixels.
  final double barHeight;

  bool get _isInsufficient =>
      points.length < 2 || points.every((p) => p.count <= 0);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    if (_isInsufficient) {
      final message =
          insufficientHistoryLabel ?? 'Insufficient history for trend';
      return Container(
        key: const Key('rating-trend-chart-insufficient'),
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space.md,
          vertical: tokens.space.md,
        ),
        decoration: BoxDecoration(
          color: tokens.warning.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(tokens.radius.sm),
          border: Border.all(color: tokens.warning.withValues(alpha: 0.28)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 18,
              color: tokens.ink.withValues(alpha: 0.75),
            ),
            SizedBox(width: tokens.space.sm),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: tokens.ink.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      key: const Key('rating-trend-chart'),
      width: double.infinity,
      padding: EdgeInsets.all(tokens.space.md),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.ink.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null && title!.isNotEmpty) ...[
            Text(
              title!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: tokens.ink,
              ),
            ),
            SizedBox(height: tokens.space.md),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < points.length; i++)
                Expanded(
                  child: _TrendBarColumn(
                    key: Key('rating-trend-bar-${points[i].period}'),
                    point: points[i],
                    barWidth: barWidth,
                    barHeight: barHeight,
                    tokens: tokens,
                    theme: theme,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendBarColumn extends StatelessWidget {
  const _TrendBarColumn({
    super.key,
    required this.point,
    required this.barWidth,
    required this.barHeight,
    required this.tokens,
    required this.theme,
  });

  final RatingTrendPoint point;
  final double barWidth;
  final double barHeight;
  final KhTokens tokens;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final fraction = (point.average / 5.0).clamp(0.0, 1.0);
    final scoreText = point.average.toStringAsFixed(1);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.space.xs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            scoreText,
            key: Key('rating-trend-score-${point.period}'),
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: tokens.ink,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.space.xs),
          Container(
            width: barWidth,
            height: barHeight,
            decoration: BoxDecoration(
              color: tokens.ink.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(tokens.radius.sm),
            ),
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: 1.0,
              heightFactor: fraction,
              child: Container(
                decoration: BoxDecoration(
                  color: tokens.gold,
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
              ),
            ),
          ),
          SizedBox(height: tokens.space.xs),
          Text(
            point.period,
            key: Key('rating-trend-period-${point.period}'),
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: tokens.ink.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
