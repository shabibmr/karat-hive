# S4 · App-shell / bootstrap / platform

> Work order derived from [`../comprehensive-review.md`](../comprehensive-review.md) §3.3.1/§3.3.8/§3.3.9/§3.3.10/§3.3.11/§3.3.12 and §4.4. Line numbers are HEAD `8880298` artefacts.

| | |
|---|---|
| **Goal** | Own the `main.dart` / router / `pubspec.yaml` hot spot: token policy, session, Firebase, bundle, flavours, routes. |
| **Owner** | 1 agent. |
| **Parallelism** | Runs alongside S1/S2/S3 which do not touch these files. |
| **Depends on** | S0 (`main.dart` error hooks merged first); S1 (`pubspec.yaml` `path:` deps merged first). |
| **Blocks** | — |
| **Owns** | `main.dart` (post-S0), `app_router.dart`, `apps/kh_admin/pubspec.yaml` (post-S1), `lib/core/auth/`, `web/`, `lib/core/platform/` |
| **Do not** | implement ADM-S20 gold rates; add a Role selector for `FR-ADM-002` |

## `E1` / `ADM-INS-09` — web token policy
- **Now:** the same `FlutterSecureStorage()` on every platform — no `kIsWeb` branch, no `WebOptions`; the web backend is localStorage. Architecture-Frontend §18.1 wants the access token **in memory only**.
- **Do:** on `kIsWeb`, keep the access token in memory only, do not persist the refresh token, re-auth on reload.
- **Done when:** dev-tools shows no token in web storage; a reload triggers silent re-auth or the login screen.

## `E2` / `ADM-INS-30` — idle timeout
- **Now:** no 60-minute idle timeout + warning (`FR-ADM-001` AC4).
- **Do:** idle timer + warning dialog; activity listener on pointer/keyboard resets it.
- **Done when:** 60 min idle → warning → logout; activity resets the clock.

## `E7` / `ADM-INS-31` / `ADM-INS-45` — password login gated
- **Now:** `loginWithPassword` + an email/password form still on ADM-S01; `adr/0010` is Google-only. `DevAuthConfig` default `'AdminSecret123!'` sits in source.
- **Do:** show the password form only when `KH_DEV_AUTOLOGIN` is set; the production path is Google Sign-In. Remove the seed password default (or move it behind the same define).
- **Done when:** a prod-flavour build shows only "Sign in with Google".

## `E8` / `ADM-SMP-31` / `ADM-INS-21` / `ADM-INS-51` — gold-rate + empty shells
- **Now:** `lib/features/gold_rate/{controller,model,presentation,repository}/` and `lib/features/auth/{controller,model,repository}/` are `.gitkeep`-only shells; nav registers `/gold-rates` as a placeholder. ADM-S20 is deferred (Yahoo Finance terms). (Nav liveness is already single-sourced on `isLive` — `ADM-SMP-32`/`60` FIXED.)
- **Do:** hide or remove the Gold Rates nav entry until ADM-S20; delete the empty feature dirs (**planning decision — confirm first**).
- **Done when:** no placeholder screen reachable; `lib/features/` has no `.gitkeep`-only dirs.

## `E23` / `ADM-SMP-45` / `ADM-INS-37` / `ADM-INS-41` / `ADM-INS-42` — bundle
- **Now:** `app_router.dart` eager-imports every screen incl. `fl_chart` via reports (`report_chart.dart:1`); no `deferred as`. `pubspec.yaml` pulls `cloud_firestore` (service deleted in Tier-0 as `ADM-SMP-30`; package may remain), `firebase_messaging`, `firebase_analytics`; `FirebaseAnalyticsObserver` / `getObserver()` never attached to `GoRouter`; `cupertino_icons` unused on a web canvas. Firestore contradicts `C-12` / `AD-FE-09` (no secondary datastore).
- **Do:** `deferred as` for `reports`, `audit`, `announcements`. Drop `cloud_firestore`, `firebase_analytics`, `cupertino_icons` from `pubspec.yaml`. Keep `firebase_messaging` (S4 wires it — see `E27`) or drop it if `E27` chooses polling.
- **Done when:** `flutter build web` no longer bundles `fl_chart` in the main chunk; unused Firebase packages gone.

## `E26` / `ADM-INS-81` / `ADM-INS-82` — flavours
- **Now:** no flavour-specific provider graph (`dev` / `staging` / `prod`); default `KH_API_BASE` is `http://localhost:3000`; no prod check that the base is `https://`; no contract-version / 426 screen.
- **Do:** flavours via `--dart-define-from-file` (already the Architecture-Frontend rule). Prod flavour refuses a non-HTTPS base. Add a contract-version mismatch / 426 screen.
- **Done when:** `prod` build against an `http://` base fails fast with a clear message.

## `E27` / `ADM-INS-08` / `ADM-SMP-46` / `ADM-INS-86` — FCM + Firebase init
- **Now:** the FCM background handler is registered in `main()`; `initializeForegroundHandler` is **never called**, so foreground messages and tap-to-invalidate never run. `Firebase.initializeApp` (`main.dart:16`) blocks the first frame; init failure is swallowed and the app runs anyway.
- **Do:** wire the FCM foreground handler (or a 30 s poll) to invalidate list providers — **coordinate provider names with S1**. Make `Firebase.initializeApp` non-blocking; fail **closed** if Google Sign-In is the only production login.
- **Done when:** a push (or the poll) refreshes an open list; a Firebase init failure blocks login instead of silently continuing.

## Routing — `ADM-INS-04` / `ADM-INS-33`
- **Now:** route paths are magic strings duplicated in `kAdminNavItems` and the `GoRoute` table (`'/vendors'`, `'/requests'`); `state.pathParameters['id'] ?? ''` still builds a detail screen with an empty id.
- **Do:** an `AdminRoutes` constants class; reject an empty `:id` (redirect to the list). Typed-routes package can wait.
- **Done when:** no literal route string outside `AdminRoutes`; `/vendors//` style URLs don't render a broken detail.

## Platform cleanup — `ADM-INS-17`, `dart:html`
- `dart:html` in `open_url_web.dart` → `package:web` (or `url_launcher`) — clears `avoid_web_libraries_in_flutter` + `deprecated_member_use`.
- Multi-tab logout not observed until 401 (`ADM-INS-85`) — broadcast logout across tabs.

## Verification
`flutter analyze && flutter test`; `flutter build web` for `dev` and `prod` flavours; confirm token absence in web storage, idle logout, Google-only prod login, deferred chunks in the build output.
