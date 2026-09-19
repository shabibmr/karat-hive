# Karat Hive

Request-driven gold marketplace for the UAE. Customers publish Requests; Vendors submit Offers; accepting an Offer reveals identities and opens a Connection.

Three deployables over **one PostgreSQL database**:

| Path | What | Toolchain |
|---|---|---|
| `backend/` | NestJS monolith — HTTP API + workers in one binary | Node 20, npm |
| `apps/kh_mobile/karat_hive/` | Dual-mode Customer/Vendor app | Flutter (in workspace) |
| `apps/kh_admin/` | Admin Portal, Flutter Web | Flutter (**outside** workspace) |
| `packages/kh_*` | Shared Dart packages | Flutter (in workspace) |

## Dead references

`docs/` was deleted on branch `chore/remove-all-docs`. Code comments, `README.md` files and commit messages still cite `docs/Architecture-Backend.md`, `docs/Screen-API-Map.md`, ADR numbers and requirement IDs (`FR-VEN-003`, `NFR-022`, `AD-BE-07`, `CP2-F05`, `CUS-S11`, `SH-DOM-08`, …). **Nothing in the repo resolves them.** Read them as provenance markers, not as findable sources — the code is the only specification. Ask the user rather than guessing what an ID meant.

## Cross-cutting invariants

These hold on both sides of the wire; breaking one on either side breaks the other.

- **Response envelope** — every success body is `{ data, meta: { requestId, serverTime, nextCursor } }`; every error is an error envelope with a stable `ErrorCode`. Clients unwrap `data`.
- **Cursor pagination** — lists page by opaque `meta.nextCursor`, never by offset.
- **Identity masking** — Customer and Vendor identities stay masked until a Connection exists. The backend enforces this at the edge (`MaskingInterceptor`); DTOs model it by *shape* (`MaskedParty` vs `RevealedParty`), not by nulled fields.
- **Bilingual, bidirectional** — `en` + `ar` with full RTL. User-facing copy lives in ARB files; an analyzer plugin fails the build on hard-coded strings in widgets.
- **Responsive everywhere** — `kh_admin` is desktop-first, `kh_mobile` mobile-first, and both must render at every viewport. Each app has a `test/responsive/` suite; check narrow *and* wide before calling a screen done.
- **Server time** — clients trust `meta.serverTime` over the device clock for expiry countdowns.

## Flutter workspace

Root `pubspec.yaml` is a Dart pub workspace **and** holds the Melos config inline (there is no `melos.yaml`). `melos run analyze | test | gen | gen-l10n` covers `apps/kh_mobile/karat_hive` and all `packages/kh_*`.

`apps/kh_admin` is excluded from the workspace and resolves by path with its own `pubspec.lock`. Melos scripts skip it — run `flutter analyze` / `flutter test` from inside `apps/kh_admin/` as well, the way CI does.

Analyzer plugins may only be declared in the **workspace-root** `analysis_options.yaml`; nested packages `include:` `tooling/analysis_options.yaml` instead. Declaring a plugin in a nested file silently does nothing.

Use `dart analyze` (not `flutter analyze`) inside the workspace so the root plugin loads.

## Directory-local guidance

Each deployable and package has its own `CLAUDE.md` with conventions that apply only there.
