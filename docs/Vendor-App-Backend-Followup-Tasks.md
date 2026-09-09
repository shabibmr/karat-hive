# Vendor App Backend Follow-up — Task Register

| | |
|---|---|
| **Product** | Karat Hive |
| **Document** | Remaining **backend** code work extracted from [`Vendor-App-Completion-Tasks.md`](Vendor-App-Completion-Tasks.md) |
| **Status** | Working backlog — validated against `backend/` on 8 September 2026 |
| **Branch checked** | `feat/vendor-app-completion` |
| **Plan of record** | [`Vendor-App-Completion-Plan.md`](Vendor-App-Completion-Plan.md) |
| **Does not override** | SRS v1.3 · `API-Route-Inventory.md` · `Architecture-Backend.md` · `Async-Contract.md` |
| **IDs** | Original `CPn-A*` IDs kept. Never reused. |

This file is **backend-only**. Flutter remainders (`CPn-B*`, `VEN-S14` / `S15` / `S17`–`S21`) stay in the Vendor task register.

Legend: **open** (code change still required) · **partial** (route/module exists, acceptance incomplete).

Suggested order: **CP4-A06 → CP5-A02 → CP5-A04 → CP5-A05 / CP6-A03 → CP6-A01 → CP6-A02 → CP3-A08 → CP6-A06**.

---

## How this was validated

Every Track A / backend-test ID in the Vendor register was checked against controllers, services, jobs in `main.ts`, Prisma, and `backend/test/`. Items whose acceptance is already met are listed in [Appendix A](#appendix-a--landed-do-not-reopen) so the 7 Sep register tags (`open` on CP-4/5/6) are not treated as work.

---

## Remaining — CP-3 Bid

### CP3-A08 — Offer integration suite (partial)

| | |
|---|---|
| **Register acceptance** | `backend/test/integration/vendor-offers.spec.ts`: submit, already-pending, revision limit, contact scan, withdraw, awardedElsewhere masking. Against CI Postgres. |
| **On disk now** | File exists. Covers submit, `OFFER_ALREADY_PENDING`, revision ×3 + `OFFER_REVISION_LIMIT`, `CONTACT_DETAILS_IN_TEXT`, withdraw. |
| **Gap** | `awardedElsewhere` case is a **static object assertion**, not a live accept-then-list. No coverage of expiry sweep / T−6 h warning (`CP3-V01`). |
| **Files** | `backend/test/integration/vendor-offers.spec.ts`; reuse `helpers.ts` + `insertPublishedRequest` / accept via Customer session. |
| **Accept** | After Customer accepts Offer A, Vendor B’s `GET /v1/me/offers?tab=CLOSED` row has `awardedElsewhere: true` and **no** winning price or winner identity (`BR-008`). An Offer left past `expires_at` is `EXPIRED` after `sweepExpiredOffers`; `expiry_warned_at` is set once by `sweepExpiryWarnings`. |

---

## Remaining — CP-4 Win and talk

### CP4-A06 — Accept concurrency + idempotent replay (open)

| | |
|---|---|
| **Register acceptance** | `backend/test/integration/acceptance-concurrency.spec.ts`. Two simultaneous accepts on the same Request produce exactly one Connection and one `ACCEPTED` Offer (`BR-011`). Idempotent replay of accept returns the **first result**. |
| **On disk now** | Product path is real: `ConnectionService.acceptOffer` locks the Request `FOR UPDATE`, rejects competitors, inserts one Connection, emits `offer.accepted` with `rejectedOfferIds` and no competitor price (`connection.service.ts`). |
| | Test on disk is `backend/test/concurrency/accept.spec.ts` — **in-memory mock**, not HTTP against CI Postgres. Named integration file is absent. |
| | Replay of accept on an already-`ACCEPTED` Request throws `OFFER_ALREADY_ACCEPTED` (`connection.service.ts` ~L82–84). Register requires returning the first Connection/Offer, not a conflict. |
| **Files** | `backend/src/modules/connections/application/connection.service.ts`; new `backend/test/integration/acceptance-concurrency.spec.ts` (move or replace the mock spec). |
| **Accept** | Two parallel `POST /v1/offers/{id}/accept` (two Customers **or** two in-flight calls on the same Offer/Request) yield exactly one `connection` row and one `ACCEPTED` offer. A second accept of the **same** Offer with the same confirmation returns the original `{ offer, connection }` (idempotent), not `OFFER_ALREADY_ACCEPTED`. A second accept of a **competitor** Offer still conflicts. |

---

## Remaining — CP-5 Reputation

### CP5-A02 — Abuse: three-Vendor auto-flag (partial)

| | |
|---|---|
| **Register acceptance** | `POST /v1/abuse-reports` (`CV`). Reporter identity withheld from the reported party. **Three distinct Vendor reports on one Request auto-flag it for priority Admin review.** Rate limit applied. |
| **On disk now** | `AbuseController` + `AbuseService.submitReport`: `CUSTOMER`/`VENDOR` entity types work (`CP5-A01` landed). Rate limit 5 / 24 h → `RATE_LIMITED`. Acknowledgement body has no reporter identity. |
| | `AbuseReport` has **no** priority column. `submitReport` never counts distinct Vendor reporters on a Request. Grep for priority / auto-flag in `backend/src` is empty. |
| **Files** | `backend/src/modules/abuse/application/abuse.service.ts`, `abuse.repository.ts`; `backend/prisma/schema.prisma` `AbuseReport` and/or `Request` (priority flag — do not invent a column name that is not in `Physical-Data-Model.md` / `SAM-GAP`; if the model has no field, add the one the physical model already proposes, or document the `[PROPOSED]` column in this file’s PR). Admin list already reads `GET /v1/admin/abuse-reports`. |
| **Accept** | Three different `VENDOR` reporters on the same `entityType=REQUEST` raise the priority flag. A fourth report does not duplicate it. Two reports, or three from the **same** Vendor, do not. `GET` of the report (Admin) never includes `reporterUserId` of another party. Rate limit unchanged. |

### CP5-A04 — Review response: second attempt → `CONFLICT` (partial)

| | |
|---|---|
| **Register acceptance** | `POST /v1/reviews/{id}/response` (`V`). One response per review, ≤500 chars, held for approval. Second attempt → `CONFLICT`. Flag re-enters Admin queue; review stays visible. |
| **On disk now** | Response route exists; body max 500. `addVendorResponse` writes `vendorResponseState: PENDING_MODERATION`. Flag creates an `abuse_report` and does not hide the review. |
| | `respondToReview` does **not** check an existing response. `addVendorResponse` is a blind `update` and **overwrites**. Second POST succeeds. |
| **Files** | `backend/src/modules/reviews/application/review.service.ts` (`respondToReview`); optionally `review.repository.ts`. |
| **Accept** | First response → `PENDING_MODERATION`. Second → HTTP 409 `CONFLICT`. Empty/oversize body still `VALIDATION_FAILED`. Flag path unchanged. |

### CP5-A05 — `ratingTrend` on Vendor performance + recompute consumer (partial)

| | |
|---|---|
| **Register acceptance** | Consumer `reviews:rating-recompute`; job `rating-reconcile` (5 min). Aggregate to 1 dp with distribution. Adds `ratingTrend: {period, average, count}[]` to **`GET /v1/me/vendor/performance`**. |
| **On disk now** | `buildSixMonthRatingTrend` writes `vendor_profile.rating_trend`. Admin approve/reject calls `recalculateRatings` inline. Job `rating-reconcile` is registered in `main.ts`. |
| | **No** outbox consumer named `reviews:rating-recompute` (`reviews.module.ts` has no `OnModuleInit` registration). |
| | `SubscriptionRepository.getVendorPerformance` returns `{ offersSubmitted, acceptanceRate, averageResponseMinutes, byOutcome }` only — **no `ratingTrend`**. Shared with `CP6-A03`. |
| **Files** | `backend/src/modules/reviews/` (consumer on `review.published` / `review.moderated`); `backend/src/modules/subscription/repository/subscription.repository.ts` + presenter/controller for `GET /v1/me/vendor/performance`. |
| **Accept** | After a review is moderated to `PUBLISHED`, either the consumer or the inline path updates aggregates; the 5 min job remains the safety net. `GET /v1/me/vendor/performance` includes `ratingTrend` of six `{ period, average, count }` points. Average is 1 decimal place. |

---

## Remaining — CP-6 Run the business

### CP6-A01 — Settings: default filter preset + locked categories (partial)

| | |
|---|---|
| **Register acceptance** | `GET/PATCH /v1/me/settings` (`C/V`). Language, notification preferences by category, channel preferences, quiet-hours window, **default filter preset**. Security-critical categories locked on. |
| **On disk now** | `SettingsController` GET/PATCH: `preferredLanguage`, `quietHours`, `notifications`, `defaultRegionId`. |
| | DTO type has `defaultFilterPresetId` but **GET does not return it** and **PATCH schema / `updateUserSettings` never persist it**. `FilterPreset` has no `isDefault`. `User` has no `default_filter_preset_id`. |
| | PATCH of `notifications` upserts whatever the client sends — **no lock** on security-critical categories. |
| **Files** | `backend/prisma/schema.prisma` (persist the default on Vendor settings or `filter_preset.is_default` — one default per Vendor); `settings.controller.ts` `patchSettingsSchema`; `settings.service.ts` / `settings.repository.ts`; `filter-presets.service.ts` if the mark-default lives there. Inventory § settings for the lock list. |
| **Accept** | Round-trip `defaultFilterPresetId` (null clears). Marking a second preset default unsets the first. PATCH that turns off a locked category is ignored or `SETTING_OUT_OF_RANGE` / `FORBIDDEN` — locked stay on. Language and quiet hours unchanged. |

### CP6-A02 — `POST /v1/auth/password` (partial)

| | |
|---|---|
| **Register acceptance** | `GET/DELETE /v1/auth/sessions[/{id}]` (`C/V/A`), `POST /v1/auth/password`. Session list with device and last-seen; revoke one. Password set/change → `PASSWORD_POLICY` on violation. |
| **On disk now** | `GET /v1/auth/sessions` and `DELETE /v1/auth/sessions/:id` exist (`auth.controller.ts`). `User.passwordHash`, `failedLoginAttempts`, `lockedUntil` exist. `ScryptPasswordHasher` exists. |
| | **No** `POST /v1/auth/password` (and no `POST /v1/auth/login/password` on this controller). `ErrorCode` has **no** `PASSWORD_POLICY`. |
| **Files** | `backend/src/modules/identity/controller/auth.controller.ts`; new application method (hasher already injected at platform); `backend/src/edge/errors/error-codes.ts`; inventory §5 if the code is already catalogued. |
| **Accept** | Authenticated Vendor can set or change password. Policy violation → `PASSWORD_POLICY`. Sessions list/revoke behaviour unchanged. Do not add a password **login** path that contradicts `adr/0010` (Google Sign-In) unless inventory already requires it — this task is **set/change**, not a new login method. |

### CP6-A03 — Performance aggregates (partial)

| | |
|---|---|
| **Register acceptance** | `GET /v1/me/vendor/performance` (`V`): `offersSubmitted`, `acceptanceRate`, `averageResponseMinutes` (publish → submit), `averageOfferedVsAccepted?`, `byOutcome[]`, `ratingTrend[]`. `averageOfferedVsAccepted` is a **period aggregate**, never per-Request (`BR-008`). |
| **On disk now** | Route exists (`SubscriptionController.getVendorPerformance`). Computes the four core fields. Interface declares `averageOfferedVsAccepted?` but **never sets it**. `ratingTrend` missing (see `CP5-A05`). |
| **Files** | `backend/src/modules/subscription/repository/subscription.repository.ts` (and service if it maps the view). |
| **Accept** | Response includes all listed fields. `averageOfferedVsAccepted` is one number (or omitted when no accepted Offers in range) — **not** a per-Request pair with a competitor price. `ratingTrend` matches `CP5-A05`. Filters `from`/`to`/`requestType`/`categoryId`/`regionId` already on the query string stay. |

### CP6-A06 — Settings / performance integration suite (open)

| | |
|---|---|
| **Register acceptance** | `backend/test/integration/vendor-settings.spec.ts`: settings round-trip, session revoke, password policy, performance aggregates, export signing. Masking spec covers the export. |
| **On disk now** | File **absent**. Unit tests exist for gold-rate, platform-config, session, CSV builder (`vendor-performance-csv.spec.ts`). Export route `GET /v1/me/vendor/performance/export` **is landed** (`CP6-A04`) — this task only needs to **test** it plus the items above. |
| **Files** | `backend/test/integration/vendor-settings.spec.ts`; extend `backend/test/masking/` if the export CSV could leak a counterparty. |
| **Accept** | Suite green against CI Postgres. Covers: settings round-trip including default preset (after `CP6-A01`); revoke session → that refresh is rejected; `PASSWORD_POLICY` (after `CP6-A02`); performance body has no per-Request competitor figure; export returns `{ downloadUrl, expiresAt }` of this Vendor’s rows only. |

Depends on `CP6-A01`, `CP6-A02`, `CP6-A03` (and `CP5-A05` for `ratingTrend`).

---

## Out of this register

| Item | Why |
|---|---|
| All `CPn-B*` / `CPn-F*` / `CPn-V*` | Flutter or manual walk-through |
| `CP2-I01` TL sign-off of `T36` | Process; schema already applied (`CP3-A01`) |
| `CP5-I01` `docs/Notification-Catalogue.md` | Docs, not backend code. Dispatcher ships placeholder copy |
| Turning on `goldRates.endUserDisplay` | `[BLOCKED]` on Yahoo Finance terms (`AD-API-09`). Module and flag **exist** (`CP6-A05`) |
| Customer or Admin screens | Out of Vendor scope |

---

## Appendix A — Landed; do not reopen

The 7 Sep Vendor register still tags these **open**. Code already meets the stated acceptance (Vendor path). Do not rebuild them.

| ID | Evidence |
|---|---|
| CP2-A01–A15 | Matching, presets, dashboard, masking, `vendor-feed.spec.ts` |
| CP3-A01–A07 | Offers module, 12/24/48 CHECK, expiry jobs in `main.ts` |
| CP4-A01 | `POST /v1/offers/:id/accept` — real Customer transaction, not a dev harness |
| CP4-A02 | `POST /v1/offers/:id/decline` + `declineReason` on Vendor presenter |
| CP4-A03 | `GET /v1/me/connections`, `GET /v1/connections/:id`, `talk.waUrl`, `IDENTITY_REVEALED` audit |
| CP4-A04 | `POST /v1/connections/:id/contact-events` — `WHATSAPP\|PHONE` only; closed → `CONNECTION_CLOSED` |
| CP4-A05 | `POST /v1/connections/:id/close` emits `connection.closed` |
| CP4-A07 | `backend/test/masking/connection-scoped-reveal.spec.ts` (+ offer/connection customer masking integration) |
| CP5-A01 | `AbuseEntityType` includes `CUSTOMER` and `VENDOR` |
| CP5-A03 | `POST /v1/connections/:id/reviews`, `GET /v1/me/reviews`, `BR-016`/`BR-017` |
| CP5-A06 | `GET /v1/notifications`, `POST …/read`, plus implemented `[PROPOSED]` `read-all` and `unread-count` |
| CP5-A07 | `notifications:dispatch` registered for consumer events; FCM adapter; quiet hours; no competitor price in plans |
| CP5-A08 | `POST /v1/devices`, `DELETE /v1/devices/:id`, job `notification-retry`. Client wires token on sign-in (not a missing route) |
| CP5-A09 | Jobs `request-expiry-warning` and `vendor-document-expiry` (`reminderSentAt` guard, 30-day window) |
| CP6-A04 | `GET /v1/me/vendor/performance/export` → signed `{ downloadUrl, expiresAt }`, own rows, no competitor identity |
| CP6-A05 | `GET /v1/gold-rates` + poll / stale-alert jobs; `isEndUserDisplayEnabled` ships **off** |

---

## Appendix B — Mapping to impl-plan `T`-IDs

Vendor-path only. Tick the `T`-ID when the **remainder in this file** is done, not when the original register row was first opened.

| Remainder | Impl-plan |
|---|---|
| CP4-A06 | `T25` (and idempotent replay of `T23`) |
| CP5-A02 | `T27` remainder |
| CP5-A04 | `T26` remainder (response uniqueness) |
| CP5-A05 | `T26` remainder (`ratingTrend` + consumer) |
| CP6-A01 / A02 | `T15` remainder |
| CP6-A03 | performance fields for `FR-VEN-023` / `VEN-S14` / `VEN-S20` |
| CP6-A06 | tests for the `T15` remainder |
| CP3-A08 | `T22` test remainder |
