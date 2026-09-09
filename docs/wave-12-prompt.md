# Karat Hive: Wave 12 Execution Prompt

Copy and run the prompt below in your fresh CLI window to complete **Wave 12** of the Vendor App completion plan.

---

```markdown
You are orchestrating the completion of Wave 12 for Karat Hive in `/Users/admin/code/gold/karat-hive`.

## Prerequisites
- Waves 0–11 are 100% COMPLETE & VERIFIED.
- Current Wave: Wave 12 (1 task).

## Wave 12 Task

### Agent: Task CP6-B03.5 — VEN-S18 Password & Active Sessions
- Mutex: `settings-screen`
- Target file: `apps/kh_mobile/karat_hive/lib/features/profile_settings/presentation/settings_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/profile_settings/settings_screen_test.dart`
- Requirements:
  1. Per `VEN-S18` / `CP6-A02`:
     - In `SettingsScreen`, build a "Security & Login" `SettingsGroup`:
       - **Password Management:**
         - `SettingRow(title: 'Change Password', leadingIcon: Icons.lock, showChevron: true)`
         - Tapping opens Change Password sheet/dialog with current password, new password, and confirm new password fields.
         - Calls `POST /v1/auth/password`.
         - If violation: display inline error for `PASSWORD_POLICY` (must be ≥ 8 chars, 1 uppercase, 1 number, 1 symbol).
         - Success: shows snackbar: "Password changed successfully."
       - **Active Sessions:**
         - Sub-section displaying list of active sessions from `GET /v1/auth/sessions`.
         - Each session card/row shows:
           - Device name / User agent / Platform icon
           - IP address & location (if available)
           - Last active timestamp
           - "Current device" badge on the active token's session.
         - Other sessions have a "Revoke" button.
         - Tapping "Revoke" prompts with `showKhConfirmDialog(destructive: true)` and calls `DELETE /v1/auth/sessions/{id}`.
         - On revoke: removes session from list and shows confirmation snackbar.
  2. Update widget tests in `settings_screen_test.dart` verifying:
     - Password dialog opens and validates policy.
     - Sessions list renders with current badge and other sessions can be revoked.
  3. Verify: `flutter test test/features/profile_settings/settings_screen_test.dart` in `apps/kh_mobile/karat_hive`.

## Post-Run Orchestrator Step
1. Run `dart analyze apps/kh_mobile/karat_hive/lib`.
2. Update `docs/Vendor-App-Completion-Work-Breakdown.md`: mark Wave 12 task as `done`, update progress counters.
```
