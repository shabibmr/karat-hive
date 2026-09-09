import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../../app/platform/open_url.dart';
import '../../../app/session/session_controller.dart';
import '../../request_feed/controller/request_feed_controller.dart';
import '../../subscription/controller/subscription_controller.dart';
import '../controller/settings_controller.dart';

/// VEN-S18 — Vendor settings (language / feed / notifications / security / legal: CP6-B03).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({
    super.key,
    this.timePicker,
    this.openUrl,
    this.onLogout,
  });

  /// Optional override for [showTimePicker] (useful in tests).
  final Future<TimeOfDay?> Function(
    BuildContext context, {
    required TimeOfDay initialTime,
  })? timePicker;

  /// Optional override for URL opening (useful in tests).
  final Future<bool> Function(String url)? openUrl;

  /// Optional override for logout routine (useful in tests).
  final Future<void> Function()? onLogout;

  TimeOfDay _parseTime(String? timeStr, TimeOfDay fallback) {
    if (timeStr == null || !timeStr.contains(':')) return fallback;
    final parts = timeStr.split(':');
    if (parts.length != 2) return fallback;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return fallback;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return fallback;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _openPresetDialog(
    BuildContext context,
    WidgetRef ref,
    List<FilterPresetItem> presets,
    String? currentPresetId,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Default Filter Preset'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                key: const Key('preset-option-none'),
                title: const Text('None'),
                trailing: currentPresetId == null || currentPresetId.isEmpty
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  ref.read(settingsControllerProvider.notifier).patch(
                        defaultFilterPresetId: '',
                      );
                  Navigator.of(dialogCtx).pop();
                },
              ),
              for (final preset in presets) ...[
                const Divider(height: 1),
                ListTile(
                  key: Key('preset-option-${preset.id}'),
                  title: Text(preset.name),
                  trailing: preset.id == currentPresetId
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    ref.read(settingsControllerProvider.notifier).patch(
                          defaultFilterPresetId: preset.id,
                        );
                    Navigator.of(dialogCtx).pop();
                  },
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _openChangePasswordDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _ChangePasswordDialog(),
    );
  }

  Future<void> _handleRevokeSession(
    BuildContext context,
    WidgetRef ref,
    AuthSessionDto session,
  ) async {
    final confirmed = await showKhConfirmDialog(
      context,
      title: 'Revoke Session',
      body:
          'Are you sure you want to revoke this session? That device will be signed out immediately.',
      confirmLabel: 'Revoke',
      cancelLabel: 'Cancel',
      destructive: true,
    );

    if (confirmed != true) return;

    final res = await ref
        .read(settingsControllerProvider.notifier)
        .revokeSession(session.id);

    if (!context.mounted) return;

    res.when(
      ok: (_) {
        ref.invalidate(activeSessionsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session revoked successfully.'),
          ),
        );
      },
      err: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message ?? 'Failed to revoke session.'),
          ),
        );
      },
    );
  }

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
    final currentLocale = ref.watch(appLocaleProvider).languageCode;
    final patchedSettings = ref.watch(settingsControllerProvider).valueOrNull;
    final serverSettings = ref.watch(userSettingsProvider).valueOrNull;
    final settings = patchedSettings ?? serverSettings;
    final notifications =
        settings?.notifications ?? const <String, NotificationChannelPref>{};
    final quietHours = settings?.quietHours;
    final quietHoursEnabled = quietHours != null;
    final startTimeStr = (quietHours != null && quietHours.start.isNotEmpty)
        ? quietHours.start
        : '22:00';
    final endTimeStr = (quietHours != null && quietHours.end.isNotEmpty)
        ? quietHours.end
        : '07:00';

    final presetsAsync = ref.watch(filterPresetsListProvider);
    final presets = presetsAsync.valueOrNull ?? const <FilterPresetItem>[];
    final defaultPresetId = settings?.defaultFilterPresetId;
    final defaultPreset = (defaultPresetId != null && defaultPresetId.isNotEmpty)
        ? presets.where((p) => p.id == defaultPresetId).firstOrNull
        : null;
    final defaultPresetName = defaultPreset?.name ?? 'None';

    final sessionsAsync = ref.watch(activeSessionsProvider);
    final configAsync = ref.watch(platformConfigProvider);
    final config = configAsync.valueOrNull;

    final categories = [
      NotificationPreferenceCategory(
        id: 'request_matches',
        label: 'Request Matches',
        pref: notifications['request_matches'] ??
            const NotificationChannelPref(
              inApp: false,
              push: false,
              email: false,
            ),
      ),
      NotificationPreferenceCategory(
        id: 'offer_updates',
        label: 'Offer Updates',
        pref: notifications['offer_updates'] ??
            const NotificationChannelPref(
              inApp: false,
              push: false,
              email: false,
            ),
      ),
      NotificationPreferenceCategory(
        id: 'connection_alerts',
        label: 'Connection Alerts',
        pref: notifications['connection_alerts'] ??
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

            // 2. Feed Preferences (CP6-B03.4)
            SettingsGroup(
              title: 'Feed Preferences',
              children: [
                SettingRow(
                  key: const Key('default-filter-preset-row'),
                  title: 'Default Filter Preset',
                  trailing: Text(
                    defaultPresetName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  showChevron: true,
                  onTap: () => _openPresetDialog(
                    context,
                    ref,
                    presets,
                    defaultPresetId,
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

            // 4. Quiet Hours
            SettingsGroup(
              title: 'Quiet Hours',
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: KhToggle(
                    key: const Key('quiet-hours-toggle'),
                    label: 'Enable Quiet Hours',
                    value: quietHoursEnabled,
                    onChanged: (enabled) {
                      if (enabled) {
                        ref.read(settingsControllerProvider.notifier).patch(
                              quietHours: QuietHours(
                                start: startTimeStr,
                                end: endTimeStr,
                              ),
                            );
                      } else {
                        ref.read(settingsControllerProvider.notifier).patch(
                              quietHours: null,
                            );
                      }
                    },
                  ),
                ),
                if (quietHoursEnabled) ...[
                  SettingRow(
                    key: const Key('quiet-hours-start'),
                    title: 'Start Time',
                    trailing: Text(
                      startTimeStr,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    showChevron: true,
                    onTap: () async {
                      final initial = _parseTime(
                        startTimeStr,
                        const TimeOfDay(hour: 22, minute: 0),
                      );
                      final picked = timePicker != null
                          ? await timePicker!(context, initialTime: initial)
                          : await showTimePicker(
                              context: context,
                              initialTime: initial,
                            );
                      if (picked != null) {
                        final formatted = _formatTime(picked);
                        ref.read(settingsControllerProvider.notifier).patch(
                              quietHours: QuietHours(
                                start: formatted,
                                end: endTimeStr,
                              ),
                            );
                      }
                    },
                  ),
                  SettingRow(
                    key: const Key('quiet-hours-end'),
                    title: 'End Time',
                    trailing: Text(
                      endTimeStr,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    showChevron: true,
                    onTap: () async {
                      final initial = _parseTime(
                        endTimeStr,
                        const TimeOfDay(hour: 7, minute: 0),
                      );
                      final picked = timePicker != null
                          ? await timePicker!(context, initialTime: initial)
                          : await showTimePicker(
                              context: context,
                              initialTime: initial,
                            );
                      if (picked != null) {
                        final formatted = _formatTime(picked);
                        ref.read(settingsControllerProvider.notifier).patch(
                              quietHours: QuietHours(
                                start: startTimeStr,
                                end: formatted,
                              ),
                            );
                      }
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // 5. Security & Login (CP6-B03.5)
            SettingsGroup(
              title: 'Security & Login',
              children: [
                SettingRow(
                  key: const Key('change-password-row'),
                  title: 'Change Password',
                  leadingIcon: Icons.lock,
                  showChevron: true,
                  onTap: () => _openChangePasswordDialog(context),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Active Sessions',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                sessionsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        key: Key('sessions-loading-indicator'),
                      ),
                    ),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Could not load active sessions',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ),
                  data: (sessions) {
                    if (sessions.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No active sessions.'),
                      );
                    }
                    return Column(
                      children: [
                        for (final (i, s) in sessions.indexed)
                          _SessionRow(
                            session: s,
                            isCurrent: s.isCurrent ||
                                (i == 0 && !sessions.any((x) => x.isCurrent)),
                            onRevoke: () => _handleRevokeSession(context, ref, s),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 6. About & Legal (CP6-B03.6)
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

            // 7. Account Actions (CP6-B03.6)
            SettingsGroup(
              title: 'Account Actions',
              children: [
                SettingRow(
                  key: const Key('logout-row'),
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
      ),
    );
  }
}

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  late final TextEditingController _currentController;
  late final TextEditingController _newController;
  late final TextEditingController _confirmController;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _currentController = TextEditingController();
    _newController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _checkPolicy(String pwd) {
    if (pwd.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(pwd)) return false;
    if (!RegExp(r'[0-9]').hasMatch(pwd)) return false;
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>\-_=+\\/\[\]~`]').hasMatch(pwd)) {
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    final current = _currentController.text;
    final newPass = _newController.text;
    final confirm = _confirmController.text;

    if (current.isEmpty) {
      setState(() => _error = 'Current password is required.');
      return;
    }
    if (!_checkPolicy(newPass)) {
      setState(() => _error =
          'Password must be at least 8 characters, include 1 uppercase letter, 1 number, and 1 symbol.');
      return;
    }
    if (newPass != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    final res = await ref
        .read(settingsControllerProvider.notifier)
        .setPassword(currentPassword: current, newPassword: newPass);

    if (!mounted) return;

    res.when(
      ok: (_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully.')),
        );
      },
      err: (failure) {
        setState(() {
          _busy = false;
          _error = failure.message ?? 'Failed to change password.';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KhTextField(
              key: const Key('current-password-input'),
              controller: _currentController,
              label: 'Current Password',
              obscure: true,
            ),
            const SizedBox(height: 12),
            KhTextField(
              key: const Key('new-password-input'),
              controller: _newController,
              label: 'New Password',
              obscure: true,
            ),
            const SizedBox(height: 12),
            KhTextField(
              key: const Key('confirm-password-input'),
              controller: _confirmController,
              label: 'Confirm New Password',
              obscure: true,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              KhInlineError(
                key: const Key('password-policy-error'),
                message: _error!,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        KhButton(
          key: const Key('submit-password-button'),
          label: 'Save',
          busy: _busy,
          onPressed: _busy ? null : _submit,
        ),
      ],
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({
    required this.session,
    required this.isCurrent,
    required this.onRevoke,
  });

  final AuthSessionDto session;
  final bool isCurrent;
  final VoidCallback onRevoke;

  static IconData _platformIcon(String? label) {
    final l = (label ?? '').toLowerCase();
    if (l.contains('ios') ||
        l.contains('iphone') ||
        l.contains('ipad') ||
        l.contains('apple') ||
        l.contains('safari')) {
      return Icons.phone_iphone;
    }
    if (l.contains('mac') || l.contains('darwin')) {
      return Icons.laptop_mac;
    }
    if (l.contains('android')) {
      return Icons.phone_android;
    }
    if (l.contains('windows') || l.contains('win')) {
      return Icons.laptop_windows;
    }
    if (l.contains('web') ||
        l.contains('chrome') ||
        l.contains('firefox') ||
        l.contains('mozilla')) {
      return Icons.web;
    }
    return Icons.devices;
  }

  static String _formatDateTime(DateTime dt) {
    final gst = GstFormatter.toGst(dt);
    final d = gst.day.toString().padLeft(2, '0');
    final m = gst.month.toString().padLeft(2, '0');
    final y = gst.year;
    final h = gst.hour.toString().padLeft(2, '0');
    final min = gst.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    final ipText = session.lastIp != null ? 'IP: ${session.lastIp}' : null;
    final activeText = 'Last active: ${_formatDateTime(session.lastUsedAt)}';
    final subtitle = ipText != null ? '$ipText • $activeText' : activeText;

    return Padding(
      key: Key('session-row-${session.id}'),
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space.md,
        vertical: tokens.space.sm,
      ),
      child: Row(
        children: [
          Icon(
            _platformIcon(session.deviceLabel),
            size: 24,
            color: tokens.ink.withValues(alpha: 0.7),
          ),
          SizedBox(width: tokens.space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  session.deviceLabel ?? 'Unknown Device',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: tokens.space.xs / 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.ink.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (isCurrent) ...[
            Chip(
              key: Key('current-device-badge-${session.id}'),
              label: const Text('Current device'),
              visualDensity: VisualDensity.compact,
            ),
          ] else ...[
            OutlinedButton(
              key: Key('revoke-button-${session.id}'),
              onPressed: onRevoke,
              child: const Text('Revoke'),
            ),
          ],
        ],
      ),
    );
  }
}
