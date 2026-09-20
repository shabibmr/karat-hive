# kh_admin — Runtime failure modes & structural risk review

**Date:** 2026-03-20 (remediation applied same session)  
**Scope:** `apps/kh_admin` (whole app, not a single PR)  
**Lens:** Strict maintainability + what the portal can fall into at runtime  
**Status:** Findings below were **fixed in code** (see remediation notes). Re-verify with full suite + manual web smoke before release.

This review prioritizes failure modes admins will hit, then the structural patterns that multiply them. Evidence paths are relative to `apps/kh_admin/`.

---

## Priority order

1. Structural regressions / whole-class failure modes  
2. Missed code-judo simplifications that delete complexity  
3. Spaghetti / branching that amplifies bugs  
4. Boundary / type-contract problems  
5. File-size / copy-paste amplification  

---

## Blockers

### B1 — Concurrent Google session sync can wipe a good login

**Evidence:** `lib/core/auth/session_controller.dart`  
- Firebase `authStateChanges` calls `_syncFirebaseUser` unawaited.  
- `loginWithGoogle` / `loginWithGoogleIdToken` also `await _syncFirebaseUser`.  
- Failure path always `clearTokens()` + Firebase `signOut()`.

**Failure mode:** Two exchanges race; the loser signs out Firebase and clears KH tokens after the winner succeeded → admin lands on login with “not linked” / empty session.

**Fix / judo:** Single-flight sync mutex (same shape as `_refreshCompleter`). Listener should no-op when already authenticated for the same uid; drive bootstrap from “Firebase ready + explicit login”, not dual uncoordinated paths.

---

### B2 — KYC document “Open” cannot authenticate in a new tab

**Evidence:** `lib/features/verification/controller/verification_controller.dart` (`_resolveDocumentUrl`, comments), `verification_detail_pane.dart` → `openUrlInNewTab`, `verification_repository.dart` `fetchDocumentUrl`.

Backend returns a relative `/v1/media/<key>` path. The client prefixes `khApiBase` and opens a new tab. Bearer auth cannot ride along.

**Failure mode:** Admin cannot view trade licence / Emirates ID; verification proceeds blind. Code already admits this is unfinished.

**Fix:** Time-limited signed absolute URL (or in-app blob fetch with bearer). Until then, disable Open and show an explicit “preview unavailable” state — do not pretend the tab works.

---

## High

### H1 — Auth stream subscribed before Firebase init (silent restore dead)

**Evidence:** `lib/main.dart` (Firebase post-frame), `session_controller.dart` constructor → `_initAuthListener` + `init()`, `firebase_auth_service.dart` (`_auth == null` → `Stream.empty()`).

**Failure mode:** On web reload, Firebase may restore the Google user after `initializeApp`, but SessionController already subscribed to an empty stream and never re-subscribes. Combined with in-memory-only web tokens (`token_storage.dart`), every refresh forces a full re-login.

**Fix / judo:** Gate session bootstrap on `firebaseInitStateProvider.isInitialized`, then subscribe / `init()`.

---

### H2 — Flavor / ApiClient rebuild recreates the whole session

**Evidence:**  
- `api_client.dart`: `apiClientProvider` **watches** `flavorConfigProvider`.  
- `session_controller.dart`: provider **watches** `apiClientProvider`, rebinds `onUnauthorized`.  
- `firebase_init.dart`: Firestore may mutate `flavorConfigProvider` after boot.  
- `ApiClient.updateBaseUrl` exists but is unused.

**Failure mode:** Remote base-URL sync disposes SessionController → re-`init` → loading → redirect to `/login`. Intermittent kick after first paint.

**Fix / judo:** Long-lived `ApiClient`; `ref.listen(flavorConfig, … updateBaseUrl)`. Session should `read` the client once, not `watch` it.

---

### H3 — Deep links / return URL destroyed by auth redirect

**Evidence:** `lib/core/router/app_router.dart` — loading forces `/login`; post-auth login always → dashboard. No `?from=` preservation.

**Failure mode:** Open `/vendors/<id>` or refresh a detail URL → bounce to login → always Dashboard. Bookmark workflows silently fail (worse with H1).

**Fix / judo:** While loading, keep current location (or splash). After auth, restore saved URI. Only unauthenticated users go to login with `from`.

---

### H4 — Transient API errors force logout

**Evidence:** `session_controller.dart` — any `getMe` failure → `silentRefresh`; any refresh failure → `logout()`.

**Failure mode:** Backend blip / CORS / 5xx clears the session mid-work. No distinction between expired refresh and network failure.

**Fix / judo:** Logout only on definitive auth failures (401/403 + invalid refresh). Network/5xx → keep tokens, surface retryable error.

---

### H5 — Idle timeout implemented but never mounted

**Evidence:** Full module `lib/core/auth/idle_timeout.dart`; zero usages outside that file. `KhAdminScaffold` does not wrap `IdleTimeoutListener`.

**Failure mode:** Unattended admin tab stays authenticated for full token lifetime. Dead security control.

**Fix / judo:** Mount in shell when authenticated, or delete/quarantine if deferred — do not leave a 500+ line dead path.

---

### H6 — List kernel: filter changes while load in flight → wrong rows

**Evidence:** `lib/core/list/cursor_paginated_notifier.dart`  
- `applyFilters` sets new filters then `await loadInitial()`.  
- `loadInitial` returns existing `_inFlightLoad` **without** bumping `_epoch`.  
- Stale completion can commit page A while `state.filters` is already B.

**Failure mode:** Rapid chip/search/URI sync shows wrong rows under wrong filters. Hits every `CursorPaginatedNotifier` consumer (customers, vendors, requests, offers, moderation, abuse, announcements, admin users, connections, audit).

**Fix / judo:** On filter change / refresh always `++_epoch`, abandon in-flight, start a new load keyed by filters (or compare a generation id on complete).

---

### H7 — Destructive mutations coupled to follow-up reload

**Evidence:** `customer_detail_controller.dart`, `vendor_detail_controller.dart`, `request_detail_controller.dart`, `verification_controller.dart` — `await mutation` then `await reload()` where `reload` uses `AsyncValue.guard` (does not throw).

**Failure mode:** Mutation succeeds, reload fails → full-screen AsyncError / misleading failure UX while server already applied suspend / erase / remove / verify. List providers are never invalidated → navigate back → stale row.

**Fix / judo:** Mutation response (or patched local state) is source of truth. Reload failure → “applied, refresh failed” + retry-reload only. `ref.invalidate` sibling list providers on success.

---

### H8 — Announcement compose closes on API failure (false success)

**Evidence:**  
- `announcement_controller.dart` `createAnnouncement` catches → `return false` (no throw).  
- `compose_announcement_dialog.dart` pops after `await onSubmit` unless an exception is thrown.  
- `announcements_screen.dart` returns early on `!success` (no snackbar) — dialog already closed.

**Failure mode:** Create fails → dialog dismisses → admin believes publish/schedule worked.

**Fix:** Throw (or return bool and only pop on true). Keep dialog open with error.

---

### H9 — Moderation mutations swallow errors silently

**Evidence:** `moderation_controller.dart` `catch (_) => false`; `moderation_screen.dart` SnackBar only on success.

**Failure mode:** Approve/reject/redact fails → no toast, looks like a no-op. Abuse at least shows a generic failure string.

**Fix:** Propagate `ApiException.message`; disable in-flight actions.

---

### H10 — Verification doc viewer sticks in loading on non-ApiException

**Evidence:** `VerificationDocViewController.openDocument` only `on ApiException`; repo uses `as Map<String, dynamic>` casts.

**Failure mode:** Cast/parse errors leave `loadingDocId` set → permanent spinner, no error banner.

**Fix:** `on Object catch`; clear loading; harden JSON via `asMap`.

---

## Medium

| ID | Issue | Evidence | Failure mode |
|---|---|---|---|
| M1 | Contract-mismatch Reload opens `_blank`; sticky flag traps old tab | `contract_mismatch_screen.dart`, `contractMismatchProvider` | New tab opens; original stays stuck |
| M2 | Global ErrorRetry has `onRetry: null`; platform errors return true | `main.dart`, `error_retry_widget.dart` | Retry no-ops; async errors vanish into logs |
| M3 | Mixed `loadMore` + `nextPage` on same cursor; `retry()` always `nextPage` | list screens + kernel `retry` | Append + pager diverge; retry replaces list |
| M4 | Copy-pasted search: `setSearchQuery`+`submitSearch` vs immediate `applyFilters` | many list screens/controllers | Double-fetch; amplifies H6 |
| M5 | Taxonomy “rollback” then overwritten by `AsyncValue.error` | `taxonomy_controller.dart` | Tree disappears into error instead of restored data |
| M6 | Unknown accountState defaults to Active | `customer_detail.dart`, `customer_repository.dart` | Wrong lifecycle buttons after partial/erasure payloads |
| M7 | Request remove lacks in-flight / mounted guards | `request_detail_screen.dart` | Double-submit; setState after dispose |
| M8 | Auth JSON hard casts instead of `asMap`/`unwrapEntity` | `auth_repository.dart`, `auth_models.dart` | TypeError on envelope drift |

---

## Structural code-judo (highest leverage)

| Collapse this | Into this |
|---|---|
| Firebase listener + `init` + login `_syncFirebaseUser` | One `SessionBootstrap` with mutex + Firebase-ready gate |
| `watch(apiClient)` / recreate-on-flavor | Stable client + `updateBaseUrl` |
| Loading → `/login` → always `/dashboard` | Hold URL + `from` return path |
| Any error ⇒ logout | Auth-failure vs retryable-failure at session boundary |
| Idle helper as unused 500-line module | Mount in shell or delete |
| Mutation + opaque reload + no list invalidate | Mutation-result state + explicit list invalidation |
| Per-feature silent `catch => false` | One action-result type (`success` / `failure(message)`) surfaced by UI |
| Dual pagination modes on one cursor | One UX per screen; typed retry |

Largest hand-written screens (~600–770 lines: dashboard, moderation, abuse, customer/vendor/request lists, admin users) are not blockers by size alone, but they are why H6/H8/H9/M3/M4 spread horizontally. Prefer extracting shared list chrome over growing more copies past ~800 lines.

---

## Suggested fix order

1. **B1 + H1 + H2** — session identity (mutex, Firebase-ready gate, stable ApiClient)  
2. **B2** — KYC signed URLs (or disable Open)  
3. **H3 + H4** — redirect/`from` + don’t logout on network  
4. **H5** — mount or remove idle timeout  
5. **H6** — list epoch/cancel on filter change (one kernel fix, many screens)  
6. **H7 + H8 + H9 + H10** — mutation/error contracts  
7. Medium items as follow-up  

---

## Approval bar

Presumptive blockers unmet:

- Plausible code-judo paths left on the table (session bootstrap, stable ApiClient, list epoch).  
- Feature logic / silent catches scattered across shared and feature paths.  
- Dead security control (idle) and known-broken KYC open path shipping as if live.  
- Announcement compose false-success is a concrete product bug.

Re-review after the suggested fix order (1–6) before treating the portal as release-ready.
