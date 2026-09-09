# Karat Hive: Wave 10 Parallel Execution Prompt (3 Concurrent Subagents)

Copy and run the prompt below in your fresh CLI window to complete **Wave 10** of the Vendor App completion plan.

---

```markdown
You are orchestrating the completion of Wave 10 for Karat Hive in `/Users/admin/code/gold/karat-hive`.

## Prerequisites
- Waves 0–9 are 100% COMPLETE & VERIFIED.
- Current Wave: Wave 10 (3 tasks). Run all 3 tasks concurrently in parallel.

## Wave 10 Tasks

### Agent 1: Task CP6-B05.6 — Rating-Trend Chart Block
- Mutex: `kh-ui-domain`
- Target file: `packages/kh_ui_domain/lib/src/rating_trend_chart.dart`
- Export in: `packages/kh_ui_domain/lib/kh_ui_domain.dart`
- Test file: `packages/kh_ui_domain/test/rating_trend_chart_test.dart`
- Requirements:
  1. Implement `RatingTrendChart`:
     - Accepts a list of historical rating points (e.g. 6 monthly periods: `{ period, average, count }`).
     - Renders a clean bar / sparkline / line chart with average score labels (1 dp) and month labels.
     - Supports LTR and RTL layouts.
     - Handles empty data / insufficient history state gracefully ("Insufficient history for trend").
  2. Implement unit/widget tests for data rendering, empty state, and RTL.
  3. Verify: `flutter test test/rating_trend_chart_test.dart` in `packages/kh_ui_domain`.

### Agent 2: Task CP6-B03.3 — VEN-S18 Notification Matrix & Quiet Hours
- Mutex: `settings-screen`
- Target file: `apps/kh_mobile/karat_hive/lib/features/profile_settings/presentation/settings_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/profile_settings/settings_screen_test.dart`
- Requirements:
  1. Per `VEN-S18` / `CP6-A01.2`:
     - Inside `SettingsGroup`, build a Notification Matrix section:
       - Notification channels: Push, Email, SMS.
       - Categories: Request Matches, Offer Updates, Connection Alerts, Security & Disputes.
       - Crucial security rule: Security-critical categories (e.g. auth, dispute alerts) are LOCKED ON (`disabled: true` switch per `CP6-A01.2`) and cannot be disabled.
     - Quiet-hours section:
       - Enable quiet hours toggle.
       - Start time and End time pickers (e.g., 22:00 to 07:00).
     - Save updates via settings repository / controller (`PATCH /v1/me/settings`).
  2. Update widget tests in `settings_screen_test.dart` verifying locked notification categories cannot be toggled off, and quiet hours pickers update state.
  3. Verify: `flutter test test/features/profile_settings/settings_screen_test.dart` in `apps/kh_mobile/karat_hive`.

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
  3. Verify: `flutter test test/features/offers_vendor/offer_history_screen_test.dart` in `apps/kh_mobile/karat_hive`.

## Post-Run Orchestrator Step
1. Run `dart analyze` across mobile and UI domain.
2. Update `docs/Vendor-App-Completion-Work-Breakdown.md`: mark Wave 10 tasks as `done`, update progress counters.
```
