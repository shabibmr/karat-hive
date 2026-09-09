import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/reports/model/report_result.dart';

/// Bar or line chart for ADM-S17. Empty [points] must not be passed — the
/// parent shows a placeholder instead of building a chart.
class ReportChart extends StatelessWidget {
  const ReportChart({super.key, required this.points});

  final List<ReportChartPoint> points;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final useLine = points.length > 12;
    return SizedBox(
      height: 260,
      child: useLine ? _lineChart(kh) : _barChart(kh),
    );
  }

  Widget _barChart(KhThemeExtension kh) {
    final maxY = points.fold<double>(0, (m, p) => p.value > m ? p.value : m);
    return BarChart(
      BarChartData(
        maxY: maxY == 0 ? 1 : maxY * 1.15,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: kh.colors.borderSubtle,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: kh.typography.caption.copyWith(color: kh.colors.textMuted),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    points[index].label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: kh.typography.caption.copyWith(color: kh.colors.textSecondary),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < points.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: points[i].value,
                  width: 16,
                  color: kh.colors.goldPrimary,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
        ],
      ),
      duration: Duration.zero,
    );
  }

  Widget _lineChart(KhThemeExtension kh) {
    final maxY = points.fold<double>(0, (m, p) => p.value > m ? p.value : m);
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY == 0 ? 1 : maxY * 1.15,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: kh.colors.borderSubtle,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: kh.typography.caption.copyWith(color: kh.colors.textMuted),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                return Text(
                  points[index].label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kh.typography.caption.copyWith(color: kh.colors.textSecondary),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < points.length; i++)
                FlSpot(i.toDouble(), points[i].value),
            ],
            isCurved: false,
            color: kh.colors.goldPrimary,
            barWidth: 2,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
      duration: Duration.zero,
    );
  }
}
