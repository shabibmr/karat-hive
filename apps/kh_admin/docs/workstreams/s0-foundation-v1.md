# S0 · Foundation

> Work order derived from [`../comprehensive-review.md`](../comprehensive-review.md) §3. Line numbers are HEAD `8880298` artefacts — use IDs to re-find.

| | |
|---|---|
| **Goal** | Land the shared primitives and analyzer strictness every other stream depends on. |
| **Owner** | 1 agent, ~2 PRs, internally ordered. |
| **Parallelism** | None — serialize. This is wave 0. |
| **Depends on** | — |
| **Blocks** | S1, S2, S3, S4, S5, S6 |
| **Owns** | `analysis_options.yaml`, all `lib/**` import statements, new `lib/core/error/`, new `lib/core/log/`, `main.dart` (error-hook insertion only), `lib/core/api/api_client.dart` (`serverTime` capture only) |
| **Do not touch** | list controllers/repositories (S1), feature presentation (S2/S5), `app_router.dart` (S4) |

## PR 1 — analyzer + imports (mechanical, land first)

### E10 + `ADM-SMP-33` — strict analyzer + `riverpod_lint`
- **Now:** stock `flutter_lints` with `invalid_annotation_target: ignore` and `unused_element: ignore`. `custom_lint` / `riverpod_lint` in `dev_dependencies` but not enabled. `unused_element: ignore` hid the dead Firestore service.
- **Do:** copy the mobile package's stricter `analysis_options.yaml` as the baseline — `strict-casts`, `strict-inference`, `strict-raw-types`, `always_use_package_imports`, `unawaited_futures`, `avoid_catches_without_on_clauses`, explicit `prefer_final_locals`, hardcoded-string / no-`DateTime.now()` lints, `custom_lint` plugin. Remove `unused_element: ignore`. Turn on one rule group per follow-up PR so the first strict pass is reviewable.
- **Done when:** `custom_lint` + `riverpod_lint` run in `flutter analyze`; `strict-casts` on; new lints triaged (fix or explicit follow-up issue).

### E11 — `package:kh_admin` imports in `lib/`
- **Now:** tests use `package:kh_admin/…`; production uses relative imports (`ADM-INS-16`).
- **Do:** convert all of `lib/` to `package:` imports (mechanical).
- **Done when:** `always_use_package_imports` passes with zero suppressions.

## PR 2 — shared infra (land before S1/S2/S4 use it)

### E5 — global error hooks (`ADM-INS-12`)
- **Now:** no `FlutterError.onError`, no `PlatformDispatcher.instance.onError`, no release `ErrorWidget.builder`, no `runZonedGuarded`, no Riverpod `ProviderObserver`.
- **Do:** install all of the above in `main()`. Log (redacted, via the S0 logger) and show an `ErrorWidget` with a retry, not the red screen. Add a `ProviderObserver` that reports to the logger.
- **Done when:** an uncaught exception in a screen shows the retry widget and a redacted log line, not a crash.

### E6 — redacting logger (`ADM-INS-10`)
- **Now:** logs do not mask PII/tokens; FCM and Google sign-in `debugPrint` raw payloads.
- **Do:** `lib/core/log/` logger that redacts `Authorization`, emails, mobiles. Delete payload `debugPrint` in the Firebase / Google sign-in paths.
- **Done when:** grep for `debugPrint(` in `lib/` shows no payload/token/PII arguments.

### E3 (helper only) — `ApiException` → `error.code` catalogue (`ADM-INS-60`)
- **Now:** login maps `ApiException` codes to ARB strings (best error UX in the app); list controllers do `e.toString()`.
- **Do:** extract login's mapping into one helper (`lib/core/error/api_error_messages.dart`) that every controller can call. Refactor login to consume it as the reference.
- **Done when:** helper exists + unit tested; login unchanged in behaviour. *Call-site adoption in list/detail/feature controllers is S1/S2/S6.*

### E16 (infra only) — `serverTime` + injected clock (`ADM-INS-07`)
- **Now:** `DateTime.now()` used as parse fallback / age basis (verification wait hours, vendor licence expiry, audit range) — device clock, not `meta.serverTime`.
- **Do:** `ApiClient` captures `meta.serverTime` from every envelope and exposes it; add an overridable `Clock` provider.
- **Done when:** `serverTime` reachable from a provider; `Clock` overridable in `ProviderScope` for tests. *Consumer migration is S5.*

## Verification
`cd apps/kh_admin && flutter analyze && flutter test` — analyze may surface new strict-lint work (expected; triage), tests stay green (352 baseline).
