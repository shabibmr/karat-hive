# Karat Hive: Wave 11 Parallel Execution Prompt (3 Concurrent Subagents)

Copy and run the prompt below in your fresh CLI window to complete **Wave 11** of the Vendor App completion plan.

---

```markdown
You are orchestrating the completion of Wave 11 for Karat Hive in `/Users/admin/code/gold/karat-hive`.

## Prerequisites
- Waves 0–10 are 100% COMPLETE & VERIFIED.
- Current Wave: Wave 11 (3 tasks). Run all 3 tasks concurrently in parallel.

## Wave 11 Tasks

### Agent 1: Task CP5-B04.2 — VEN-S20 Distribution & Trend Integration
- Mutex: `my-reviews-screen`
- Target file: `apps/kh_mobile/karat_hive/lib/features/reviews/presentation/my_reviews_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/reviews/my_reviews_screen_test.dart`
- Requirements:
  1. Per `VEN-S20` / `CP5-A05.2`:
     - In `MyReviewsScreen`, below the aggregate header, integrate:
       - The 5-star distribution bar breakdown (5, 4, 3, 2, 1) from `RatingSummaryView`.
       - The `RatingTrendChart` (`CP6-B05.6` from `kh_ui_domain`), populated with the six `ratingTrend` points retrieved from `VendorPerformanceDto` (`GET /v1/me/vendor/performance`).
     - Display cleanly with section header "Rating History & Trends".
  2. Update widget tests in `my_reviews_screen_test.dart` verifying the distribution and rating trend chart are displayed when data is present.
  3. Verify: `flutter test test/features/reviews/my_reviews_screen_test.dart` in `apps/kh_mobile/karat_hive`.

### Agent 2: Task CP6-B03.4 — VEN-S18 Default Filter Preset
- Mutex: `settings-screen`
- Target file: `apps/kh_mobile/karat_hive/lib/features/profile_settings/presentation/settings_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/profile_settings/settings_screen_test.dart`
- Requirements:
  1. Per `VEN-S18` / `CP6-A01.1`:
     - In `SettingsScreen`, under a "Feed Preferences" `SettingsGroup`:
       - Display a `SettingRow` for "Default Filter Preset".
       - Shows current default preset name (or "None").
       - Tapping opens a selection dialog/bottom-sheet of the vendor's saved presets (`GET /v1/filter-presets`).
       - Selecting a preset saves it via `PATCH /v1/me/settings` (`defaultFilterPresetId`).
       - Crucial logic: setting a new default automatically unsets the previous default preset (`CP6-A01.1`).
  2. Update widget tests in `settings_screen_test.dart` verifying preset list displays and selecting updates the setting.
  3. Verify: `flutter test test/features/profile_settings/settings_screen_test.dart` in `apps/kh_mobile/karat_hive`.

### Agent 3: Task CP6-B04.5 — VEN-S14 CSV Export
- Mutex: `offer-history-screen`
- Target file: `apps/kh_mobile/karat_hive/lib/features/offers_vendor/presentation/offer_history_screen.dart`
- Test file: `apps/kh_mobile/karat_hive/test/features/offers_vendor/offer_history_screen_test.dart`
- Requirements:
  1. Per `VEN-S14` / `CP6-A04` / `CP6-A06.4`:
     - Add an "Export CSV" button (e.g. in AppBar action or filters footer).
     - Tapping calls `GET /v1/me/vendor/performance/export` with the active date range / filter parameters.
     - Backend returns signed `{ downloadUrl, expiresAt }`.
     - Opens the download URL via `openExternalUrl` or platform file saver.
     - Data masking guarantee (`CP6-A06.4`): Only own vendor records are exported; counterparty identities are masked unless already revealed by a connection; strictly NO competitor prices.
     - Handles loading state on the button and error snackbar if download fails.
  2. Update widget tests in `offer_history_screen_test.dart` verifying export button triggers repo export call and handles response.
  3. Verify: `flutter test test/features/offers_vendor/offer_history_screen_test.dart` in `apps/kh_mobile/karat_hive`.

## Post-Run Orchestrator Step
1. Run `dart analyze` across mobile and UI domain.
2. Update `docs/Vendor-App-Completion-Work-Breakdown.md`: mark Wave 11 tasks as `done`, update progress counters.
```
