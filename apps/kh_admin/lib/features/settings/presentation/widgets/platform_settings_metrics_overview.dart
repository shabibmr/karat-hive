import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/widgets/kh_metric_card.dart';
import 'package:kh_admin/features/settings/model/platform_setting_item.dart';
import 'package:kh_admin/features/settings/model/platform_settings_state.dart';

/// Metrics overview row for platform settings. Was
/// `_PlatformSettingsScreenState._buildMetricsOverview` (TR-S2-11).
class PlatformSettingsMetricsOverview extends StatelessWidget {
  const PlatformSettingsMetricsOverview({
    super.key,
    required this.state,
    required this.onSelectCategory,
  });

  final PlatformSettingsState state;
  final ValueChanged<SettingCategory?> onSelectCategory;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 36) / 4;
        final minWidth = cardWidth > 220 ? cardWidth : 220.0;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: minWidth,
              child: KhMetricCard(
                value: '${state.settings.length}',
                label: 'TOTAL SETTINGS',
                linkText: 'All parameters',
                onTap: () => onSelectCategory(null),
              ),
            ),
            SizedBox(
              width: minWidth,
              child: KhMetricCard(
                value: '${state.countByCategory(SettingCategory.lifecycle)}',
                label: 'LIFECYCLE RULES',
                linkText: 'View lifecycle',
                emphasized: state.selectedCategory == SettingCategory.lifecycle,
                onTap: () => onSelectCategory(SettingCategory.lifecycle),
              ),
            ),
            SizedBox(
              width: minWidth,
              child: KhMetricCard(
                value: '${state.countByCategory(SettingCategory.limits)}',
                label: 'TRADING LIMITS',
                linkText: 'View limits',
                emphasized: state.selectedCategory == SettingCategory.limits,
                onTap: () => onSelectCategory(SettingCategory.limits),
              ),
            ),
            SizedBox(
              width: minWidth,
              child: KhMetricCard(
                value: '${state.countByCategory(SettingCategory.media)}',
                label: 'MEDIA & STORAGE',
                linkText: 'View media',
                emphasized: state.selectedCategory == SettingCategory.media,
                onTap: () => onSelectCategory(SettingCategory.media),
              ),
            ),
          ],
        );
      },
    );
  }
}
