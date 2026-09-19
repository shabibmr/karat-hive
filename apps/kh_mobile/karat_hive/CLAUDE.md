# karat_hive (mobile)

One Flutter binary that is **both** the Customer and the Vendor app. The signed-in account's role picks the shell; there is no separate vendor build.

Riverpod for state, go_router for navigation, Firebase for auth/push/analytics, `kh_*` packages for everything shared.

## Shells and guards

`app/router.dart` swaps between `app/shells/`: `splash` → `unauth` → `customer` | `vendor` | `awaiting_approval` (vendor pending KYC approval).

`app/guards.dart` holds every route constant and the redirect rules. It is a **usability mirror of the server's rules, never a security boundary** — the backend re-checks. Add a route constant there rather than inlining a path string.

**Guest-first.** A signed-out user lands on `/customer/guest` and may walk the whole create-request wizard (`/customer/requests/create…`) without a token; publishing is what gates login. Code in the create flow must tolerate a null session — the pending-publish intent is stashed and replayed after sign-in.

## Feature shape

```
features/<feature>/
  controller/      Riverpod notifiers + state
  presentation/    screens, plus widgets/
  repository/      calls kh_api, returns Result
  routes.dart      the GoRoute list this feature contributes
```

Features are split by audience where the surfaces diverge (`offers_customer` / `offers_vendor`, `connections` / `connections_customer`).

`app/di.dart` is the composition root: `envProvider`, `tokenStorageProvider`, `serverClockProvider`, `apiClientProvider`, `khApiProvider`. Reach the API through `ref.watch(khApiProvider)`; construct `KhApiClient` nowhere else.

**Domain calls carry the Karat Hive access token, not the Firebase ID token.** Firebase sign-in is exchanged for a session bundle once, at auth time.

## Imports

`lib/` uses **relative** imports and `always_use_package_imports` is deliberately disabled for this app. Match the surrounding file; converting a file to `package:karat_hive/…` is churn, not a cleanup.

`package:` imports are still correct for the `kh_*` packages.

## Flavors

`main_dev.dart` / `main_staging.dart` / `main_prod.dart` all call `bootstrap()`; the difference is the dart-define file:

```
flutter run --dart-define-from-file=config/dev.json
```

`run_android`, `run_chrome`, `run_webserver`, `build_web` exist as both `.sh` and `.ps1` — use them rather than retyping the defines.

**`bootstrap()` may override the API base URL at runtime.** It reads a per-flavor URL from Firestore and falls back to `KH_API_BASE_URL` from the define only when that lookup is empty or fails. A request going somewhere unexpected is usually this, not the config file.

## Tests

`test/` mirrors `lib/` (`test/features/…`, `test/app/…`). `test/helpers/` holds the session and converter fakes — reuse `fake_session.dart` instead of hand-rolling a signed-in state. `test/responsive/` asserts the layouts at narrow and wide; a new screen belongs in it.

Run with `melos run test` from the repo root, or `flutter test` here.
