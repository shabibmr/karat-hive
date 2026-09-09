# Karat Hive: Wave 13 Execution Prompt (Final Wave)

Copy and run the prompt below in your fresh CLI window to complete **Wave 13** — the final wave of the Vendor App completion plan!

---

```markdown
You are orchestrating the completion of Wave 13 (the final wave) for Karat Hive in `/Users/admin/code/gold/karat-hive`.

## Prerequisites
- Waves 0–12 are 100% COMPLETE & VERIFIED.
- Current Wave: Wave 13 (1 task).

## Wave 13 Task

### Agent: Task CP6-B03.6 — VEN-S18 Legal, App Version, Logout
- Mutex: `settings-screen`
- Target file: `apps/kh_mobile/karat_hive/lib/features/profile_settings/presentation/settings_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/profile_settings/settings_screen_test.dart`
- Requirements:
  1. Per `VEN-S18`:
     - In `SettingsScreen`, build the "About & Legal" and "Account Actions" sections:
       - **Legal & Support:**
         - `SettingRow(title: 'Terms of Service', leadingIcon: Icons.description, showChevron: true)` $\rightarrow$ opens terms URL from platform config via `openExternalUrl`.
         - `SettingRow(title: 'Privacy Policy', leadingIcon: Icons.privacy_tip, showChevron: true)` $\rightarrow$ opens privacy URL from platform config via `openExternalUrl`.
         - `SettingRow(title: 'Support & Help', leadingIcon: Icons.help_outline, showChevron: true)` $\rightarrow$ opens support portal URL.
       - **App Version:**
         - `SettingRow(title: 'App Version', subtitle: 'v1.0.0 (build 42)', leadingIcon: Icons.info_outline)`
       - **Logout Flow:**
         - `SettingRow` or prominent red `KhButton` for "Log Out".
         - Tapping shows confirmation dialog:
           `showKhConfirmDialog(context, title: 'Log Out', body: 'Are you sure you want to log out of your account?', confirmLabel: 'Log Out', cancelLabel: 'Cancel', destructive: true)`
         - On confirmation:
           - Calls auth logout API / controller (`ref.read(authControllerProvider.notifier).logout()`).
           - Clears tokens from secure storage.
           - Clears Riverpod provider state.
           - Redirects user to `/login` or `/welcome`.
  2. Update widget tests in `settings_screen_test.dart` verifying:
     - Legal links trigger URL opener.
     - Version text renders properly.
     - Logout confirmation dialog displays and invokes logout routine on confirm.
  3. Verify: `flutter test test/features/profile_settings/settings_screen_test.dart` in `apps/kh_mobile/karat_hive`.

## Final Completion & Acceptance Step
Once Task CP6-B03.6 is complete and tests pass:
1. Run full test suites:
   - `flutter test` in `packages/kh_ui_domain`
   - `flutter test` in `apps/kh_mobile/karat_hive`
   - `dart analyze .` across the workspace.
2. Update `docs/Vendor-App-Completion-Work-Breakdown.md`:
   - Mark `CP6-B03.6` as `done`.
   - Update metadata counters:
     - `done_count: 74`
     - `in_scope_done: 74`
     - `completion_pct: 100.0`
     - Status: **ALL 74 TASKS ACROSS ALL 14 WAVES ARE 100% COMPLETE!**
```
