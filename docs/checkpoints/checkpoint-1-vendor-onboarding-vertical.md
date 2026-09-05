# Check-point-1 — Vendor Frontend, First Vertical: Onboarding & Activation

> **Status: implemented** on branch `feat/vendor-onboarding-vertical` (3 commits, 2 Sep 2026).
> Backend vertical verified end-to-end against the Supabase database; Flutter Melos
> workspace + all 6 screens scaffolded, `melos run analyze`/`test` green.
> This document is the plan of record; see the commit messages for what shipped.
>
> **Post-checkpoint (6 Sep 2026):** `SUPABASE_SERVICE_ROLE_KEY` set and the KYC storage
> round-trip verified; the deferred Supabase Data-API / RLS exposure is now **resolved**
> — locked down at the database, see [`docs/adr/0009`](../adr/0009-managed-postgres-supabase.md).

## Context

The Vendor app has no working code — `apps/kh_mobile` is a broken `flutter create` stub, the 6 shared
`packages/*` are empty dirs, and the NestJS backend serves only `/health` + `/ready` (spine done: guards,
interceptors, Prisma schema w/ ~60 models + 1 applied migration, outbox, JWT plumbing — no domain endpoints,
no login). Check-point-1 delivers **one vendor journey end-to-end**, backend + Flutter, as the foundation
every later vertical mounts into.

**Chosen vertical — V1 Onboarding & Activation** (recommended because it is the mandatory gate for every
other vertical, has the fewest backend dependencies, and forces us to build the router/shell/session/media
skeleton once, correctly):

`Vendor login → registration (OTP) → KYC upload → Awaiting-Approval shell → declare Categories/Regions →
dashboard shell`. Screens **VEN-S04, VEN-S01, VEN-S02, VEN-S03, VEN-S16**, thin **VEN-S05**.

### Decisions locked (from user)
- Build **both** backend endpoints and the Flutter vertical (true end-to-end).
- OTP delivery = **console/fixed-code stub** behind an `OtpSender` interface (real SMS later).
- Flutter = **full Melos monorepo now**: Riverpod (`AD-FE-03`), go_router typed routes + guards (`AD-FE-04`),
  freezed + json_serializable (`AD-FE-05`).
- KYC media = **Supabase Storage** (project `husuemlfcvacrysapwho`), private `kyc` bucket, backend mints
  signed upload URLs with the service-role key.
- `PENDING_VERIFICATION → VERIFIED` via a **dev-only guarded verify endpoint** + a Prisma seed helper.
- **CI**: extend `backend.yml` with a Postgres service; add a new Flutter workflow.
- Supabase RLS/Data-API exposure: deferred at this checkpoint → **resolved 6 Sep 2026** (`docs/adr/0009`, `AD-BE-15`).

### Authoritative inputs
`docs/Requirements-Spec-v1.3.md` (FR-VEN-001/002/003/025/031, BR-002, vendor state machine §5.4, OTP rules
FR-CUS-001), `docs/API-Route-Inventory.md` §8/§9/§12/§20 (all `[PROPOSED]`), `docs/Screen-API-Map.md` §4 +
SAM-GAP-6/7, `docs/Architecture-Frontend.md` §5–7, `docs/Architecture-Backend.md`, `ui-screens/vendor/VEN-S01..S05,S16.md`,
`CONTEXT.md`, domain invariants in `CLAUDE.md`.

---

## Backend

### B0. Cross-cutting prep (must land before any domain controller compiles)
- `backend/src/edge/errors/error-codes.ts` **and** `error-messages.ts` (en+ar, typechecked `Record`) — add:
  `OTP_INVALID, OTP_EXPIRED, OTP_RATE_LIMITED, MOBILE_ALREADY_REGISTERED, EMAIL_ALREADY_REGISTERED,
  ACCOUNT_LOCKED, ACCOUNT_SUSPENDED, ACCOUNT_DEACTIVATED, VENDOR_NOT_ACTIVE, MEDIA_TYPE_REJECTED,
  MEDIA_QUARANTINED, MEDIA_NOT_READY, UPLOAD_NOT_COMPLETED, ILLEGAL_VENDOR_TRANSITION`.
- `error/http-error.filter.ts` — map HTTP 423 → `ACCOUNT_LOCKED`.
- `backend/src/config/env.ts` — add `JWT_REFRESH_TTL_DAYS(14)`, `OTP_DEV_MODE`, `OTP_FIXED_CODE(000000)`,
  `OTP_TTL_SECONDS(300)`, `OTP_MAX_PER_NUMBER_PER_HOUR(5)`, `LOGIN_MAX_FAILURES(5)`, `LOGIN_LOCK_MINUTES(15)`,
  `PASSWORD_MIN_LENGTH(10)`, `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_STORAGE_BUCKET_KYC(kyc)`,
  `SIGNED_UPLOAD_TTL_SECONDS(900)`, `DEV_VERIFY_ENABLED(false)`, `DEV_VERIFY_KEY`.
- `backend/src/platform/outbox/outbox.events.ts` — append `vendor.registered`, `vendor.documents.submitted`
  (`[PROPOSED]`; register in `docs/Async-Contract.md` §2). `vendor.verification.decided` +
  `vendor.eligibility.changed` already exist.
- **Schema change (only one):** new migration `backend/prisma/migrations/20260902xxxxxx_vendor_vertical/migration.sql`
  adding `user.failed_login_attempts INT NOT NULL DEFAULT 0` + `user.locked_until TIMESTAMPTZ(6)`; mirror in
  `schema.prisma`; `npx prisma generate`. **Do not reopen the init migration** (Backend-Gap-Fix-Plan).
- `verification_message` (SAM-GAP-6) is **already** in the schema/init migration — just surface + write it.

### B1. Platform ports & adapters — `backend/src/platform/ports/` + `adapters/`
- `otp-sender.port.ts` (token `OTP_SENDER`) + `adapters/sms/console-otp-sender.ts` (logs
  `[OTP] +9715… -> 123456`; `fixed` mode → `OTP_FIXED_CODE`).
- `storage.port.ts` `ObjectStorage { createSignedUploadUrl, headObject, createSignedDownloadUrl }`
  (token `OBJECT_STORAGE`) + `adapters/storage/supabase-storage.adapter.ts` (Supabase Storage REST via Node 20
  global `fetch`, service-role bearer; bucket `kyc` private; path `vendor/{vendorProfileId}/KYC_DOCUMENT/{mediaKey}`;
  upload+download TTL 900s) + `adapters/storage/local-disk-storage.adapter.ts` (bound when `NODE_ENV=test`).
- `password-hasher.port.ts` — `node:crypto` scrypt, no new dependency.
- Provide/select in `platform.module.ts`; wire into `AppModule`.

### B2. Module `identity` — `backend/src/modules/identity/` (layer folders exist; cross-module via `index.ts`)
Endpoints (all identity-returning handlers need `@RevealsIdentity()` or the global MaskingInterceptor 500s):

| Endpoint | Notes |
|---|---|
| `POST /v1/auth/otp/request` `@Public` | body `{mobileNumber, purpose: REGISTER_VENDOR\|LOGIN\|CHANGE_MOBILE}`. `REGISTER_VENDOR`+live number → `MOBILE_ALREADY_REGISTERED`; `LOGIN`+unknown → dummy challenge (anti-enumeration). Per-number/hour cap enforced in service (count `otp_challenge` rows). `201 {challengeId, expiresAt, retryAfterSeconds}` |
| `POST /v1/auth/otp/verify` `@Public @RevealsIdentity` | `OTP_INVALID`/`OTP_EXPIRED`; 5 bad attempts → challenge-locked. `REGISTER_VENDOR` → `{challengeId, mobileVerified:true}`. `LOGIN` → `SessionBundle` |
| `POST /v1/auth/register/vendor` `@Public @RevealsIdentity` | body per API §8. One `withTx`: validate challenge → uniqueness (mobile/email/licence) → `taxonomy.assertActive(ids)` → create `user` (VENDOR, accountState ACTIVE) → `vendor-onboarding.createProfile` (`PENDING_VERIFICATION`) → `vendor_category`/`vendor_region` rows → outbox `vendor.registered` → audit `VENDOR_REGISTERED` → `SessionBundle`. `201` |
| `POST /v1/auth/login/password` `@Public @RevealsIdentity` | body `{email,password}`. `locked_until>now` → `423 ACCOUNT_LOCKED`; verify fail → `failed_login_attempts++`, at max → lock + audit; success → reset. Branch on VENDOR: `REJECTED` → 403, `SUSPENDED/DEACTIVATED` → matching 403, else `SessionBundle`. Admin → out of slice |
| `POST /v1/auth/refresh` `@Public @RevealsIdentity` / `POST /v1/auth/logout` (auth) | thin wrappers over existing `TokenService`. Refresh TTL 14 days; access stays 900s. logout → `204` |
| `GET /v1/me` `@RevealsIdentity` / `PATCH /v1/me` | `me.service` + `me.presenter`; vendor sub-read via `vendor-onboarding.getVendorMe` → `VendorMe` (API §9) **+ `verificationMessage?`**, `lifecycle`, `awaitingApprovalReason`. PATCH: `preferredLanguage` only this slice |

Key internal files: `application/otp.service.ts`, `registration.service.ts`, `login.service.ts`,
`session.service.ts`, `me.service.ts`; pure `domain/otp-challenge.ts`, `account-lock.ts`,
`vendor-lifecycle.ts` (composes `VendorAccountState` + `awaitingApprovalReason` enum
`PENDING_DOCUMENTS|PENDING_ADMIN|CATEGORIES_REQUIRED|REJECTED`); `repository/otp.repository.ts` (+ `countSince`),
`user.repository.ts`; `presenter/me.presenter.ts`, `session.presenter.ts`.

### B3. Module `vendor-onboarding` — `backend/src/modules/vendor-onboarding/`

| Endpoint | Notes |
|---|---|
| `GET/PATCH /v1/me/vendor` `@RevealsIdentity` | `VendorProfile` (API §20) + `verificationMessage`, `lifecycle`. PATCH: `legalBusinessName\|tradeLicenceNumber\|businessAddress` → `PENDING_VERIFICATION` (`BR-004`), outbox `vendor.eligibility.changed`, audit. Minimal impl |
| `GET/POST /v1/me/vendor/documents` `@RevealsIdentity` | POST body `{documentType, mediaKey, expiryDate?}`. Load `Media` by key: `bucket=KYC`, `uploadedByUserId=viewer`, state `PENDING_PROCESSING\|READY` else `UPLOAD_NOT_COMPLETED`/`MEDIA_QUARANTINED`. Insert `vendor_document`; when mandatory set (`TRADE_LICENCE`+`EMIRATES_ID`) complete → outbox `vendor.documents.submitted`; audit. Presenter returns **no URL** |
| `POST /v1/me/vendor/resubmit` `@RevealsIdentity` | only from `REJECTED` → `PENDING_VERIFICATION`, clear message, outbox, audit; else `409 ILLEGAL_VENDOR_TRANSITION` |
| `PUT /v1/me/vendor/categories` / `PUT /v1/me/vendor/regions` | body `{categoryIds[]}` / `{regionIds[]}` (≥1, active). Replace join rows; `tryActivate()`: if `VERIFIED` && ≥1 cat && ≥1 region → **transition `VERIFIED → ACTIVE`** (SRS §5.4), outbox `vendor.eligibility.changed`, audit `VENDOR_ACTIVATED`. Optional `{estimatedMatchVolume}` (`FR-VEN-025` AC4), may be null |
| `PATCH /v1/me/vendor/availability` | `{awayMode?, businessHours?}` |
| `POST /v1/dev/vendors/{id}/verify` **dev-only** | guard: `DEV_VERIFY_ENABLED && NODE_ENV!=production && (role=ADMIN \|\| header x-dev-key=DEV_VERIFY_KEY)`, else `404`. body `{decision: VERIFY\|REJECT\|REQUEST_INFO, rationale?, message?}`. `VERIFY` → `VERIFIED` (→ `ACTIVE` same tx if cats+regions present, mirrors real admin AC5); `REJECT` → `REJECTED`; `REQUEST_INFO` → writes `verification_message`. Calls same module-public `markVerified(tx,…)` the real admin module will use. Illegal source → `409 ILLEGAL_VENDOR_TRANSITION` |
| `GET /v1/me/dashboard` **ACTIVE only** | API §14 shape with **zeroed counts** (`newRequests/pendingOffers/activeConnections` = 0), rating from profile, `goldRates:null`, `subscriptions:[]`. Real counts arrive with marketplace modules |

**Shell auth guard (resolves SAM-GAP-7):** reads `viewer.vendorVerificationState` + `accountState`.
`GET/PATCH /v1/me/vendor`, documents, resubmit → allow `PENDING_VERIFICATION|VERIFIED|ACTIVE`.
`PUT categories|regions`, `PATCH availability` → allow **`VERIFIED` (pre-ACTIVE) and `ACTIVE`** (the Route
Index's ACTIVE-only literal makes first activation unreachable — implement the guard, not the literal).
`GET /v1/me/dashboard` → `ACTIVE` only. Others → `403 VENDOR_NOT_ACTIVE`.

Internal: `domain/vendor-state-machine.ts` (pure transition table, TDD first), `document-rules.ts`;
`application/vendor-{profile,documents,taxonomy,verification}.service.ts`; `presenter/vendor-me.presenter.ts`,
`vendor-document.presenter.ts`; `index.ts` module-public `createProfile(tx,…)`, `getVendorMe(id)`,
`assertActiveVendor(viewer)`, `markVerified(tx,…)`.

### B4. Module `taxonomy` — `GET /v1/categories`, `GET /v1/regions` (any authed role incl. shell), active-only
two-level tree, no pagination, empty → `200 data:[]`. `index.ts`: `assertActive(ids)`, `listActive()`.

### B5. Module `media` — KYC path
- `POST /v1/media/upload-intent` (**Idempotency-Key required** — already in `idempotency.policy.ts`): body
  `{purpose, contentType, byteSize, parentType?, parentId?}`. `KYC_DOCUMENT` → vendor (shell ok).
  `media-rules` (PDF/JPEG/PNG, ≤10 MiB) else `422 MEDIA_TYPE_REJECTED`. `key=randomUUID()`;
  `ObjectStorage.createSignedUploadUrl`; insert `media` row `PENDING_UPLOAD`. `201 {key, uploadUrl, requiredHeaders, maxBytes, expiresAt}`.
- `POST /v1/media/{key}/complete`: `headObject` verify size/type, mismatch → `409 UPLOAD_NOT_COMPLETED`;
  `PENDING_UPLOAD → PENDING_PROCESSING`; outbox `media.uploaded`. **Dev shortcut:** synchronously mark KYC
  `READY` (real EXIF/scan worker is Backend-Impl-Plan P4/T17).
- `DELETE /v1/media/{key}` → `204` while unattached.
- `index.ts`: `getReadyMedia(key, ownerUserId)`.

### B6. Seeds — `backend/prisma/seed/` (add `seed` script + `prisma.seed` to `package.json`)
- `taxonomy.seed.ts` — UAE 7-emirate region tree + two-level category tree.
- `platform-settings.seed.ts` — `request.lifetime_hours=48`, `bullion.minimum_value_aed`, `offer.validity_hours_options=[12,24,48]`,
  `request.max_concurrent_live=10`, karat list, media limits, `legal.termsUrl/privacyUrl/supportContactUrl` (SAM-GAP-5).
- `admin.seed.ts` — one ADMIN user for dev-verify.
- `vendor-dev.seed.ts` — exported `seedVendor({state: 'PENDING'|'VERIFIED'|'ACTIVE'})` helper
  (user + vendor_profile + docs + categories + regions + subscription at the chosen lifecycle).
- `index.ts` — idempotent (upsert) orchestrator.

### B7. Wiring — `backend/src/app.module.ts`: import `PlatformModule` (ports), `TaxonomyModule`, `MediaModule`,
`VendorOnboardingModule`; `IdentityModule` gains controllers.

### Outbox / audit
| Event | By | Consumer this slice |
|---|---|---|
| `vendor.registered` `[PROPOSED]` | register/vendor | none (audit trail) |
| `vendor.documents.submitted` `[PROPOSED]` | documents (mandatory set complete) | none |
| `vendor.verification.decided` | dev-verify | notifications (later) |
| `vendor.eligibility.changed` | VERIFIED→ACTIVE, BR-004 | matching (later) |
Audit (all `AuditWriter.append(tx,…)` in-tx): `VENDOR_REGISTERED, AUTH_OTP_LOGIN, AUTH_PASSWORD_LOGIN,
AUTH_ACCOUNT_LOCKED, KYC_UPLOAD_INTENT, VENDOR_DOCUMENT_ADDED, VENDOR_RESUBMIT, VENDOR_VERIFIED,
VENDOR_REJECTED, VENDOR_INFO_REQUESTED, VENDOR_ACTIVATED, VENDOR_PROFILE_REVERIFY`.

---

## Frontend

### F1. Melos + packages
`melos.yaml` at repo root (`packages: apps/kh_mobile/karat_hive, apps/kh_admin/hive_admin, packages/*`;
scripts `analyze`/`test`/`gen`); root `pubspec.yaml` with `melos` dev-dep. Delete the stray
`apps/kh_mobile/lib/features/*` tree outside the Flutter package. Each package gets a real `pubspec.yaml`
(`name` = folder, `publish_to: none`, inter-deps as `path:`). `tooling/` gets shared strict
`analysis_options.yaml` + `golden_runner.dart`.

| Package | Contents (this vertical) |
|---|---|
| `kh_core` | `Result<T,Failure>` + sealed `Failure`; flavor `Env`; `Clock` + server-time offset; `Dio` factory + interceptor chain (correlation, auth + **single-flight refresh**, locale, idempotency-key gen&persist, server-time, envelope→`Failure`); `flutter_secure_storage` `TokenStorage`; `AppLogger` w/ PII masking |
| `kh_domain` | pure Dart. `VendorLifecycle` + `AwaitingApprovalReason` enums (unknown → `.unknown`, `NFR-027`), `VendorMe`, `MeUser`, `SessionBundle`, `Category`/`Region` tree, `DocumentType`, `VendorDocument`, VOs `PhoneNumber/Email/LicenceNumber` |
| `kh_api` | hand-written typed client (OpenAPI gen deferred — see risks): `AuthApi/MeApi/VendorApi/MediaApi/TaxonomyApi`; freezed DTOs mirroring the Backend section; DTO→domain mappers; envelope unwrap |
| `kh_design_system` | tokens via `ThemeExtension` (placeholder values); `KhScaffold/KhAppBar/KhButton/KhTextField`; `SH-AUTH-01/02/03/07/08` (mobile field, OTP entry w/ cooldown+countdown, send/resend, lockout, email+pw); `SH-MED-04` upload tile; `SH-FND-12/13/14`; `SH-SHELL-05/06`. `EdgeInsetsDirectional` only, `Semantics` inline, golden LTR+RTL |
| `kh_l10n` | `app_en.arb`/`app_ar.arb` (auth/onboarding/shell), generated delegates, `MoneyFormatter`, `RelativeTimeFormatter`, Arabic-Indic numerals |
| `kh_ui_domain` | minimal: `VendorStatusCard`, `DocumentChecklist`, `CategoryRegionPicker` |

`kh_admin` stays untouched but listed in `melos.yaml` so bootstrap doesn't break; keep web deps out of `kh_design_system`.

### F2. App `apps/kh_mobile/karat_hive`
- `pubspec.yaml`: add `flutter_riverpod`, `go_router`, the 6 `kh_*` (path), `flutter_secure_storage`, `dio`,
  `image_picker`, `file_picker`; dev: `build_runner`, `freezed`, `json_serializable`, `mocktail`.
- **Delete the counter `lib/main.dart`.** New: `main_dev/staging/prod.dart` → `bootstrap.dart`
  (`ProviderScope` + env + restore tokens + server time + `runApp`); `app/app.dart` (`MaterialApp.router`,
  theme, l10n, RTL); `app/router.dart` (GoRouter from feature routes + redirect guard chain);
  `app/guards.dart`; `app/session/session_controller.dart` (keep-alive `Notifier<SessionState>`:
  tokens, `MeUser`, `VendorLifecycle`; signIn/refresh/signOut); `app/shells/{unauth,awaiting_approval,vendor}_shell.dart`.
- **Guard chain** (mirrors backend, never authoritative): not bootstrapped → `/splash`; not authed →
  `/vendor/login`; `pendingVerification|rejected` → `/awaiting`; `verified` (cats/regions not declared) →
  `/awaiting` (CTA → `/vendor/categories-regions`); `active` → `/vendor/home`.

Features (each: `presentation/ controller/ repository/ model/ routes.dart` per `Architecture-Frontend.md` §5.1):
- `features/auth/` — VEN-S04 `vendor_login_screen` (OTP tab + email/password tab), VEN-S01
  `vendor_register_screen` (multi-section form + inline OTP), `otp_field` (wraps `SH-AUTH-02`);
  `vendor_login_controller` (AsyncNotifier idle/otpSent/loading/error/authed), `vendor_register_controller`
  (flow-scoped notifier, form draft survives back-nav: details → otpRequest → otpVerify → submit);
  `auth_repository` → `Result<SessionBundle, Failure>`.
- `features/onboarding/` (dedicated folder — cleaner than the arch's auth/profile_settings split, still
  layer-compliant) — VEN-S02 `kyc_upload_screen` (`SH-MED-04` tile per `DocumentType`), VEN-S03
  `awaiting_approval_screen` (status, `verificationMessage`, CTAs, logout), VEN-S16
  `categories_regions_screen` (`CategoryRegionPicker`, away mode); `kyc_upload_controller` (per-file
  state machine: intent → `dio.put(uploadUrl)` w/ progress → complete → poll `READY` → attach; per-file
  retry, survives nav), `awaiting_approval_controller` (foreground-poll `GET /v1/me`, derive CTAs),
  `categories_regions_controller`; `vendor_onboarding_repository` (wraps `VendorApi` + `MediaApi`).
- `features/dashboard/` — VEN-S05 `vendor_dashboard_screen` (zeroed counts, gold-rate placeholder, rating,
  subscription summary, pull-to-refresh); `vendor_dashboard_controller` → `GET /v1/me/dashboard`.

---

## Infra / wiring

1. `cd backend && npx prisma migrate deploy` (applies `20260902_vendor_vertical` to Supabase Postgres) → `npx prisma generate`.
2. Verify/apply `backend/prisma/sql/extensions.sql` + `partial-indexes.sql` (pg_trgm, offer/subscription
   partial-unique indexes, validity CHECK) via Supabase MCP `apply_migration` so the Supabase log stays in sync.
3. Supabase Storage: create **private** bucket `kyc`
   (`insert into storage.buckets (id,name,public) values ('kyc','kyc',false)` via `execute_sql`). No anon
   policies; backend uses service-role key (bypasses Storage RLS).
4. `SUPABASE_SERVICE_ROLE_KEY` + the other B0 vars into `backend/.env`, `.env.example`, CI secrets. Never in
   the client bundle. Frontend `KH_API_BASE_URL` via `--dart-define-from-file config/{dev,staging,prod}.json`.
5. ~~**Open decision (deferred):** "Supabase Data-API exposure"~~ — **resolved 6 Sep 2026.** Locked down at
   the database (Supabase migration `lock_down_data_api_public_schema`): RLS deny-all on all 42 `public`
   tables, `anon`/`authenticated` grants + schema `USAGE` revoked, `postgres` default privileges revoked.
   Backend connects as `postgres` (owner, `rolbypassrls`) so it is unaffected. See
   [`docs/adr/0009`](../adr/0009-managed-postgres-supabase.md) and `AD-BE-15`.

### CI
- Extend `.github/workflows/backend.yml`: add `services: postgres:16` (health-checked), test env, run
  `prisma migrate deploy` + `psql -f prisma/sql/*.sql` before tests. Split `unit` (existing) vs `integration`
  (new) jobs; keep `lint`/`build`/`format:check`.
- New `.github/workflows/frontend.yml`: `subosito/flutter-action` (pinned SDK) → `melos bootstrap` →
  `melos run analyze` → `melos run test` → goldens → optional `flutter build apk --debug`. Path filter
  `apps/**`, `packages/**`, `melos.yaml`.

---

## Sequencing

**Backend-first for contract-bearing work; Flutter package scaffolding runs in parallel from day 1.**

Track A (backend, critical path): A1 B0 prep (gate: `nest build` + `npm test` green) → A2 ports+adapters →
A3 `taxonomy` + seeds → A4 `identity` (OTP → register → login → refresh → `/v1/me`) → A5 `vendor-onboarding`
(domain state machines TDD → profile → documents → categories/regions+activation → dev-verify → dashboard) →
A6 `media` (∥ A4) → A7 integration suites + masking spec + CI Postgres → A8 Supabase migrate/storage wiring.

Track B (frontend, converges after A4/A5): B1 melos + `kh_core`/`kh_domain`/`kh_l10n`/`kh_design_system`
(no backend dep) → B2 `kh_api` DTOs against this plan's schemas + fix `main.dart`/bootstrap/router/guards/session
→ B3 `auth` feature vs mock `AuthApi`, swap to real when A4 up → B4 `onboarding` (needs A5+A6) → B5
`dashboard` (needs A5) → B6 controller + widget tests + frontend CI → B7 end-to-end walk-through.

### Risks / watch-items
- **API-Route-Inventory is `[PROPOSED]`** — this plan's Backend section is the frozen contract for the
  vertical; `kh_api` DTOs hand-written and cheap to change; follow-up: generate OpenAPI from Nest/Zod (T31/T35).
- **MaskingInterceptor 500s** are the most likely "why is my endpoint broken" — every identity-returning
  handler needs `@RevealsIdentity()`; covered by a dedicated masking spec.
- **SAM-GAP-7** (categories/regions auth scope) is the one live contradiction — resolved by the shell guard
  admitting `VERIFIED` pre-ACTIVE.
- **SAM-GAP-6** (`verificationMessage`) — column already exists; just surface + write from dev-verify `REQUEST_INFO`.
- **Account-lockout columns** are the only schema change — keep the migration to those two `user` columns.
- **OTP per-number/hour cap** must be enforced in the OTP service (the edge `otp` rate-limit bucket is a
  coarse per-IP guard, capacity 5/min — not the FR-CUS-001 rule).
- **`start:worker`** has no media/EXIF worker yet — KYC `complete` synchronously marks `READY` in dev.
- **Supabase migration log already diverged** from `_prisma_migrations` (Prisma applied init directly) —
  standardise on Prisma for schema; use Supabase MCP only for Storage + raw `sql/*.sql`.
- Melos/Flutter Web not needed here (mobile only); `kh_admin` untouched.

---

## Verification (end-to-end)

Backend up: `cd backend && npm run seed && npm run start:dev` with `OTP_DEV_MODE=console`,
`DEV_VERIFY_ENABLED=true`, `DEV_VERIFY_KEY=…`.

```
BASE=http://localhost:3000
1. POST $BASE/v1/auth/otp/request   {"mobileNumber":"+971500000001","purpose":"REGISTER_VENDOR"}
   → read code from backend console  [OTP] +971500000001 -> 123456
2. POST $BASE/v1/auth/otp/verify    {"challengeId":"<CID>","code":"123456"}  → {mobileVerified:true}
3. POST $BASE/v1/auth/register/vendor  {challengeId, legalBusinessName, tradingName, tradeLicenceNumber,
   licenceExpiryDate, businessAddress, contactPersonName, businessEmail, regionId, categoryIds:[<CAT>],
   servedRegionIds:[<REGION>], termsVersion:"1.0", privacyVersion:"1.0"}
   → SessionBundle, user.vendor.lifecycle = PENDING_VERIFICATION   (save accessToken)
4. GET  $BASE/v1/me  -H "authorization: Bearer <T>"   → lifecycle PENDING_VERIFICATION
5. POST $BASE/v1/media/upload-intent  -H "idempotency-key: <uuid>"  {"purpose":"KYC_DOCUMENT",
   "contentType":"application/pdf","byteSize":123456}  → {key, uploadUrl}
   PUT  <uploadUrl>  --data-binary @licence.pdf
   POST $BASE/v1/media/<key>/complete
   POST $BASE/v1/me/vendor/documents  {"documentType":"TRADE_LICENCE","mediaKey":"<key>"}   (repeat: EMIRATES_ID)
6. POST $BASE/v1/dev/vendors/<vendorProfileId>/verify  -H "x-dev-key: <KEY>"  {"decision":"VERIFY"}
7. GET  $BASE/v1/me   → VERIFIED (awaitingApprovalReason CATEGORIES_REQUIRED) or ACTIVE if cats/regions present
8. PUT  $BASE/v1/me/vendor/categories  {"categoryIds":["<CAT>"]}
   PUT  $BASE/v1/me/vendor/regions     {"regionIds":["<REGION>"]}
9. GET  $BASE/v1/me         → lifecycle ACTIVE
10.GET  $BASE/v1/me/dashboard → 200, zeroed counts
```

Flutter: `melos bootstrap` → `cd apps/kh_mobile/karat_hive` →
`flutter run --dart-define-from-file=config/dev.json` (`{"KH_API_BASE_URL":"http://10.0.2.2:3000"}`).
Walk: Login → Register → Send OTP (read console) → verify → Awaiting-Approval shell → Upload KYC PDF →
(curl step 6 dev-verify) → pull-to-refresh → Categories/Regions CTA → select + save → Dashboard (VEN-S05).

Automated: backend Vitest integration suites per endpoint (happy + every error code + state transitions) +
masking spec, against the CI Postgres. Frontend: controller tests (loading/empty/error/data per screen) +
widget tests for every `SH-FND-12`/`SH-FND-13` state + LTR/RTL goldens for `kh_design_system`.
