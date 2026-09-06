# Checkpoint-1 — First Admin Vertical: Taxonomy Management (end-to-end)

## Context

The Karat Hive Admin Portal (Flutter Web, `apps/kh_admin/hive_admin`) is a stock Flutter counter
demo — zero real code. The backend (`backend/`, NestJS 11 + Fastify + Prisma) has only the platform
spine built (P0/P1: env, envelope/error/masking interceptors, `AuthGuard`, outbox, rate-limit,
`TokenService`, `AuditWriter`). There are **no auth endpoints and no `/v1/admin/*` endpoints**, and
no OpenAPI document. Supabase project `husuemlfcvacrysapwho` has the full schema migrated but
**0 rows** — no admin user exists to log in as.

This checkpoint drives **one** admin vertical fully through every layer — Postgres → NestJS API →
hand-written Dart repo → Flutter Web screen — and stands up the minimum reusable foundation
(auth, app shell, design tokens, API client, audit-write) that every later admin screen inherits.

**Chosen vertical: Taxonomy Management — ADM-S14 (Categories) + ADM-S15 (Regions).**
Why: 2 screens driven by 1 shared widget (`SH-ADM-14` tree editor), no PII, no identity masking,
no charts, and — critically — **not blocked by `AD-FE-12`** (the data-grid build/buy decision that
gates 14 other admin screens). Pure CRUD. `Category` and `Region` are identical self-referential
2-level trees (`backend/prisma/schema.prisma:539` and `:558`), so one implementation covers both.

## Decisions locked with the user

| Topic | Decision |
|---|---|
| First vertical | Taxonomy (ADM-S14 + ADM-S15) |
| Auth scope | Originally password-only (2FA deferred). **Superseded on `main`:** product gate is Google Sign-In; backend accepts Firebase ID tokens in `AuthGuard`. Password routes remain; **TOTP 2FA still deferred** |
| API client | Hand-write typed Dart repositories in-app; **defer OpenAPI generation** (`AD-FE-06`) |
| FE structure | Build inside `apps/kh_admin/hive_admin`; **defer Melos monorepo** (`AD-FE-02`); flatten the odd nested folder |
| Backend host | Local `npm run start:dev` → existing Supabase DB; Flutter Web → `localhost:3000` |
| Seed | Real UAE taxonomy (7 emirates + areas, real 2-level gold Category tree from `CONTEXT.md`) + 1 Super Admin user |
| Spec sync | Fold in the small doc fixes (SAM-GAP-9 wording, flip built API rows, decision registers) |
| Git | One feature branch off `main`, staged commits, **draft PR** |

## Deliberate deviations from spec (tag in code + register in docs)

1. **Admin login returns `200 SessionBundle` directly** instead of `401 TWO_FACTOR_REQUIRED`
   (`API-Route-Inventory.md:826`). 2FA endpoints (`/v1/auth/admin/2fa/*`) not built this slice.
   Mark with `// [DEVIATION AD-API: 2FA deferred — checkpoint-1]` and note in the API inventory §8.
2. **No OpenAPI doc** yet → `packages/kh_api` stays empty; repos hand-written in
   `hive_admin/lib/core/api/`. Note against `AD-FE-06` in `Architecture-Frontend.md` §3.
3. **Coarse RBAC** — single admin, no role column (already the spec's `AD-API-03` position). Fine.
4. **3-strike lockout / audit-on-every-attempt** (`FR-ADM-001`): implement the audit-write on
   login attempts; implement lockout counter too (cheap, uses existing tables) — but if time-boxed,
   lockout may be deferred with a `[DEVIATION]` tag.

---

## Part A — Backend: auth + taxonomy API

Work in `backend/`. Follow existing conventions: NestJS module = `application/ controller/ domain/`,
Zod for input validation, throw `ApiException(status, ErrorCode)`, controllers return plain data
(the `EnvelopeInterceptor` wraps it), write audit rows inside a Prisma transaction via `AuditWriter`.

### A1. Identity / auth endpoints (`src/modules/identity/`)
Extend the existing module (it already has `TokenService`, `SessionQuery`, `IdentityModule`).

- **Add `PasswordHasher`** (`application/password-hasher.ts`) — add `argon2` (or `bcrypt`) to
  `backend/package.json`. `hash()` / `verify()`. Used by seed + login.
- **`AuthController`** (`src/modules/identity/controller/auth.controller.ts`), all `@Public()`:
  - `POST /v1/auth/login/password` — body `{email, password}` (Zod). Load user by email; branch on
    `userType`. `ADMIN` + valid password → issue access+refresh (`TokenService.signAccess` +
    `issueRefresh`, TTL from a new `JWT_REFRESH_TTL_SECONDS` env, default 30d) → `200 SessionBundle`.
    Bad password / unknown email → `401 UNAUTHENTICATED`. `accountState != ACTIVE` → `403 FORBIDDEN`.
    Non-admin userType for this slice → `401`. Audit every attempt (`action: "ADMIN_LOGIN"`,
    outcome in `afterValue`, `ipAddress`/`userAgent` from `client-ip.ts` / headers). Lockout:
    increment a counter (reuse `OtpChallenge`-style or a small in-module query on `audit_log`
    recent failures); ≥3 fails in 30 min → `423` (add `ACCOUNT_LOCKED` to `ErrorCode`).
  - `POST /v1/auth/refresh` — body `{refreshToken}` → `TokenService.rotateRefresh` → `200 SessionBundle`.
  - `POST /v1/auth/logout` — body `{refreshToken}` → `TokenService.revokePresented` → `204`.
- **`MeController`** (`src/modules/identity/controller/me.controller.ts`):
  - `GET /v1/me` — authenticated; build `Me` from `ViewerContext` + a `SessionQuery` load.
    Only the `admin: { displayName }` branch needs to be correct this slice.
- **Wire admin-surface guard**: extend `AuthGuard` (or add a lightweight `@AdminOnly()` decorator +
  check in the guard) so any `/v1/admin/*` route requires `viewer.role === 'ADMIN'`, else
  `404 NOT_FOUND` (per `AD-API-01`, `API-Route-Inventory.md:1665`). Register `AuthController`,
  `MeController` in `app.module.ts`.
- **`SessionBundle` / `Me` presenters** — plain TS types in `domain/`, matching
  `API-Route-Inventory.md:763` and `:904`.

### A2. Taxonomy module (`src/modules/taxonomy/`)
Currently empty `.gitkeep` dirs. Build:

- **`TaxonomyRepository`** (`repository/taxonomy.repository.ts`) — thin Prisma wrapper over
  `category` + `region` (same shape → one generic private helper parametrised by model, or two
  near-identical classes; prefer a `TaxonomyKind` enum + switch). Methods: `listTree(kind, {includeInactive})`,
  `create(kind, dto)`, `update(kind, id, dto)`, `deactivate(kind, id)`, `countReferences(kind, id)`.
  References: category → `request` + `vendor_category`; region → `request` + `vendor_region` +
  `customer_profile.defaultRegionId`.
- **`TaxonomyService`** (`application/taxonomy.service.ts`) — rules from `FR-ADM-024/025` + `BR-019`:
  - 2-level only: reject `create`/`update` that would nest under a node that itself has a parent
    → `422 VALIDATION_FAILED`.
  - `nameEn` + `nameAr` mandatory & non-blank; `displayOrder` int (category); `isActive` bool.
  - No DELETE route at all (deactivate only). If a future `delete` is attempted with references →
    `409` with new `ErrorCode.TAXONOMY_IN_USE` (add it; `API-Route-Inventory.md:560`).
  - Every mutation wrapped in `prisma.$transaction` with an `AuditWriter.append` call
    (`action: "CATEGORY_CREATE"` etc., `entityType: "category"|"region"`, before/after JSON).
- **`AdminTaxonomyController`** (`controller/admin-taxonomy.controller.ts`), `@AdminOnly()`:
  - `GET  /v1/admin/categories`            → full tree incl. inactive
  - `POST /v1/admin/categories`            → body `{parentId?, nameEn, nameAr, icon?, displayOrder, isActive}`
  - `PATCH /v1/admin/categories/{id}`      → partial
  - `POST /v1/admin/categories/{id}/deactivate`
  - identical four routes for `/v1/admin/regions` (no `icon`, no `displayOrder` in the screen spec —
    but the column exists; accept it optionally).
  - Response DTO = `CategorySummary` / `RegionSummary` (`API-Route-Inventory.md:305`).
- Register `TaxonomyModule` in `app.module.ts`.
- **Public read** (needed by seed verification / future screens, cheap): `GET /v1/categories`,
  `GET /v1/regions` (active only, `@Public()`) — `API-Route-Inventory.md:603`. Optional this slice;
  include if trivial.

### A3. Seed script (`backend/prisma/seed/`)
- Add `"seed": "tsx prisma/seed/index.ts"` (or ts-node) to `backend/package.json`; wire
  `prisma.seed` config. Idempotent (upsert on natural keys).
- **Admin user**: `user` (`userType: ADMIN`, `accountState: ACTIVE`, `email`,
  `passwordHash` via `PasswordHasher`) + `admin_profile` (`displayName: "Platform Admin"`).
  Credentials from env (`SEED_ADMIN_EMAIL`, `SEED_ADMIN_PASSWORD`) with dev defaults printed once.
- **Regions**: 7 emirates (Abu Dhabi, Dubai, Sharjah, Ajman, Umm Al Quwain, Ras Al Khaimah,
  Fujairah) each with a handful of real areas as children, EN + AR names, `displayOrder`.
- **Categories**: real 2-level gold taxonomy — top level e.g. Jewellery, Bullion / Bars, Coins,
  Scrap / Old Gold, Watches; children under each (e.g. Jewellery → Rings, Necklaces, Bangles,
  Earrings). EN + AR. (Draft list included in PR description for PO review; tagged `[ASSUMED]`.)
- **`platform_setting` defaults** from `backend/prisma/seed/README.md` table — include even though
  unused this slice; it's the documented minimum seed.
- Do **not** seed KYC bytes, customers, vendors, offers.

### A4. Backend tests (`vitest`, existing runner)
- `taxonomy.service.spec.ts` — 2-level enforcement, blank-name rejection, deactivate keeps
  associations, audit row written, `TAXONOMY_IN_USE` on referenced delete.
- `auth.controller` integration-ish — password login happy path, bad password → 401,
  non-admin `/v1/admin/*` → 404, refresh rotation.
- Keep `npm run lint` + `npm run format:check` + `npm test` green (CI `.github/workflows/backend.yml`).

---

## Part B — Frontend: kh_admin foundation + taxonomy screens

Work in `apps/kh_admin/hive_admin`. First **flatten**: this app currently sits at
`apps/kh_admin/hive_admin/` with a *second* dead `lib/features` tree at `apps/kh_admin/lib/`.
Move the real project up to `apps/kh_admin/` (or delete `apps/kh_admin/lib` + `apps/kh_admin/app`
and keep `hive_admin/` as the app root). Decide during execution; the plan assumes app root =
`apps/kh_admin/` after the move, `pubspec.yaml` `name: kh_admin`.

### B1. Dependencies (`pubspec.yaml`)
Add: `flutter_riverpod` (`AD-FE-03`), `go_router` (`AD-FE-04`), `freezed_annotation` +
`json_annotation`, `dio` (HTTP), `flutter_secure_storage` (web-safe token storage);
dev: `build_runner`, `freezed`, `json_serializable`, `riverpod_lint`/`custom_lint`.
Locale: `flutter_localizations` + `intl` (EN + AR scaffolding, `AD-FE` §55). SDK stays `^3.12.2`.

### B2. Design tokens (`lib/core/design/`)
Per design-context §51 file layout. Create `theme/kh_colors.dart`, `kh_typography.dart`,
`kh_spacing.dart`, `kh_shapes.dart`, `kh_theme.dart` — the **admin-density** variant (sapphire/gold/
cream palette from `Karat_Hive_UI_Design_Context.md` §4.1, **no gold-sweep animation**, §79–81).
Expose via a `ThemeExtension` (`context.kh.colors.goldPrimary`) so screens never hardcode `Color`.
Skip `kh_motion` decorative pieces this slice.

### B3. Core plumbing (`lib/core/`)
- `api/api_client.dart` — `dio` instance, `baseUrl` from `--dart-define=KH_API_BASE`
  (default `http://localhost:3000`), unwraps the `{data, meta}` envelope, maps error envelope →
  typed `ApiException` (code + message). Interceptor attaches `Authorization: Bearer`.
- `auth/` — `session_controller.dart` (keep-alive Riverpod notifier holding tokens + `Me` +
  `serverTime` offset, `AD-FE` §8), `auth_repository.dart` (login / refresh / logout / me against
  Part A endpoints), token persistence via `flutter_secure_storage`. 401 → auto one-shot refresh,
  else bounce to login.
- `router/app_router.dart` — `go_router`, redirect guard: unauthenticated → `/login`; authed →
  app shell. Routes: `/login`, `/` (dashboard placeholder), `/taxonomy/categories`,
  `/taxonomy/regions`. **List state (which node selected, showInactive) encoded in query params**
  from day one (`AD-FE` §16.2 — non-negotiable, cheap here).

### B4. App shell (`lib/core/shell/`) — `SH-ADM-01`
`KhAdminScaffold`: left sidebar nav (flat list, mirrors `ui-mock/js/nav.js` admin ordering — but
only Dashboard + Categories + Regions are live; rest render a "Coming soon" stub), top bar with
admin `displayName` + logout. Responsive ≥1280 (`Architecture-Frontend.md:176`); below that, drawer.

### B5. Auth screen (`lib/features/auth/presentation/login_screen.dart`) — ADM-S01 (password only)
Email + password fields, submit → `authRepository.login`. Error states: bad credentials,
locked (`ACCOUNT_LOCKED`), server down. No 2FA field this slice (note in code + screen has a
`// TODO ADM-S01 2FA`). Art-Deco framed card, but form-legible per design context §13/§104.

### B6. Taxonomy feature (`lib/features/taxonomy/`) — ADM-S14 + ADM-S15
- `model/` — `freezed` `TaxonomyNode` (`id, parentId, nameEn, nameAr, icon?, displayOrder,
  isActive, children`), request DTOs. `json_serializable` from the API shape.
- `repository/taxonomy_repository.dart` — hand-written, typed, wraps `api_client` for the 8 routes.
- `controller/taxonomy_controller.dart` — Riverpod `AsyncNotifier<List<TaxonomyNode>>` per kind
  (`family` over `TaxonomyKind`); `create/update/deactivate/reorder` mutate then invalidate
  (`AD-FE-09` — in-memory, explicit invalidation, no local DB).
- `presentation/`:
  - `taxonomy_screen.dart` — shared, parametrised by `TaxonomyKind` → both `/taxonomy/categories`
    and `/taxonomy/regions` render from it (mirrors the backend's single implementation).
  - `taxonomy_tree.dart` — `SH-ADM-14`: 2-level expandable tree, inactive rows dimmed +
    "Inactive" text chip (never colour-only, design §40/§56), show/hide-inactive toggle.
  - `node_editor_panel.dart` — `SH-ADM-08`-ish side panel: EN + AR name (RTL-aware AR field),
    icon (category only), display order, active toggle; Create / Rename / Deactivate actions.
    Deactivate → `SH-FND-15` confirm dialog; "Delete" wording is **not** shown (SAM-GAP-9 fix).
  - Empty state (`SH-FND-12`), validation banner (`SH-FND-13`), toast on success (`SH-FND-17`).
- `l10n` — EN + AR ARB entries for the screen chrome (labels, buttons); data names come from API.

### B7. Frontend tests (`test/`)
- `taxonomy_controller_test.dart` — load, create optimistic + invalidate, deactivate.
- `login_screen_test.dart` — widget test: submit calls repo, error renders.
- A golden or two for `taxonomy_tree` LTR + RTL (`AD-FE-13`) — optional if time-boxed.
- `flutter analyze` clean; `flutter test` green.

---

## Part C — Spec-doc reconciliation (small, in-scope)

- `ui-screens/admin/ADM-S14-*.md` + `ADM-S15-*.md` — drop the "Delete" action row / reword to
  "Deactivate (in-use cannot be removed)" — resolves **SAM-GAP-9**.
- `docs/Screen-API-Map.md` — mark SAM-GAP-9 resolved; note ADM-S01 is password-only in v-checkpoint-1.
- `docs/API-Route-Inventory.md` — annotate the taxonomy rows (§21.6) and
  `/v1/auth/login/password`, `/v1/auth/refresh`, `/v1/auth/logout`, `/v1/me` as **built**
  (drop `[PROPOSED]` where now real); add a deviation note under §8 that admin 2FA is deferred.
- `docs/Backend-Implementation-Plan.md` — tick T13 (partial: password only), T16 (taxonomy),
  and the P11 taxonomy items; add a "checkpoint-1" note.
- `docs/Architecture-Frontend.md` §3 — note `AD-FE-02` (Melos) and `AD-FE-06` (generated client)
  are deliberately deferred past checkpoint-1, with rationale.
- `CLAUDE.md:7` — update the stale "There is no application code yet" line.
- **Do not** bump the SRS version; these are annotations, not a revision.

---

## Verification (end-to-end)

1. **Backend up**: `cd backend && npm install && npm run prisma:generate && npm run seed &&
   npm run start:dev`. Confirm `GET http://localhost:3000/health` and `/ready` → 200.
2. **API smoke** (curl / REST client):
   - `POST /v1/auth/login/password` with seeded admin creds → `200` + `SessionBundle`.
   - `GET /v1/me` with the bearer token → `admin.displayName`.
   - `GET /v1/admin/categories` → seeded tree incl. inactive; same token on a *non-admin* path
     pattern check → `/v1/admin/categories` with no token → `401`, with a (future) non-admin token → `404`.
   - `POST /v1/admin/categories` (new child) → `201`; `PATCH` rename → `200`;
     `POST .../deactivate` → `200` and the node reads `isActive:false` on re-list.
   - Check `audit_log` in Supabase (`mcp__supabase__execute_sql`) — one row per mutation with
     `actor_user_id`, before/after, IP.
3. **Frontend up**: `cd apps/kh_admin && flutter pub get && dart run build_runner build &&
   flutter run -d chrome --dart-define=KH_API_BASE=http://localhost:3000`.
4. **Click-through** (record a GIF via claude-in-chrome):
   - Login with seeded creds → lands on app shell.
   - Navigate Categories → tree renders from API. Create a child, rename it, toggle show-inactive,
     deactivate a node → toast + tree updates. Repeat on Regions.
   - Reload the page mid-screen → URL query params restore selection/filter (`AD-FE` §16.2).
   - Log out → back to login; hitting `/taxonomy/categories` unauthenticated redirects to `/login`.
5. **Tests**: `backend` → `npm test && npm run lint && npm run format:check` green;
   `apps/kh_admin` → `flutter analyze && flutter test` green.
6. **Docs**: `grep -rn "no application code yet\|SAM-GAP-9" docs/ CLAUDE.md` shows the fixes landed.

## Git

- Branch: `feat/checkpoint-1-admin-taxonomy` off `main`.
- Commits, in order:
  1. `backend: password login, refresh, /v1/me, admin-surface guard`
  2. `backend: taxonomy module (categories + regions CRUD) + audit`
  3. `backend: seed script — admin user + UAE taxonomy + platform settings`
  4. `kh_admin: foundation — deps, design tokens, api client, auth, router, shell`
  5. `kh_admin: taxonomy screens (ADM-S14 + ADM-S15)`
  6. `docs: reconcile SAM-GAP-9, mark built endpoints, note checkpoint-1 deviations`
- Push branch, open **draft PR** to `main` with the click-through GIF and the seed-taxonomy list
  for PO review. Do not merge.
