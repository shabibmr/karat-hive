# kh_admin

Platform Admin Portal, Flutter **Web**, desktop-first. Riverpod + go_router + Dio.

## Self-contained by design

`kh_admin` sits **outside** the Dart pub workspace: its own `pubspec.lock`, its own analyzer config (`custom_lint`, `strict-inference`, `avoid_catches_without_on_clauses`, `prefer_final_locals`), its own `lib/l10n/` ARB files and `l10n.yaml`. Melos scripts do not reach it — run `flutter pub get` / `flutter analyze` / `flutter test` from this directory, as the `admin` CI job does.

It declares the `kh_*` packages as dependencies but barely uses them: `Failure` and `TokenStorage` from `kh_core`, `KhStatusTone` from `kh_design_system`, the party/masking types from `kh_domain`. Everything else is local — **`core/api/api_client.dart` is the admin's own client, not `kh_core`'s `KhApiClient`**, and models live per feature under `features/<f>/model/` rather than in `kh_api`. Follow the local pattern; reaching for a shared package here is the exception, not the default.

`always_use_package_imports` is **on** — import as `package:kh_admin/…`, including within `lib/`. (The mobile app is the opposite; don't carry its style over.)

## Feature shape

```
features/<feature>/
  controller/      Riverpod notifiers
  model/           freezed/json models + filter objects + enums
  presentation/    screens, plus widgets/
  repository/      calls ApiClient
```

Roughly one feature per admin surface: vendors, customers, requests, offers, connections, moderation, abuse, verification, taxonomy, audit, reports, announcements, admin_users, contract_version, settings, dashboard, auth.

## URL is the state

Every list screen round-trips its filters, cursor and selection through the browser URL, so a pasted link reproduces the view. `core/router/` holds one `*_query_params.dart` codec per feature plus the generic `ListUrlState` / `query_navigation.dart`. Adding a filter means extending that feature's codec — not holding it in controller state only.

Pair it with `core/list/`: `Paginated<T>` (items + `nextCursor`, `hasMore` derived from the cursor) and `CursorPaginatedNotifier`. Lists are cursor-paged; there is no page-number API.

`core/widgets/debounced_search_mixin.dart` is the shared search-input debounce.

## Web-only concerns

- **Multi-tab auth** — `core/auth/auth_broadcast.dart` conditionally imports the web BroadcastChannel implementation (`dart.library.js_interop`) or a stub. Sign-out in one tab propagates. Keep the stub compiling when you touch the interface.
- **Idle timeout** — `core/auth/idle_timeout.dart` ends admin sessions on inactivity.
- **Flavor** — `AppFlavor` plus `KH_API_BASE` via `--dart-define`; default base is `https://algoray.cloud/kh_api`.

## Backend shape

Admin routes are served by `backend/src/modules/admin/`. Several return comparatively raw rows, so admin models often parse shapes with no DTO counterpart in `kh_api` — `core/api/json_parse.dart` is the tolerant-parsing helper. Check the controller in `backend/src/modules/admin/controller/` before assuming a field exists.

## Tests

`test/` mirrors `lib/`, with `test/responsive/admin_responsive_test.dart` asserting layouts across viewports. Desktop-first does not mean desktop-only — the portal must still render narrow.
