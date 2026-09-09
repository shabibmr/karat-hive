# Karat Hive: Wave 9 Parallel Execution Prompt (5 Concurrent Subagents)

Copy and run the prompt below in your fresh CLI window to complete **Wave 9** of the Vendor App completion plan.

---

```markdown
You are orchestrating the completion of Wave 9 for Karat Hive in `/Users/admin/code/gold/karat-hive`.

## Prerequisites
- Waves 0–8 are 100% COMPLETE & VERIFIED.
- Current Wave: Wave 9 (5 tasks). Run all 5 tasks in parallel with 5 concurrent subagents.

## Wave 9 Tasks

### Agent 1: Task CP6-B05.2 — Settings Group & Setting Row (SH-SET-02)
- Mutex: `kh-ui-domain`
- Target file: `packages/kh_ui_domain/lib/src/settings_group.dart`
- Export in: `packages/kh_ui_domain/lib/kh_ui_domain.dart`
- Test file: `packages/kh_ui_domain/test/settings_group_test.dart`
- Requirements:
  1. Implement `SettingsGroup` & `SettingRow`:
     - `SettingRow`: Takes `title`, optional `subtitle`, `leadingIcon`, `trailing`, `onTap`, `showChevron`. Renders ink response, token spacing/typography, and chevron if specified.
     - `SettingsGroup`: Takes optional `title`, optional `description`, `List<Widget> children`. Renders a card container with rounded corners and subtle border, inserting dividers between children.
  2. Implement unit/widget tests for title rendering, child dividers, and tap interactions.
  3. Verify: `flutter test test/settings_group_test.dart` in `packages/kh_ui_domain`.

### Agent 2: Task CP5-B05.3 — Report Abuse Entry from S08 / S13
- Mutex: `connection-detail`
- Target files:
  - `apps/kh_mobile/karat_hive/lib/features/request_feed/presentation/request_detail_screen.dart`
  - `apps/kh_mobile/karat_hive/lib/features/connections/presentation/connection_detail_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/connections/connection_detail_screen_test.dart`
- Requirements:
  1. In `request_detail_screen.dart` (VEN-S08):
     - Add a "Report this request" option (overflow menu or report button).
     - Navigates to `/abuse/new?targetType=REQUEST&targetId=$requestId`.
  2. In `connection_detail_screen.dart` (VEN-S13):
     - Replace the placeholder `_cp5Snack` on the "Report" button with navigation to `/abuse/new?targetType=CONNECTION&targetId=$connectionId`.
  3. Verify: `flutter test test/features/connections/` and `dart analyze lib/features/connections/`.

### Agent 3: Task CP6-B03.2 — VEN-S18 Language & Immediate RTL
- Mutex: `settings-screen`
- Target file: `apps/kh_mobile/karat_hive/lib/features/profile_settings/presentation/settings_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/profile_settings/settings_screen_test.dart`
- Requirements:
  1. Per `VEN-S18`:
     - Embed `LanguagePickerTile` (`SH-SET-01` from `kh_ui_domain`) inside a `SettingsGroup`.
     - Connect locale changes to app locale provider / state. Switching between 'en' and 'ar' updates app locale and triggers immediate RTL layout mirroring.
  2. Write widget tests in `settings_screen_test.dart` verifying locale switch triggers callback and updates displayed language.
  3. Verify: `flutter test test/features/profile_settings/settings_screen_test.dart` in `apps/kh_mobile/karat_hive`.

### Agent 4: Task CP6-B04.3 — VEN-S14 Performance Metric Block
- Mutex: `offer-history-screen`
- Target file: `apps/kh_mobile/karat_hive/lib/features/offers_vendor/presentation/offer_history_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/offers_vendor/offer_history_screen_test.dart`
- Requirements:
  1. Per `VEN-S14`:
     - Read `offerHistoryPerformanceProvider`.
     - Render aggregate performance cards:
       - Offers Submitted (count)
       - Acceptance Rate (% format)
       - Average Response Time (minutes / hours)
       - Average Offered vs Accepted (period aggregate mean % delta when lost; omitted if none; strictly NEVER per-request per `BR-008`).
     - Handle loading and empty states cleanly.
  2. Update widget tests in `offer_history_screen_test.dart` verifying all 4 metrics render with correct values.
  3. Verify: `flutter test test/features/offers_vendor/offer_history_screen_test.dart` in `apps/kh_mobile/karat_hive`.

### Agent 5: Task CP5-B04.4 — VEN-S20 Flag Review as Unfair
- Mutex: `my-reviews-screen`
- Target file: `apps/kh_mobile/karat_hive/lib/features/reviews/presentation/my_reviews_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/reviews/my_reviews_screen_test.dart`
- Requirements:
  1. Per `VEN-S20`:
     - Each customer review card has a "Flag as unfair" action.
     - On tap, show confirmation dialog (`showKhConfirmDialog`) explaining the moderation review process.
     - On confirm: call `reviewsRepo.flag(review.id)`.
     - Show confirmation snackbar: "Review flagged for moderation."
     - Flagged review displays a persistent "Flagged for moderation" badge and disables re-flagging.
  2. Update widget tests in `my_reviews_screen_test.dart` to verify dialog appearance, API invocation, and UI badge update.
  3. Verify: `flutter test test/features/reviews/my_reviews_screen_test.dart` in `apps/kh_mobile/karat_hive`.

## Post-Run Orchestrator Step
1. Run `dart analyze` across mobile and UI domain.
2. Update `docs/Vendor-App-Completion-Work-Breakdown.md`: mark Wave 9 tasks as `done`, update progress counters.
```
