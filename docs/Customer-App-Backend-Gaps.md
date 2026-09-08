# Karat Hive — Backend gaps for the Customer App

| | |
|---|---|
| **Product** | Karat Hive |
| **Document** | Backend changes required (or recommended) to unblock the Customer mobile app (`CUS-S01`…`CUS-S22`) |
| **Status** | Working note — raised from the `feat/customer-app` branch, checked against the `main` working tree on 8 September 2026 |
| **Author** | shabibmr (via Claude Code) |
| **Does not override** | SRS v1.3 · [`API-Route-Inventory.md`](API-Route-Inventory.md) · [`Screen-API-Map.md`](Screen-API-Map.md) · [`adr/0010`](adr/0010-google-signin-only-login.md) |
| **Scope** | Customer-facing endpoints only. No Vendor / Admin work is described here. |

The Customer-side API is in good shape: `requests`, `offers`, `connections`, `reviews`, `abuse`,
`media`, `notifications`, `settings`, and the Customer branch of `identity` (`GET/PATCH /v1/me`,
`register/customer`, `google/session`, `mobile/change`, `deactivate`, `deletion-requests`) are all
committed on `main` with role presenters and the full customer error-code set
(`CONTACT_DETAILS_IN_TEXT`, `BULLION_BELOW_MINIMUM`, `CONCURRENT_REQUEST_LIMIT`,
`STRUCTURAL_FIELD_IMMUTABLE`, `OFFER_EXPIRED`, `REVIEW_ALREADY_EXISTS`, …).

What follows is the short list of things the Customer app will actually hit that are **not** ready.

---

## 1. Blocking — must be built before the screen that needs it

### CBG-01 · `unreadOfferCount` on `RequestForCustomer` list rows (`SAM-GAP-1`)

- **Screens:** `CUS-S02` Home (per-Request unread badge), `CUS-S11` Offers list (list-level count).
- **State today:**
  - `OfferForCustomer.viewedByCustomerAt` — **built** (`offer.presenter.ts:167`).
  - `POST /v1/offers/:id/viewed` — **built** (`offers` controller).
  - `RequestForCustomer.unreadOfferCount` — **missing**. `request.presenter.ts` exposes
    `offerCount` only; `listForCustomer` does no unread aggregation.
- **Required change:** add `unreadOfferCount` to `RequestForCustomer` (both the `GET /v1/me/requests`
  list rows and `GET /v1/requests/:id`), computed as
  `count(offers where state = PENDING and viewedByCustomerAt is null)`.
  Keep it a presenter-time aggregate (no denormalised column) to stay consistent with the
  `connectionId` join approach already used for `SAM-GAP-3`.
- **Acceptance:** a published Request with 3 pending offers, none viewed → `unreadOfferCount: 3`;
  after `POST /v1/offers/{one}/viewed` → `2`; an accepted/expired offer never counts.

---

### CBG-08 · Nested `offers` on `RequestForCustomer` are hard-stubbed to `[]`

- **Screens:** `CUS-S10` Request detail (owner presenter, offers shown inline per `Screen-API-Map` §3).
- **State today:** `requests/presenter/request.presenter.ts` `presentRequestForCustomer()` sets
  `res.offers = []` unconditionally — even when the caller passes `includeOffers` — with a
  `// TODO` marker. `GET /v1/requests/:id` therefore never carries the nested offer array.
- **Impact:** `CUS-S10` cannot render the offers block from the detail payload. A workaround
  exists — the client can call `GET /v1/requests/:id/offers` (built, used by `CUS-S11` / `CFE-23`)
  as a second request — so this is **blocking-as-speced, not blocking-in-practice**.
- **Required change:** populate `res.offers` from the already-loaded relation when `includeOffers`
  is set, mapped through `presentOfferForCustomer` (masked vendor, `viewedByCustomerAt`,
  `unreadOfferCount` semantics per CBG-01). No new query — `findByIdForCustomer` already includes
  the offers relation for `offerCount` / `unreadOfferCount`.
- **Acceptance:** `GET /v1/requests/:id?includeOffers` on a published Request with 2 pending offers
  returns `offers` with 2 masked entries; vendor identity fields absent until Acceptance (CBG-07).

### CBG-09 · `ConnectionController` is missing `@RevealsIdentity()` — Accept flow returns `500`

- **Screens:** `CUS-S14` Accept, `CUS-S15` Connection detail, `CUS-S16` Connections list, `CUS-S18`
  review entry (reads the Connection). This is the **commercial spine** (`BR-011`–`BR-013`).
- **Found by:** CBG-07 integration test (`test/masking/offer-connection-customer-masking.integration.spec.ts`).
- **State today:** `connections/controller/connection.controller.ts` (`@Controller('v1')`) carries no
  `@RevealsIdentity()` — not at class level, not on any handler — unlike
  `identity/controller/me.controller.ts:30` (class-level) and `auth.controller.ts` (per-handler).
  The global `MaskingInterceptor` (`edge/masking/masking.interceptor.ts`) scans every response body
  and, finding `legalBusinessName` / `tradingName` / `tradeLicenceNumber` / `displayName` in the
  (correctly revealed) `ConnectionForCustomer` payload, logs
  `Identity key "legalBusinessName" leaked on a masked route` and throws
  `500 INTERNAL`.
- **Effect:** `POST /v1/offers/:id/accept`, `GET /v1/connections/:id`, `GET /v1/me/connections`,
  `POST /v1/connections/:id/close`, `POST /v1/connections/:id/contact-events` all `500`. The DB
  transaction still commits (Acceptance is atomic — invariant 2 holds server-side), but the
  Customer never receives the Connection or the revealed Vendor over HTTP. The Accept→Talk→Review
  path is unusable.
- **Required change:** add `@RevealsIdentity()` at the class level of `ConnectionController` — the
  same reason `MeController` has it. Every connection route is already scoped by the service to a
  Connection the viewer is a party to (`BR-007`), so class-level reveal is consistent with
  invariant 1: identity is revealed *only* inside a Connection the viewer produced.
- **Acceptance:** CBG-07 test 3 (`accept` returns `200` with the Connection) and test 4
  (`GET /v1/connections/:id` carries `vendor.legalBusinessName` + `vendor.phone` to the owner) pass;
  the pre-Connection masking assertions (tests 1–2) still pass unchanged.
- **Effort:** XS — one decorator. **Priority: highest of the open items** — blocks P4/P5 screen work.

### CBG-10 · `PlatformModule` cannot resolve `RoutedPushAdapter` — integration suite dead on boot

- **Screens:** none directly; blocks CI verification of `CBG-06` / `CBG-07` and every existing
  `test/integration/*` and `test/masking/*.integration.spec.ts`.
- **Found by:** booting the real `AppModule` for the CBG-06/07 tests.
- **State today:** `platform/platform.module.ts` binds `PUSH_GATEWAY → RoutedPushAdapter`, whose
  constructor injects `FcmPushAdapter` and `ApnsPushAdapter` (both `@Injectable`, both need only the
  `@Global` `ENV`). Neither is listed in `PlatformModule.providers`, so Nest DI fails:
  `Nest can't resolve dependencies of the RoutedPushAdapter (?, ApnsPushAdapter) … argument
  FcmPushAdapter at index [0] is available in the PlatformModule module` — then a native
  `process.abort()`.
- **Why it hides:** `npm run test` (unit tier) never boots `AppModule`, so it stays green.
  `npm run test:integration` is currently fully broken.
- **Required change:** add `FcmPushAdapter` and `ApnsPushAdapter` to `PlatformModule.providers`
  (no `provide`/`useClass` indirection needed — they are concrete injectables). Zero behaviour
  change. `RoutedPushAdapter` already routes `IOS → APNs`, `ANDROID → FCM`.
- **Acceptance:** `npx vitest run --config vitest.integration.config.ts` boots; the CBG-06/07 specs
  and the pre-existing integration specs run.
- **Effort:** XS — two provider entries.

---

## 2. Recommended — not strictly blocking, but the client works around them otherwise

### CBG-02 · `GET /v1/gold-rates` shape for the create flow (`CUS-S04`…`CUS-S07`)

- The route exists (`v1/gold-rates`). Confirm the payload carries the flags the create screens
  branch on per `Screen-API-Map` rows 59–62: `available:false` (compose still allowed, valuation
  suppressed), `stale:true` (bullion warning), and that `CUS-S07` bullion publish returns
  `GOLD_RATE_UNAVAILABLE` when no rate is present. If any flag is absent, add it — the client must
  not infer staleness from timestamps.
- **Action:** verify against the live response and, if a flag is missing, raise it into the
  inventory §7 before adding.

### CBG-03 · `POST /v1/offers/:id/viewed` semantics

- Confirm this endpoint is idempotent and only settable by the owning Customer, sets
  `viewedByCustomerAt` once (first write wins), and is a no-op on a terminal offer. The client will
  call it on every offer-detail open (`CUS-S13`) and on bulk list render (`CUS-S11`).

---

## 3. Documentation drift to fix (no code)

### CBG-04 · `Screen-API-Map.md` still cites `POST /v1/auth/oauth/bind`

- Rows `CUS-S01` and `CUS-S09` reference `POST /v1/auth/oauth/bind` and `OAUTH_REQUIRED` as a
  bind-then-publish step. Under [`adr/0010`](adr/0010-google-signin-only-login.md) (Google is the
  only login) there is no separate bind step — `register/customer` + `google/session` cover it,
  and an unbound Google token returns `401 UNAUTHENTICATED` rather than provisioning.
- **Action:** update the two `CUS-S01` / `CUS-S09` rows and the `oauth/bind` mentions to the
  Google-session flow. `publish` still legitimately returns `OAUTH_REQUIRED` when the Customer has
  no Google binding — keep that.

### CBG-05 · Stale "partial" notes in `Backend-Implementation-Plan.md`

- `SAM-GAP-3` (`connectionId?` on `RequestForCustomer`) is marked "Partial — GET does not join it".
  It **is** joined now: `request.repository.ts` includes `acceptedOfferConnectionInclude` on
  `findById`, `findByIdForCustomer`, and `listForCustomer`, and
  `connectionIdForAcceptedRequest()` derives it. Mark resolved.
- `SAM-GAP-4` (abuse `VENDOR` / `CUSTOMER` entity types) is built (`abuse.controller.ts` enum,
  `abuse.repository.ts` switch). Mark resolved.
- `SAM-GAP-5` (`legal`/`support` URLs) is built — `platform-config.query.ts` returns `termsUrl`,
  `privacyUrl`, `supportContactUrl`. Mark resolved.

---

## 4. Test coverage the Customer vertical will want

### CBG-06 · Customer Google round-trip integration test (`G2-I13`)

- Already tracked in `Backend-Gap-Tasks.md` as open. Google ID token → `google/session` →
  `register/customer` (terms + real mobile) → `GET /v1/me` returns a `customer` profile with
  `liveRequestCount` / `canCreateRequest` / `oauthBound`. Needed before the app's auth flow can be
  trusted end to end.

### CBG-07 · Masking release-gate on the Offer/Connection customer path

- `test/masking/` covers the matches feed. Add an HTTP-level assertion that a Vendor's
  `mobileNumber` / `displayName` / `legalBusinessName` is **absent** from `GET /v1/requests/:id`
  (owner presenter, offers nested) and `GET /v1/offers/:id` until the Connection exists, and
  present on `GET /v1/connections/:id` after Acceptance. This is the Customer-side mirror of
  `FR-VEN-011` and guards domain invariant 1.

---

## Summary

| ID | Type | Screen(s) | Effort |
|---|---|---|---|
| CBG-01 | Blocking | CUS-S02, CUS-S11 | S — one presenter aggregate + list query |
| CBG-08 | Blocking-as-speced (client workaround exists) | CUS-S10 | S — populate `res.offers` from the loaded relation |
| CBG-09 | Blocking — Accept flow `500`s | CUS-S14, CUS-S15, CUS-S16, CUS-S18 | XS — one `@RevealsIdentity()` decorator |
| CBG-10 | Blocking (test infra) | — | XS — two provider entries in `PlatformModule` |
| CBG-02 | Verify / maybe build | CUS-S04–S07 | S |
| CBG-03 | Verify | CUS-S11, CUS-S13 | XS |
| CBG-04 | Doc | CUS-S01, CUS-S09 | XS |
| CBG-05 | Doc | — | XS |
| CBG-06 | Test | auth | M |
| CBG-07 | Test | CUS-S10, CUS-S13, CUS-S15 | M |

**CBG-01** blocks `CUS-S02` / `CUS-S11`. **CBG-08** blocks `CUS-S10` only as speced — the client
can fetch offers via `GET /v1/requests/:id/offers` in the interim. Everything else can proceed in
parallel with the Flutter build.

### Status (8 September 2026)

| ID | State |
|---|---|
| CBG-01 | **Done** (uncommitted) — `unreadOfferCount` filtered `_count` on `GET /v1/me/requests` + `GET /v1/requests/:id`; +5 vitest |
| CBG-02 | **Done** (uncommitted) — `stale:true` added to the display-not-licensed gold-rates payload |
| CBG-03 | **Done** (uncommitted) — `state:'PENDING'` guard on `/offers/:id/viewed`; idempotency + owner-only already enforced |
| CBG-04 | **Done** — `Screen-API-Map.md` CUS-S01/S09 rows on the `google/session` + `register/customer` flow |
| CBG-05 | **Done** — `Backend-Implementation-Plan.md` SAM-GAP-3/4/5 marked resolved with source pointers |
| CBG-06 | **Done** (uncommitted) — `test/integration/customer-google-roundtrip.spec.ts` (2 tests); needs CBG-10 to run in CI |
| CBG-07 | **Done** (uncommitted) — `test/masking/offer-connection-customer-masking.integration.spec.ts` (4 tests; test 4 is an `it.fails` tripwire that flips green when CBG-09 lands); needs CBG-10 to run in CI |
| CBG-08 | **Open** — raised 8 Sep 2026 |
| CBG-09 | **Open** — raised 8 Sep 2026 · highest priority · one decorator |
| CBG-10 | **Open** — raised 8 Sep 2026 · one module edit |
