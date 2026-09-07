import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../../app/guards.dart';
import '../controller/categories_regions_controller.dart';
import '../repository/onboarding_repository.dart';

/// VEN-S16 — declare the categories and regions that drive matching (FR-VEN-025).
class CategoriesRegionsScreen extends ConsumerWidget {
  const CategoriesRegionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final state = ref.watch(categoriesRegionsControllerProvider);
    final controller = ref.read(categoriesRegionsControllerProvider.notifier);
    final categories = ref.watch(categoriesProvider);
    final regions = ref.watch(regionsProvider);

    return KhScaffold(
      title: l10n?.onboardingCategoriesRegions ?? 'Categories & regions',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.failure != null) ...[
            KhInlineError(
              message: state.failure!.message ??
                  (l10n?.onboardingCouldNotSave ?? 'Could not save.'),
            ),
            const SizedBox(height: 12),
          ],
          Text(l10n?.onboardingCategoriesHeading ?? 'Categories'),
          const SizedBox(height: 8),
          categories.when(
            data: (nodes) => CategoryRegionPicker(
              nodes: nodes,
              selected: state.categoryIds,
              locale: locale.languageCode,
              onToggle: controller.toggleCategory,
            ),
            loading: () => const KhLoadingView(),
            error: (_, __) => KhInlineError(
              message:
                  l10n?.couldNotLoadCategories ?? 'Could not load categories.',
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n?.onboardingRegionsHeading ?? 'Regions'),
          const SizedBox(height: 8),
          regions.when(
            data: (nodes) => CategoryRegionPicker(
              nodes: nodes,
              selected: state.regionIds,
              locale: locale.languageCode,
              onToggle: controller.toggleRegion,
            ),
            loading: () => const KhLoadingView(),
            error: (_, __) => KhInlineError(
              message: l10n?.couldNotLoadRegions ?? 'Could not load regions.',
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n?.onboardingAwayMode ?? 'Away mode'),
            subtitle: Text(
              l10n?.onboardingAwayModeHint ??
                  'Pause new-request notifications without deactivating.',
            ),
            value: state.awayMode,
            onChanged: state.busy ? null : controller.setAwayMode,
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.onboardingVolumePlaceholder ??
                'Matched-request volume will appear once matching is live.',
          ),
          const SizedBox(height: 24),
          KhButton(
            label: l10n?.onboardingSave ?? 'Save',
            busy: state.busy,
            onPressed: state.canSave
                ? () async {
                    final ok = await controller.save();
                    if (ok && context.mounted) context.go(AppGuards.home);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
