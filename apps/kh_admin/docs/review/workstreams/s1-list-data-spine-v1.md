# S1 · List-data spine

> Work order derived from [`../comprehensive-review.md`](../comprehensive-review.md) §3.3.2/§3.3.4/§3.3.5 and §4.2–§4.6. Line numbers are HEAD `8880298` artefacts.

| | |
|---|---|
| **Goal** | Collapse the forked data layer, the two list-controller families, and the missing URL state into one kernel. |
| **Owner** | 1 agent, **sequential** through the sub-phases below. ~50% of total remaining effort. |
| **Parallelism** | None internally. Runs alongside S2/S4/S6 which avoid its files. |
| **Depends on** | S0 (analyzer, `package:` imports, `serverTime`/`Clock`). |
| **Blocks** | S3 per-list rewire, S6 abuse actions. |
| **Owns** | `lib/core/api/`, `lib/core/list/` (new), `lib/core/router/*_query_params.dart` + `query_navigation.dart`, root `pubspec.yaml` / `melos.yaml`, `apps/kh_admin/pubspec.yaml` (path deps), every `lib/features/*/controller/` + `repository/` + `model/` |
| **Do not** | resolve `AD-FE-12`; upgrade Riverpod to 3 in this stream; touch `KhDataTable` (S3) or presentation layout (S2) |

## Phase 1 — rejoin the package graph (`ADM-SMP-65`, `ADM-SMP-01`, `E15`)
- **Now:** `apps/kh_admin/pubspec.yaml` consumes **none** of `packages/` (`kh_core`, `kh_domain`, `kh_api`, `kh_design_system`, `kh_l10n`, `kh_ui_domain`); `kh_mobile` consumes all six via `path:` deps. `kh_admin` is excluded from the Melos workspace (root `pubspec.yaml`). The admin copy is a **regressed subset**: `ApiClient` lacks correlation-id + idempotency-key headers and clock sync; `ApiException` is one flat class vs `kh_core`'s sealed `Failure`; token storage keeps expiries as raw strings; `KhStatusChip` has 5 tones vs 6, same class name, incompatible enum.
- **Do:** add the `path:` deps as `kh_mobile` does; plan Melos inclusion as its own slice. **`E15`:** introduce `MaskedParty` / `RevealedParty` (or import `kh_domain`) so `OfferParentRequestSummary.customerName` / `customerMobile` / `customerEmail` stop being bare `String?` — a pre-acceptance widget must not compile against identity fields (`ADM-INS-06`, `AD-FE-07`).
- **Done when:** admin builds against `kh_core` types; the parallel `ApiException` / token-storage / status-chip forks are gone or thin adapters; identity is a type, not a nullable string.

## Phase 2 — normalise the envelope once (`ADM-SMP-62`, `-04`, `-05`, `-10`)
- **Now:** `ApiClient.getCollection` unwraps the list envelope centrally (incl. the pre-`ADM-C-70` double-wrap fallback) but returns a raw `meta` map, so 9 repos re-derive `hasMore` (fixed in Tier-0 via `json_parse.dart`) and **5 repos each invent a different sentinel field** for single-entity unwrap (`id`/`profile`/`user`, `titleEn`, `key`, `name`). Nested `user`/`profile` flattening re-derived in **6** repos. **3** repos (verification, taxonomy, reports) bypass `getCollection` entirely.
- **Do:** fix the double-wrap in `ApiClient._send` the way `getCollection` already does for lists. Delete the per-repo sentinel heuristics and the hand flattening. Route the 3 bypassing repos through the shared path.
- **Done when:** no repo contains an envelope-shape heuristic; one place knows the wire shape.

## Phase 3 — the list kernel (`E9`, `ADM-SMP-61`, `-20`, `-21`, `-24`, `-25`)
- **Now:** 10 list controllers (~1,784 lines) in two incompatible families —
  - **Family A** (vendors, requests, offers, customers, connections, audit): cursor + prev/next + `cursorHistory`.
  - **Family B** (abuse, moderation, announcements, admin_users): `StateNotifier`, infinite scroll only.
  - `vendor_list_controller` vs `offer_list_controller` differ in 26/174 lines; `abuse_controller` vs `moderation_controller` in 54/183.
  - Boolean soup: `isLoading` / `isLoadingMore` / `error` / `items` — `isLoading && error != null` is representable (`ADM-INS-19`).
  - `hasMore` stored in the page DTO **and** controller state **and** re-derived in `canLoadMore`; typed `bool?` in 5, `bool` in 5 — can desync via `copyWith` (`ADM-SMP-24`).
  - 11 near-identical `XxxListPage` envelopes instead of one `Paginated<T>` (`ADM-SMP-25`).
  - `kh_core/src/paged_list_controller.dart` (365 L) already exists with cursor-cycle detection and dedup-by-key.
  - All 5 *detail* controllers already use `FamilyAsyncNotifier` + `AsyncValue` correctly — the list side just never adopted it.
- **Do:** one `CursorPaginatedNotifier<TItem, TFilters>` — sealed state or `AsyncValue` + pagination metadata, no boolean flags. Adopt `kh_core`'s `PagedListController` where it fits (after phase 1). Replace the 11 page envelopes with one `Paginated<T>`. Delete `hasMore` as stored state — one getter on `nextCursor`. Migrate all 10 features onto it. Also fold in the `Future.microtask(refresh)` in `Notifier.build()` (six controllers) → `AsyncNotifier.build()` returning the fetch. Adopt the S0 `E3` error helper at every catch site (`on ApiException`, never `e.toString()`).
- **Done when:** one kernel, one state shape, 10 features on it, `hasMore` unrepresentable-when-wrong.

## Phase 4 — filter models (`ADM-SMP-22`, `-23`)
- **Now:** 11 filter models, three `copyWith`-clear idioms — `@freezed` (3), `bool clearX` (7), `T? Function()?` (`customer_list_filters.dart`). 4 (abuse, moderation, announcement, report) define no `==` / `hashCode`, so equality-based rebuild-skipping can't work.
- **Do:** one idiom — all `@freezed` (or all with `==` / `hashCode`). One clear semantic.
- **Done when:** every filter model is value-equal and clears the same way.

## Phase 5 — query-params codec + URL state (`E19`, `ADM-SMP-63`, `-07`, `-64`)
- **Now:** query params wired only for vendors / requests / offers / verification / taxonomy; cursor & sort never encoded even there; **8 of 13** list screens have no URL state. `ADM-SMP-07` is PART — shared `applyQueryParameters` + `stringMapsEqual` exist in `lib/core/router/query_navigation.dart` but 5 files aren't migrated. **`ADM-SMP-64` (behaviour bug):** `taxonomy_query_params.dart:66` and `verification_query_params.dart:54` pass `null` (not `const {}`) to `Uri.replace(queryParameters:)`, so `Uri.replace` **preserves** the old query — clearing the last filter doesn't clear the URL. The other 3 files pass `const <String,String>{}` and clear correctly.
- **Do:** one `QueryParamsCodec<T>` + the shared nav extension. Encode filters **and** cursor **and** selected id on every list. Migrate the 5 unfinished files. Migrate `taxonomy` + `verification` onto the shared extension (which already has the correct clear semantics) and add a regression test for the clear.
- **Done when:** every list screen round-trips its full state through the URL; clearing the last filter clears the query string everywhere.

## Phase 6 — server-side filters + audit call (`E20`, `ADM-SMP-29`, `E30`)
- **Now:** `RequestRepository.fetchRequests` filters *after* fetch; `hasMore` follows the unfiltered cursor (`ADM-INS-46`). `admin_users` fetches the **entire** dataset and filters client-side — no cursor at all (`ADM-SMP-29`). No customer-list access audit call (`FR-ADM-010` AC5, `ADM-INS-40`).
- **Do:** push list filters to the API — coordinate with `docs/admin-backend-api-gaps.md` for the backend follow-up. Give `admin_users` a cursor. Add the customer-list access audit call in the repository/controller.
- **Done when:** no page-local `where` after fetch; `admin_users` paginates; opening the customer list writes an audit entry.

## Constraint
Shared admin list query `limit` **max 100** — honour it in the kernel.

## Verification
`flutter analyze && flutter test`; manually page + filter + deep-link every list screen at a narrow and a wide viewport (standing `kh_admin` responsive rule).
