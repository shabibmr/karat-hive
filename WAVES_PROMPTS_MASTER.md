# Karat Hive: Master Parallel Execution Prompts (Waves 8 – 13)

This document contains self-contained execution prompts for completing all remaining waves (**Waves 8 through 13**, 18 tasks total) of the Vendor App completion plan in `/Users/admin/code/gold/karat-hive`.

Each wave prompt specifies the tasks, mutex boundaries, target files, acceptance rules, and test verification commands for 5-agent parallel orchestration.

---

## Wave Schedule Overview

| Wave | Tasks | Parallelism | Target Files / Scope |
| :--- | :---: | :---: | :--- |
| [Wave 8](#wave-8-prompt-5-tasks) | 5 | 5 subagents | Settings UI, legal re-verify warning, review CTAs, abuse form screen, review response handling |
| [Wave 9](#wave-9-prompt-5-tasks) | 5 | 5 subagents | Settings group/row UI, abuse navigation entry, RTL layout switch, offer performance metrics, flag review as unfair |
| [Wave 10](#wave-10-prompt-3-tasks) | 3 | 3 subagents | Rating-trend chart widget, notification matrix & quiet hours, terminal offer history list |
| [Wave 11](#wave-11-prompt-3-tasks) | 3 | 3 subagents | Rating distribution + trend view, default filter preset, signed performance CSV export |
| [Wave 12](#wave-12-prompt-1-task) | 1 | 1 subagent | Password change & active sessions list with revoke |
| [Wave 13](#wave-13-prompt-1-task) | 1 | 1 subagent | Legal links, app version, logout flow, and final 100% completion |

---

## Wave 8 Prompt (5 Tasks)

```markdown
You are orchestrating the completion of Wave 8 for Karat Hive in `/Users/admin/code/gold/karat-hive`.

## Prerequisites
- Waves 0–7 are 100% COMPLETE & VERIFIED.
- Current Wave: Wave 8 (5 tasks). Launch 5 concurrent subagents in parallel:

### Agent 1: Task CP6-B05.1 — Language Picker Tile (SH-SET-01)
- Mutex: `kh-ui-domain`
- Target file: `packages/kh_ui_domain/lib/src/language_picker_tile.dart`
- Export in: `packages/kh_ui_domain/lib/kh_ui_domain.dart`
- Test file: `packages/kh_ui_domain/test/language_picker_tile_test.dart`
- Requirements:
  1. Implement `LanguagePickerTile` (`FR-VEN-025`, `FR-CUS-031`):
     - Takes `required String currentLocale`, `required ValueChanged<String> onLocaleChanged`.
     - Displays `Icons.language`, title "App Language", subtitle "العربية (Arabic - RTL)" or "English (LTR)".
     - Uses `SegmentedButton<String>` with segments `[ButtonSegment(value: 'en', label: Text('EN')), ButtonSegment(value: 'ar', label: Text('عربي'))]`.
     - On selection change, invokes `onLocaleChanged`.
  2. Implement unit/widget tests for English and Arabic selection and callback firing.
  3. Verify: run `flutter test test/language_picker_tile_test.dart` in `packages/kh_ui_domain`.

### Agent 2: Task CP6-B02.4 — Legal Identity & Confirmation (VEN-S15 BR-004)
- Mutex: `business-profile-screen`
- Target file: `apps/kh_mobile/karat_hive/lib/features/profile_settings/presentation/business_profile_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/profile_settings/business_profile_screen_test.dart`
- Requirements:
  1. Per `VEN-S15` / `BR-004`:
     - Legal business name, trade licence number, and registered address are legal identity fields.
     - When a vendor edits any of these legal identity fields and taps Save, show an explicit re-verification warning confirmation dialog using `showKhConfirmDialog`:
       - `title`: 'Re-verification Required'
       - `body`: 'Changing legal identity fields requires administrator re-verification. Your account will enter pending verification until reviewed.'
       - `destructive: true`
       - `confirmLabel`: 'Submit for Re-verification'
       - `cancelLabel`: 'Cancel'
     - If confirmed, proceed to save changes; if cancelled, do not submit.
     - If only safe fields (trading name, description, contact person, business email) are changed, save directly without the re-verification warning dialog.
  2. Update `business_profile_screen_test.dart` with a widget test verifying that editing legal fields triggers the `Re-verification Required` confirm dialog.
  3. Verify: run `flutter test test/features/profile_settings/business_profile_screen_test.dart` in `apps/kh_mobile/karat_hive`.

### Agent 3: Task CP5-B03.4 — Connection Detail Review CTA (Close Connection → VEN-S19)
- Mutex: `connection-detail`
- Target file: `apps/kh_mobile/karat_hive/lib/features/connections/presentation/connection_detail_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/connections/connection_detail_screen_test.dart`
- Requirements:
  1. Per `CP5-B03.4` & `VEN-S13`:
     - When a connection is closed (or from the "Leave feedback" action button), replace the placeholder `_cp5Snack(...)` with navigation to `LeaveReviewScreen`:
       `context.push('/reviews/new?connectionId=$connectionId');`
     - After successfully closing the connection via `_close(...)`, navigate to `context.push('/reviews/new?connectionId=$connectionId')` or show feedback CTA.
     - Ensure the "Leave feedback" button is visible and active when connection is closed.
  2. Verify: run `flutter test test/features/connections/` and `dart analyze lib/features/connections/` in `apps/kh_mobile/karat_hive`.

### Agent 4: Task CP5-B05.2 — Report Abuse Screen (VEN-S21 Form)
- Mutex: `flutter-abuse`
- Target file: `apps/kh_mobile/karat_hive/lib/features/abuse/presentation/report_abuse_screen.dart`
- Routes file: `apps/kh_mobile/karat_hive/lib/features/abuse/routes.dart` (or app routing)
- Test file: `apps/kh_mobile/karat_hive/test/features/abuse/report_abuse_screen_test.dart`
- Requirements:
  1. Per `VEN-S21`:
     - Vendor abuse report screen embedding `AbuseReportForm` (`SH-RPT-01` from `package:kh_ui_domain/kh_ui_domain.dart`).
     - Accepts constructor / route parameters: `targetType` ('REQUEST' or 'CONNECTION'), `targetId`, and optional `targetSummary`.
     - Provides Vendor-specific reporting categories ('UNRESPONSIVE', 'SPAM_OR_FRAUD', 'ABUSIVE_LANGUAGE', 'OFF_PLATFORM_SOLICITATION', 'OTHER').
     - On submission: calls abuse reporting API/controller, shows confirmation snackbar upon success ("Report submitted for admin moderation"), and pops the route.
  2. Implement unit/widget tests for `ReportAbuseScreen`.
  3. Verify: run `flutter test test/features/abuse/` and `dart analyze lib/features/abuse/` in `apps/kh_mobile/karat_hive`.

### Agent 5: Task CP5-B04.3 — Review Response Dialog & Conflict Handling (VEN-S20)
- Mutex: `my-reviews-screen`
- Target file: `apps/kh_mobile/karat_hive/lib/features/reviews/presentation/my_reviews_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/reviews/my_reviews_screen_test.dart`
- Requirements:
  1. Per `VEN-S20` / `CP5-A04`:
     - Published customer reviews list renders `ReviewListItem` (`SH-ID-06`).
     - When vendor taps "Respond", show response dialog with character limit counter (≤ 500 chars).
     - Submit calls `ref.read(reviewActionsControllerProvider.notifier).respond(id: review.id, response: text)`.
     - On second response attempt / 409 conflict (`REVIEW_RESPONSE_EXISTS` / `CONFLICT`), show error message indicating only one public response is permitted per review.
     - On success: shows snackbar: "Response submitted. Held for moderation."
  2. Add widget tests in `my_reviews_screen_test.dart` covering:
     - Opening response dialog and validating character length (≤ 500 chars).
     - Submitting response calls controller and updates UI.
  3. Verify: run `flutter test test/features/reviews/my_reviews_screen_test.dart` in `apps/kh_mobile/karat_hive`.
```

---

## Wave 9 Prompt (5 Tasks)

```markdown
You are orchestrating the completion of Wave 9 for Karat Hive in `/Users/admin/code/gold/karat-hive`.

## Prerequisites
- Waves 0–8 are 100% COMPLETE & VERIFIED.
- Current Wave: Wave 9 (5 tasks). Launch 5 concurrent subagents in parallel:

### Agent 1: Task CP6-B05.2 — Settings Group & Setting Row (SH-SET-02)
- Mutex: `kh-ui-domain`
- Target file: `packages/kh_ui_domain/lib/src/settings_group.dart`
- Export in: `packages/kh_ui_domain/lib/kh_ui_domain.dart`
- Test file: `packages/kh_ui_domain/test/settings_group_test.dart`
- Requirements:
  1. Implement `SettingsGroup` & `SettingRow`:
     - `SettingRow`: Takes `title`, optional `subtitle`, `leadingIcon`, `trailing`, `onTap`, `showChevron`. Renders ink response, token spacing/typography, and chevron if specified.
     - `SettingsGroup`: Takes optional `title`, optional `description`, `List<Widget> children`. Renders card container with subtle border and dividers between children.
  2. Implement unit/widget tests for title, child dividers, and tap callback.
  3. Verify: run `flutter test test/settings_group_test.dart` in `packages/kh_ui_domain`.

### Agent 2: Task CP5-B05.3 — Report Abuse Entry from S08 / S13
- Mutex: `connection-detail`
- Target files:
  - `apps/kh_mobile/karat_hive/lib/features/request_feed/presentation/request_detail_screen.dart`
  - `apps/kh_mobile/karat_hive/lib/features/connections/presentation/connection_detail_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/connections/connection_detail_screen_test.dart`
- Requirements:
  1. In `request_detail_screen.dart` (VEN-S08):
     - Add "Report this request" button/action navigating to `/abuse/new?targetType=REQUEST&targetId=$requestId`.
  2. In `connection_detail_screen.dart` (VEN-S13):
     - Wire "Report" button to navigate to `/abuse/new?targetType=CONNECTION&targetId=$connectionId`.
  3. Verify: run `flutter test test/features/connections/` in `apps/kh_mobile/karat_hive`.

### Agent 3: Task CP6-B03.2 — VEN-S18 Language & Immediate RTL
- Mutex: `settings-screen`
- Target file: `apps/kh_mobile/karat_hive/lib/features/profile_settings/presentation/settings_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/profile_settings/settings_screen_test.dart`
- Requirements:
  1. Per `VEN-S18`:
     - Embed `LanguagePickerTile` (`SH-SET-01` from `kh_ui_domain`) inside a `SettingsGroup`.
     - Connect locale selection to app locale provider. Switching between 'en' and 'ar' updates app locale and causes immediate RTL layout rebuild.
  2. Update widget tests in `settings_screen_test.dart` verifying locale toggle updates language.
  3. Verify: run `flutter test test/features/profile_settings/settings_screen_test.dart` in `apps/kh_mobile/karat_hive`.

### Agent 4: Task CP6-B04.3 — VEN-S14 Performance Metric Block
- Mutex: `offer-history-screen`
- Target file: `apps/kh_mobile/karat_hive/lib/features/offers_vendor/presentation/offer_history_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/offers_vendor/offer_history_screen_test.dart`
- Requirements:
  1. Per `VEN-S14`:
     - Read `offerHistoryPerformanceProvider`.
     - Render aggregate performance cards:
       - Offers Submitted
       - Acceptance Rate
       - Average Response Time
       - Average Offered vs Accepted (period aggregate mean % delta when lost; omitted if none; strictly NEVER per-request per `BR-008`).
     - Handle loading and empty states cleanly.
  2. Update widget tests in `offer_history_screen_test.dart` verifying the 4 metrics render.
  3. Verify: run `flutter test test/features/offers_vendor/offer_history_screen_test.dart` in `apps/kh_mobile/karat_hive`.

### Agent 5: Task CP5-B04.4 — VEN-S20 Flag Review as Unfair
- Mutex: `my-reviews-screen`
- Target file: `apps/kh_mobile/karat_hive/lib/features/reviews/presentation/my_reviews_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/reviews/my_reviews_screen_test.dart`
- Requirements:
  1. Per `VEN-S20`:
     - Review cards have a "Flag as unfair" CTA.
     - On tap, show confirmation dialog (`showKhConfirmDialog`) explaining the moderation review process.
     - On confirm: call `reviewsRepo.flag(review.id)`.
     - Show confirmation snackbar: "Review flagged for moderation."
     - Flagged review displays a persistent "Flagged for moderation" badge and disables duplicate flagging.
  2. Update widget tests in `my_reviews_screen_test.dart` verifying flag flow.
  3. Verify: run `flutter test test/features/reviews/my_reviews_screen_test.dart` in `apps/kh_mobile/karat_hive`.
```

---

## Wave 10 Prompt (3 Tasks)

```markdown
You are orchestrating the completion of Wave 10 for Karat Hive in `/Users/admin/code/gold/karat-hive`.

## Prerequisites
- Waves 0–9 are 100% COMPLETE & VERIFIED.
- Current Wave: Wave 10 (3 tasks). Launch 3 concurrent subagents in parallel:

### Agent 1: Task CP6-B05.6 — Rating-Trend Chart Block
- Mutex: `kh-ui-domain`
- Target file: `packages/kh_ui_domain/lib/src/rating_trend_chart.dart`
- Export in: `packages/kh_ui_domain/lib/kh_ui_domain.dart`
- Test file: `packages/kh_ui_domain/test/rating_trend_chart_test.dart`
- Requirements:
  1. Implement `RatingTrendChart`:
     - Accepts 6 historical rating points (`{ period, average, count }`).
     - Renders bar/sparkline chart with average score labels (1 dp) and month labels.
     - Supports LTR and RTL layouts.
     - Handles empty data / insufficient history state ("Insufficient history for trend").
  2. Implement unit/widget tests for data rendering, empty state, and RTL.
  3. Verify: run `flutter test test/rating_trend_chart_test.dart` in `packages/kh_ui_domain`.

### Agent 2: Task CP6-B03.3 — VEN-S18 Notification Matrix & Quiet Hours
- Mutex: `settings-screen`
- Target file: `apps/kh_mobile/karat_hive/lib/features/profile_settings/presentation/settings_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/profile_settings/settings_screen_test.dart`
- Requirements:
  1. Per `VEN-S18` / `CP6-A01.2`:
     - Inside `SettingsGroup`, build Notification Matrix section:
       - Notification channels: Push, Email, SMS.
       - Categories: Request Matches, Offer Updates, Connection Alerts, Security & Disputes.
       - Security rule: Security-critical categories (e.g. auth, dispute alerts) are LOCKED ON (`disabled: true` switch per `CP6-A01.2`) and cannot be disabled.
     - Quiet-hours section:
       - Enable quiet hours toggle.
       - Start time and End time pickers (e.g., 22:00 to 07:00).
     - Save updates via settings controller (`PATCH /v1/me/settings`).
  2. Update widget tests in `settings_screen_test.dart` verifying locked notification categories and quiet hours pickers.
  3. Verify: run `flutter test test/features/profile_settings/settings_screen_test.dart` in `apps/kh_mobile/karat_hive`.

### Agent 3: Task CP6-B04.4 — VEN-S14 Terminal Offer History List
- Mutex: `offer-history-screen`
- Target file: `apps/kh_mobile/karat_hive/lib/features/offers_vendor/presentation/offer_history_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/offers_vendor/offer_history_screen_test.dart`
- Requirements:
  1. Per `VEN-S14`:
     - Render terminal offer history list matching current active filters (ACCEPTED, REJECTED, EXPIRED, WITHDRAWN).
     - Each card displays:
       - Request title / category badge
       - Submission date and closed date
       - Offer price and terms
       - Final status badge (Accepted, Rejected, Expired, Withdrawn)
       - If rejected/lost: show `awardedElsewhere: true` badge if customer chose another vendor, but strictly NO competitor prices or competitor identities per `BR-008`.
  2. Update widget tests in `offer_history_screen_test.dart` verifying terminal items render and no competitor prices appear.
  3. Verify: run `flutter test test/features/offers_vendor/offer_history_screen_test.dart` in `apps/kh_mobile/karat_hive`.
```

---

## Wave 11 Prompt (3 Tasks)

```markdown
You are orchestrating the completion of Wave 11 for Karat Hive in `/Users/admin/code/gold/karat-hive`.

## Prerequisites
- Waves 0–10 are 100% COMPLETE & VERIFIED.
- Current Wave: Wave 11 (3 tasks). Launch 3 concurrent subagents in parallel:

### Agent 1: Task CP5-B04.2 — VEN-S20 Distribution & Trend Integration
- Mutex: `my-reviews-screen`
- Target file: `apps/kh_mobile/karat_hive/lib/features/reviews/presentation/my_reviews_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/reviews/my_reviews_screen_test.dart`
- Requirements:
  1. Per `VEN-S20` / `CP5-A05.2`:
     - In `MyReviewsScreen`, below the aggregate header, integrate:
       - The 5-star distribution bar breakdown (5, 4, 3, 2, 1) from `RatingSummaryView`.
       - The `RatingTrendChart` (`CP6-B05.6` from `kh_ui_domain`), populated with the six `ratingTrend` points retrieved from `VendorPerformanceDto`.
     - Display under section header "Rating History & Trends".
  2. Update widget tests in `my_reviews_screen_test.dart` verifying distribution and trend display.
  3. Verify: run `flutter test test/features/reviews/my_reviews_screen_test.dart` in `apps/kh_mobile/karat_hive`.

### Agent 2: Task CP6-B03.4 — VEN-S18 Default Filter Preset
- Mutex: `settings-screen`
- Target file: `apps/kh_mobile/karat_hive/lib/features/profile_settings/presentation/settings_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/profile_settings/settings_screen_test.dart`
- Requirements:
  1. Per `VEN-S18` / `CP6-A01.1`:
     - In `SettingsScreen`, under "Feed Preferences" `SettingsGroup`:
       - Display a `SettingRow` for "Default Filter Preset".
       - Shows current default preset name (or "None").
       - Tapping opens a selection dialog of saved presets (`GET /v1/filter-presets`).
       - Selecting a preset saves it via `PATCH /v1/me/settings` (`defaultFilterPresetId`).
       - Crucial rule: setting a new default automatically unsets the previous default preset (`CP6-A01.1`).
  2. Update widget tests in `settings_screen_test.dart` verifying preset selector updates the setting.
  3. Verify: run `flutter test test/features/profile_settings/settings_screen_test.dart` in `apps/kh_mobile/karat_hive`.

### Agent 3: Task CP6-B04.5 — VEN-S14 CSV Export
- Mutex: `offer-history-screen`
- Target file: `apps/kh_mobile/karat_hive/lib/features/offers_vendor/presentation/offer_history_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/offers_vendor/offer_history_screen_test.dart`
- Requirements:
  1. Per `VEN-S14` / `CP6-A04` / `CP6-A06.4`:
     - Add "Export CSV" button.
     - Tapping calls `GET /v1/me/vendor/performance/export` with active date range.
     - Handles signed `{ downloadUrl, expiresAt }`.
     - Opens download URL via `openExternalUrl`.
     - Data masking guarantee (`CP6-A06.4`): Only own vendor records are exported; counterparty identities are masked unless already revealed by a connection; strictly NO competitor prices.
  2. Update widget tests in `offer_history_screen_test.dart` verifying export button triggers repo export call.
  3. Verify: run `flutter test test/features/offers_vendor/offer_history_screen_test.dart` in `apps/kh_mobile/karat_hive`.
```

---

## Wave 12 Prompt (1 Task)

```markdown
You are orchestrating the completion of Wave 12 for Karat Hive in `/Users/admin/code/gold/karat-hive`.

## Prerequisites
- Waves 0–11 are 100% COMPLETE & VERIFIED.
- Current Wave: Wave 12 (1 task).

### Agent: Task CP6-B03.5 — VEN-S18 Password & Active Sessions
- Mutex: `settings-screen`
- Target file: `apps/kh_mobile/karat_hive/lib/features/profile_settings/presentation/settings_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/profile_settings/settings_screen_test.dart`
- Requirements:
  1. Per `VEN-S18` / `CP6-A02`:
     - In `SettingsScreen`, build "Security & Login" `SettingsGroup`:
       - **Password Management:**
         - `SettingRow(title: 'Change Password', leadingIcon: Icons.lock, showChevron: true)`
         - Tapping opens Change Password dialog (current password, new password, confirm new password).
         - Calls `POST /v1/auth/password`.
         - Displays inline error for `PASSWORD_POLICY` violation (≥ 8 chars, 1 uppercase, 1 number, 1 symbol).
       - **Active Sessions:**
         - Lists active sessions from `GET /v1/auth/sessions`.
         - Shows device name, platform icon, IP, last-seen timestamp, and "Current device" badge.
         - Other sessions have "Revoke" button calling `DELETE /v1/auth/sessions/{id}` with confirmation.
  2. Update widget tests in `settings_screen_test.dart` verifying password change validation and session revocation.
  3. Verify: run `flutter test test/features/profile_settings/settings_screen_test.dart` in `apps/kh_mobile/karat_hive`.
```

---

## Wave 13 Prompt (Final Wave)

```markdown
You are orchestrating the completion of Wave 13 (the final wave) for Karat Hive in `/Users/admin/code/gold/karat-hive`.

## Prerequisites
- Waves 0–12 are 100% COMPLETE & VERIFIED.
- Current Wave: Wave 13 (1 task).

### Agent: Task CP6-B03.6 — VEN-S18 Legal, App Version, Logout
- Mutex: `settings-screen`
- Target file: `apps/kh_mobile/karat_hive/lib/features/profile_settings/presentation/settings_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/profile_settings/settings_screen_test.dart`
- Requirements:
  1. Per `VEN-S18`:
     - In `SettingsScreen`, build "About & Legal" and "Account Actions":
       - **Legal & Support:**
         - Terms of Service & Privacy Policy rows opening platform-config URLs via `openExternalUrl`.
         - Support & Help row.
       - **App Version:**
         - Displays current app version string and build number.
       - **Logout Flow:**
         - Red "Log Out" action showing confirmation dialog:
           `showKhConfirmDialog(context, title: 'Log Out', body: 'Are you sure you want to log out?', confirmLabel: 'Log Out', cancelLabel: 'Cancel', destructive: true)`
         - On confirmation: calls auth logout, clears secure storage tokens, resets providers, and routes to `/login`.
  2. Update widget tests in `settings_screen_test.dart` verifying legal links, version string, and logout routine.
  3. Verify: run `flutter test test/features/profile_settings/settings_screen_test.dart` in `apps/kh_mobile/karat_hive`.

## Final Workspace Verification & DAG Closeout
Once Task CP6-B03.6 is verified:
1. Run full test suites:
   - `flutter test` in `packages/kh_ui_domain`
   - `flutter test` in `apps/kh_mobile/karat_hive`
   - `dart analyze .` across the repository.
2. Update `docs/Vendor-App-Completion-Work-Breakdown.md`:
   - Mark `CP6-B03.6` as `done`.
   - Update metadata:
     - `done_count: 74`
     - `in_scope_done: 74`
     - `completion_pct: 100.0`
     - Status: **ALL 74 TASKS ACROSS ALL 14 WAVES ARE 100% COMPLETE!**
```
