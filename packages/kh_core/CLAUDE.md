# kh_core

Foundations every client layer sits on: `Result`/`Failure`, `Env`, `ServerClock`, `TokenStorage`, `AppLogger`, `PagedListController`, and `KhApiClient`.

Depends on Flutter + Dio + secure storage and **nothing else in this repo**. It is the bottom of the dependency graph — a `kh_domain` or `kh_api` import here is a cycle.

## KhApiClient

The Dio wrapper that implements the whole interceptor chain in one place: correlation id, bearer auth with **single-flight** refresh, locale header, idempotency key, `meta.serverTime` capture, and envelope → `Failure` mapping.

Calls return the unwrapped `data` payload as a `Result`; `KhListPayload` carries a list page's items plus `meta.nextCursor`. `validateStatus` is permissive on purpose — HTTP status is turned into a `Failure`, not thrown.

`ServerClock` exists because expiry countdowns must follow server time rather than the device clock.

## Result

`Result<T>` is `Ok`/`Err` with `when(ok:, err:)`. Repositories return it; they do not throw for expected failures. Map a `Failure` to copy at the UI edge (`kh_l10n`), not here — this package holds no user-facing strings.

`kh_admin` uses only `Failure` and `TokenStorage` from here; it has its own client. Changing `KhApiClient` affects the mobile app; changing `Failure` affects both.

Add a new export to `lib/kh_core.dart`.
