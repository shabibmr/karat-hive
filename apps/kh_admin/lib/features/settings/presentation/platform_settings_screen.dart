import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/features/settings/controller/platform_settings_controller.dart';
import 'package:kh_admin/features/settings/model/platform_setting_item.dart';
import 'package:kh_admin/features/settings/model/platform_settings_state.dart';
import 'package:kh_admin/features/settings/presentation/widgets/edit_setting_dialog.dart';
import 'package:kh_admin/features/settings/presentation/widgets/offer_validity_notice_banner.dart';
import 'package:kh_admin/features/settings/presentation/widgets/platform_settings_filter_bar.dart';
import 'package:kh_admin/features/settings/presentation/widgets/platform_settings_metrics_overview.dart';
import 'package:kh_admin/features/settings/presentation/widgets/platform_settings_states.dart';
import 'package:kh_admin/features/settings/presentation/widgets/platform_settings_table.dart';

/// ADM-S19 Platform Settings screen.
/// Surfaces global operational parameters, timeouts, trading constraints, and media limits.
///
/// Composition root only: sections and the edit dialog live in
/// `presentation/widgets/` (TR-S2-11).
class PlatformSettingsScreen extends ConsumerStatefulWidget {
  const PlatformSettingsScreen({super.key});

  @override
  ConsumerState<PlatformSettingsScreen> createState() =>
      _PlatformSettingsScreenState();
}

class _PlatformSettingsScreenState
    extends ConsumerState<PlatformSettingsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditSettingDialog(BuildContext context, PlatformSettingItem item) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => EditSettingDialog(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final state = ref.watch(platformSettingsControllerProvider);
    final controller = ref.read(platformSettingsControllerProvider.notifier);

    // Show error snackbar if error occurs
    ref.listen<PlatformSettingsState>(platformSettingsControllerProvider,
        (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: kh.colors.error,
          ),
        );
      } else if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: kh.colors.success,
          ),
        );
      }
    });

    final filteredItems = state.filteredSettings;

    return SingleChildScrollView(
      padding: EdgeInsets.all(kh.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Screen Header
          KhScreenHeader(
            eyebrow: 'PLATFORM GOVERNANCE',
            heading: 'Platform Settings',
            supportingText:
                'Global operational parameters, lifecycle timeouts, trading constraints, and media limits.',
            trailing: OutlinedButton.icon(
              key: const Key('refresh-settings-button'),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh'),
              onPressed: state.isLoading ? null : () => controller.refresh(),
            ),
          ),
          SizedBox(height: kh.spacing.lg),

          // 2. Metrics Overview Row
          PlatformSettingsMetricsOverview(
            state: state,
            onSelectCategory: controller.selectCategory,
          ),
          SizedBox(height: kh.spacing.lg),

          // 3. Pending Offer-Validity Architecture Decision Banner
          const OfferValidityNoticeBanner(),
          SizedBox(height: kh.spacing.lg),

          // 4. Category Tabs & Search Bar
          PlatformSettingsFilterBar(
            state: state,
            searchController: _searchController,
            onSelectCategory: controller.selectCategory,
            onSearchChanged: controller.setSearchQuery,
            onClearSearch: () {
              _searchController.clear();
              controller.setSearchQuery('');
            },
          ),
          SizedBox(height: kh.spacing.md),

          // 5. Settings Data Table
          if (state.isLoading && state.settings.isEmpty)
            Center(
              key: const Key('settings-list-loading'),
              child: Padding(
                padding: EdgeInsets.all(kh.spacing.xl),
                child: const CircularProgressIndicator(),
              ),
            )
          else if (state.errorMessage != null && state.settings.isEmpty)
            PlatformSettingsErrorState(
              message: state.errorMessage!,
              onRetry: () => controller.refresh(),
            )
          else if (filteredItems.isEmpty)
            const PlatformSettingsEmptyState()
          else
            PlatformSettingsTable(
              items: filteredItems,
              onEdit: (item) => _showEditSettingDialog(context, item),
            ),
        ],
      ),
    );
  }
}
