import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/settings/model/platform_setting_item.dart';
import 'package:kh_admin/features/settings/model/platform_settings_state.dart';

/// Category pills + search field for platform settings. Was
/// `_PlatformSettingsScreenState._buildFilterBar` / `_buildCategoryChip`
/// (TR-S2-11).
class PlatformSettingsFilterBar extends StatelessWidget {
  const PlatformSettingsFilterBar({
    super.key,
    required this.state,
    required this.searchController,
    required this.onSelectCategory,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  final PlatformSettingsState state;
  final TextEditingController searchController;
  final ValueChanged<SettingCategory?> onSelectCategory;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _CategoryChip(
                label: 'All Settings (${state.settings.length})',
                isSelected: state.selectedCategory == null,
                onTap: () => onSelectCategory(null),
              ),
              SizedBox(width: kh.spacing.xs),
              _CategoryChip(
                label:
                    'Lifecycle (${state.countByCategory(SettingCategory.lifecycle)})',
                isSelected:
                    state.selectedCategory == SettingCategory.lifecycle,
                onTap: () => onSelectCategory(SettingCategory.lifecycle),
              ),
              SizedBox(width: kh.spacing.xs),
              _CategoryChip(
                label:
                    'Trading Limits (${state.countByCategory(SettingCategory.limits)})',
                isSelected: state.selectedCategory == SettingCategory.limits,
                onTap: () => onSelectCategory(SettingCategory.limits),
              ),
              SizedBox(width: kh.spacing.xs),
              _CategoryChip(
                label:
                    'Media & Storage (${state.countByCategory(SettingCategory.media)})',
                isSelected: state.selectedCategory == SettingCategory.media,
                onTap: () => onSelectCategory(SettingCategory.media),
              ),
              SizedBox(width: kh.spacing.xs),
              _CategoryChip(
                label:
                    'System & Security (${state.countByCategory(SettingCategory.security)})',
                isSelected:
                    state.selectedCategory == SettingCategory.security,
                onTap: () => onSelectCategory(SettingCategory.security),
              ),
            ],
          ),
        ),
        SizedBox(height: kh.spacing.sm),

        // Search Field
        TextField(
          key: const Key('settings-search-field'),
          controller: searchController,
          style: kh.typography.body.copyWith(color: kh.colors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search settings by key, description, or value...',
            prefixIcon:
                Icon(Icons.search, size: 18, color: kh.colors.goldPrimary),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 16),
                    onPressed: onClearSearch,
                  )
                : null,
          ),
          onChanged: onSearchChanged,
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return InkWell(
      onTap: onTap,
      borderRadius: kh.shapes.pill,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: kh.spacing.md,
          vertical: kh.spacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? kh.colors.goldPrimary.withValues(alpha: 0.18)
              : kh.colors.backgroundElevated,
          borderRadius: kh.shapes.pill,
          border: Border.all(
            color: isSelected
                ? kh.colors.goldPrimary
                : kh.colors.borderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: kh.typography.bodySmall.copyWith(
            color: isSelected
                ? kh.colors.goldPrimary
                : kh.colors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
