import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../../app/guards.dart';
import '../../../app/session/session_controller.dart';
import '../controller/vendor_me_controller.dart';
import '../repository/onboarding_repository.dart';

/// VEN-S03 — the only shell a non-ACTIVE Vendor sees. No marketplace data.
class AwaitingApprovalScreen extends ConsumerWidget {
  const AwaitingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = KhStrings.of(context);
    final me = ref.watch(vendorMeProvider);

    Future<void> refresh() async {
      ref.invalidate(vendorMeProvider);
      await ref.read(sessionProvider.notifier).refreshUser();
    }

    return KhScaffold(
      title: s.s('onboarding.awaitingTitle'),
      onRefresh: refresh,
      actions: [
        IconButton(
          onPressed: () => ref.read(sessionProvider.notifier).signOut(),
          icon: const Icon(Icons.logout),
        ),
      ],
      body: me.when(
        loading: () => const KhLoadingView(),
        error: (_, __) => KhErrorView(
          message: 'Could not load your status.',
          onRetry: refresh,
        ),
        data: (vendor) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            VendorStatusCard(
              lifecycle: vendor.lifecycle,
              tradingName: vendor.tradingName,
              lifecycleLabel: s.s('lifecycle.${vendor.lifecycle.name}'),
              subtitle: _reasonText(s, vendor),
              verificationMessage: vendor.verificationMessage,
            ),
            const SizedBox(height: 24),
            ..._actions(context, s, vendor, ref),
          ],
        ),
      ),
    );
  }

  String _reasonText(KhStrings s, VendorMe v) => switch (v.awaitingApprovalReason) {
        AwaitingApprovalReason.pendingDocuments => s.s('onboarding.pendingDocuments'),
        AwaitingApprovalReason.pendingAdmin => s.s('onboarding.pendingAdmin'),
        AwaitingApprovalReason.categoriesRequired => s.s('onboarding.categoriesRequired'),
        AwaitingApprovalReason.rejected => s.s('onboarding.rejected'),
        _ => s.s('onboarding.pendingAdmin'),
      };

  List<Widget> _actions(BuildContext c, KhStrings s, VendorMe v, WidgetRef ref) {
    return switch (v.lifecycle) {
      VendorLifecycle.verified => [
          KhButton(
            label: s.s('onboarding.categoriesRegions'),
            onPressed: () => c.go(AppGuards.categories),
          ),
        ],
      VendorLifecycle.rejected => [
          KhButton(
            label: s.s('onboarding.uploadKyc'),
            onPressed: () => c.go(AppGuards.kyc),
          ),
          const SizedBox(height: 8),
          KhButton(
            label: s.s('onboarding.resubmit'),
            secondary: true,
            onPressed: () async {
              await ref.read(onboardingRepositoryProvider).resubmit();
              ref.invalidate(vendorMeProvider);
              await ref.read(sessionProvider.notifier).refreshUser();
            },
          ),
        ],
      _ => [
          KhButton(
            label: s.s('onboarding.uploadKyc'),
            onPressed: () => c.go(AppGuards.kyc),
          ),
        ],
    };
  }
}
