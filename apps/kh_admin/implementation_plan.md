# Implementation Plan — Workstream S1 · List-Data Spine

**Goal:** Collapse the forked data layer, the two list-controller families, and missing URL state into one shared, robust kernel.
**Specification:** `apps/kh_admin/docs/workstreams/task-register-v1.md` (§S1) & `apps/kh_admin/docs/workstreams/s1-list-data-spine-v1.md`.
**Verification Command:** `cd apps/kh_admin && flutter analyze && flutter test`

---

## High-Level Architecture & Phase Breakdown

```
Phase 1: Rejoin Package Graph
  ├── TR-S1-04: Replace ApiException fork with kh_core Failure adapter (<=20 lines)
  ├── TR-S1-05: Replace token-storage fork with kh_core TokenStorage & DateTime expiries
  └── TR-S1-07: MaskedParty / RevealedParty types for OfferParentRequestSummary

Phase 2: Normalise API Envelopes
  ├── TR-S1-08: Centrally unwrap double-wrapped responses ({ data: { data: ... } }) in ApiClient._send
  ├── TR-S1-09: Shared unwrapEntity helper in lib/core/api/json_parse.dart
  ├── TR-S1-10a..o: Strip bespoke sentinel fields & manual flattening from all 15 repositories
  ├── TR-S1-11: Route bypassing repositories (verification, taxonomy, reports) through getCollection
  └── TR-S1-12: Envelope regression tests (single entity, list, double-wrap, nested entities)

Phase 3: The List Kernel
  ├── TR-S1-13: Unified Paginated<T> envelope replacing 11 XxxListPage DTOs (hasMore getter)
  ├── TR-S1-14: Sealed / exclusive ListState<T> where (loading && error) is unrepresentable
  ├── TR-S1-15: CursorPaginatedNotifier<TItem, TFilters> with limit <= 100, dedup, cycle detection
  ├── TR-S1-16: Kernel exclusive-state and transition unit tests
  └── TR-S1-17a..j: Migrate all 10 list features (Vendors, Requests, Offers, Customers, Connections, Audit, Abuse, Moderation, Announcements, Admin Users)

Phase 4: Filter Models
  ├── TR-S1-18: Standardize on @freezed filter models with value-equality and clean clear() semantics
  ├── TR-S1-19a..k: Convert all 11 filter models to @freezed with == / hashCode
  └── TR-S1-20: Rebuild-skip test verifying identical filter instances do not retrigger fetches

Phase 5: Query-Params Codec & URL State
  ├── TR-S1-21: QueryParamsCodec<T> for round-tripping filters, cursor, and selectedId
  ├── TR-S1-22 & 23: Fix Uri.replace query parameter clearing bug in taxonomy & verification
  ├── TR-S1-24: Clear-semantics regression tests in query_navigation_test.dart
  ├── TR-S1-25a..e: Finish URL migration on unmigrated query params classes
  └── TR-S1-26a..h: Wire URL state into the 8 list screens currently lacking deep-linking

Phase 6: Server-Side Filters & Access Audit
  ├── TR-S1-27: Push request-list filters to API (stop client-side post-fetch filtering)
  ├── TR-S1-28: Add cursor pagination to AdminUserRepository
  ├── TR-S1-29: Audit and remove all remaining client-side .where() post-fetch filters
  ├── TR-S1-30: Add customer-list access audit log call on customer list load
  └── TR-S1-31: Log any unsupported filter parameters into docs/admin-backend-api-gaps.md
```

---

## Detailed File Changes by Phase

### Phase 1 — Rejoin the Package Graph

#### `[MODIFY] lib/core/api/api_exception.dart` (TR-S1-04)
- Turn `ApiException` into a thin <=20-line adapter around `package:kh_core/kh_core.dart`'s `Failure`.
- Preserve `statusCode`, `code`, `message`, `details`, `requestId` getters for call site compatibility.
- Expose `Failure toFailure()`.

#### `[MODIFY] lib/core/auth/auth_models.dart` & `[MODIFY] lib/core/auth/token_storage.dart` (TR-S1-05)
- Update `SessionTokens` so `accessExpiresAt` and `refreshExpiresAt` are typed `DateTime` (parsed in `fromJson`, serialized to ISO 8601 in `toJson`).
- In `TokenStorage`, delegate to `kh_core.TokenStorage` (or adopt its storage keys `kh.access`, `kh.refresh`, `kh.access_exp`, `kh.refresh_exp`), removing manual string storage.

#### `[MODIFY] lib/features/offers/model/offer_detail.dart` & `[MODIFY] lib/features/offers/presentation/offer_detail_screen.dart` (TR-S1-07)
- Import `package:kh_domain/kh_domain.dart` (`Party`, `MaskedParty`, `RevealedParty`).
- Replace bare `customerName`, `customerMobile`, `customerEmail` strings in `OfferParentRequestSummary` with `Party? customer`.
- In `offer_detail_screen.dart:528`, conditionally show customer contact info only when `request.customer is RevealedParty`.

---

### Phase 2 — Normalise the Envelope Once

#### `[MODIFY] lib/core/api/api_client.dart` (TR-S1-08)
- In `_send()`, detect double-wrapped responses (`body['data'] is Map && body['data'].containsKey('data')`) and unwrap `body['data']['data']` centrally.

#### `[MODIFY] lib/core/api/json_parse.dart` (TR-S1-09)
- Add top-level helper `Map<String, dynamic> unwrapEntity(dynamic response)` that handles:
  - Raw map with entity keys
  - Single-wrapped `{ data: { ... } }`
  - Double-wrapped `{ data: { data: { ... } } }`
- Throws clear `FormatException` if empty or not an object map.

#### `[MODIFY] lib/features/*/repository/*.dart` (TR-S1-10a..o)
- Sweep 15 repositories:
  - `announcements/repository/announcement_repository.dart`
  - `admin_users/repository/admin_user_repository.dart`
  - `settings/repository/platform_settings_repository.dart`
  - `reports/repository/reports_repository.dart`
  - `vendors/repository/vendor_repository.dart`
  - `customers/repository/customer_repository.dart`
  - `requests/repository/request_repository.dart`
  - `offers/repository/offer_repository.dart`
  - `connections/repository/connection_repository.dart`
  - `audit/repository/audit_repository.dart`
  - `abuse/repository/abuse_repository.dart`
  - `moderation/repository/moderation_repository.dart`
  - `verification/repository/verification_repository.dart`
  - `taxonomy/repository/taxonomy_repository.dart`
  - `dashboard/repository/dashboard_repository.dart`
- Delete bespoke `_unwrapEntity` implementations and sentinel heuristics (`id`/`profile`/`titleEn`/`key`/`name`); replace with `unwrapEntity(response)`.

#### `[MODIFY] verification_repository.dart`, `taxonomy_repository.dart`, `reports_repository.dart` (TR-S1-11)
- Route list calls through `ApiClient.getCollection` rather than raw `ApiClient.get`.

#### `[NEW] test/core/api/api_envelope_normalization_test.dart` (TR-S1-12)
- Unit tests verifying:
  - Single-wrapped `{ data: { id: "1" } }`
  - Double-wrapped `{ data: { data: { id: "1" } } }`
  - Double-wrapped collections `{ data: { data: [...], nextCursor: "c1" } }`
  - Unwrapping returns standard entity and list payloads without repo-specific code.

---

### Phase 3 — The List Kernel

#### `[NEW] lib/core/list/paginated.dart` (TR-S1-13)
- Define generic `Paginated<T>`:
  - `final List<T> items`
  - `final String? nextCursor`
  - `final int? totalCount`
  - `bool get hasMore => nextCursor != null && nextCursor!.trim().isNotEmpty;`
  - `const Paginated.empty()` constructor

#### `[NEW] lib/core/list/list_state.dart` (TR-S1-14)
- Define sealed `CursorListState<T>` (or `AsyncValue<Paginated<T>>` with strict state transitions) where `loading && error` is unrepresentable.
- States:
  - `CursorListInitial<T>`
  - `CursorListLoading<T>`
  - `CursorListLoaded<T>` (items, nextCursor, hasMore, isLoadingMore, loadMoreError)
  - `CursorListError<T>` (error, message)

#### `[NEW] lib/core/list/cursor_paginated_notifier.dart` (TR-S1-15)
- Abstract notifier base class / family notifier:
  - `limit` enforced to `<= 100`.
  - Dedup by key (using `itemKey` extractor).
  - Cursor cycle detection (tracked `visitedCursors` set).
  - Methods: `loadInitial()`, `nextPage()`, `applyFilters(TFilters filters)`, `refresh()`, `retry()`.
  - Direct integration with `TR-S0-19` error mapping helper (`resolveApiErrorMessage`).

#### `[NEW] test/core/list/cursor_paginated_notifier_test.dart` (TR-S1-16)
- Test full lifecycle: initial -> loading -> loaded -> load next page -> error on next page -> retry -> loaded.
- Verify cursor cycle detection halts pagination without crashing.
- Verify deduplication by ID.

#### `[MODIFY] lib/features/<feature>/controller/*_list_controller.dart` & `model/*_page.dart` (TR-S1-17a..j)
- Migrate 10 list features:
  1. `vendors`: `vendor_list_controller.dart`
  2. `requests`: `request_list_controller.dart`
  3. `offers`: `offer_list_controller.dart`
  4. `customers`: `customer_list_controller.dart`
  5. `connections`: `connection_list_controller.dart`
  6. `audit`: `audit_controller.dart`
  7. `abuse`: `abuse_controller.dart`
  8. `moderation`: `moderation_controller.dart`
  9. `announcements`: `announcements_controller.dart`
  10. `admin_users`: `admin_user_controller.dart`
- Replace per-feature `*ListPage` with `Paginated<T>` (using typedefs where helpful for backward compatibility).
- Re-express controllers onto `CursorPaginatedNotifier`.

---

### Phase 4 — Filter Models

#### Decision (TR-S1-18)
- Standardize all filter models on `@freezed` (or immutable classes with explicit `==` and `hashCode`) with:
  - Default empty constructor (e.g. `const VendorListFilters()`).
  - Pure `isEmpty` getter.
  - Consistent `clear()` or copy reset behavior.

#### `[MODIFY] lib/features/*/model/*_filters.dart` (TR-S1-19a..k)
- Update 11 filter models:
  - `vendors/model/vendor_list_filters.dart`
  - `requests/model/request_list_filters.dart`
  - `offers/model/offer_list_filters.dart`
  - `customers/model/customer_list_filters.dart` (remove `T? Function()?` closure pattern)
  - `connections/model/connection_list_filters.dart`
  - `audit/model/audit_filters.dart`
  - `abuse/model/abuse_filters.dart` (add `==` / `hashCode`)
  - `moderation/model/moderation_filters.dart` (add `==` / `hashCode`)
  - `announcements/model/announcement_filters.dart` (add `==` / `hashCode`)
  - `admin_users/model/admin_user_filters.dart` (add `==` / `hashCode`)
  - `reports/model/report_filters.dart` (add `==` / `hashCode`)

#### `[NEW] test/core/list/filter_rebuild_skip_test.dart` (TR-S1-20)
- Unit test ensuring equal filter objects don't trigger refetches or duplicate state notifications.

---

### Phase 5 — Query-Params Codec & URL State

#### `[NEW] lib/core/router/query_params_codec.dart` (TR-S1-21)
- Abstract interface:
  ```dart
  abstract class QueryParamsCodec<TFilters> {
    Map<String, String> toQueryParams({
      required TFilters filters,
      String? cursor,
      String? selectedId,
    });
    ({TFilters filters, String? cursor, String? selectedId}) fromQueryParams(
      Map<String, String> params,
    );
  }
  ```
- Integrates `applyQueryParameters` & `stringMapsEqual` from `query_navigation.dart`.

#### `[MODIFY] lib/core/router/taxonomy_query_params.dart` & `verification_query_params.dart` (TR-S1-22, TR-S1-23)
- Fix `Uri.replace` so `const <String, String>{}` is passed instead of `null`, correctly clearing URL query when last filter is deselected.

#### `[MODIFY] test/core/router/query_navigation_test.dart` (TR-S1-24)
- Regression test for clear-semantics: verify filtering -> clearing empties the query string.

#### `[MODIFY] lib/core/router/*_query_params.dart` (TR-S1-25a..e)
- Migrate existing `vendor`, `request`, `offer` query param helpers to use `QueryParamsCodec` and `applyQueryParameters`.

#### `[MODIFY] lib/features/<f>/presentation/*_list_screen.dart` & `[NEW] lib/core/router/*_query_params.dart` (TR-S1-26a..h)
- Wire URL state for the 8 list screens:
  - `customers`, `connections`, `audit`, `abuse`, `moderation`, `announcements`, `admin_users`, and `reports`.

---

### Phase 6 — Server-Side Filters & Access Audit

#### `[MODIFY] lib/features/requests/repository/request_repository.dart` (TR-S1-27)
- Forward filters (`state`, `category`, `budget`, etc.) directly as query parameters to `GET /v1/admin/requests`; remove post-fetch `.where()` filtering.

#### `[MODIFY] lib/features/admin_users/repository/admin_user_repository.dart` (TR-S1-28)
- Accept `cursor` and `limit` parameters; paginate admin users instead of downloading whole directory.

#### `[MODIFY] lib/features/*/repository/*.dart` (TR-S1-29)
- Audit and eliminate any remaining client-side `.where()` filtering on fetched collections.

#### `[MODIFY] lib/features/customers/repository/customer_repository.dart` (TR-S1-30)
- Add access audit logging call on customer list access (matching detail view audit requirements).

#### `[MODIFY] docs/admin-backend-api-gaps.md` (TR-S1-31)
- Document any backend filter parameters that cannot yet be processed by the API.

---

## Verification & Validation Strategy

1. **Unit Test Coverage**:
   - `test/core/api/api_envelope_normalization_test.dart` (TR-S1-12)
   - `test/core/list/cursor_paginated_notifier_test.dart` (TR-S1-16)
   - `test/core/list/filter_rebuild_skip_test.dart` (TR-S1-20)
   - `test/core/router/query_navigation_test.dart` (TR-S1-24)
2. **Feature Regression Suites**:
   - Run feature-specific test suites for all 10 migrated list features.
3. **Full Workspace Gate**:
   - `flutter analyze`: clean for strict analyzer rules and custom lints.
   - `flutter test`: all 465+ tests green.
