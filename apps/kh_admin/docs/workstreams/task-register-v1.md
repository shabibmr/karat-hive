# Admin Portal — workstream task register (v1)

> **Derived from** the 9 work orders in [`.`](.) (`s0`–`s8`) and the master
> [`../review/implementation-workstreams-v1.md`](../review/implementation-workstreams-v1.md).
> Findings are **not reworded** — every task carries its originating `E*` / `ADM-SMP-*` /
> `ADM-INS-*` / `SDC-*` id in the **Src** column. Full context for any id: the matching
> `s*-*-v1.md` work order, then [`../review/comprehensive-review.md`](../review/comprehensive-review.md).
>
> **HEAD** `88802985` (`8880298`) — line numbers in the work orders are artefacts of that
> commit; use ids and symbol names to re-find.
>
> **Purpose:** the work orders are lead-level ("build the list kernel"). This register
> breaks each step into **atomic tasks** — one file-cluster, one concrete action, one
> checkable done-when — so an agent can pick up a single row cold and finish it without
> reading another document.

## Legend & conventions

- `[ ]` not started · `[-]` in-progress · `[~]` blocked / needs a decision · `[x]` done
- **Task id:** `TR-S<stream>-<nn>` — stable, never renumbered. Sub-tasks use `a/b/c`.
- **Files:** exact repo paths. `[NEW]` = file to create. Work orders that say
  `lib/core/widgets/…` for shared design widgets mean **`lib/core/design/widgets/…`**
  (where `kh_data_table.dart`, `kh_status_chip.dart`, `kh_metric_card.dart`,
  `kh_screen_header.dart` actually live). The admin scaffold is
  `lib/core/shell/kh_admin_scaffold.dart`.
- **Deps:** other `TR-*` ids, and/or a wave gate (`wave 1`) or handoff gate
  (`S1 migrated features/abuse`).
- **Done when:** a single condition. A work-order bullet with "done when X; Y; Z" is
  split into that many tasks.
- Every path below is `apps/kh_admin/`-relative unless it starts with `docs/` or
  `.github/` or `packages/`.

## How to use & Orchestrator Tracking Rules

1. **Pick & Mark In-Progress (Orchestrator)**: When picking a task whose **Deps** are all `[x]` and wave gate has opened:
   - Mark the task with `[-]` to show it is in-progress.
   - Record the start timestamp directly on the task row (e.g., `_started: YYYY-MM-DDTHH:mm:ss_`).
2. **Execution Context**: **Files + Action + Done when** are the whole brief. Open the work order only if you need the "why".
3. **Verification**: Implement the change. Run the stream's **verification command** (top of each section).
4. **Complete & Record Timing (Orchestrator)**: Upon verification:
   - Mark the task with `[x]` (done).
   - Record the completion timestamp and duration (e.g., `_completed: YYYY-MM-DDTHH:mm:ss (duration: Xm Ys)_`).
   - If the task was `[~]`, get the decision recorded first (see the decision tasks — `TR-S*-DECIDE-*`).

## Wave / sequencing recap (from master §5)

| Wave | Runs | Gate to open |
|---|---|---|
| **0** | S0 (2 PRs, serial), S7 (start now, continuous), S8 (start now, continuous) | — |
| **1** | S1 (long, 1 owner, sequential phases), S2 (primitives → per-screen), S4 (full), S3 (build table only, no rewire), S6 (dashboard only) | S0 both PRs merged |
| **2** | S3 per-list rewire, S5 full sweep (merges last), S6 abuse, S7 goldens + integration test | per-feature: S1 migrated that feature; per-detail: S2 split that screen |

**Per-feature pipeline** (list features): `S1 kernel+URL` → `S3 virtualise + .select()` → `S5 ARB + a11y`.
**Per-detail pipeline**: `S2 split` → `S5 ARB + a11y`. Full id chains in the [appendix](#appendix--per-feature-pipelines).

---

## S0 · Foundation

**Goal:** land the shared primitives + analyzer strictness every other stream depends on.
**Depends on:** — · **Blocks:** S1, S2, S3, S4, S5, S6 · **Parallelism:** none, serialize (wave 0).
**Verification:** `cd apps/kh_admin && flutter analyze && flutter test` — analyze surfaces new
strict-lint work (expected; triage per task); tests stay green (**352** baseline).

### PR 1 — analyzer + imports (mechanical, land first)

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[x]` **TR-S0-01** copy strict baseline | E10, `ADM-SMP-33` | `analysis_options.yaml` (from `apps/kh_mobile/karat_hive/analysis_options.yaml`) | Copy the mobile package's `analysis_options.yaml` as the new baseline: `strict-casts`, `strict-inference`, `strict-raw-types`, `language` block. Do **not** yet enable the rule groups below — add them commented / staged. | — | `analysis_options.yaml` has the three `strict-*` flags on; `flutter analyze` runs (may report new issues). |
| `[x]` **TR-S0-02** enable custom_lint + riverpod_lint | E10, `ADM-SMP-33` | `analysis_options.yaml`, `pubspec.yaml` | Confirm `custom_lint` + `riverpod_lint` in `dev_dependencies`; add the `custom_lint` analyzer plugin line so it runs inside `flutter analyze`. | TR-S0-01 | `flutter analyze` output includes `custom_lint` / `riverpod_lint` diagnostics. |
| `[x]` **TR-S0-03** drop `unused_element: ignore` | E10 | `analysis_options.yaml` | Remove `unused_element: ignore` and `invalid_annotation_target: ignore`. File the resulting dead-code hits as fixes in this PR or a listed follow-up issue. | TR-S0-01 | neither `ignore` key present; no new analyze errors left untriaged. |
| `[x]` **TR-S0-04** rule group: package imports | E10 | `analysis_options.yaml` | Turn on `always_use_package_imports`. Triage fallout (fixed in TR-S0-10). | TR-S0-01 | rule enabled; count of violations recorded in the PR description. |
| `[x]` **TR-S0-05** rule group: unawaited_futures | E10 | `analysis_options.yaml` | Turn on `unawaited_futures`; add `unawaited(...)` or `await` at each hit. | TR-S0-01 | rule on; `flutter analyze` clean for this rule. |
| `[x]` **TR-S0-06** rule group: catch clauses | E10 | `analysis_options.yaml` | Turn on `avoid_catches_without_on_clauses`; annotate or narrow each bare `catch`. | TR-S0-01 | rule on; analyze clean for this rule. |
| `[x]` **TR-S0-07** rule group: prefer_final_locals | E10 | `analysis_options.yaml` | Turn on explicit `prefer_final_locals`; auto-fix (`dart fix`). | TR-S0-01 | rule on; analyze clean for this rule. |
| `[x]` **TR-S0-08** rule group: strict-raw-types fallout | E10 | `analysis_options.yaml`, `lib/**` | Resolve `strict-raw-types` diagnostics (add type args). | TR-S0-01 | analyze clean for raw-types. |
| `[x]` **TR-S0-09** stage hardcoded-string + no-`DateTime.now()` lints | E10 | `analysis_options.yaml` | Add the mobile workspace's hardcoded-string and `no-DateTime.now()` custom lints **disabled**, with a comment: enabled by `TR-S5-24` (strings) / `TR-S5-25` (time) after those sweeps. | TR-S0-01 | lints present but off; comment points at the S5 tasks. |
| `[x]` **TR-S0-10** relative → `package:` imports | E11, `ADM-INS-16` | all of `lib/**` | Mechanical: rewrite every relative import in `lib/` to `package:kh_admin/…`. | TR-S0-04 | no relative import in `lib/`. |
| `[x]` **TR-S0-11** verify import lint clean | E11 | `analysis_options.yaml`, `lib/**` | Confirm `always_use_package_imports` passes with **zero** `// ignore:` suppressions. | TR-S0-10 | grep for `ignore: always_use_package_imports` in `lib/` → 0. |

### PR 2 — shared infra (land before S1/S2/S4 consume it)

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[x]` **TR-S0-12** logger: redacting core | E6, `ADM-INS-10` | `[NEW] lib/core/log/kh_logger.dart`, `[NEW] lib/core/log/kh_logger_provider.dart` | Create a logger that redacts `Authorization` header values, email addresses, and mobile numbers before emitting. Expose via a Riverpod provider. | — | unit test: a log call with an email + bearer token emits neither verbatim. |
| `[x]` **TR-S0-13** logger: kill raw payload prints | E6 | `lib/core/firebase/firebase_notification_service.dart`, `lib/core/firebase/firebase_auth_service.dart` | Delete every `debugPrint(` that passes an FCM payload, token, or PII; route anything still needed through `TR-S0-12`'s logger. | TR-S0-12 | grep `debugPrint(` in `lib/` shows no payload/token/PII argument. |
| `[x]` **TR-S0-14** error hook: `FlutterError.onError` | E5, `ADM-INS-12` | `lib/main.dart` | In `main()` set `FlutterError.onError` to log (redacted, via TR-S0-12) then forward to presentation. | TR-S0-12 | a thrown build error is logged, not printed raw. |
| `[x]` **TR-S0-15** error hook: `PlatformDispatcher…onError` | E5 | `lib/main.dart` | Set `PlatformDispatcher.instance.onError` to log + swallow (return `true`). | TR-S0-12 | an async uncaught error is logged, app survives. |
| `[x]` **TR-S0-16** error hook: `runZonedGuarded` | E5 | `lib/main.dart` | Wrap `runApp` in `runZonedGuarded`, funnelling to TR-S0-12. | TR-S0-12 | zone error handler installed. |
| `[x]` **TR-S0-17** error hook: release `ErrorWidget.builder` | E5 | `lib/main.dart`, `[NEW] lib/core/error/error_retry_widget.dart` | In release, replace `ErrorWidget.builder` with a widget that shows a message + **Retry** (rebuild) — not the red screen. | TR-S0-12 | forcing a widget error in release shows the retry widget. |
| `[x]` **TR-S0-18** error hook: `ProviderObserver` | E5 | `[NEW] lib/core/log/provider_logger.dart`, `lib/main.dart` | Add a `ProviderObserver` reporting provider failures to TR-S0-12; attach to root `ProviderScope`. | TR-S0-12 | a provider that throws produces one redacted log line. |
| `[x]` **TR-S0-19** error helper: extract login mapping | E3, `ADM-INS-60` | `[NEW] lib/core/error/api_error_messages.dart`, `lib/features/auth/**` (login mapping source) | Extract login's `ApiException.code` → ARB-key mapping into one pure helper any controller can call. | — | helper compiles; returns a localised message for every code login handles. |
| `[x]` **TR-S0-20** error helper: refactor login onto it + test | E3 | `lib/features/auth/**`, `[NEW] test/core/error/api_error_messages_test.dart` | Point login at the helper; behaviour unchanged. Add the unit test. | TR-S0-19 | login shows the same strings as before; helper test passes. |
| `[x]` **TR-S0-21** `serverTime` capture in `ApiClient` | E16, `ADM-INS-07` | `lib/core/api/api_client.dart`, `[NEW] lib/core/api/server_time_provider.dart` | `ApiClient` reads `meta.serverTime` from every envelope, stores the latest, exposes it via a provider. **Capture only — no consumer migration.** | — | after any API call a provider returns the server's timestamp. |
| `[x]` **TR-S0-22** overridable `Clock` provider | E16, `ADM-INS-07` | `[NEW] lib/core/time/clock.dart` (or `lib/core/api/`) | Add a `Clock` abstraction + provider defaulting to wall-clock, overridable in `ProviderScope` for tests. | — | a test overrides `clockProvider` and reads a fixed `now()`. |

---

## S1 · List-data spine

**Goal:** collapse the forked data layer, the two list-controller families, and the missing
URL state into one kernel.
**Depends on:** S0 (analyzer, `package:` imports, `serverTime`/`Clock`).
**Blocks:** S3 per-list rewire, S6 abuse actions. · **Parallelism:** none internally — one
owner, sequential through the phases.
**Verification:** `flutter analyze && flutter test`; then manually page + filter + deep-link
**every** list screen at a narrow and a wide viewport.
**Constraint:** shared admin list query `limit` **max 100** — enforce in the kernel.

### Phase 1 — rejoin the package graph

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S1-01** add `path:` deps | `ADM-SMP-65`, `ADM-SMP-01`, E15 | `apps/kh_admin/pubspec.yaml` | Add `path:` deps on `packages/kh_core`, `kh_domain`, `kh_api`, `kh_design_system`, `kh_l10n`, `kh_ui_domain` exactly as `apps/kh_mobile/karat_hive/pubspec.yaml` does. | S0 PR1 | `flutter pub get` resolves; admin can `import 'package:kh_core/…'`. |
| `[~]` **TR-S1-02** DECIDE: Melos inclusion slice | `ADM-SMP-65` | root `pubspec.yaml`, `melos.yaml` | Decide whether to add `kh_admin` to the Melos workspace now or as a separate follow-up slice. Record the decision. | TR-S1-01 | decision noted in this row; if "now", TR-S1-03 unblocks. |
| `[ ]` **TR-S1-03** Melos: include `kh_admin` | `ADM-SMP-65` | root `pubspec.yaml`, `melos.yaml` | Add `apps/kh_admin` to the workspace package list / Melos globs. | TR-S1-02 = "now" | `melos list` includes `kh_admin`. |
| `[ ]` **TR-S1-04** replace `ApiException` fork with `kh_core` `Failure` | `ADM-SMP-01` | `lib/core/api/api_exception.dart`, all `catch` sites | Swap the flat `ApiException` for `kh_core`'s sealed `Failure` (or a thin adapter). Keep call sites compiling. | TR-S1-01 | `api_exception.dart` is gone or a ≤20-line adapter; no parallel error class. |
| `[ ]` **TR-S1-05** replace token-storage fork | `ADM-SMP-01` | `lib/core/auth/token_storage.dart` | Use `kh_core`'s token storage (typed expiries), or adapt; stop keeping expiries as raw strings. | TR-S1-01 | expiries are `DateTime`; no bespoke parsing in `token_storage.dart`. |
| `[ ]` **TR-S1-06** reconcile `KhStatusChip` | `ADM-SMP-01` | `lib/core/design/widgets/kh_status_chip.dart` | Align the admin `KhStatusChip` (5 tones) with `kh_design_system`'s (6 tones, same class name, incompatible enum) — import the shared one or map onto its enum. | TR-S1-01 | one `KhStatusChip` type in use; enum matches the shared package. |
| `[ ]` **TR-S1-07** `MaskedParty` / `RevealedParty` types | E15, `ADM-INS-06`, `AD-FE-07` | `lib/features/offers/model/**` (`OfferParentRequestSummary`), import from `kh_domain` if it exists | Replace bare `String? customerName / customerMobile / customerEmail` on `OfferParentRequestSummary` with a `MaskedParty` / `RevealedParty` type so a pre-acceptance widget cannot compile against identity fields. | TR-S1-01 | identity fields are a sealed type, not nullable `String`; pre-acceptance widgets reference only the masked variant. |

### Phase 2 — normalise the envelope once

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S1-08** fix double-wrap in `_send` | `ADM-SMP-62`, `ADM-SMP-04` | `lib/core/api/api_client.dart` | Apply the same pre-`ADM-C-70` double-wrap unwrap that `getCollection` does for lists, inside `ApiClient._send`, so single-entity responses are unwrapped centrally too. | Phase 1 | a single-entity GET returns the inner object with no per-repo help. |
| `[ ]` **TR-S1-09** shared single-entity unwrap | `ADM-SMP-05` | `lib/core/api/api_client.dart` or `lib/core/api/json_parse.dart` | Add one `unwrapEntity` path; remove the need for repo-invented sentinel fields (`id`/`profile`/`user`, `titleEn`, `key`, `name`). | TR-S1-08 | one function knows the single-entity shape. |
| `[ ]` **TR-S1-10a..o** delete per-repo sentinel + hand-flatten | `ADM-SMP-05`, `ADM-SMP-10` | one row per repo: `lib/features/{vendors,requests,offers,customers,connections,audit,abuse,moderation,announcements,admin_users,verification,taxonomy,reports,dashboard,settings}/repository/*.dart` | Per repo: delete its bespoke envelope-shape heuristic and its manual `user`/`profile` flattening; call the shared unwrap from TR-S1-09. | TR-S1-09 | that repo contains no envelope-shape or flatten heuristic. |
| `[ ]` **TR-S1-11** route bypassing repos through `getCollection` | `ADM-SMP-62` | `lib/features/verification/repository/*.dart`, `lib/features/taxonomy/repository/*.dart`, `lib/features/reports/repository/*.dart` | Make these 3 repos call `ApiClient.getCollection` instead of hand-rolling the list fetch/unwrap. | TR-S1-09 | none of the 3 build a list from a raw `_send`. |
| `[ ]` **TR-S1-12** envelope regression test | `ADM-SMP-62` | `test/core/api/api_client_test.dart` | Add cases: double-wrapped list, double-wrapped entity, nested `user`/`profile`, all unwrap through the shared path. | TR-S1-08..11 | tests cover all four shapes. |

### Phase 3 — the list kernel

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S1-13** `Paginated<T>` envelope | `ADM-SMP-25` | `[NEW] lib/core/list/paginated.dart` | One generic `Paginated<T>` (items + `nextCursor` + total?) replacing the 11 `XxxListPage` DTOs. | Phase 2 | type exists + tested; `hasMore` is a getter on `nextCursor != null`, not a stored field. |
| `[ ]` **TR-S1-14** kernel state type | E9, `ADM-INS-19` | `[NEW] lib/core/list/list_state.dart` | Sealed state (or `AsyncValue<Paginated<T>>` + pagination meta) where `loading && error` is **unrepresentable**. No `isLoading`/`isLoadingMore`/`error`/`items` bag. | TR-S1-13 | `loading + error` cannot be constructed; state is exhaustively switched. |
| `[ ]` **TR-S1-15** `CursorPaginatedNotifier<TItem,TFilters>` | E9, `ADM-SMP-61`, `-20`, `-21` | `[NEW] lib/core/list/cursor_paginated_notifier.dart` | One `AsyncNotifier`-based kernel: `build()` returns the first fetch (folds in the six controllers' `Future.microtask(refresh)`), `nextPage()`, `applyFilters()`, `retry()`. Adopt `kh_core/src/paged_list_controller.dart` (cursor-cycle detection, dedup-by-key) where it fits. Enforce `limit` ≤ 100. Every catch uses `TR-S0-19`'s helper (`on ApiException`, never `e.toString()`). | TR-S1-14, TR-S0-19..22 | kernel unit-tested: first load, next page, filter change resets cursor, retry after error, cursor cycle halts. |
| `[ ]` **TR-S1-16** kernel exclusive-state test | E9, `ADM-INS-19` | `test/core/list/cursor_paginated_notifier_test.dart` | Loading→error→retry→loaded transition test; assert no impossible combos. | TR-S1-15 | test passes; cross-linked from `TR-S7-08`. |
| `[ ]` **TR-S1-17a..j** migrate each list feature onto the kernel | E9, `ADM-SMP-61` | one row per feature — Family A: `vendors`, `requests`, `offers`, `customers`, `connections`, `audit`; Family B: `abuse`, `moderation`, `announcements`, `admin_users`. Files: `lib/features/<f>/controller/*_list_controller.dart` (+ `.freezed.dart`), `lib/features/<f>/model/*_page.dart` | Per feature: delete the bespoke controller + page DTO, re-express on `CursorPaginatedNotifier` + `Paginated<T>`; Family B gains cursor+prev/next it lacked. No screen-layout change. | TR-S1-15 | that feature's list loads/pages/filters via the kernel; its old `*ListPage` and `hasMore` field are deleted; feature tests green. |

### Phase 4 — filter models

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S1-18** pick the filter idiom | `ADM-SMP-22`, `-23` | — (decision, record here) | Choose: all filter models `@freezed`. One clear semantic (a single `cleared()` / sentinel approach). | Phase 3 | idiom written in this row. |
| `[ ]` **TR-S1-19a..k** convert each filter model | `ADM-SMP-22`, `-23` | one row per model: `lib/features/{vendors,requests,offers,customers,connections,audit,abuse,moderation,announcements,admin_users,reports}/model/*_filters.dart` | Per model: make it `@freezed` (value equality via generated `==`/`hashCode`), single clear semantic. Special: `customer_list_filters.dart` drops the `T? Function()?` idiom; abuse/moderation/announcement/report gain `==`/`hashCode`. | TR-S1-18 | that model is value-equal and clears the one agreed way. |
| `[ ]` **TR-S1-20** rebuild-skip check | `ADM-SMP-23` | `test/features/*/`, kernel | Assert equal filter objects don't retrigger a fetch. | TR-S1-19* | a re-applied identical filter is a no-op. |

### Phase 5 — query-params codec + URL state

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S1-21** `QueryParamsCodec<T>` | E19, `ADM-SMP-63` | `[NEW] lib/core/router/query_params_codec.dart` | One codec: encode/decode filters **+ cursor + selected id** to/from query params. Reuse `applyQueryParameters` + `stringMapsEqual` from `lib/core/router/query_navigation.dart`. | Phase 4 | codec round-trips a full list state; unit-tested. |
| `[ ]` **TR-S1-22** fix `Uri.replace` clear bug — taxonomy | `ADM-SMP-64` | `lib/core/router/taxonomy_query_params.dart` (`:66`) | Migrate onto `query_navigation.dart`'s shared extension (which passes `const <String,String>{}`), so clearing the last filter clears the query string. | TR-S1-21 | clearing the last taxonomy filter empties the URL query. |
| `[ ]` **TR-S1-23** fix `Uri.replace` clear bug — verification | `ADM-SMP-64` | `lib/core/router/verification_query_params.dart` (`:54`) | Same migration as TR-S1-22. | TR-S1-21 | clearing the last verification filter empties the URL query. |
| `[ ]` **TR-S1-24** clear-semantics regression test | `ADM-SMP-64` | `test/core/router/query_navigation_test.dart` | Test: apply filter → clear → URL query is empty, for the shared extension. | TR-S1-22, -23 | test passes. |
| `[ ]` **TR-S1-25a..e** finish URL migration on the 5 unmigrated files | `ADM-SMP-07`, E19 | one row each: the 5 `*_query_params.dart` not yet on `applyQueryParameters` (`vendor`, `request`, `offer` + the 2 above are the started set; enumerate the actual 5 unmigrated at pickup from `grep -L applyQueryParameters lib/core/router/*_query_params.dart`) | Per file: move to the shared nav extension + `QueryParamsCodec`. | TR-S1-21 | that file uses the shared extension; no bespoke `Uri.replace`. |
| `[ ]` **TR-S1-26a..h** add URL state to the 8 list screens that have none | `ADM-SMP-63`, `ADM-SMP-07` | one row per screen: `customers`, `connections`, `audit`, `abuse`, `moderation`, `announcements`, `admin_users`, plus 1 more (the review says **8 of 13** lack URL state — confirm the 8th at pickup) — files `lib/features/<f>/presentation/*_list_screen.dart` + a new `<f>_query_params.dart` | Per screen: wire `QueryParamsCodec` so filters + cursor + selected id round-trip through the URL. | TR-S1-21, TR-S1-17* for that feature | deep-linking that screen's URL restores its full state. |

### Phase 6 — server-side filters + audit call

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S1-27** push request-list filters to the API | E20, `ADM-INS-46` | `lib/features/requests/repository/request_repository.dart` | Send filters as query params; stop the post-fetch `where`. Coordinate any missing param with `docs/admin-backend-api-gaps.md`. | Phase 3 | no client-side `where` after fetch; `hasMore` follows the filtered cursor. |
| `[ ]` **TR-S1-28** give `admin_users` a cursor | `ADM-SMP-29` | `lib/features/admin_users/repository/admin_user_repository.dart`, controller | Stop fetching the whole dataset; use cursor pagination like the others. | TR-S1-17 (admin_users) | `admin_users` requests one page at a time. |
| `[ ]` **TR-S1-29** audit any other page-local `where` | E20 | `grep -rn "\.where(" lib/features/*/repository lib/features/*/controller` | Remove any remaining post-fetch filtering; push to API. | TR-S1-27 | no repo/controller filters a fetched page in memory. |
| `[ ]` **TR-S1-30** customer-list access audit call | E30, `ADM-INS-40`, `FR-ADM-010` AC5 | `lib/features/customers/repository/customer_repository.dart` or controller | On customer-list load, POST the access-audit entry (mirrors the detail-view audit note). | TR-S1-17 (customers) | opening the customer list writes one audit entry. |
| `[ ]` **TR-S1-31** backend follow-up log | E20 | `docs/admin-backend-api-gaps.md` | Record every filter param the API still can't accept. | TR-S1-27..29 | each gap has a row in that doc. |

---

## S2 · Detail screens

**Goal:** extract shared detail primitives, then break the god screens into rebuild-bounded widgets.
**Depends on:** S0. · **Blocks:** S5 per detail screen. · **Parallelism:** high after primitives land.
**Verification:** `flutter analyze && flutter test`; every detail screen renders unchanged
(pixel diff via S7 goldens once they exist); narrow + wide spot-check. **No behaviour or string change.**

### Step 1 — shared primitives (blocking within S2, 1 PR)

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[-]` **TR-S2-01** `KhDetailRow` _started: 2026-09-09T06:18:00_ | `ADM-SMP-11` | `[NEW] lib/core/design/widgets/kh_detail_row.dart` | One label/value row widget replacing `_buildDetailRow` (request), `_DetailRow` (offer), `_buildFieldRow` (vendor `:260`), `_buildInfoRow` (customer `:330`), inline (connection). | S0 | widget exists, unit-tested; `TR-S7-11` golden requested. |
| `[-]` **TR-S2-02** `KhDetailCard` _started: 2026-09-09T06:18:00_ | `ADM-SMP-12` | `[NEW] lib/core/design/widgets/kh_detail_card.dart` | One card scaffold replacing the `Container`+`BoxDecoration` literal (8× in `request_detail_screen.dart` alone). | S0 | widget exists, unit-tested; golden requested. |
| `[~]` **TR-S2-03 DECIDE** feedback-banner visual winner | `ADM-SMP-08` | screenshots of `customer_detail:222`, `request_detail:248`, `vendor_detail:178` | Pick the winning padding / alpha (0.10 vs 0.12) / border / icon style (outline vs filled) / weight / dismissibility. Record the choice. | — | one visual spec written here; design sign-off noted. |
| `[ ]` **TR-S2-04** `KhFeedbackBanner` | `ADM-SMP-08` | `[NEW] lib/core/design/widgets/kh_feedback_banner.dart`, the 3 call sites | Build to the TR-S2-03 spec; **preserve each test-facing `Key`**; swap all 3 call sites. | TR-S2-03 | one banner widget; all 3 `Key`s intact; screens visually match the chosen winner. |
| `[ ]` **TR-S2-05** replace `_buildStatTile` with `KhMetricCard` | `ADM-SMP-09` | `lib/features/announcements/presentation/announcements_screen.dart` (`:312`) | Delete the hand-rolled metric tile; use the existing `KhMetricCard`. | S0 | no `_buildStatTile` in the file; tile renders via `KhMetricCard`. |

### Step 2 — split the god screens (one agent each; order = worst first)

Per file: split into `header` / `summary` / `timeline` / `actions` / `dialogs` widgets —
real `StatelessWidget`/`ConsumerWidget`, `const` where possible, each in its own file
under the feature's `presentation/`. Use the Step-1 primitives. **No behaviour or string change.**
Done when: the screen file is a composition root and no `_build*` returns a subtree larger
than a screenful.

| Task | Src | File (lines) | Deps | Extra |
|---|---|---|---|---|
| `[ ]` **TR-S2-06** | E12, `ADM-SMP-26`, `-27` | `lib/features/requests/presentation/request_detail_screen.dart` (1484) | TR-S2-01..05 | worst; 8× card literal |
| `[ ]` **TR-S2-07** | E12 | `lib/features/offers/presentation/offer_detail_screen.dart` (1388) | TR-S2-01..05 | |
| `[ ]` **TR-S2-08** | E12 | `lib/features/announcements/presentation/announcements_screen.dart` (1204) | TR-S2-01..05 | also **TR-S2-09** |
| `[ ]` **TR-S2-09** extract compose dialog | E12 | `[NEW] lib/features/announcements/presentation/compose_announcement_dialog.dart` from `announcements_screen.dart:774-1210` | — | ~440 L, a whole second feature — its own file |
| `[ ]` **TR-S2-10** | E12 | `lib/features/vendors/presentation/vendor_detail_screen.dart` (1075) | TR-S2-01..05 | |
| `[ ]` **TR-S2-11** | E12 | `lib/features/settings/presentation/platform_settings_screen.dart` (1059) | TR-S2-01..05 | |
| `[ ]` **TR-S2-12** | E12 | `lib/features/customers/presentation/customer_detail_screen.dart` (1022) | TR-S2-01..05 | |
| `[ ]` **TR-S2-13** | E12 | `lib/features/audit/presentation/audit_screen.dart` (882) | TR-S2-01..05 | structure only |
| `[ ]` **TR-S2-14** | E12 | `lib/features/connections/presentation/connection_detail_screen.dart` (819) | TR-S2-01..05 | |

### Step 3 — presentation must not call repositories

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S2-15** move `fetchDocumentUrl` into the controller | E17, `ADM-INS-11` | `lib/features/verification/presentation/verification_detail_pane.dart`, `lib/features/verification/controller/verification_controller.dart` | Move the `ref.read(verificationRepositoryProvider).fetchDocumentUrl` call into `VerificationController`; the pane reads controller state. | S0 | grep `ref.read(*RepositoryProvider)` in any `presentation/` file → 0. |
| `[ ]` **TR-S2-16** sweep for other presentation→repo calls | E17 | `grep -rn "RepositoryProvider" lib/features/*/presentation` | Fix any other hit the same way. | — | zero repo reads in `presentation/`. |

---

## S3 · Shared widgets & performance

**Goal:** make the admin table lazy, stop whole-state rebuilds, bound image decode.
**Depends on:** S0; then S1 **per-list**. · **Blocks:** — · **Parallelism:** build the widget
early in isolation; rewire each list screen only after S1 migrates that feature.
**Do not** pick a third-party data grid — `AD-FE-12` is open; build the lazy viewport only.
**Verification:** `flutter analyze && flutter test`; scroll a large list at 60fps in profile
mode; S7 goldens for `KhDataTable` (LTR/RTL/200%) pass.

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[-]` **TR-S3-01** virtualise `KhDataTable` body _started: 2026-09-09T06:18:00_ | E13, `ADM-SMP-40` | `lib/core/design/widgets/kh_data_table.dart` (`:73-81`) | Replace the `Column` + `for` row build with a vertical `ListView.builder` (fixed `itemExtent` from `kh.spacing.tableRowHeight`) inside the existing horizontal scroller. Keep row hover (`InkWell.hoverColor`) + header behaviour. **API unchanged.** | S0 | a 500-row page builds a bounded number of row widgets. |
| `[ ]` **TR-S3-02** table golden behind old API | E13, `ADM-SMP-40` | `test/core/design/widgets/kh_data_table_golden_test.dart` | Golden the virtualised table (LTR / RTL / 200% text) before any screen rewire. | TR-S3-01 | goldens committed; cross-linked from `TR-S7-10`. |
| `[ ]` **TR-S3-03a..l** drop outer scroll + rewire per list screen | E13, `ADM-SMP-41` | one row per screen: `request_list`, `vendor_list`, `offer_list`, `announcements`, `platform_settings`, `admin_users`, `moderation`, `abuse`, `audit`, `connection_list`, `customer_list`, `reports` — `lib/features/<f>/presentation/*_list_screen.dart` (+ `reports` presentation) | Per screen: remove the outer `SingleChildScrollView` wrapping `KhDataTable`; let the table own the one scroll view. | TR-S3-01 **and** S1 migrated that feature (`TR-S1-17*`) | that screen has exactly one scroll view for the list; no nested scroll/layout pass. |
| `[ ]` **TR-S3-04a..l** `.select()` granularity per list screen | `ADM-SMP-42`, `ADM-INS-73` | same 12 screens as TR-S3-03 | Per screen: `ref.watch(listProvider.select((s) => s.items))` for the table; separate watches for filters, pagination flags, error. | TR-S1-14 (clean selectors) **and** TR-S3-03 for that screen | toggling a filter chip or the "loading more" flag does not rebuild the row list. |
| `[ ]` **TR-S3-05** image decode bounds | E29, `ADM-INS-72` | KYC / vendor document thumbnail widgets (`grep -rn "Image.network\|Image(" lib/features/{vendors,verification}/presentation`) | Add `cacheWidth` / `cacheHeight` to every thumbnail-sized `Image`. | S0 | no thumbnail slot decodes a full-resolution image. |
| `[ ]` **TR-S3-06** hand off signed-URL KYC open to S4 | E29, `ADM-INS-48` | note only → `TR-S4-*` (media/auth path) | S3 bounds decode only; the bearer-less `/v1/media/<key>` → signed-URL change is S4's. Record the dependency. | — | a row in S4 (`TR-S4-19`) owns the signed-URL open. |

---

## S4 · App-shell / bootstrap / platform

**Goal:** own the `main.dart` / router / `pubspec.yaml` hot spot — token policy, session,
Firebase, bundle, flavours, routes.
**Depends on:** S0 (`main.dart` hooks first); S1 (`pubspec.yaml` `path:` deps first).
**Blocks:** — · **Parallelism:** runs alongside S1/S2/S3.
**Do not** implement ADM-S20 gold rates or add an `FR-ADM-002` Role selector.
**Verification:** `flutter analyze && flutter test`; `flutter build web` for `dev` and `prod`
flavours; confirm token absence in web storage, idle logout, Google-only prod login,
deferred chunks in build output.

### Token / session

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S4-01** web token policy — access token in memory | E1, `ADM-INS-09` | `lib/core/auth/token_storage.dart` | On `kIsWeb`, keep the access token **in memory only** (no `FlutterSecureStorage`, no `WebOptions`). | S0, TR-S1-05 | dev-tools shows no access token in web storage. |
| `[ ]` **TR-S4-02** web token policy — no persisted refresh token | E1 | `lib/core/auth/token_storage.dart`, `lib/core/auth/session_controller.dart` | On web, do not persist the refresh token; re-auth on reload (silent refresh or login screen). | TR-S4-01 | a reload triggers silent re-auth or shows login; nothing in web storage. |
| `[-]` **TR-S4-03** idle timeout timer _started: 2026-09-09T06:18:00_ | E2, `ADM-INS-30`, `FR-ADM-001` AC4 | `[NEW] lib/core/auth/idle_timeout.dart`, `lib/main.dart` | 60-minute idle timer; pointer/keyboard activity resets it. | S0 | 60 min idle fires the timeout callback; activity resets the clock. |
| `[ ]` **TR-S4-04** idle warning dialog + logout | E2 | `lib/core/auth/idle_timeout.dart`, a warning dialog widget | Warn before logout; on no response, log out. | TR-S4-03 | idle → warning dialog → logout. |
| `[ ]` **TR-S4-05** multi-tab logout broadcast | `ADM-INS-85` | `lib/core/auth/session_controller.dart`, web broadcast channel | Broadcast logout across tabs (don't wait for a 401). | TR-S4-01 | logging out in one tab logs out the others. |

### Login gating

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S4-06** gate the password form | E7, `ADM-INS-31`, `adr/0010` | `lib/features/auth/presentation/**` | Show the email/password form **only** when `KH_DEV_AUTOLOGIN` is set; production path is Google Sign-In. | S0 | a prod-flavour build shows only "Sign in with Google". |
| `[ ]` **TR-S4-07** remove seed password default | E7, `ADM-INS-45` | `lib/core/auth/dev_auth.dart` | Delete the `'AdminSecret123!'` default (or move behind `KH_DEV_AUTOLOGIN`). | TR-S4-06 | grep `AdminSecret123` in `lib/` → 0. |

### Gold-rate + empty shells

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[~]` **TR-S4-08 DECIDE** delete empty feature dirs | E8, `ADM-SMP-31` | `lib/features/gold_rate/**`, `lib/features/auth/{controller,model,repository}/**` (`.gitkeep`-only) | Confirm deletion of the `.gitkeep`-only shells (ADM-S20 deferred). Record. | — | decision noted here. |
| `[ ]` **TR-S4-09** hide the Gold Rates nav entry | E8, `ADM-INS-21` | `lib/core/shell/kh_admin_scaffold.dart`, `lib/core/router/app_router.dart` | Remove/hide the `/gold-rates` nav item + placeholder route until ADM-S20. | — | no placeholder screen reachable. |
| `[ ]` **TR-S4-10** delete empty feature dirs | E8 | `lib/features/gold_rate/**`, empty `lib/features/auth/*` dirs | Delete per TR-S4-08. | TR-S4-08 = "delete" | `lib/features/` has no `.gitkeep`-only dir. |

### Bundle

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S4-11** `deferred as` for heavy routes | E23, `ADM-INS-37` | `lib/core/router/app_router.dart` | Load `reports`, `audit`, `announcements` screens via `deferred as`. | S0 | `flutter build web` no longer bundles `fl_chart` in the main chunk. |
| `[ ]` **TR-S4-12** drop `cloud_firestore` | E23, `ADM-SMP-30`, `AD-FE-09`, `C-12` | `apps/kh_admin/pubspec.yaml` | Remove `cloud_firestore` (service already deleted in Tier-0). | TR-S1-01 | package gone; `flutter pub get` clean; no Firestore import in `lib/`. |
| `[ ]` **TR-S4-13** drop `firebase_analytics` | E23, `ADM-INS-41` | `apps/kh_admin/pubspec.yaml`, any `FirebaseAnalyticsObserver` refs | Remove `firebase_analytics` (observer never attached). | TR-S1-01 | package gone; no analytics import. |
| `[ ]` **TR-S4-14** drop `cupertino_icons` | E23, `ADM-INS-42` | `apps/kh_admin/pubspec.yaml` | Remove unused `cupertino_icons`. | TR-S1-01 | package gone; build clean. |

### Flavours

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S4-15** flavour provider graph | E26, `ADM-INS-81` | `[NEW] lib/core/platform/flavor.dart`, `lib/main.dart` | `dev` / `staging` / `prod` via `--dart-define-from-file`; per-flavour provider overrides. | S0 | each flavour boots with its own config. |
| `[ ]` **TR-S4-16** prod refuses non-HTTPS base | E26, `ADM-INS-82` | `lib/core/platform/flavor.dart` or `lib/core/api/api_client.dart` | Prod flavour throws at startup if `KH_API_BASE` is not `https://`. | TR-S4-15 | a `prod` build against `http://` fails fast with a clear message. |
| `[ ]` **TR-S4-17** contract-version / 426 screen | E26 | `[NEW] lib/features/…/contract_mismatch_screen.dart`, `lib/core/api/api_client.dart` | On a contract-version mismatch / HTTP 426, show a dedicated screen. | TR-S4-15 | a simulated 426 renders the screen, not a generic error. |

### FCM + Firebase init

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S4-18** wire the FCM foreground handler (or poll) | E27, `ADM-INS-08`, `ADM-SMP-46` | `lib/core/firebase/firebase_notification_service.dart`, `lib/main.dart` | Call `initializeForegroundHandler` (or a 30s poll) to invalidate list providers on a relevant push. **Coordinate provider names with S1's kernel.** | TR-S1-15 (provider names) | an incoming push (or the poll) refreshes an open list. |
| `[ ]` **TR-S4-19** non-blocking Firebase init, fail closed | E27, `ADM-INS-86` | `lib/main.dart` (`:16`) | Make `Firebase.initializeApp` not block the first frame; if Google Sign-In is the only prod login, an init failure must **block login**, not continue silently. | TR-S4-06 | a simulated Firebase init failure blocks login in prod. |
| `[ ]` **TR-S4-20** decide `firebase_messaging` keep/drop | E23, E27 | `apps/kh_admin/pubspec.yaml` | If TR-S4-18 chose polling, drop `firebase_messaging`; else keep. Record. | TR-S4-18 | package state matches the TR-S4-18 choice. |

### Routing + platform

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S4-21** `AdminRoutes` constants | `ADM-INS-04` | `[NEW] lib/core/router/admin_routes.dart`, `lib/core/router/app_router.dart`, `lib/core/shell/kh_admin_scaffold.dart` | One constants class; replace the magic route strings duplicated between `kAdminNavItems` and the `GoRoute` table. | S0 | no literal route string outside `AdminRoutes`. |
| `[ ]` **TR-S4-22** reject empty `:id` | `ADM-INS-33` | `lib/core/router/app_router.dart` | A route with an empty `:id` (`state.pathParameters['id'] ?? ''`) redirects to the list. | TR-S4-21 | `/vendors//` does not render a broken detail screen. |
| `[ ]` **TR-S4-23** `dart:html` → `package:web` | `ADM-INS-17` | `lib/core/platform/open_url_web.dart` | Replace `dart:html` with `package:web` (or `url_launcher`). | S0 | `avoid_web_libraries_in_flutter` + `deprecated_member_use` clear; URL open still works. |

---

## S5 · i18n & accessibility sweep

**Goal:** every user-visible string via ARB; every interactive element reachable and labelled.
**Depends on:** S1, S2, S4 (merges last, to avoid rebasing string churn).
**Blocks:** — · **Parallelism:** per-screen, additive.
**Do not** change layout structure (S2) or controller logic (S1).
**Verification:** `flutter analyze && flutter test`; run the AR locale + a screen-reader pass;
S7 goldens at 100% and 200% text scale, LTR + RTL.

### ARB migration (`E14` / `ADM-INS-02`)

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S5-01** migrate the shell | E14 | `lib/core/shell/kh_admin_scaffold.dart`, `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb` | Move nav titles + `'Dashboard'`/`'Gold Rates'`/`'Soon'`/`'Sign Out'` to ARB; `AppLocalizations.of(context)!`. | S4 shell settled | no English literal in the scaffold. |
| `[ ]` **TR-S5-02..09** migrate the 8 un-migrated features | E14 | one row each: `customers`, `connections`, `abuse`, `audit`, `admin_users`, `announcements`, `moderation`, `settings` — `lib/features/<f>/presentation/**` + both ARB files | Per feature: add `AppLocalizations` import; move every visible string (incl. dialog copy) to ARB EN + AR. | S1 for that feature, S2 if it was split | that feature has no English literal; AR keys added. |
| `[ ]` **TR-S5-10** migrate login's stragglers | E14 | `lib/features/auth/presentation/**` | Replace hardcoded `'Administrative Portal'` / `'Sign in with Google'` with the ARB keys. | S4 | login shows only ARB-sourced strings. |
| `[ ]` **TR-S5-11** `l10n?.key ?? '…'` → required | E14 | every file currently using the nullable-fallback idiom (`grep -rn "l10n?\." lib/`) | Switch to `AppLocalizations.of(context)!`; delete the English fallback literals. | TR-S5-01..10 | grep `l10n?\.` in `lib/` → 0. |
| `[ ]` **TR-S5-12** AR key-set parity check | E14 | `lib/l10n/app_ar.arb` | Every EN key has an AR entry. | TR-S5-01..11 | key sets are equal (diff is empty). |
| `[ ]` **TR-S5-13** enable the hardcoded-string lint | E14 | `analysis_options.yaml` | Turn on the lint staged in `TR-S0-09`. | TR-S5-11, `TR-S0-09` | lint on; `flutter analyze` clean for it. |

### Accessibility (`E24`)

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S5-14** `Semantics` on icon-only buttons | E24, `ADM-INS-36` | every icon-only `IconButton` (`grep -rn "IconButton(" lib/`) | Wrap in `Semantics(button: true, label: …)` with an ARB label. | TR-S5-01..12 | a screen reader announces every icon action. |
| `[ ]` **TR-S5-15** `SelectionArea` at the scaffold body | E24, `ADM-INS-63` | `lib/core/shell/kh_admin_scaffold.dart` | Wrap the body in `SelectionArea` for canvas copy-paste. | S4 shell | body text is selectable. |
| `[ ]` **TR-S5-16** raise hit targets to 48px | E24, `ADM-INS-12` | `lib/core/design/theme/kh_spacing.dart`, sidebar row (38), offer Inspect (`Size(60,30)`), table `IconButton`s (18px icon) | Pad interactive targets to ≥48px (visual density can stay). | — | every tap target measures ≥48px. |
| `[ ]` **TR-S5-17** list find field bound to `q` | E24 | each list screen header / `lib/core/design/widgets/` | Add a find field wired to the existing `q` filter. | S1 per feature | typing in find filters the list. |
| `[ ]` **TR-S5-18** portal `Shortcuts` map | E24 | `lib/core/shell/kh_admin_scaffold.dart` | `Shortcuts`/`Actions`: Esc closes a dialog, `/` focuses find. | TR-S5-17 | `/` focuses find; Esc closes an open dialog. |

### Directional + de-litteralise

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S5-19** `AlignmentDirectional` / `EdgeInsetsDirectional` | `ADM-INS-03` | `lib/core/shell/kh_admin_scaffold.dart` + the 2 detail screens with physical `Alignment.centerLeft/Right` | Replace physical alignment/insets with directional. | S2 for those screens | AR (RTL) build mirrors; no physical `Alignment.center{Left,Right}` in `lib/`. |
| `[ ]` **TR-S5-20** de-litteralise colours | `ADM-INS-18` | vendor / customer / request detail, login, verification dialogs (`Colors.white` / `Colors.black`) | Use `context.kh.colors.onPrimary` etc. | S2 for those screens | no raw `Colors.` in `lib/` outside token defs. |
| `[ ]` **TR-S5-21** de-litteralise text styles | `ADM-INS-18` | offer list + connection detail (`TextStyle(fontSize: 12.0)`) | Use `kh.typography`. | S2 for those screens | no bare `TextStyle(` in `lib/` outside token defs. |
| `[ ]` **TR-S5-22** lint: ban raw `Colors.*` + raw `TextStyle` | `ADM-INS-18` | `analysis_options.yaml` | Add the custom lints. | TR-S5-20, -21 | lints on; analyze clean. |

### Time display (`E16` consumers)

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S5-23** consume `serverTime` + `Clock` | E16, `ADM-INS-07` | verification wait-hours, vendor licence-expiry, audit range — the `DateTime.now()` fallback/age sites (`grep -rn "DateTime.now()" lib/`) | Replace `DateTime.now()` with `TR-S0-21`/`TR-S0-22` providers. | `TR-S0-21`, `TR-S0-22` | grep `DateTime.now()` in `lib/` → 0 (for ages/fallbacks). |
| `[ ]` **TR-S5-24** format instants in GST | E16, `BR-021` | date/time formatting call sites, `lib/core/format/kh_formats.dart` | Display via `Asia/Dubai` (Gulf Standard Time); store UTC. | TR-S5-23 | timestamps render in GST. |
| `[ ]` **TR-S5-25** enable the no-`DateTime.now()` lint | E16 | `analysis_options.yaml` | Turn on the lint staged in `TR-S0-09`. | TR-S5-23, `TR-S0-09` | lint on; analyze clean. |

---

## S6 · Feature completion

**Goal:** close the three product-visible feature gaps.
**Depends on:** S0. Dashboard can start in wave 1. **Abuse waits for S1** to migrate `features/abuse`.
**Blocks:** — · **Parallelism:** isolated feature folders (1–2 agents).
**Verification:** `flutter analyze && flutter test`; exercise each feature against a seeded
backend; narrow + wide viewport.

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S6-01** per-queue-source state on the dashboard | E4, `ADM-INS-61` | `lib/features/dashboard/controller/dashboard_controller.dart`, `lib/features/dashboard/presentation/**` | Each queue source carries its own `AsyncValue`; remove the `catch`-returns-`[]` swallow. | S0 | a queue source that throws is `error`, not empty. |
| `[ ]` **TR-S6-02** per-source error chip + retry | E4 | `lib/features/dashboard/presentation/**` | Render a per-source error chip with a **Retry**, not a vanished section; message via `TR-S0-19` helper. | TR-S6-01, `TR-S0-19` | killing the verification endpoint shows an error chip on that queue, not "0 pending". |
| `[ ]` **TR-S6-03** dashboard date-range selector | E21, `ADM-INS-32` | `lib/features/dashboard/**` | Add a date-range control feeding the queries. | S0 | changing the range refetches. |
| `[ ]` **TR-S6-04** dashboard trend series | E21 | `lib/features/dashboard/**`, `fl_chart` | Show a trend series for the key metrics. | TR-S6-03 | a trend renders for the selected range. |
| `[ ]` **TR-S6-05** dashboard drill-down deep-links | E21 | `lib/features/dashboard/presentation/**` | Each figure deep-links into the relevant filtered list using `TR-S1-21`'s codec. | `TR-S1-21` | clicking a figure opens the underlying list pre-filtered. |
| `[~]` **TR-S6-06 DECIDE** abuse action set | E22, `FR-ADM-032` (`[ASSUMED]`) | — | Confirm the warn / suspend / deactivate set against `FR-ADM-032`; Product sign-off. Record. | — | action set noted here. |
| `[ ]` **TR-S6-07** abuse actions — API wiring | E22, `ADM-INS-38` | `lib/features/abuse/repository/abuse_repository.dart`, `docs/admin-backend-api-gaps.md` | Wire warn / suspend / deactivate to the admin API; log any missing route. | TR-S6-06, **S1 migrated `features/abuse`** (`TR-S1-17` abuse) | each action calls a real (or logged-as-missing) endpoint. |
| `[ ]` **TR-S6-08** abuse actions — UI + list refresh | E22 | `lib/features/abuse/presentation/abuse_screen.dart`, controller | Action buttons on a report; list reflects the new state after action. | TR-S6-07 | an admin actions a report and the row updates. |

---

## S8 · Documentation carve

**Goal:** carve per-surface doc sets so a session scoped to `apps/kh_admin` needs no
repo-wide `docs/`.
**Depends on:** confirm `SDC-07` + `SDC-08` before phase 3. · **Blocks:** — · **Parallelism:**
fully independent, no code overlap.
**Owns:** `docs/**`, `.claude/skills/carve-surface-docs/`, `scripts/check-surface-docs.mjs`.
**Verification:** `node scripts/check-surface-docs.mjs` exits 0; no content lost (derived ⊇
source ID set); no broken inbound links; `flutter analyze && flutter test` + `backend` build
unaffected; skill re-run idempotent; spot-read passes.

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[~]` **TR-S8-01 DECIDE** `SDC-07` move vs copy | `SDC-07` | — | Confirm: surface-only docs referenced by nothing else are **moved** with a redirect stub (verified-safe list: 4 admin docs, vendor/customer task docs, 7 backend docs). Record. | — | decision noted here. |
| `[~]` **TR-S8-02 DECIDE** `SDC-08` skill timing | `SDC-08` | — | Confirm the carve skill is authored **after** the admin pilot (phase 2). Record. | — | decision noted here. |
| `[ ]` **TR-S8-03** carve `docs/core/` README + Glossary+Invariants | `SDC-01..06` | `[NEW] docs/core/00-README.md`, `[NEW] docs/core/01-Glossary-and-Invariants.md` | Self-contained extracts with a derived-from header (authority stays with `docs/`). | — | both files exist; header present. |
| `[ ]` **TR-S8-04** carve `docs/core/` API-Conventions + Cross-Cutting-Requirements | `SDC-01..06` | `[NEW] docs/core/02-API-Conventions.md`, `[NEW] docs/core/03-Cross-Cutting-Requirements.md` | Same pattern. | — | both files exist. |
| `[ ]` **TR-S8-05** carve `docs/core/` Entity-Dictionary + Design-Tokens + ADRs-index | `SDC-01..06` | `[NEW] docs/core/04-Entity-Dictionary.md`, `[NEW] docs/core/05-Design-Tokens.md`, `[NEW] docs/core/06-ADRs-index.md` | Same pattern; ~2,400 common lines carved once. | — | all three exist; everything links to `docs/core/`. |
| `[ ]` **TR-S8-06** admin pilot — 10 top-level docs | review §1.5.1 | `[NEW] apps/kh_admin/docs/00..09-*.md` | Hand-carve the 10 top-level admin docs (numbering `00`–`08` stable). | TR-S8-05 | 10 files exist with derived-from headers. |
| `[ ]` **TR-S8-07** admin pilot — 23 screen copies + READMEs | `SDC-02` | `[NEW] apps/kh_admin/docs/screens/ADM-S*.md` (23) + section READMEs | Copy each admin screen spec verbatim per screen. | TR-S8-06 | 23 screen files + READMEs present; content byte-identical to source screen specs. |
| `[ ]` **TR-S8-08** admin-set tensions carried, not resolved | review §2, §5.2 | `apps/kh_admin/docs/01-Admin-Requirements.md` | Carry into the derived docs, unresolved: 6 `[ASSUMED]` `FR-ADM` (`002/012/019/028/032/033`); `FR-ADM-002` flat-RBAC vs 3-role tension; ADM-S20 deferred; admin masking exemption (`Arch-Backend §9.5`); list `limit` max 100; 60 specified vs ~45 live routes + double-wrapped envelope + `Decimal`→string. | TR-S8-06 | each item appears in a derived doc, flagged as open/deferred. |
| `[ ]` **TR-S8-09** carve skill | `SDC-08` | `[NEW] .claude/skills/carve-surface-docs/SKILL.md` | Author the skill from what the admin pilot proved. | TR-S8-02, TR-S8-07 | skill exists. |
| `[ ]` **TR-S8-10** surface manifest | phase 3 | `[NEW] docs/surface-map.md` | Manifest of surfaces → doc sets → source sections. | TR-S8-07 | manifest lists core + admin. |
| `[ ]` **TR-S8-11** check script | phase 3 | `[NEW] scripts/check-surface-docs.mjs` | ID coverage (34/31/33/12 FRs, 67 screens, all `BR`/`NFR`/`C`/`AD-*`), no invented IDs, links resolve, no stale sources. | TR-S8-10 | `node scripts/check-surface-docs.mjs` exits 0 on core + admin. |
| `[ ]` **TR-S8-12** mobile carve | phase 4 | `apps/kh_mobile/**/docs/` (58 files, customer + vendor, two mode subfolders) | Run `/carve-surface-docs customer` then `vendor`. | TR-S8-11 | script green on mobile; 58 files. |
| `[ ]` **TR-S8-13** backend carve | phase 5 | `backend/docs/**` (11 files, mostly `git mv` + redirect stubs) | Run `/carve-surface-docs backend`. | TR-S8-11, TR-S8-01 | script green on backend; inbound-link grep returns only stubs + derived files. |

---

## S7 · Testing

**Goal:** close the test gaps; add goldens, an integration test, a CI size budget.
**Depends on:** — (start wave 0). Goldens / integration tests for restructured screens land
**after** S2/S3 touch them. · **Blocks:** — · **Parallelism:** fully parallel, additive-only.
**Owns:** `test/**`, `[NEW] integration_test/**`, `.github/workflows/frontend.yml`.
**Keep the style:** hand fakes + `ProviderScope` overrides, **no mocktail/mockito**.
**Verification:** `flutter test` + `flutter test integration_test` green; CI shows the size
number; `flutter analyze` warning count for `apps/kh_admin` is 0.

### Cheap first — do now (no restructure dependency)

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S7-01** request-list screen test | E18, `ADM-INS-39` | `[NEW] test/features/requests/request_list_screen_test.dart` | empty / error / loading states. **Do this first.** | — | 3 states asserted; passes. |
| `[ ]` **TR-S7-02** `request_detail_controller` test | E18 | `[NEW] test/features/requests/request_detail_controller_test.dart` | Cover load / error / actions. | — | passes. |
| `[ ]` **TR-S7-03** `offer_detail_controller` test | E18 | `[NEW] test/features/offers/offer_detail_controller_test.dart` | Same. | — | passes. |
| `[ ]` **TR-S7-04** `vendor_detail_controller` test | E18 | `[NEW] test/features/vendors/vendor_detail_controller_test.dart` | Same. | — | passes. |
| `[ ]` **TR-S7-05** `audit` + `dashboard` + `reports` controller tests | E18 | `[NEW] test/features/{audit,dashboard,reports}/*_controller_test.dart` | Controllers untested (repos are). | — | 3 files; pass. |
| `[ ]` **TR-S7-06** `taxonomy` repository test | E18 | `[NEW] test/features/taxonomy/taxonomy_repository_test.dart` | Repo untested (controller + screen are). | — | passes. |
| `[ ]` **TR-S7-07** `verification_query_params` test | E18 | `[NEW] test/core/router/verification_query_params_test.dart` | Untested (other query-param helpers are). | — | passes. |
| `[ ]` **TR-S7-08** exclusive-state transition test | E18, `ADM-INS-19` | `test/core/list/cursor_paginated_notifier_test.dart` | loading→error→retry against the S1 kernel. | `TR-S1-15` | transition asserted; no impossible combo. |
| `[ ]` **TR-S7-09** fix the 2 existing warnings | E18 | `test/features/announcements/announcements_screen_test.dart` (unused import), `test/features/settings/platform_settings_controller_test.dart` (unused fake params) | Remove them. | — | `flutter analyze` on `test/` drops those 2. |

### Goldens + integration + CI

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S7-10** goldens for the 4 existing shared widgets | E25, `ADM-INS-01` | `[NEW] test/core/design/widgets/*_golden_test.dart` for `KhStatusChip`, `KhDataTable`, `KhMetricCard`, `KhScreenHeader` | LTR + RTL + 200% text scale. `KhDataTable` golden re-baselines after `TR-S3-01`. | `TR-S3-01` for the table | goldens pass at all 3 configs. |
| `[ ]` **TR-S7-11** goldens for the 3 new detail primitives | E25 | `[NEW] test/core/design/widgets/kh_detail_*_golden_test.dart` | `KhDetailCard`, `KhDetailRow`, `KhFeedbackBanner` as they land. | `TR-S2-01`, `TR-S2-02`, `TR-S2-04` | goldens pass. |
| `[ ]` **TR-S7-12** screen goldens for restructured screens | E25 | `[NEW] test/features/{requests,offers}/*_detail_golden_test.dart` + list-screen goldens | Write / re-baseline **after** S2 splits and S3 virtualises. | `TR-S2-06`, `TR-S2-07`, `TR-S3-03*` | goldens match the settled trees. |
| `[ ]` **TR-S7-13** integration test | E28, `ADM-INS-80` | `[NEW] integration_test/admin_flow_test.dart` | login → dashboard → one list → detail, against a seeded Chrome. | S1, S2 for those screens | `flutter test integration_test` green. |
| `[ ]` **TR-S7-14** CI: compressed main-js size budget | E28, `ADM-INS-84` | `.github/workflows/frontend.yml` (`admin` job) | Measure compressed main-js after `flutter build web`; fail past a threshold. | — | CI prints the size number and fails on regression. |
| `[ ]` **TR-S7-15** CI: fail on `flutter analyze` warnings for `apps/kh_admin` | E28 | `.github/workflows/frontend.yml` | Scope an analyze-warning gate to `apps/kh_admin`. | — | a new warning fails the `admin` job. |

---

## Appendix — per-feature pipelines

Ordered `TR-*` chain each feature passes through. A screen enters a stage only when the
prior stage's task for that feature is `[x]`.

### List features

| Feature | S1 kernel | S1 URL state | S3 virtualise | S3 `.select()` | S5 ARB | S5 a11y |
|---|---|---|---|---|---|---|
| requests | TR-S1-17a | (has some) TR-S1-25* | TR-S3-03a | TR-S3-04a | TR-S5-02..09 n/a (started) / TR-S5-11 | TR-S5-14 |
| vendors | TR-S1-17b | TR-S1-25* | TR-S3-03b | TR-S3-04b | TR-S5-11 | TR-S5-14 |
| offers | TR-S1-17c | TR-S1-25* | TR-S3-03c | TR-S3-04c | TR-S5-11, TR-S5-21 | TR-S5-14 |
| customers | TR-S1-17d | TR-S1-26a | TR-S3-03k | TR-S3-04k | TR-S5-02 | TR-S5-14 |
| connections | TR-S1-17e | TR-S1-26b | TR-S3-03j | TR-S3-04j | TR-S5-03 | TR-S5-14 |
| audit | TR-S1-17f | TR-S1-26c | TR-S3-03i | TR-S3-04i | TR-S5-05 | TR-S5-14 |
| abuse | TR-S1-17g | TR-S1-26d | TR-S3-03h | TR-S3-04h | TR-S5-04 | TR-S5-14 |
| moderation | TR-S1-17h | TR-S1-26e | TR-S3-03g | TR-S3-04g | TR-S5-08 | TR-S5-14 |
| announcements | TR-S1-17i | TR-S1-26f | TR-S3-03d | TR-S3-04d | TR-S5-07 | TR-S5-14 |
| admin_users | TR-S1-17j | TR-S1-26g + TR-S1-28 | TR-S3-03f | TR-S3-04f | TR-S5-06 | TR-S5-14 |
| reports | (via TR-S1-11) | — | TR-S3-03l | TR-S3-04l | TR-S5-11 | TR-S5-14 |
| platform_settings | (config, not list) | — | TR-S3-03e | TR-S3-04e | TR-S5-09 | TR-S5-14 |

### Detail features

| Feature | S2 split | S5 ARB | S5 directional / colour |
|---|---|---|---|
| request_detail | TR-S2-06 | TR-S5-11 | TR-S5-19, TR-S5-20 |
| offer_detail | TR-S2-07 | TR-S5-11, TR-S5-21 | — |
| announcements | TR-S2-08 + TR-S2-09 | TR-S5-07 | — |
| vendor_detail | TR-S2-10 | TR-S5-11 | TR-S5-20 |
| platform_settings | TR-S2-11 | TR-S5-09 | — |
| customer_detail | TR-S2-12 | TR-S5-02 | TR-S5-20 |
| audit_screen | TR-S2-13 | TR-S5-05 | — |
| connection_detail | TR-S2-14 | TR-S5-03 | TR-S5-21 |

---

## Coverage checklist — every work-order id → task(s)

> "Did we lose anything." Every `E*` / `ADM-SMP-*` / `ADM-INS-*` / `SDC-*` id that appears
> in any `workstreams/s*.md` maps to ≥1 `TR-*`. Cross-checked against master §9.

| Id | Stream | Task(s) |
|---|---|---|
| E1 | S4 | TR-S4-01, TR-S4-02 |
| E2 | S4 | TR-S4-03, TR-S4-04 |
| E3 (helper) | S0 | TR-S0-19, TR-S0-20 |
| E3 (call sites) | S1/S2/S6 | TR-S1-15, TR-S6-02 (+ every kernel/controller catch) |
| E4 | S6 | TR-S6-01, TR-S6-02 |
| E5 | S0 | TR-S0-14, TR-S0-15, TR-S0-16, TR-S0-17, TR-S0-18 |
| E6 | S0 | TR-S0-12, TR-S0-13 |
| E7 | S4 | TR-S4-06, TR-S4-07 |
| E8 | S4 | TR-S4-08, TR-S4-09, TR-S4-10 |
| E9 | S1 | TR-S1-13..17 |
| E10 | S0 | TR-S0-01..09 |
| E11 | S0 | TR-S0-10, TR-S0-11 |
| E12 | S2 | TR-S2-06..14 |
| E13 | S3 | TR-S3-01, TR-S3-02, TR-S3-03* |
| E14 | S5 | TR-S5-01..13 |
| E15 | S1 | TR-S1-07 |
| E16 (infra) | S0 | TR-S0-21, TR-S0-22 |
| E16 (consumers) | S5 | TR-S5-23, TR-S5-24, TR-S5-25 |
| E17 | S2 | TR-S2-15, TR-S2-16 |
| E18 | S7 | TR-S7-01..09 |
| E19 | S1 | TR-S1-21, TR-S1-25* |
| E20 | S1 | TR-S1-27, TR-S1-29, TR-S1-31 |
| E21 | S6 | TR-S6-03, TR-S6-04, TR-S6-05 |
| E22 | S6 | TR-S6-06, TR-S6-07, TR-S6-08 |
| E23 | S4 | TR-S4-11..14, TR-S4-20 |
| E24 | S5 | TR-S5-14..18 |
| E25 | S7 | TR-S7-10, TR-S7-11, TR-S7-12 |
| E26 | S4 | TR-S4-15, TR-S4-16, TR-S4-17 |
| E27 | S4 | TR-S4-18, TR-S4-19, TR-S4-20 |
| E28 | S7 | TR-S7-13, TR-S7-14, TR-S7-15 |
| E29 | S3 | TR-S3-05, TR-S3-06 |
| E30 | S1 | TR-S1-30 |
| `ADM-SMP-01` | S1 | TR-S1-04, TR-S1-05, TR-S1-06 |
| `ADM-SMP-04` | S1 | TR-S1-08 |
| `ADM-SMP-05` | S1 | TR-S1-09, TR-S1-10* |
| `ADM-SMP-07` | S1 | TR-S1-25*, TR-S1-26* |
| `ADM-SMP-08` | S2 | TR-S2-03, TR-S2-04 |
| `ADM-SMP-09` | S2 | TR-S2-05 |
| `ADM-SMP-10` | S1 | TR-S1-10* |
| `ADM-SMP-11` | S2 | TR-S2-01 |
| `ADM-SMP-12` | S2 | TR-S2-02 |
| `ADM-SMP-20` | S1 | TR-S1-15 |
| `ADM-SMP-21` | S1 | TR-S1-15 |
| `ADM-SMP-22` | S1 | TR-S1-18, TR-S1-19* |
| `ADM-SMP-23` | S1 | TR-S1-19*, TR-S1-20 |
| `ADM-SMP-24` | S1 | TR-S1-13, TR-S1-14 |
| `ADM-SMP-25` | S1 | TR-S1-13 |
| `ADM-SMP-26` | S2 | TR-S2-06..14 |
| `ADM-SMP-27` | S2 | TR-S2-06..14 |
| `ADM-SMP-29` | S1 | TR-S1-28 |
| `ADM-SMP-30` | S4 | TR-S4-12 |
| `ADM-SMP-31` | S4 | TR-S4-08, TR-S4-09, TR-S4-10 |
| `ADM-SMP-33` | S0 | TR-S0-01, TR-S0-02 |
| `ADM-SMP-40` | S3 | TR-S3-01, TR-S3-02 |
| `ADM-SMP-41` | S3 | TR-S3-03* |
| `ADM-SMP-42` | S3 | TR-S3-04* |
| `ADM-SMP-45` | S4 | TR-S4-11 |
| `ADM-SMP-46` | S4 | TR-S4-18 |
| `ADM-SMP-61` | S1 | TR-S1-15, TR-S1-17* |
| `ADM-SMP-62` | S1 | TR-S1-08, TR-S1-11 |
| `ADM-SMP-63` | S1 | TR-S1-21, TR-S1-26* |
| `ADM-SMP-64` | S1 | TR-S1-22, TR-S1-23, TR-S1-24 |
| `ADM-SMP-65` | S1 | TR-S1-01, TR-S1-02, TR-S1-03 |
| `ADM-INS-01` | S7 | TR-S7-10 |
| `ADM-INS-02` | S5 | TR-S5-01..13 |
| `ADM-INS-03` | S5 | TR-S5-19 |
| `ADM-INS-04` | S4 | TR-S4-21 |
| `ADM-INS-06` | S1 | TR-S1-07 |
| `ADM-INS-07` | S0/S5 | TR-S0-21, TR-S0-22, TR-S5-23 |
| `ADM-INS-08` | S4 | TR-S4-18 |
| `ADM-INS-09` | S4 | TR-S4-01 |
| `ADM-INS-10` | S0 | TR-S0-12 |
| `ADM-INS-11` | S2 | TR-S2-15 |
| `ADM-INS-12` | S0/S5 | TR-S0-14..18, TR-S5-16 |
| `ADM-INS-16` | S0 | TR-S0-10 |
| `ADM-INS-17` | S4 | TR-S4-23 |
| `ADM-INS-18` | S5 | TR-S5-20, TR-S5-21, TR-S5-22 |
| `ADM-INS-19` | S1 | TR-S1-14, TR-S1-16 |
| `ADM-INS-21` | S4 | TR-S4-09 |
| `ADM-INS-22` | S2 | TR-S2-06..14 |
| `ADM-INS-30` | S4 | TR-S4-03 |
| `ADM-INS-31` | S4 | TR-S4-06 |
| `ADM-INS-32` | S6 | TR-S6-03..05 |
| `ADM-INS-33` | S4 | TR-S4-22 |
| `ADM-INS-36` | S5 | TR-S5-14 |
| `ADM-INS-37` | S4 | TR-S4-11 |
| `ADM-INS-38` | S6 | TR-S6-07, TR-S6-08 |
| `ADM-INS-39` | S7 | TR-S7-01..08 |
| `ADM-INS-40` | S1 | TR-S1-30 |
| `ADM-INS-41` | S4 | TR-S4-13 |
| `ADM-INS-42` | S4 | TR-S4-14 |
| `ADM-INS-45` | S4 | TR-S4-07 |
| `ADM-INS-46` | S1 | TR-S1-27 |
| `ADM-INS-48` | S3/S4 | TR-S3-06, TR-S4-19 |
| `ADM-INS-51` | S4 | TR-S4-08 (auth shell dirs) |
| `ADM-INS-60` | S0 | TR-S0-19 |
| `ADM-INS-61` | S6 | TR-S6-01, TR-S6-02 |
| `ADM-INS-63` | S5 | TR-S5-15 |
| `ADM-INS-72` | S3 | TR-S3-05 |
| `ADM-INS-73` | S3 | TR-S3-04* |
| `ADM-INS-80` | S7 | TR-S7-13 |
| `ADM-INS-81` | S4 | TR-S4-15 |
| `ADM-INS-82` | S4 | TR-S4-16 |
| `ADM-INS-84` | S7 | TR-S7-14 |
| `ADM-INS-85` | S4 | TR-S4-05 |
| `ADM-INS-86` | S4 | TR-S4-19 |
| `SDC-01..06` | S8 | TR-S8-03..07 |
| `SDC-07` | S8 | TR-S8-01, TR-S8-13 |
| `SDC-08` | S8 | TR-S8-02, TR-S8-09 |

### Noted as already FIXED (Tier-0) — no task

`ADM-SMP-02/03/06/13/28/32/43/44/60` — fixed in the working tree (master §9, review §4.7).
`ADM-SMP-07` was PART → finished by TR-S1-25*/TR-S1-26*.
Nav liveness single-sourcing (`ADM-SMP-32/60`) — done.
