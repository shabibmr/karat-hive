import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../../app/guards.dart';
import '../../../app/session/session_controller.dart';

/// CUS-S20 — Customer profile tab: account summary, settings link, and log out.
class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key, this.onLogout});

  /// Optional override for logout routine (useful in tests).
  final Future<void> Function()? onLogout;

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showKhConfirmDialog(
      context,
      title: 'Log Out',
      body: 'Are you sure you want to log out of your account?',
      confirmLabel: 'Log Out',
      cancelLabel: 'Cancel',
      destructive: true,
    );
    if (confirmed != true) return;

    if (onLogout != null) {
      await onLogout!();
    } else {
      await ref.read(sessionProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final user = session is SignedIn ? session.user : null;
    final displayName = user?.customer?.displayName.trim().isNotEmpty == true
        ? user!.customer!.displayName
        : (user?.mobileNumber ?? '');

    return KhScaffold(
      title: 'Profile',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsGroup(
            title: 'Account',
            children: [
              SettingRow(
                title: displayName,
                subtitle: user?.mobileNumber,
                leadingIcon: Icons.person_outline,
              ),
              if (user?.email != null && user!.email!.isNotEmpty)
                SettingRow(
                  title: user.email!,
                  leadingIcon: Icons.email_outlined,
                ),
            ],
          ),
          const SizedBox(height: 16),
          SettingsGroup(
            children: [
              SettingRow(
                key: const Key('customer-settings-row'),
                title: 'Settings',
                leadingIcon: Icons.settings_outlined,
                showChevron: true,
                onTap: () => context.go('${AppGuards.customerProfile}/settings'),
              ),
              SettingRow(
                key: const Key('customer-logout-row'),
                title: Text(
                  'Log Out',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                leadingIcon: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.error,
                ),
                onTap: () => _handleLogout(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
