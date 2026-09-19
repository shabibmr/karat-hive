import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../../app/platform/open_url.dart';
import '../../../app/session/session_controller.dart';
import '../../onboarding/repository/onboarding_repository.dart';
import '../../subscription/controller/subscription_controller.dart';
import '../controller/settings_controller.dart';

/// CUS-S21 — Customer settings (`FR-CUS-034`, `FR-CUS-004`).
///
/// Shares [settingsControllerProvider] / [userSettingsProvider] with the
/// Vendor settings screen (VEN-S18) — `GET/PATCH /v1/me/settings` is role-
/// agnostic. Adds the Customer-only account lifecycle actions (deactivate,
/// request deletion) that VEN-S18 doesn't have.
class CustomerSettingsScreen extends ConsumerWidget {
  const CustomerSettingsScreen({
    super.key,
    this.openUrl,
    this.onLogout,
  });

  /// Optional override for URL opening (useful in tests).
  final Future<bool> Function(String url)? openUrl;

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

  void _showError(BuildContext context, Failure failure, String fallback) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(failure.message ?? fallback)),
    );
  }

  Future<void> _handleDeactivate(BuildContext context, WidgetRef ref) async {
    final confirmed = await showKhConfirmDialog(
      context,
      title: 'Deactivate Account',
      body:
          'Deactivating closes your published Requests and blocks login until '
          'you contact support to reactivate. Are you sure?',
      confirmLabel: 'Deactivate',
      cancelLabel: 'Cancel',
      destructive: true,
    );
    if (confirmed != true) return;

    final res =
        await ref.read(settingsControllerProvider.notifier).deactivateAccount();
    if (!context.mounted) return;
    res.when(
      ok: (_) async {
        if (onLogout != null) {
          await onLogout!();
        } else {
          await ref.read(sessionProvider.notifier).signOut();
        }
      },
      err: (f) => _showError(context, f, 'Could not deactivate account.'),
    );
  }

  Future<void> _handleRequestDeletion(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final firstConfirm = await showKhConfirmDialog(
      context,
      title: 'Request Permanent Deletion',
      body: 'This permanently deletes your account. Your personal data is '
          'anonymised within 30 days; reviews you left show as "Deleted '
          'user". This is refused if you have a Connection in the last 30 '
          'days. This cannot be undone.',
      confirmLabel: 'Continue',
      cancelLabel: 'Cancel',
      destructive: true,
    );
    if (firstConfirm != true) return;
    if (!context.mounted) return;

    final createRes = await ref
        .read(settingsControllerProvider.notifier)
        .createDeletionRequest();
    if (!context.mounted) return;

    await createRes.when(
      ok: (request) => _confirmDeletionWithOtp(context, ref, request),
      err: (f) async =>
          _showError(context, f, 'Could not start account deletion.'),
    );
  }

  Future<void> _confirmDeletionWithOtp(
    BuildContext context,
    WidgetRef ref,
    AccountDeletionRequest request,
  ) async {
    final challengeId = request.challengeId;
    if (challengeId == null) {
      _showError(
        context,
        const ServerFailure(message: 'Missing deletion challenge.'),
        'Could not start account deletion.',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeletionOtpDialog(
        challengeId: challengeId,
        requestId: request.id,
      ),
    );
    if (confirmed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deletion requested. You have been logged out.'),
        ),
      );
      if (onLogout != null) {
        await onLogout!();
      } else {
        await ref.read(sessionProvider.notifier).signOut();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(appLocaleProvider).languageCode;
    final patchedSettings = ref.watch(settingsControllerProvider).valueOrNull;
    final serverSettings = ref.watch(userSettingsProvider).valueOrNull;
    final settings = patchedSettings ?? serverSettings;
    final notifications =
        settings?.notifications ?? const <String, NotificationChannelPref>{};
    final defaultRegionId = settings?.defaultRegionId;

    final regionsAsync = ref.watch(regionsProvider);
    final configAsync = ref.watch(platformConfigProvider);
    final config = configAsync.valueOrNull;

    final categories = [
      NotificationPreferenceCategory(
        id: 'offer_updates',
        label: 'Offers',
        pref: notifications['offer_updates'] ??
            const NotificationChannelPref(
              inApp: false,
              push: false,
              email: false,
            ),
      ),
      NotificationPreferenceCategory(
        id: 'request_expiry',
        label: 'Request Expiry',
        pref: notifications['request_expiry'] ??
            const NotificationChannelPref(
              inApp: false,
              push: false,
              email: false,
            ),
      ),
      NotificationPreferenceCategory(
        id: 'review_reminder',
        label: 'Review Reminders',
        pref: notifications['review_reminder'] ??
            const NotificationChannelPref(
              inApp: false,
              push: false,
              email: false,
            ),
      ),
      NotificationPreferenceCategory(
        id: 'announcement',
        label: 'Announcements',
        pref: notifications['announcement'] ??
            const NotificationChannelPref(
              inApp: false,
              push: false,
              email: false,
            ),
      ),
      NotificationPreferenceCategory(
        id: 'security',
        label: 'Security & Disputes',
        hint: 'Required for account security',
        locked: true,
        pref: notifications['security'] ?? kLockedNotificationChannelPref,
      ),
    ];

    return KhScaffold(
      title: 'Settings',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Language
            SettingsGroup(
              title: 'Language',
              children: [
                LanguagePickerTile(
                  currentLocale: currentLocale,
                  onLocaleChanged: (newLocale) {
                    ref
                        .read(appLocaleProvider.notifier)
                        .setLanguageCode(newLocale);
                    ref.read(settingsControllerProvider.notifier).patch(
                          preferredLanguage: newLocale,
                        );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Default region
            SettingsGroup(
              title: 'Default Region',
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: regionsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) =>
                        const Text('Could not load regions'),
                    data: (regions) => DropdownButtonFormField<String?>(
                      key: const Key('default-region-select'),
                      initialValue: defaultRegionId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'No default region',
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('No default region'),
                        ),
                        ...regions.map(
                          (r) => DropdownMenuItem<String?>(
                            value: r.id,
                            child: Text(r.nameEn),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        ref.read(settingsControllerProvider.notifier).patch(
                              defaultRegionId: value ?? '',
                            );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Notifications
            SettingsGroup(
              title: 'Notifications',
              children: [
                NotificationPreferenceMatrix(
                  padding: const EdgeInsets.all(12),
                  pushLabel: 'Push',
                  emailLabel: 'Email',
                  inAppLabel: 'SMS',
                  categories: categories,
                  onChanged: (categoryId, nextPref) {
                    final updated =
                        Map<String, NotificationChannelPref>.from(notifications);
                    updated[categoryId] = nextPref;
                    ref.read(settingsControllerProvider.notifier).patch(
                          notifications: updated,
                        );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4. About & Legal
            SettingsGroup(
              title: 'About & Legal',
              children: [
                SettingRow(
                  key: const Key('terms-of-service-row'),
                  title: 'Terms of Service',
                  leadingIcon: Icons.description,
                  showChevron: true,
                  onTap: () {
                    final url = config?.termsUrl ?? 'https://karathive.ae/terms';
                    (openUrl ?? openExternalUrl)(url);
                  },
                ),
                SettingRow(
                  key: const Key('privacy-policy-row'),
                  title: 'Privacy Policy',
                  leadingIcon: Icons.privacy_tip,
                  showChevron: true,
                  onTap: () {
                    final url =
                        config?.privacyUrl ?? 'https://karathive.ae/privacy';
                    (openUrl ?? openExternalUrl)(url);
                  },
                ),
                SettingRow(
                  key: const Key('support-help-row'),
                  title: 'Support & Help',
                  leadingIcon: Icons.help_outline,
                  showChevron: true,
                  onTap: () {
                    final url = config?.supportContactUrl ??
                        'https://karathive.ae/support';
                    (openUrl ?? openExternalUrl)(url);
                  },
                ),
                const SettingRow(
                  key: Key('app-version-row'),
                  title: 'App Version',
                  subtitle: 'v1.0.0 (build 42)',
                  leadingIcon: Icons.info_outline,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 5. Account actions
            SettingsGroup(
              title: 'Account',
              children: [
                SettingRow(
                  key: const Key('customer-settings-logout-row'),
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
                const Divider(height: 1),
                SettingRow(
                  key: const Key('deactivate-account-row'),
                  title: 'Deactivate Account',
                  leadingIcon: Icons.pause_circle_outline,
                  showChevron: true,
                  onTap: () => _handleDeactivate(context, ref),
                ),
                const Divider(height: 1),
                SettingRow(
                  key: const Key('request-deletion-row'),
                  title: Text(
                    'Request Permanent Deletion',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  leadingIcon: Icon(
                    Icons.delete_forever_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  showChevron: true,
                  onTap: () => _handleRequestDeletion(context, ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Second step of account deletion: the backend issues an OTP challenge with
/// [AccountDeletionRequest.challengeId] (`me.service.ts` → `otp.requireVerified`,
/// purpose `CHANGE_MOBILE`) that must be verified before
/// `confirmDeletionRequest` will finalise.
class _DeletionOtpDialog extends ConsumerStatefulWidget {
  const _DeletionOtpDialog({required this.challengeId, required this.requestId});

  final String challengeId;
  final String requestId;

  @override
  ConsumerState<_DeletionOtpDialog> createState() => _DeletionOtpDialogState();
}

class _DeletionOtpDialogState extends ConsumerState<_DeletionOtpDialog> {
  final _codeController = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Enter the code sent to your mobile.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    final controller = ref.read(settingsControllerProvider.notifier);
    final verifyRes = await controller.verifyDeletionOtp(
      challengeId: widget.challengeId,
      code: code,
    );

    final verifyFailure = verifyRes.failureOrNull;
    if (verifyFailure != null) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = verifyFailure.message ?? 'Invalid or expired code.';
      });
      return;
    }

    final verified = verifyRes.valueOrNull;
    if (verified == null || !verified.mobileVerified) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Invalid or expired code.';
      });
      return;
    }

    final confirmRes = await controller.confirmDeletionRequest(
      widget.requestId,
      challengeId: widget.challengeId,
    );

    if (!mounted) return;

    confirmRes.when(
      ok: (_) => Navigator.of(context).pop(true),
      err: (f) => setState(() {
        _busy = false;
        _error = f.message ?? 'Could not confirm account deletion.';
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Deletion'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Enter the verification code sent to your mobile number.'),
          const SizedBox(height: 12),
          KhTextField(
            key: const Key('deletion-otp-input'),
            controller: _codeController,
            label: 'Verification Code',
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            KhInlineError(
              key: const Key('deletion-otp-error'),
              message: _error!,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        KhButton(
          key: const Key('deletion-otp-submit-button'),
          label: 'Confirm Deletion',
          busy: _busy,
          onPressed: _busy ? null : _submit,
        ),
      ],
    );
  }
}
