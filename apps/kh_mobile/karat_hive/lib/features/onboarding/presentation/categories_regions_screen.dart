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
    final s = KhStrings.of(context);
    final state = ref.watch(categoriesRegionsControllerProvider);
    final controller = ref.read(categoriesRegionsControllerProvider.notifier);
    final categories = ref.watch(categoriesProvider);
    final regions = ref.watch(regionsProvider);

    return KhScaffold(
      title: s.s('onboarding.categoriesRegions'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.failure != null) ...[
            KhInlineError(message: state.failure!.message ?? 'Could not save.'),
            const SizedBox(height: 12),
          ],
          const Text('Categories'),
          const SizedBox(height: 8),
          categories.when(
            data: (nodes) => CategoryRegionPicker(
              nodes: nodes,
              selected: state.categoryIds,
              locale: s.isRtl ? 'ar' : 'en',
              onToggle: controller.toggleCategory,
            ),
            loading: () => const KhLoadingView(),
            error: (_, __) => const KhInlineError(message: 'Could not load categories.'),
          ),
          const SizedBox(height: 16),
          const Text('Regions'),
          const SizedBox(height: 8),
          regions.when(
            data: (nodes) => CategoryRegionPicker(
              nodes: nodes,
              selected: state.regionIds,
              locale: s.isRtl ? 'ar' : 'en',
              onToggle: controller.toggleRegion,
            ),
            loading: () => const KhLoadingView(),
            error: (_, __) => const KhInlineError(message: 'Could not load regions.'),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(s.s('onboarding.awayMode')),
            subtitle: Text(s.s('onboarding.awayModeHint')),
            value: state.awayMode,
            onChanged: state.busy ? null : controller.setAwayMode,
          ),
          const SizedBox(height: 8),
          Text(s.s('onboarding.volumePlaceholder')),
          const SizedBox(height: 24),
          KhButton(
            label: s.s('onboarding.save'),
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
