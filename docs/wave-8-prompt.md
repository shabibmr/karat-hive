# Karat Hive: Wave 8 Parallel Execution Prompt (5 Concurrent Subagents)

Copy and run the prompt below in your fresh CLI window (e.g. Claude Code, Antigravity CLI, or any agentic terminal) to complete **Wave 8** of the Vendor App completion plan.

---

```markdown
You are orchestrating the completion of Wave 8 for Karat Hive in `/Users/admin/code/gold/karat-hive`.

## Context & Current Status
- Waves 0–6 (52 tasks) are 100% COMPLETE & VERIFIED.
- Wave 7 (4 tasks) is 100% COMPLETE & VERIFIED:
  - `CP5-B06.8`: Abuse report form widget (`abuse_report_form.dart` in `kh_ui_domain`) + goldens/tests pass.
  - `CP6-B02.3`: Branding & media section (`business_profile_screen.dart`) + tests pass.
  - `CP5-B03.3`: Leave review screen (`leave_review_screen.dart`) + routes + tests pass.
  - `CP5-B04.1`: Aggregate reviews header (`my_reviews_screen.dart`) + tests pass.

## Objective
Spawn 5 concurrent subagents (one per task) to implement, test, and verify the 5 tasks of Wave 8 in parallel. Each agent works on a strictly independent file/mutex:

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

## Verification & Status Update Step
Once all 5 agents complete:
1. Run `dart analyze` across `packages/kh_ui_domain` and `apps/kh_mobile/karat_hive`.
2. Update `docs/Vendor-App-Completion-Work-Breakdown.md`:
   - Mark Wave 7 tasks (`CP5-B06.8`, `CP6-B02.3`, `CP5-B03.3`, `CP5-B04.1`) as `done`.
   - Mark Wave 8 tasks (`CP6-B05.1`, `CP6-B02.4`, `CP5-B03.4`, `CP5-B05.2`, `CP5-B04.3`) as `done`.
   - Update metadata counters (`done_count: 61`, `in_scope_done: 61`).
3. Report final status.
```
