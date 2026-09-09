# Admin Flutter Portal — simplification review

| | |
|---|---|
| **Product** | Karat Hive |
| **Surface** | Flutter Web Admin Portal (`apps/kh_admin`) |
| **Scope** | All of `apps/kh_admin/lib` — 191 Dart files, ~53,300 lines |
| **HEAD** | `8880298` (`main` = `origin/main`) |
| **Date** | 9 September 2026 |
| **Status** | Snapshot + applied Tier-0 fixes. **Not the plan of record.** |
| **Finding prefix** | `ADM-SMP-nn` — simplification finding. Stable, **never reused**. |
| **Does not override** | SRS v1.3 · `Architecture-Frontend.md` · `Admin-App-Completion-Plan.md` · `API-Route-Inventory.md` |
| **Does not mint** | `FR-*`, `AD-FE-*`, `ADM-S*`, `SAM-GAP-*`, `ADM-C-*` — cited, never replaced |
| **Does not renumber** | `ADM-INS-*` — see *Relation to `docs/inspection/`* below |

## Relation to `docs/inspection/`

`docs/inspection/` is an axis-set inspection of the **same HEAD**, registering `ADM-INS-01`–`87`
against documented standards, the SRS, structure, quality, efficiency and operability.

This document is a **separate pass with a different question**. The inspection asks *does the code
meet the documented bar?* This review asks *what does the code make harder than it needs to be?* —
reuse, simplification, efficiency and altitude only. It does **not** hunt correctness bugs
(that is `/code-review`).

The two overlap, and where they do, the **Cites** column names the `ADM-INS` id so the registers can
be reconciled. `ADM-INS` remains authoritative for standards and spec conformance; where a fact
appears in both, this document adds the *quantity* and the *named replacement*, not a second verdict.

## Method

Four independent reviews of `lib/` — reuse, simplification, efficiency, altitude — with every claim
re-verified against the source before entry. Findings that could not be reproduced were dropped.
Two claims were corrected during verification and are recorded in
*[Corrections made during this pass](#corrections-made-during-this-pass)*.

Ranges follow the sibling register's habit; gaps are reserved, not mistakes.

| Range | Axis |
|---|---|
| `ADM-SMP-01`–`19` | Reuse |
| `ADM-SMP-20`–`39` | Simplification |
| `ADM-SMP-40`–`59` | Efficiency |
| `ADM-SMP-60`–`79` | Altitude |

**Status:** `FIXED` applied in this pass · `PART` partly applied · `OPEN` documented only.

**Line numbers are as at HEAD `8880298`**, before the Tier-0 fixes in §7. Files listed as `FIXED`
have since shifted; use the identifier, not the line, to find them in the current tree.

---

## 1. Register

### Reuse (`01`–`19`)

| ID | Status | Title | Primary evidence | Cites |
|---|---|---|---|---|
| **ADM-SMP-01** | OPEN | `kh_admin` forks `kh_core` / `kh_design_system` as a **regressed subset** | `lib/core/api/api_client.dart` vs `packages/kh_core/lib/src/api_client.dart` | ADM-INS-53 |
| **ADM-SMP-02** | FIXED | `hasMore` derived by the same 1-line expression in **9** repositories | 9 × `*_repository.dart` | ADM-INS-20 |
| **ADM-SMP-03** | FIXED | `_asMap` / `_toDouble` byte-identical in 2 repos, inlined in a 3rd | `connection_repository.dart:241`, `offer_repository.dart:305` | ADM-INS-52 |
| **ADM-SMP-04** | OPEN | Nested `user` / `profile` flattening re-derived in **6** repos | `customer:59`, `vendor:62`, `connection:123`, `offer:120`, `verification:57`, `admin_user:70` | ADM-INS-52 |
| **ADM-SMP-05** | OPEN | Single-entity unwrap uses a different **sentinel field** per feature | `admin_user:70` (`id`/`profile`/`user`), `announcement:106` (`titleEn`), `settings:78` (`key`), `reports:132` (`name`) | ADM-INS-52 |
| **ADM-SMP-06** | FIXED | `_stringMapsEqual` byte-identical in 3 router files | `offer:177`, `request:161`, `vendor:101` | ADM-INS-20 |
| **ADM-SMP-07** | PART | Query-param navigation boilerplate repeated in 5 files | `lib/core/router/*_query_params.dart` | ADM-INS-33 |
| **ADM-SMP-08** | OPEN | Feedback banner written 3× with divergent visuals | `customer_detail:222`, `request_detail:248`, `vendor_detail:178` | — |
| **ADM-SMP-09** | OPEN | `_buildStatTile` hand-rolls a metric tile beside a real `KhMetricCard` | `announcements_screen.dart:312` | — |
| **ADM-SMP-10** | OPEN | 3 repos bypass `ApiClient.getCollection` and unwrap by hand | `verification:20`, `taxonomy`, `reports` | — |
| **ADM-SMP-11** | OPEN | The label/value row primitive is invented **5 times under 5 names** | `_buildDetailRow` (request), `_DetailRow` (offer), `_buildFieldRow` (vendor:260), `_buildInfoRow` (customer:330), inline (connection) | ADM-INS-22 |
| **ADM-SMP-12** | OPEN | No shared detail-card scaffold; the same `Container`+`BoxDecoration` literal appears 8× in one file | `request_detail_screen.dart` | ADM-INS-22 |
| **ADM-SMP-13** | FIXED | 350 ms debounce `Timer` plumbing duplicated across **9** list screens | 9 × `*_screen.dart` | ADM-INS-23 |

### Simplification (`20`–`39`)

| ID | Status | Title | Primary evidence | Cites |
|---|---|---|---|---|
| **ADM-SMP-20** | OPEN | **6** cursor-list controllers ~85% byte-identical (~900 duplicated lines) | vendors / requests / offers / customers / connections / audit | ADM-INS-19, ADM-INS-20 |
| **ADM-SMP-21** | OPEN | **4** more list controllers on a *second*, incompatible `StateNotifier` idiom | abuse / moderation / announcements / admin_users | ADM-INS-20 |
| **ADM-SMP-22** | OPEN | 11 filter models split across **three** `copyWith`-clear idioms | `@freezed` (3) · `bool clearX` (7) · `T? Function()?` (`customer_list_filters.dart:13`) | ADM-INS-05 |
| **ADM-SMP-23** | OPEN | 4 filter models define no `==` / `hashCode`, so equality-based rebuild-skipping cannot work | abuse / moderation / announcement / report filters | — |
| **ADM-SMP-24** | OPEN | `hasMore` is **stored state derivable from `nextCursor`**, then re-derived again in `canLoadMore` | 9 page DTOs + 10 controller states | — |
| **ADM-SMP-25** | OPEN | 11 near-identical `XxxListPage` envelopes instead of one `Paginated<T>` | `*_list_page.dart` | ADM-INS-20 |
| **ADM-SMP-26** | OPEN | **19** presentation files exceed 400 lines, totalling 19,132 — ~36% of `lib/` | `request_detail` 1484 · `offer_detail` 1388 · `announcements` 1210 | ADM-INS-22 |
| **ADM-SMP-27** | OPEN | `_ComposeAnnouncementDialog` (~440 lines) lives at the end of another screen's file | `announcements_screen.dart:774-1210` | ADM-INS-22 |
| **ADM-SMP-28** | FIXED | `dynamic kh` on 35 helper signatures defeats type checking on the theme | request / vendor / connection detail screens | — |
| **ADM-SMP-29** | OPEN | `admin_users` fetches the **entire** dataset and filters client-side — no cursor at all | `admin_user_controller.dart:88` | ADM-INS-46 |
| **ADM-SMP-30** | FIXED | `FirestoreService` + `FirebaseAnalyticsService` dead — zero references in `lib/` or `test/` | `lib/core/firebase/` | ADM-INS-41, ADM-INS-42 |
| **ADM-SMP-31** | OPEN | `gold_rate/` (4 dirs) and `auth/{controller,model,repository}` are `.gitkeep`-only shells | `lib/features/` | ADM-INS-21 |
| **ADM-SMP-32** | FIXED | Router placeholder exclusion list = 18 lines restating a flag that already exists | `app_router.dart:205` | ADM-INS-51 |
| **ADM-SMP-33** | OPEN | `unused_element: ignore` suppresses the lint that would have caught `ADM-SMP-30` | `analysis_options.yaml:14` | ADM-INS-15 |

### Efficiency (`40`–`59`)

| ID | Status | Title | Primary evidence | Cites |
|---|---|---|---|---|
| **ADM-SMP-40** | OPEN | `KhDataTable` builds **every** row into a `Column` — no lazy path at any page size | `kh_data_table.dart:73-81` | ADM-INS-13 |
| **ADM-SMP-41** | OPEN | 12 list screens nest that table inside a **second** `SingleChildScrollView` | see §4 | ADM-INS-70 |
| **ADM-SMP-42** | OPEN | **Zero** `.select(` calls in 191 files — every screen watches whole controller state | 16 screens | ADM-INS-73 |
| **ADM-SMP-43** | FIXED | `DateFormat` / `NumberFormat` constructed per `build()`, up to 8× in one frame | `request_detail_screen.dart` (8 sites) | — |
| **ADM-SMP-44** | FIXED | Export poll: flat 400 ms × 40 attempts, no backoff | `reports_repository.dart:24` | ADM-INS-71 |
| **ADM-SMP-45** | OPEN | `fl_chart` eagerly imported for one screen; no `deferred as` | `report_chart.dart:1` | ADM-INS-37 |
| **ADM-SMP-46** | OPEN | `Firebase.initializeApp` blocks the first frame | `main.dart:16` | ADM-INS-86 |

### Altitude (`60`–`79`)

| ID | Status | Title | Deeper change | Cites |
|---|---|---|---|---|
| **ADM-SMP-60** | FIXED | Nav liveness had **two sources of truth** | Read the `isLive` flag that already exists | ADM-INS-51 |
| **ADM-SMP-61** | OPEN | No list kernel — every feature re-implements paginate+filter+search | One `CursorPaginatedNotifier<TItem, TFilters>`; `kh_core` already ships `PagedListController` (365 L) | ADM-INS-20 |
| **ADM-SMP-62** | OPEN | No shared response normaliser — repos each re-derive the envelope shape | Fix the double-wrap in `ApiClient._send`, as `getCollection` already does for lists | ADM-INS-52 |
| **ADM-SMP-63** | OPEN | No query-params codec, so **8 of 13** list screens have no URL state at all | One `QueryParamsCodec<T>` + the shared navigation extension | ADM-INS-33 |
| **ADM-SMP-64** | OPEN | `taxonomy` / `verification` **never clear** the query string — see §6 | Adopt the shared navigation extension | ADM-INS-62 |
| **ADM-SMP-65** | OPEN | `kh_admin` is outside the shared package graph, so fixes cannot propagate either way | Add the `path:` deps `kh_mobile` already uses | ADM-INS-53 |

**Counts:** 13 reuse · 14 simplification · 7 efficiency · 6 altitude = **40 findings**, of which
**9 are fixed** and 1 partly fixed in this pass.

---

## 2. Reuse

### The fork is the expensive one (`ADM-SMP-01`, `ADM-SMP-65`)

`packages/` already contains `kh_core`, `kh_domain`, `kh_api`, `kh_design_system`, `kh_l10n` and
`kh_ui_domain`. `apps/kh_mobile/karat_hive/pubspec.yaml` consumes all six via `path:` deps.
`apps/kh_admin/pubspec.yaml` consumes **none** — it depends on `dio`, `flutter_riverpod` and
`go_router` directly and rebuilds the shared layer:

| Concept | `kh_admin` | `packages/` | Difference |
|---|---|---|---|
| HTTP client | `lib/core/api/api_client.dart` | `kh_core/src/api_client.dart` (258 L) | admin lacks correlation-id + idempotency-key headers and server-clock sync |
| Error model | `ApiException` — one flat class with a `code` string | `kh_core/src/failure.dart` — sealed `Failure` hierarchy | admin cannot pattern-match on failure kind |
| Token storage | `lib/core/auth/token_storage.dart` | `kh_core/src/token_storage.dart` (64 L) | admin keeps expiries as raw strings, `kh_core` parses to `DateTime` |
| Paged list | 13 hand-rolled controllers | `kh_core/src/paged_list_controller.dart` (365 L) | generic, with cursor-cycle detection and dedup by key |
| Status chip | `KhStatusChip` (5 tones) | `KhStatusChip` (6 tones) | **same class name**, incompatible tone enums |

This is not simply duplication — the admin copy is a **regressed subset**. A fix landed in
`kh_core` (a refresh race, a missing header) does not reach the admin portal, and vice versa.
Everything else in this document is downstream of it.

### Repository normalisation (`ADM-SMP-02`–`05`, `ADM-SMP-10`)

`ApiClient.getCollection` already unwraps the list envelope centrally, including the documented
pre-`ADM-C-70` double-wrap fallback. That knowledge stops at the boundary: `getCollection` returns a
raw `meta` map, so all **9** paginated repos then wrote the same line —

```dart
final hasMore = nextCursor != null && nextCursor.isNotEmpty;
```

— and for **single** entities, five repos each invented a different sentinel field to decide whether
a residual `data` wrapper is present (`id`/`profile`/`user`, `titleEn`, `key`, `name`). Five
independent heuristics that must each be re-checked whenever the backend envelope moves.

### The other duplications

`ADM-SMP-11` is the sharpest small example: the same "label on the left, value on the right" row is
implemented five times under five names — `_buildDetailRow`, `_DetailRow`, `_buildFieldRow`,
`_buildInfoRow`, and inline. Two of the five are widget classes, three are methods.

---

## 3. Simplification

### Two competing list idioms, neither shared (`ADM-SMP-20`, `ADM-SMP-21`)

Ten list controllers, ~1,784 lines, split into two families that solve the same problem differently:

| | Family A — cursor + prev/next | Family B — `StateNotifier`, infinite only |
|---|---|---|
| Members | vendors, requests, offers, customers, connections, audit | abuse, moderation, announcements, admin_users |
| State | `@freezed` (3) / hand-written (3) | hand-written (4) |
| Paging | `refresh`/`loadMore`/`nextPage`/`previousPage` + `cursorHistory` | `loadInitial`/`loadMore` only |

`vendor_list_controller.dart` vs `offer_list_controller.dart` differ in **26 of 174 lines**;
`abuse_controller.dart` vs `moderation_controller.dart` in 54 of 183. The drift is already visible:
`audit` has no `totalCount`, `customer` has no `totalCount`, and `admin_users` has no pagination at
all (`ADM-SMP-29`).

**The codebase already knows the better idiom.** All five *detail* controllers use
`FamilyAsyncNotifier` + `AsyncValue` with no hand-rolled loading flags. Only the list side never
adopted it.

### Derivable state (`ADM-SMP-24`)

`hasMore` is computed from `nextCursor` in the repository, **stored** in the page DTO, **stored
again** in controller state, then re-derived a third time:

```dart
bool get canLoadMore {
  if (hasMore == false) return false;
  final cursor = nextCursor;
  return cursor != null && cursor.isNotEmpty;   // the same test again
}
```

It is also typed `bool?` in five controllers and `bool` in the other five. `copyWith` can move
`hasMore` without `nextCursor`, so the two can desync. Deleting the field in favour of one getter on
`nextCursor` removes a field from 9 DTOs and 10 states and makes the desync unrepresentable.

### Presentation weight (`ADM-SMP-26`, `ADM-SMP-27`)

19 files over 400 lines, 19,132 lines total — roughly **36% of `lib/`** is screen code, and the three
largest are detail screens whose per-card scaffolding is copy-pasted (`ADM-SMP-12`).
`announcements_screen.dart` additionally carries a whole second feature — a ~440-line compose dialog
— larger than most complete list screens.

---

## 4. Efficiency

### Table rendering (`ADM-SMP-40`, `ADM-SMP-41`)

`kh_data_table.dart:73-81` builds every row eagerly:

```dart
child: Column(
  children: [
    _headerRow(context),
    for (var i = 0; i < rows.length; i++)
      _bodyRow(context, rows[i], isLast: i == rows.length - 1),
  ],
),
```

There is no `ListView.builder` path at any page size. This is currently masked by a default page
size of 20 (`request_repository.dart:15`) — the widget itself has no ceiling. On top of that, all 12
screens that host the table wrap it in an outer `SingleChildScrollView` while the table runs its own
scroll view internally (`kh_data_table.dart:69`), so every list screen pays two nested scroll/layout
passes per frame:

`request_list` · `vendor_list` · `offer_list` · `announcements` · `platform_settings` ·
`admin_users` · `moderation` · `abuse` · `audit` · `connection_list` · `customer_list` · `reports`

Both are blocked behind `AD-FE-12` (admin data grid — build or buy), which is still an open decision.

### Watch granularity (`ADM-SMP-42`)

`grep -rn "\.select(" lib/` returns **0** across 191 files. `RequestListState` bundles 10
independent fields; flipping `isLoadingMore` during `nextPage()` rebuilds the whole screen subtree
including the table, even though `items` did not change.

---

## 5. Altitude

Ranked by how much else each one would remove:

1. **`ADM-SMP-65` — rejoin the package graph.** Wiring is cheap (`path:` deps, as `kh_mobile`
   already does); migration is not. But it dissolves `ADM-SMP-01` and much of `61`/`62`.
2. **`ADM-SMP-61` — one list kernel.** Collapses `ADM-SMP-20`, `21`, `24`, `25` and most of `13`.
   `kh_core/paged_list_controller.dart` already exists.
3. **`ADM-SMP-62` — normalise once, at the client.** If `_send` resolved the double-wrap the way
   `getCollection` already does for lists, `ADM-SMP-02`–`05` and `10` stop existing.
4. **`ADM-SMP-63` — a query-params codec.** The reason 8 of 13 list screens have no URL state is
   that adopting the pattern costs a bespoke ~150-line file per feature.
5. **`ADM-SMP-60` — fixed.** The pattern to notice: the router restated a fact the nav table already
   held. Special-casing on top of shared infrastructure is the smell; reading the existing flag is
   the fix.

---

## 6. Behavioural divergence found (not fixed) — `ADM-SMP-64`

Verified empirically while unifying the query-param helpers, and worth a decision:

```dart
// taxonomy_query_params.dart:66, verification_query_params.dart:54
final newUri = state.uri.replace(
  queryParameters: updated.toQueryParameters().isEmpty
      ? null                                   // <-- keeps the OLD query
      : updated.toQueryParameters(),
);
```

`Uri.replace(queryParameters: null)` **preserves** the existing query rather than clearing it:

```text
/taxonomy/categories?selectedId=abc&showInactive=true
  .replace(queryParameters: null)      -> /taxonomy/categories?selectedId=abc&showInactive=true
  .replace(queryParameters: const {})  -> /taxonomy/categories?
```

So on those two screens, clearing the last filter does not clear the URL. The other three files
(`offer`, `request`, `vendor`) pass `const <String, String>{}` and clear correctly.

**Not fixed here** — this is a behaviour change, outside a quality pass's remit, and it wants a
regression test alongside it. The shared `applyQueryParameters` extension added in this pass already
has the correct semantics, so the fix is to migrate those two files onto it.

---

## 7. Applied in this pass (Tier 0)

31 files changed, **387 deletions against 172 insertions**, plus 137 lines of new shared code.
Analyzer and tests unchanged from baseline throughout.

| ID | Change | Effect |
|---|---|---|
| `ADM-SMP-32` `60` | `app_router.dart`: 18-line route-exclusion chain → `.where((item) => !item.isLive)` | −18 lines; one source of truth. The 16 excluded paths exactly matched the 16 `isLive: true` items, and *Gold Rates* remains the only placeholder |
| `ADM-SMP-30` | Deleted `firestore_service.dart` (45 L) and `firebase_analytics_service.dart` (54 L); trimmed the barrel | −99 lines. `FirestoreService` also contradicted `C-12` / `AD-FE-09` (no secondary datastore). `FirebaseNotificationService` **kept** — `main.dart:19` needs its background handler |
| `ADM-SMP-06` `07` | New `lib/core/router/query_navigation.dart` — one `applyQueryParameters` extension + one `stringMapsEqual` | 3 copies of the helper and 3 copies of the try/catch collapsed to one |
| `ADM-SMP-02` `03` | New `lib/core/api/json_parse.dart` — `asMap`, `toDouble`, `toDoubleOrNull`, `hasMoreFromCursor` | 9 repos share the cursor derivation; 3 share the coercion helpers |
| `ADM-SMP-43` | New `lib/core/format/kh_formats.dart` — 4 shared formatter instances | Removes up to 8 formatter allocations per frame on the request detail screen |
| `ADM-SMP-13` | New `lib/core/widgets/debounced_search_mixin.dart` | 9 screens lose their `Timer` field, `dispose` cancel and timer plumbing. `admin_users`' 300 ms is preserved by overriding `searchDebounceDuration` |
| `ADM-SMP-28` | `dynamic kh` → `KhThemeExtension kh` on 35 signatures | Restores type checking on every theme access in the three worst detail screens; compiled with no type errors, proving the annotations were already correct |
| `ADM-SMP-44` | Export poll: flat 400 ms × 40 → doubling backoff capped at 2 s, 12 attempts | ~21 s of patience across **12** requests, where the old flat interval spent **40** to cover ~16 s. A zero interval still disables waiting, so tests are unaffected |

### Deliberately not applied

| ID | Why |
|---|---|
| `ADM-SMP-08` | The three banners differ in padding, alpha (0.10 vs 0.12), border alpha, icon style (outline vs filled), text weight and dismissibility. Merging them **picks a winner visually** on at least two screens, and each carries a test-facing `Key`. That is a design decision, not a cleanup |
| `ADM-SMP-64` | A behaviour change; wants a regression test (see §6) |
| `ADM-SMP-01` `65` | Cross-package migration — needs sign-off |
| `ADM-SMP-61` `62` `63` | Structural; ~900 lines of controller logic and 11 DTOs |
| `ADM-SMP-40` `41` | Blocked behind `AD-FE-12`; changes scroll semantics |
| `ADM-SMP-45` `46` | `deferred as` changes web load semantics — wants a measured before/after |
| `ADM-SMP-31` | `gold_rate/` is a real deferred screen (ADM-S20), not litter; deleting its shell is a planning decision |
| `ADM-SMP-22` `26` `27` | Already owned by `ADM-INS-05` / `ADM-INS-22` |

## Corrections made during this pass

Two claims did not survive verification and are recorded so they are not re-derived:

| Claim | Correction |
|---|---|
| "`lib/` has no empty directories, so `ADM-INS-21` is stale" | **Wrong.** `find -type d -empty` misses them because each holds a `.gitkeep`. The `gold_rate/` and `auth/` shells are real — `ADM-INS-21` stands, and is re-registered here as `ADM-SMP-31` |
| "`FirebaseNotificationService` is unused and can be deleted with its siblings" | **Wrong.** The class has no external references, but `main.dart:19` uses the file's free function `firebaseMessagingBackgroundHandler`. The file is kept |

---

## 8. Verification

```bash
cd apps/kh_admin
flutter analyze --no-fatal-infos    # 3 issues, all pre-existing, all in test/
flutter test                        # 352 tests, all passing
flutter run -d chrome --dart-define=KH_API_BASE=http://localhost:3000
```

Both were run before and after the Tier-0 fixes with identical results — 3 analyzer issues
(`announcements_screen_test.dart:9`, `platform_settings_controller_test.dart:11,13`, none in `lib/`)
and 352 passing tests.

Manual checks worth doing before merge:

| Change | Check |
|---|---|
| `ADM-SMP-32` | Every sidebar entry routes to its real screen; only *Gold Rates* shows the placeholder |
| `ADM-SMP-13` | Type into search on each of the 9 list screens — one request after the pause, not one per keystroke; `admin_users` still at 300 ms |
| `ADM-SMP-44` | Run an export and confirm it still completes; the first re-check is 400 ms, later ones stretch to 2 s |
| `ADM-SMP-28` `43` | Request and vendor detail screens render unchanged |

Per the standing responsive rule for `kh_admin`, spot-check one list screen and one detail screen at
both a narrow and a wide viewport. `test/responsive/admin_responsive_test.dart` covers phone through
desktop and passes.
