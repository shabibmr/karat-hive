# Implementation plan — complete S2 & S3 (kh_admin)

**Source:** `apps/kh_admin/docs/workstreams/task-register-v1.md`
**Scope:** every open `[ ]` / `[~]` task under **S2 · Detail screens** and **S3 · Shared widgets & performance**.
**Hard rule (both streams):** no behaviour change, no string change. Preserve every test-facing `Key`.
**Verification (run after each wave):** `cd apps/kh_admin && flutter analyze && flutter test`. Baseline: analyze clean, tests green (352 baseline per S0).
All paths below are `apps/kh_admin/`-relative.

---

## Wave A — S2 shared primitives (TR-S2-03, TR-S2-04)

### TR-S2-03 DECIDE — feedback-banner visual spec (resolves the `[~]`)
Three inline `_buildFeedbackBanner` impls exist (request / vendor / customer). Chosen single spec — **vendor's**, the richest, with the softer border 2 of 3 already use:

| property | value |
|---|---|
| padding | `EdgeInsets.all(kh.spacing.md)` |
| shape | `kh.shapes.roundedMd` |
| fill | `color.withValues(alpha: 0.12)` |
| border | `Border.all(color: color.withValues(alpha: 0.4))` |
| icon | **outline** — `Icons.check_circle_outline` / `Icons.error_outline`, size 20 |
| gap | `SizedBox(width: kh.spacing.sm)` |
| text | `kh.typography.bodySmall.copyWith(color: color, fontWeight: FontWeight.w600)` |
| colors | success → `kh.colors.success`; error → `kh.colors.error` |
| dismiss | optional — close `IconButton` (`Icons.close`, size 16) shown only when `onDismiss != null` |

### TR-S2-04 — `[NEW] lib/core/design/widgets/kh_feedback_banner.dart`
`KhFeedbackBanner extends StatelessWidget`:
```
const KhFeedbackBanner({ Key? key, required String message, required bool isSuccess, VoidCallback? onDismiss })
```
Build to the table above. Swap the 3 call sites, **keeping each existing outer `Key`** by passing it through:
- `request_detail_screen.dart:248` → `key: const Key('request-feedback-banner')`, `onDismiss: () => setState(() => _actionFeedback = null)`
- `vendor_detail_screen.dart:178` → `key: const Key('vendor-action-feedback-banner')`, `onDismiss: …`
- `customer_detail_screen.dart:222` → `key: const Key('customer-detail-feedback-banner')`, `onDismiss: null` (was not dismissible)
Delete the 3 private `_buildFeedbackBanner` methods.
Unit test `[NEW] test/core/design/widgets/kh_feedback_banner_test.dart` (success/error tokens, dismiss shown/hidden, message renders). Golden requested via TR-S7-11 (not in this scope).

---

## Wave B — S2 presentation→repository (TR-S2-15, TR-S2-16)

Only **one** offending call site (grep `RepositoryProvider` in `lib/features/*/presentation/` → 1 hit).

### TR-S2-15 — `lib/features/verification/`
- `controller/verification_controller.dart`: on `VerificationDetailController` add doc-view state + `Future<void> openDocument(String documentId)`.
  Model the state as a small immutable class held alongside the `AsyncValue` (separate `StateProvider`/field), e.g. `VerificationDocView { String? loadingDocId, String? errorMessage, String? openedDocId, String? openedDocUrl }`. Method calls `repository.fetchDocumentUrl`, resolves relative `/v1/media/<key>` against `khApiBase` (move `_resolveDocumentUrl` here), calls `openUrlInNewTab`, updates state. Catch is `on ApiException` → message via `TR-S0-19` helper (`resolveApiErrorMessage`), never `e.toString()`.
- `presentation/verification_detail_pane.dart`: delete `ref.read(verificationRepositoryProvider)` + the 4 `_VerificationDetailPaneState` doc fields + `_resolveDocumentUrl`; `_viewDocument` becomes `ref.read(verificationDetailControllerProvider(id).notifier).openDocument(doc.id)`; render from the controller's doc-view state.

### TR-S2-16 — sweep
After TR-S2-15: `grep -rn "RepositoryProvider" lib/features/*/presentation` → **0**. Done-when is then satisfied with no further edits.

---

## Wave C — S2 split the god screens (TR-S2-06 … TR-S2-14)

**Pattern (copy from `lib/features/verification/presentation/` multi-file split + `offer_detail_screen.dart`'s constructor-arg `StatelessWidget` sections):**
per screen create `lib/features/<f>/presentation/widgets/` and move each `_buildXxxCard` / `_Xxx` section into its own file as a real `StatelessWidget` / `ConsumerWidget`, `const` where possible, taking its data via constructor (not `ref` unless it already used it). The screen file stays a composition root; no `_build*` returns a subtree larger than a screenful. **Use the Step-1 primitives** (`KhDetailRow` for `_buildDetailRow`/`_DetailRow`/`_buildFieldRow`/`_buildInfoRow`; `KhDetailCard` for the `Container`+`BoxDecoration` card literals; `KhFeedbackBanner` from Wave A). **No behaviour or string change.**

| Task | File | new files (under `presentation/widgets/`, indicative) |
|---|---|---|
| TR-S2-06 | `requests/presentation/request_detail_screen.dart` (1484) | `request_detail_header.dart`, `request_removed_notice_banner.dart`, `request_connection_banner.dart`, `request_specifications_card.dart`, `request_customer_card.dart`, `request_media_gallery_card.dart`, `request_offers_card.dart`, `request_matched_vendors_card.dart`, `request_timeline_card.dart`, `request_admin_actions_card.dart`, `request_internal_notes_card.dart`, `request_remove_dialog.dart` |
| TR-S2-07 | `offers/presentation/offer_detail_screen.dart` (1395) | one file per existing `_Xxx` class: `winning_offer_card.dart`, `vendor_profile_card.dart`, `parent_request_card.dart`, `pricing_breakdown_card.dart`, `commercial_terms_card.dart`, `revisions_timeline_card.dart`, `state_transitions_card.dart`, `offer_internal_notes_card.dart`, `offer_detail_error_state.dart` (mechanical — already constructor-arg classes) |
| TR-S2-08 | `announcements/presentation/announcements_screen.dart` (1242) | `announcement_filter_bar.dart`; body sections of `build` → `announcements_metrics_row.dart`, `announcements_table.dart` |
| TR-S2-09 | ↑ compose dialog 806–1242 | `[NEW] announcements/presentation/compose_announcement_dialog.dart` (move `_ComposeAnnouncementDialog` + state verbatim) |
| TR-S2-10 | `vendors/presentation/vendor_detail_screen.dart` (1075) | `vendor_detail_header.dart`, `vendor_profile_card.dart`, `vendor_taxonomy_card.dart`, `vendor_kyc_documents_card.dart`, `vendor_lifecycle_actions_card.dart` (+ its dialogs → `vendor_action_dialogs.dart`) |
| TR-S2-11 | `settings/presentation/platform_settings_screen.dart` (1059) | `platform_settings_metrics.dart`, `platform_settings_filter_bar.dart`, `platform_settings_table.dart`, `edit_setting_dialog.dart` |
| TR-S2-12 | `customers/presentation/customer_detail_screen.dart` (1022) | `customer_detail_header.dart`, `customer_summary_card.dart`, `customer_lifecycle_actions_card.dart`, `customer_request_history_card.dart`, `customer_admin_notes_card.dart` (+ note dialogs) |
| TR-S2-13 | `audit/presentation/audit_screen.dart` (927) | structure only: `audit_filters_toolbar.dart`, `audit_table.dart`, `audit_pagination_controls.dart`, `audit_metadata_grid.dart` / `audit_diff_section.dart` (detail-pane helpers) |
| TR-S2-14 | `connections/presentation/connection_detail_screen.dart` (819) | `connection_request_card.dart`, `connection_accepted_offer_card.dart`, `connection_contact_events_card.dart`, `connection_lifecycle_actions_card.dart`, `connection_admin_notes_card.dart` |

Each split lands + `flutter analyze && flutter test` green before the next. Existing screen tests (`test/features/<f>/*_screen_test.dart`) must pass unchanged.

---

## Wave D — S3 table golden harness (TR-S3-02)

No golden lib present; use Flutter built-in `matchesGoldenFile`.
- `[NEW] test/support/golden.dart` — `pumpForGolden(tester, child, {TextDirection, double textScale})` = `MaterialApp(theme: buildKhAdminTheme())` + `Directionality` + `MediaQuery(textScaler: TextScaler.linear(textScale))`, fixed surface size.
- `[NEW] test/core/design/widgets/kh_data_table_golden_test.dart` — a representative populated `KhDataTable` at LTR / RTL / textScale 2.0. Generate baselines: `flutter test --update-goldens test/core/design/widgets/kh_data_table_golden_test.dart`; commit PNGs under `test/core/design/widgets/goldens/`.
- Cross-link comment to `TR-S7-10`.

---

## Wave E — S3 per-list rewire (TR-S3-03a…l) + selectors (TR-S3-04a…l)

All 12 list screens share one shape: `Material > SingleChildScrollView(padding all(xl)) > Column[KhScreenHeader, filterBar, if/else(loading|error|empty|KhDataTable), paginationControls]`.

**Per screen, do S3-03 and S3-04 together (one PR-sized change each):**
1. **S3-03 — one scroll view.** Replace the outer `SingleChildScrollView` with a `Column`; wrap only the results region in `Expanded` so `KhDataTable` enters its **bounded** `LayoutBuilder` branch (header + `Expanded(ListView.builder)`) and owns the single vertical viewport. Header / filter bar / metric cards / pagination controls / error+empty states stay outside the `Expanded`, non-scrolling (they're fixed-height rows). Pass `rowHeight: kh.spacing.tableRowHeight` (fallback 52) so `itemExtent` is set. Keep `minWidth` and the horizontal scroller untouched. Result: exactly one scroll view for the list, no nested scroll/layout pass.
2. **S3-04 — granular `.select()`.** For the 10 kernel-backed screens: table body `ref.watch(<f>ControllerProvider.select((s) => s.items))`; separate `.select` watches for `.filters` (filter bar — 8 already do this), `.isPaging` / `.hasMore` / `.page` (pagination controls), `.errorMessage` (error region), `.isLoading` (initial spinner). Remove the whole-state `ref.watch(<f>ControllerProvider)`. Toggling a filter chip or the paging flag must not rebuild the row list.
   - `reports` → same idea against `ReportsState` (`isLoading` / `isExporting` / `filters` / `result` / `errorMessage`); no cursor pagination.
   - `platform_settings` → config screen; split `ref.watch(platformSettingsControllerProvider)` into `.select` slices for the table sub-section vs the metrics/filter bar.

| TR | screen file |
|---|---|
| a | `requests/presentation/request_list_screen.dart` |
| b | `vendors/presentation/vendor_list_screen.dart` |
| c | `offers/presentation/offer_list_screen.dart` |
| d | `announcements/presentation/announcements_screen.dart` |
| e | `settings/presentation/platform_settings_screen.dart` |
| f | `admin_users/presentation/admin_users_screen.dart` |
| g | `moderation/presentation/moderation_screen.dart` |
| h | `abuse/presentation/abuse_screen.dart` |
| i | `audit/presentation/audit_screen.dart` |
| j | `connections/presentation/connection_list_screen.dart` |
| k | `customers/presentation/customer_list_screen.dart` |
| l | `reports/presentation/reports_screen.dart` |

Depends on: TR-S3-01 (done) + S1 kernel migration (done for the 10). `audit` and `announcements` are also touched by Wave C — do Wave C first for those two, then rewire.

---

## Wave F — S3 handoff note (TR-S3-06)

Doc-only. Add a row to `docs/admin-backend-api-gaps.md` (and note against `TR-S4-19`) recording that the bearer-less `/v1/media/<key>` → signed-URL open is owned by S4, not S3. No code.

---

## Execution order & checkpoints

1. Wave A → verify
2. Wave B → verify
3. Wave D (golden harness — independent, unblocks nothing but low risk) → verify
4. Wave C, one screen at a time, worst-first (06→14) → verify per screen
5. Wave E, one screen at a time (a→l); C-before-E for audit + announcements → verify per screen
6. Wave F (doc)
7. Final full `flutter analyze && flutter test`; update the task register rows to `[x]` with timestamps.

## Task tracking
Live checklist in `task.md` (project root), updated `[x]` as each row lands.
