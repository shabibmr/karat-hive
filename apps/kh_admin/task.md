# Task Execution Checklist — S1 · List-Data Spine

## Phase 1 — Rejoin the Package Graph
- [x] 1.1 `[MODIFY] lib/core/api/api_exception.dart` — adapter over `kh_core.Failure` (TR-S1-04)
- [x] 1.2 `[MODIFY] lib/core/auth/auth_models.dart` & `token_storage.dart` — typed `DateTime` expiries (TR-S1-05)
- [x] 1.3 `[MODIFY] lib/features/offers/model/offer_detail.dart` & `offer_detail_screen.dart` — `MaskedParty` / `RevealedParty` (TR-S1-07)
- [x] 1.4 Phase 1 verification (`flutter analyze && flutter test`)

## Phase 2 — Normalise the Envelope Once
- [x] 2.1 `[MODIFY] lib/core/api/api_client.dart` — double-wrap unwrap in `_send` (TR-S1-08)
- [x] 2.2 `[MODIFY] lib/core/api/json_parse.dart` — shared `unwrapEntity` helper (TR-S1-09)
- [x] 2.3 `[MODIFY] lib/features/*/repository/*.dart` — strip bespoke sentinels and `_unwrapEntity` across 15 repos (TR-S1-10)
- [x] 2.4 `[MODIFY] verification_repository.dart`, `taxonomy_repository.dart`, `reports_repository.dart` — route through `getCollection` (TR-S1-11)
- [x] 2.5 `[NEW] test/core/api/api_envelope_normalization_test.dart` — envelope regression tests (TR-S1-12)
- [x] 2.6 Phase 2 verification (`flutter test test/core/api`)

## Phase 3 — The List Kernel
- [ ] 3.1 `[NEW] lib/core/list/paginated.dart` — `Paginated<T>` envelope with `hasMore` getter (TR-S1-13)
- [ ] 3.2 `[NEW] lib/core/list/list_state.dart` — sealed `CursorListState<T>` (TR-S1-14)
- [ ] 3.3 `[NEW] lib/core/list/cursor_paginated_notifier.dart` — kernel notifier with limit <= 100, dedup, cycle detection (TR-S1-15)
- [ ] 3.4 `[NEW] test/core/list/cursor_paginated_notifier_test.dart` — kernel unit tests (TR-S1-16)
- [ ] 3.5 `[MODIFY] lib/features/<f>/controller/*_list_controller.dart` — migrate 10 list features (TR-S1-17a..j)
- [ ] 3.6 Phase 3 verification (`flutter test test/core/list && flutter test test/features`)

## Phase 4 — Filter Models
- [ ] 4.1 Record filter idiom decision (@freezed value equality + default instance) (TR-S1-18)
- [ ] 4.2 `[MODIFY] lib/features/*/model/*_filters.dart` — convert 11 filter models to value equality (TR-S1-19a..k)
- [ ] 4.3 `[NEW] test/core/list/filter_rebuild_skip_test.dart` — rebuild-skip check (TR-S1-20)
- [ ] 4.4 Phase 4 verification (`flutter test`)

## Phase 5 — Query-Params Codec & URL State
- [ ] 5.1 `[NEW] lib/core/router/query_params_codec.dart` — codec interface for filters/cursor/selectedId (TR-S1-21)
- [ ] 5.2 `[MODIFY] taxonomy_query_params.dart` & `verification_query_params.dart` — fix Uri.replace clear bug (TR-S1-22, 23)
- [ ] 5.3 `[MODIFY] test/core/router/query_navigation_test.dart` — clear-semantics regression test (TR-S1-24)
- [ ] 5.4 `[MODIFY] lib/core/router/*_query_params.dart` — complete URL migration on unmigrated files (TR-S1-25a..e)
- [ ] 5.5 `[MODIFY] lib/features/<f>/presentation/*_list_screen.dart` — wire URL state for 8 remaining screens (TR-S1-26a..h)
- [ ] 5.6 Phase 5 verification (`flutter test test/core/router`)

## Phase 6 — Server-Side Filters & Access Audit
- [ ] 6.1 `[MODIFY] request_repository.dart` — push filters to API params (TR-S1-27)
- [ ] 6.2 `[MODIFY] admin_user_repository.dart` — cursor pagination (TR-S1-28)
- [ ] 6.3 Audit and remove remaining in-memory `.where()` list filtering (TR-S1-29)
- [ ] 6.4 `[MODIFY] customer_repository.dart` — customer-list access audit log (TR-S1-30)
- [ ] 6.5 `[MODIFY] docs/admin-backend-api-gaps.md` — log backend gaps (TR-S1-31)
- [ ] 6.6 Full suite verification (`flutter analyze && flutter test`)
- [ ] 6.7 Update `task-register-v1.md` with completed S1 tasks and timings
