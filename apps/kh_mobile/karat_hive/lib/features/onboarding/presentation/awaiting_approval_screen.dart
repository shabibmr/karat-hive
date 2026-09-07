import 'dart:async';

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
class AwaitingApprovalScreen extends ConsumerStatefulWidget {
  const AwaitingApprovalScreen({super.key});

  @override
  ConsumerState<AwaitingApprovalScreen> createState() => _AwaitingApprovalScreenState();
}

class _AwaitingApprovalScreenState extends ConsumerState<AwaitingApprovalScreen>
    with WidgetsBindingObserver {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _poll = Timer.periodic(const Duration(seconds: 15), (_) => _refresh());
  }

  @override
  void dispose() {
    _poll?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    ref.invalidate(vendorMeProvider);
    await ref.read(sessionProvider.notifier).refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(vendorMeProvider);

    return KhScaffold(
      title: l10n?.onboardingAwaitingTitle ?? 'Verification in progress',
      onRefresh: _refresh,
      actions: [
        IconButton(
          onPressed: () => ref.read(sessionProvider.notifier).signOut(),
          icon: const Icon(Icons.logout),
          tooltip: l10n?.commonLogout ?? 'Log out',
        ),
      ],
      body: me.when(
        loading: () => const KhLoadingView(),
        error: (_, __) => KhErrorView(
          message: 'Could not load your status.',
          onRetry: _refresh,
        ),
        data: (vendor) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            VendorStatusCard(
              lifecycle: vendor.lifecycle,
              tradingName: vendor.tradingName,
              lifecycleLabel: _lifecycleLabel(l10n, vendor.lifecycle),
              subtitle: _reasonText(l10n, vendor),
              verificationMessage: vendor.verificationMessage,
            ),
            const SizedBox(height: 24),
            ..._actions(context, l10n, vendor),
          ],
        ),
      ),
    );
  }

  String _lifecycleLabel(AppLocalizations? l10n, VendorLifecycle lifecycle) =>
      switch (lifecycle) {
        VendorLifecycle.registered => l10n?.lifecycleRegistered ?? 'Registered',
        VendorLifecycle.pendingVerification =>
          l10n?.lifecyclePendingVerification ?? 'Under review',
        VendorLifecycle.verified => l10n?.lifecycleVerified ?? 'Verified',
        VendorLifecycle.active => l10n?.lifecycleActive ?? 'Active',
        VendorLifecycle.suspended => l10n?.lifecycleSuspended ?? 'Suspended',
        VendorLifecycle.rejected => l10n?.lifecycleRejected ?? 'Needs changes',
        VendorLifecycle.deactivated =>
          l10n?.lifecycleDeactivated ?? 'Deactivated',
        VendorLifecycle.unknown => l10n?.lifecycleUnknown ?? 'Unknown',
      };

  String _reasonText(AppLocalizations? l10n, VendorMe v) =>
      switch (v.awaitingApprovalReason) {
        AwaitingApprovalReason.pendingDocuments =>
          l10n?.onboardingPendingDocuments ??
              'Upload your business documents to continue.',
        AwaitingApprovalReason.pendingAdmin =>
          l10n?.onboardingPendingAdmin ??
              'Our team is reviewing your documents.',
        AwaitingApprovalReason.categoriesRequired =>
          l10n?.onboardingCategoriesRequired ??
              'Choose the categories and regions you serve.',
        AwaitingApprovalReason.rejected =>
          l10n?.onboardingRejected ?? 'Your application needs changes.',
        _ => l10n?.onboardingPendingAdmin ??
            'Our team is reviewing your documents.',
      };

  List<Widget> _actions(BuildContext c, AppLocalizations? l10n, VendorMe v) {
    return switch (v.lifecycle) {
      VendorLifecycle.verified => [
          KhButton(
            label: l10n?.onboardingCategoriesRegions ?? 'Categories & regions',
            onPressed: () => c.go(AppGuards.categories),
          ),
        ],
      VendorLifecycle.rejected => [
          KhButton(
            label: l10n?.onboardingUploadKyc ?? 'Upload documents',
            onPressed: () => c.go(AppGuards.kyc),
          ),
          const SizedBox(height: 8),
          KhButton(
            label: l10n?.onboardingResubmit ?? 'Resubmit for review',
            secondary: true,
            onPressed: () async {
              await ref.read(onboardingRepositoryProvider).resubmit();
              await _refresh();
            },
          ),
        ],
      _ => [
          KhButton(
            label: l10n?.onboardingUploadKyc ?? 'Upload documents',
            onPressed: () => c.go(AppGuards.kyc),
          ),
        ],
    };
  }
}
