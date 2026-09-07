# Karat Hive — Backend Code Review & Implementation Gap Report

| Document Info | Details |
|---|---|
| **Scope** | Backend monolith (`backend/src/`, `prisma/`, `test/`) |
| **Baseline Specs** | SRS v1.3 · Architecture-Backend.md · Backend-Implementation-Plan.md · API-Route-Inventory.md · Async-Contract.md · Checkpoint 1 Tasks |
| **Evaluation Standard** | Multi-Dimensional 5-Axis Quality Review (`/code-review-and-quality`) |
| **Date** | 6 September 2026 |
| **Status** | Snapshot — 6 September 2026. **Not the plan of record.** |
| **Plan of record** | [`Backend-Gap-Tasks.md`](Backend-Gap-Tasks.md) (`G2-*`). That register reviews this snapshot, splits TSK-BE-01–27, and maps onto T12–T44. |

> Section 5 (`TSK-BE-01`–`TSK-BE-27`) is **retired**. Do not implement from it. Open decisions in this snapshot (Google Sign-In vs `BR-001`; `POST /v1/auth/firebase/session` not in the inventory) stay open — they are `G2-D01` / `G2-D02` in the plan of record.

---

## 1. Executive Summary

The Karat Hive backend is structured as a modular Node.js monolith (`C-11`) utilizing NestJS 11, Fastify 5, Prisma ORM 5, and PostgreSQL 16 (`C-12`).

As of September 6, 2026:
- **Scaffolding & Tooling (P0)**: Complete. TypeScript strict compilation passes cleanly (`npm run build`), Vitest unit test suite passes (20 test files, 130 tests), ESLint + Prettier pass (`npm run lint`), and Prisma schema contains all 38 models and 22 enums.
- **Implemented Verticals**:
  1. **Platform Spine (P1)**: Outbox event emission/claiming, job lock leasing, audit logging, rate limiting, and masking interceptors are functional.
  2. **Identity & Sessions (P2)**: Vendor OTP, Vendor/Admin password authentication, refresh token family rotation, session management, and `GET/PATCH /v1/me` are functional.
  3. **Taxonomy & Platform Reference (P3)**: Public 2-level category/region trees and full Admin CRUD are implemented.
  4. **Media Port (P4)**: Presigned upload intents, completion checks, and attachment bindings are functional for KYC documents.
  5. **Vendor Onboarding Vertical (P5 / CP1)**: Profile management, KYC document uploads, dev verification shortcut, categories/regions assignment, state-machine activation, and thin dashboard are functional.
- **New Firebase Auth Integration**: Firebase ID token verification (via Google JWKS) and on-the-fly user provisioning were recently introduced to support Google Sign-In on mobile and web clients. This represents a significant architectural shift from the original specification that requires immediate alignment.
- **Pending Marketplace Modules (P6–P12)**: 11 of the 16 domain modules (`requests`, `matching`, `offers`, `connections`, `reviews`, `abuse`, `notifications`, `gold-rate`, `settings`, `subscription`, `admin`) currently exist only as `.gitkeep` directory stubs. All commercial transaction flows, matching fan-out, offer bidding, connection reveals, and background workers remain to be built.

---

## 2. Deep-Dive: Firebase Auth Integration Analysis

### 2.1 What Was Implemented
In commits `2689a38`, `29abf0d`, and `58f205f`:
1. **Frontend**: Mobile and Admin clients integrate Firebase Auth (Google Sign-In) and pass the resulting Firebase ID token directly in the `Authorization: Bearer <token>` header to the backend.
2. **Backend Auth Guard (`AuthGuard`)**:
   - Detects RS256 JWTs using `isFirebaseToken()`.
   - Validates the token signature and claims (`sub`, `email`, `email_verified`, `phone_number`, `name`, `picture`) against Google's public JWKS via `FirebaseTokenService`.
   - Calls `SessionQuery.findOrCreateUserForFirebase(claims)` to find or provision the user in PostgreSQL.
3. **Session Query (`SessionQuery`)**:
   - Checks `OauthBinding` by `subjectHash = sha256(claims.uid)`.
   - If missing, attempts to match an existing user by verified `email` or `phoneNumber`, binding Google OAuth to that user.
   - If no match exists, auto-provisions a `User`, `VendorProfile`, and `OauthBinding` in a single transaction.

### 2.2 Architectural & Specification Gaps (Firebase vs Specs)

| Area | Original Design (`Architecture-Backend.md`, `API-Route-Inventory.md`) | Current Firebase Implementation | Severity / Impact |
|---|---|---|---|
| **Login Mechanism** | OAuth is **never** a login mechanism (`BR-001`). Customers authenticate via SMS OTP; Vendors via OTP or Email/Password; Admin via Email/Password + 2FA. OAuth is exclusively used as an identity verification gate before publishing a Request (`POST /v1/auth/oauth/bind`). | Firebase ID token is used as the primary bearer credential across all endpoints. | **Required**: Diverges from BR-001. Requires architectural decision on whether Google Sign-In replaces OTP for Customer login or acts as an alternative authentication provider. |
| **Auto-Provisioning Role** | Explicit registration routes with terms/privacy acceptance, phone verification, and role selection (`POST /v1/auth/register/customer`, `POST /v1/auth/register/vendor`). | Auto-provisions any unrecognized Firebase user unconditionally as `userType: 'VENDOR'` with synthetic `VendorProfile` (`PENDING_<uid>`). | **Critical**: A Customer or Admin logging in via Google is forced into a Vendor identity, breaking customer flows and corrupting role segregation. |
| **HTTP Idempotency / Guard Side-Effects** | `AuthGuard` is a read-only request gate (`canActivate`). Mutations belong in controllers/services executed under `POST`. | `AuthGuard.canActivate()` performs database writes (`User.create`, `VendorProfile.create`, `OauthBinding.create`) inside a `GET` request. | **Critical**: Violates HTTP idempotent semantics and NestJS guard boundaries. Vulnerable to write amplification and race conditions on concurrent initial requests. |
| **Phone Number Format** | E.164 format strictly enforced (`/^\+[1-9]\d{6,14}$/`) via `OtpChallenge`. | Fallback mobile number generated as `+fb_${claims.uid.slice(0, 15)}`. | **Critical**: Generates invalid phone numbers that violate the E.164 constraint enforced across other endpoints, corrupting database integrity. |
| **Legal Compliance** | Mandatory acceptance of Terms & Privacy with explicit version stamping (`terms_version`, `privacy_version`, `terms_accepted_at`). | Auto-provisioned users have `null` for `termsVersion`, `privacyVersion`, and `termsAcceptedAt`. | **Required**: Violates UAE PDPL / regulatory compliance requirements outlined in `FR-CUS-001` / `FR-VEN-001`. |
| **Token Architecture** | Stateless HS256 short-lived access tokens (900s) + stateful refresh tokens with family reuse detection (`RefreshToken`). | Dual-token mode: both HS256 internal JWTs and RS256 Google tokens are accepted in the same guard. | **Consider**: Dual-token validation is workable, but needs unified session exchange to decouple backend domain services from Firebase JWKS latency. |

---

## 3. Five-Axis Code Review (Existing Backend Codebase)

### 3.1 Correctness
- **Finding [Critical] Hardcoded Vendor Provisioning in `SessionQuery`**:
  - `SessionQuery.findOrCreateUserForFirebase` hardcodes `userType: 'VENDOR'` (line 114).
  - *Remedy*: Move auto-provisioning out of `AuthGuard`. Expose an explicit exchange/registration endpoint (`POST /v1/auth/firebase/session` or `POST /v1/auth/register/customer`) where the user's intended role and onboarding payload (Terms acceptance, default region) are explicitly supplied.
- **Finding [Required] Missing Customer Path in `MeService`**:
  - `MeService.forUser` checks `user.userType === 'VENDOR'` and `user.userType === 'ADMIN'`, but omits `user.userType === 'CUSTOMER'`. Customers calling `GET /v1/me` receive no `customer` profile data even if present in the database.
  - *Remedy*: Add `customer` branch calling `customerProfile` presenter.
- **Finding [Required] Invalid Fallback Mobile Number**:
  - Auto-generated phone number `+fb_...` breaks downstream validations (e.g. SMS OTP, WhatsApp Talk link generation in `wa.me`).
  - *Remedy*: Require phone number verification via OTP or retain `mobileNumber` as mandatory input during first-party account completion.
- **Finding [Optional] `isFirebaseToken` Heuristic**:
  - `isFirebaseToken` checks solely whether JWT header algorithm is `RS256`. If additional RS256 providers or internal RS256 signing are introduced, this check will misidentify tokens.
  - *Remedy*: Validate issuer matches `https://securetoken.google.com/` before routing to Firebase verification.

### 3.2 Readability & Simplicity
- **Strength**: Code in `modules/vendor-onboarding`, `modules/taxonomy`, and `modules/identity` is well-structured with clear separation of application services, repositories, and presenters.
- **Finding [Required] CQRS Violation in `SessionQuery`**:
  - `SessionQuery` is named as a read query, but contains write transactions (`tx.user.create`, `tx.vendorProfile.create`).
  - *Remedy*: Extract provisioning into `FirebaseRegistrationService` or `OAuthAccountService`.
- **Finding [Nit] Redundant `isFirebaseToken` delegation**:
  - `TokenService.isFirebaseToken` simply delegates to a standalone function of the exact same name in the same file.
  - *Remedy*: Keep single canonical export.

### 3.3 Architecture & Module Boundaries
- **Strength**: Clean platform ports (`ObjectStorage`, `OtpSender`, `PasswordHasher`) allow transparent switching between local development and cloud production adapters.
- **Strength**: `MaskingInterceptor` properly enforces identity masking at the serialization boundary.
- **Finding [Required] Guard Coupling to Domain Mutations**:
  - `AuthGuard` directly calls domain write operations. Guards should establish the caller identity (`ViewerContext`), not mutate domain aggregates.
  - *Remedy*: If a Firebase user has no Karat Hive user account, `AuthGuard` should attach an unprovisioned Firebase viewer or throw a specific error (`401 ONBOARDING_REQUIRED`), prompting the client to complete registration.
- **Finding [FYI] Empty Module Stubs**:
  - 11 module directories contain only `.gitkeep` files in `application/`, `controller/`, `domain/`, `presenter/`, `repository/`. These preserve directory structure but represent pending architectural slices.

### 3.4 Security & Hardening
- **Strength**: Password hashing in `ScryptPasswordHasher` uses robust parameters (`N=16384, r=8, p=1`) with random 32-byte salts.
- **Strength**: Account lockout policy (`isLocked`, `registerFailure`) enforces 5 failures / 15-minute lockout for Vendors and 3 failures / 30-minute lockout for Admins with audit trail (`AUTH_ACCOUNT_LOCKED`).
- **Strength**: Public endpoints are explicitly decorated with `@Public()`; Admin routes require `@AdminOnly()` and return `404 NOT_FOUND` per `AD-API-01` to prevent route discovery.
- **Finding [Critical] Unverified User Creation via Forged Email**:
  - In `SessionQuery.findOrCreateUserForFirebase`, if a Firebase token has `email` but `emailVerified` is false, it can match an existing user with the same email and bind Google OAuth to it without proof of email ownership.
  - *Remedy*: Require `claims.emailVerified === true` before matching existing accounts by email:
    ```ts
    if (email && claims.emailVerified) {
      matchedUser = await this.prisma.user.findUnique({ where: { email } });
    }
    ```
- **Finding [Required] Storage Path Traversal Prevention**:
  - In `MediaService.createIntent`, ensure `objectKey` generation is strictly deterministic and sanitized against path manipulation. (Currently uses `randomUUID()` for key, which is safe).

### 3.5 Performance
- **Strength**: Database indexes are well-placed on hot columns (`mobile_number`, `email`, `subject_hash`, composite index on `[account_state, created_at]`).
- **Finding [Required] AuthGuard DB Query Amplification**:
  - For every incoming request, `AuthGuard` executes `this.sessions.findUserForViewer(id)` or `findOrCreateUserForFirebase(claims)` with multiple `LEFT JOIN`s (`customerProfile`, `vendorProfile`, `adminProfile`).
  - *Remedy*: In high-throughput environments, cache `UserForViewer` in an in-memory/Fastify request-scoped cache or lightweight session store with short TTL (e.g., 60s) invalidating on token version changes.
- **Finding [FYI] Fastify Platform Execution**:
  - Using Fastify instead of Express provides significant throughput benefits for JSON serialization and parsing.

---

## 4. Documentation vs Implementation Status

| Domain Module | Planned Scope (Docs / Specifications) | Current Implementation Status | Identified Gaps |
|---|---|---|---|
| **Identity & Sessions** | Customer/Vendor OTP, Customer/Vendor registration, password login, refresh rotation, sessions list/delete, OAuth bind, password reset, mobile change, deactivation, deletion request. | Vendor OTP, Vendor registration, password login (Vendor/Admin), refresh rotation, `GET/PATCH /v1/me`, Firebase token verification. | Missing: Customer registration, Customer `GET /v1/me` profile, password change/reset, mobile change, account deactivation/deletion, device tokens, session management routes. |
| **Taxonomy** | 2-level category & region trees, active filtering, admin CRUD, audit logs. | Fully implemented (`TaxonomyController`, `AdminTaxonomyController`, `TaxonomyService`, `TaxonomyRepository`). | Complete for Checkpoint 1. Missing: `GET /v1/platform-config`. |
| **Media** | Presigned upload intents, complete HEAD verification, delete, KYC bucket separation, background processing (EXIF strip, malware scan, thumbnails). | Presigned upload intents, complete verification, delete, local & Supabase adapters. KYC sync ready in dev. | Missing: Async background worker for EXIF stripping, virus/malware inspection, image re-encoding, and thumbnail generation. |
| **Vendor Onboarding** | Profile management, KYC document uploads & status, dev verification, category & region selection, away mode, dashboard counts, document expiry worker. | Profile GET/PATCH, KYC upload/list/resubmit, category/region assignment, availability patch, dev-verify endpoint, dashboard zeros. | Missing: Vendor subscriptions (`GET /v1/me/subscriptions`), real Admin verification queue, document expiry cron worker. |
| **Requests (Customer)** | Draft creation, edit rules, publish validation (OAuth, bullion floor, media ready, contact scan), cancel, duplicate, list, Customer presenter, draft purge worker. | Empty (`modules/requests/.gitkeep`). | **0% implemented**. Entire Customer request lifecycle missing. |
| **Matching Engine** | Event-driven match fan-out on publish, eligibility filtering, match-set recompute on vendor change, `/v1/matches` feed, pg_trgm search, filter presets. | Empty (`modules/matching/.gitkeep`). | **0% implemented**. Vendor match feed and notifications missing. |
| **Offers** | Vendor offer submission against match, revision history (max 3), withdrawal, offer comparison, offer expiry sweep worker, warning worker. | Empty (`modules/offers/.gitkeep`). | **0% implemented**. Vendor bidding and offer handling missing. |
| **Acceptance & Connections** | Atomic transaction: accept offer, close request, reject competitor offers, create Connection, reveal identity, audit log, outbox notifications. Talk URL (`wa.me`), contact events. | Empty (`modules/connections/.gitkeep`). | **0% implemented**. Commercial transaction spine missing. |
| **Reviews & Abuse** | Customer & Vendor reviews, moderation hold, rating aggregation worker, vendor response, abuse reports with reporter masking. | Empty (`modules/reviews/.gitkeep`, `modules/abuse/.gitkeep`). | **0% implemented**. Feedback and reporting systems missing. |
| **Notifications** | In-app notification center, user preferences, quiet hours, push dispatchers (FCM/APNs), retry worker, 90-day retention purge worker. | Empty (`modules/notifications/.gitkeep`). | **0% implemented**. In-app center and push delivery missing. |
| **Admin Operations** | User management, vendor KYC verification queue, oversight of requests/offers/connections, moderation queue, audit log viewer, platform announcements, settings. | Only Admin Taxonomy endpoints implemented. | **10% implemented**. Core back-office management interfaces missing. |
| **Gold Rate & Scheduling** | Yahoo Finance price feed polling (15m), manual override, stale alert worker, display licensing gate. 15 scheduled background jobs. | Scheduler platform module (`JobLock`) exists. Domain module empty (`modules/gold-rate/.gitkeep`). | **0% implemented**. Live pricing and scheduled cron workers missing. |

---

## 5. Tasks to Complete Backend Implementation

To guide remaining implementation, work is broken down into sequenced, priority-ranked phases matching the architecture roadmap:

### Phase A: Auth & Identity Stabilization (Immediate Priority)
- [ ] **TSK-BE-01: Refactor Firebase Auth Flow**:
  - Prevent `AuthGuard` from performing auto-provisioning database writes during `canActivate()`.
  - Implement dedicated `POST /v1/auth/firebase/session` endpoint for exchanging Firebase ID tokens for Karat Hive `SessionBundle`.
  - Add strict email verification check (`claims.emailVerified === true`) before linking to existing users.
- [ ] **TSK-BE-02: Implement Customer Registration & Profile**:
  - Build `POST /v1/auth/register/customer` supporting both OTP-verified and Firebase-authenticated sign-ups.
  - Implement `customerProfile` data handling in `MeService` and `GET/PATCH /v1/me`.
- [ ] **TSK-BE-03: Platform Config Endpoint**:
  - Implement `GET /v1/platform-config` to serve platform settings (`requestLifetimeHours`, `bullionMinimumAed`, `offerValidityHours`, etc.) from `platform_setting`.

### Phase B: Customer Requests (P6)
- [ ] **TSK-BE-04: Request Domain Entity & State Machine**:
  - Implement pure domain state transition table for Request (`DRAFT` -> `PUBLISHED` -> `OFFERS_RECEIVED` -> `ACCEPTED` -> `CLOSED` / `EXPIRED` / `CANCELLED`).
- [ ] **TSK-BE-05: Request CRUD Endpoints**:
  - Implement `POST /v1/requests` (draft creation with optional attributes).
  - Implement `PATCH /v1/requests/:id` enforcing `BR-014` (draft vs published field immutability).
  - Implement `GET /v1/me/requests` and `GET /v1/requests/:id` with Customer presenter.
- [ ] **TSK-BE-06: Request Publish & Validation**:
  - Implement `POST /v1/requests/:id/publish` checking OAuth/Auth gate, media readiness, bullion floor, contact details scanner (`BR-022`), and emitting `request.published` outbox event.
- [ ] **TSK-BE-07: Request Cancellation & Duplication**:
  - Implement `POST /v1/requests/:id/cancel` and `POST /v1/requests/:id/duplicate`.

### Phase C: Matching Engine & Vendor Feed (P7)
- [ ] **TSK-BE-08: Matching Fan-Out Worker**:
  - Implement worker consuming `request.published`: queries eligible `ACTIVE` vendors with matching categories, regions, and active subscriptions; inserts rows into `request_match`.
- [ ] **TSK-BE-09: Vendor Feed Endpoints**:
  - Implement `GET /v1/matches` with filters (type, karat, weight, budget), sorting, and `pg_trgm` full-text search.
  - Implement `POST /v1/matches/:id/viewed` to track viewed status.
- [ ] **TSK-BE-10: Match Set Recompute**:
  - Implement handler for `vendor.eligibility.changed` to re-index live requests for newly activated or subscribed vendors.

### Phase D: Offers & Bidding (P8)
- [ ] **TSK-BE-11: Offer Domain & Submission**:
  - Implement `POST /v1/requests/:id/offers` enforcing 1 pending offer per vendor (`BR-009`), validity hours clamp, and note text contact scan.
- [ ] **TSK-BE-12: Offer Revisions & Withdrawal**:
  - Implement `POST /v1/offers/:id/revise` (recording `offer_revision`, max 3 revisions) and `POST /v1/offers/:id/withdraw`.
- [ ] **TSK-BE-13: Offer Presenters & Lists**:
  - Implement `GET /v1/requests/:id/offers` (Customer view, masking vendor identities) and `GET /v1/me/offers` (Vendor view, masking competitor terms).
  - Implement `GET /v1/offers/:id/vendor-rating` (`FR-CUS-031`).

### Phase E: Acceptance & Connections Commercial Spine (P9)
- [ ] **TSK-BE-14: Acceptance Atomic Transaction**:
  - Implement `POST /v1/offers/:id/accept` with `SELECT FOR UPDATE` concurrency lock on Request:
    1. Transition Offer to `ACCEPTED`.
    2. Transition Request to `ACCEPTED`.
    3. Transition competing pending Offers to `REJECTED`.
    4. Create `Connection` record with `identity_revealed_at = now()`.
    5. Write `IDENTITY_REVEALED` audit log.
    6. Emit outbox notifications for winner and rejected vendors.
- [ ] **TSK-BE-15: Offer Decline**:
  - Implement `POST /v1/offers/:id/decline` with optional `DeclineReason`.
- [ ] **TSK-BE-16: Connections & Talk Handoff**:
  - Implement `GET /v1/me/connections` and `GET /v1/connections/:id` generating the WhatsApp handoff link (`talk.waUrl`).
  - Implement `POST /v1/connections/:id/close` and `POST /v1/connections/:id/contact-events`.
- [ ] **TSK-BE-17: Acceptance Concurrency Integration Test**:
  - Implement rigorous concurrency test (`test/concurrency/accept.spec.ts`) asserting two simultaneous accept requests produce exactly 1 connection and 1 409 conflict.

### Phase F: Reviews, Abuse & Notifications (P10)
- [ ] **TSK-BE-18: Review Lifecycle**:
  - Implement `POST /v1/connections/:id/reviews` (hold-for-approval `PENDING_MODERATION`), `PATCH /v1/reviews/:id`, `POST /v1/reviews/:id/response`, `POST /v1/reviews/:id/flag`.
- [ ] **TSK-BE-19: Rating Aggregation Worker**:
  - Implement worker recalculating vendor `aggregate_rating`, `review_count`, and 6-month `ratingTrend`.
- [ ] **TSK-BE-20: Abuse Reporting**:
  - Implement `POST /v1/abuse-reports` with caller identity masked.
- [ ] **TSK-BE-21: In-App Notification Center & Push**:
  - Implement `GET /v1/notifications`, `POST /v1/notifications/:id/read`, and `NotificationDispatcher` handling the 21 outbox event triggers.

### Phase G: Admin Operations (P11)
- [ ] **TSK-BE-22: Vendor Verification Back-Office**:
  - Implement `GET /v1/admin/vendors`, `GET /v1/admin/vendors/:id`, and decision endpoints (`POST /v1/admin/vendors/:id/verify`, `/reject`, `/request-info`).
- [ ] **TSK-BE-23: Request / Offer / Review Moderation**:
  - Implement back-office moderation endpoints: review approval/rejection, connection closure, customer suspension/reactivation.
- [ ] **TSK-BE-24: Platform Settings & Audit Log Viewer**:
  - Implement `GET /v1/admin/audit-log` and `PATCH /v1/admin/settings/:key`.

### Phase H: Gold Rates & Scheduled Workers (P12)
- [ ] **TSK-BE-25: Gold Rate Ingestion & Manual Override**:
  - Implement Yahoo Finance rate polling adapter (15-minute cron), manual admin override, and `GET /v1/gold-rates`.
- [ ] **TSK-BE-26: Scheduled Cron Workers Registration**:
  - Register all 15 background jobs (`outbox-drain`, `media-processing`, `request-draft-purge`, `offer-expiry-sweep`, `offer-expiry-warning`, `request-expiry-sweep`, `request-expiry-warning`, `retention-purge`, `rating-reconcile`, `notification-retry`, etc.) on `SchedulerModule` using `job_lock`.
- [ ] **TSK-BE-27: OpenAPI Generation & Contract Gates**:
  - Configure NestJS/Zod OpenAPI generator and establish CI contract test suite.

---

## 6. Verification Status

| Verification Area | Method | Result | Notes |
|---|---|---|---|
| **TypeScript Compilation** | `npm run build` (`nest build`) | **PASS** (0 errors) | Strict mode clean. |
| **Unit Test Suite** | `npm test` (`vitest run`) | **PASS** (20 files, 130 tests) | 100% green across edge, platform, identity, taxonomy, and masking tests. |
| **Linting & Code Style** | `npm run lint` (`eslint src`) | **PASS** (0 errors, 0 warnings) | Boundaries and style clean. |
| **Database Schema** | `npx prisma validate` | **PASS** | Validated against PostgreSQL 16 schema. |
| **Integration Test Suite** | `npm run test:integration` | **LOCAL DB REQUIRED** | Suites test against PostgreSQL with pgcrypto & pg_trgm. |
