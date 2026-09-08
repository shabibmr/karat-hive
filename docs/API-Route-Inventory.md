# Karat Hive — API Route Inventory

| | |
|---|---|
| **Product** | Karat Hive — Digital Jewellery Marketplace |
| **Document** | HTTP API Route Inventory (pre-code contract) |
| **Version** | 0.3 |
| **Status** | Draft — `[PROPOSED]`. Technical Lead sign-off required before it becomes binding. |
| **Date** | 8 September 2026 |
| **Source of truth** | [`docs/Requirements-Spec-v1.3.md`](Requirements-Spec-v1.3.md) · [`CONTEXT.md`](../CONTEXT.md) · [`docs/Architecture-Backend.md`](Architecture-Backend.md) §13–§16 |
| **Superseded by** | Generated OpenAPI (`NFR-030`, `AD-BE-14`) once application code exists. Until then this document is the catalogue the clients may design against. |
| **Companion** | [`docs/Screen-API-Map.md`](Screen-API-Map.md) — screen-by-screen coverage check of this inventory; open gaps tracked as `SAM-GAP-nn`. |
| **Identifier prefix** | `AD-API-nn` — decisions made by *this* document. Stable, never reused. |

---

## Table of Contents

1. [Purpose and status](#1-purpose-and-status)
2. [Decision register](#2-decision-register)
3. [Conventions](#3-conventions)
4. [Shared types](#4-shared-types)
5. [Error catalogue](#5-error-catalogue)
6. [Route index](#6-route-index)
7. [Health](#7-health)
8. [Authentication and sessions](#8-authentication-and-sessions)
9. [Current user (`/v1/me`)](#9-current-user-v1me)
10. [Taxonomy and platform config](#10-taxonomy-and-platform-config)
11. [Reference gold rates](#11-reference-gold-rates)
12. [Media](#12-media)
13. [Requests](#13-requests)
14. [Match set (Vendor feed)](#14-match-set-vendor-feed)
15. [Offers](#15-offers)
16. [Connections and Talk](#16-connections-and-talk)
17. [Reviews](#17-reviews)
18. [Notifications](#18-notifications)
19. [Abuse reports](#19-abuse-reports)
20. [Vendor onboarding, profile and subscriptions](#20-vendor-onboarding-profile-and-subscriptions)
21. [Admin (`/v1/admin`)](#21-admin-v1admin)
22. [FR → route traceability](#22-fr--route-traceability)
23. [Open items and spec tensions](#23-open-items-and-spec-tensions)

---

## 1. Purpose and status

The SRS (`§7.5`) and the backend architecture (`§13`) fix **style**, not the catalogue. `NFR-030` / `AD-BE-14` say the authoritative OpenAPI is **generated from code**. This document is the missing middle: a near-OpenAPI inventory so Flutter clients and the Node monolith can be implemented without inventing paths independently.

**This document does not invent product behaviour.** Every route cites one or more `FR-*` / `BR-*` / `NFR-*`. Where the SRS is silent and a route is still required to make a screen work, the route is tagged `[ASSUMED]` (product) or `[PROPOSED]` (engineering). Appendix B.3 unsigned FRs are included as **full schemas**, not stubs — they remain `[ASSUMED]` until Product Owner sign-off.

Domain nouns follow `CONTEXT.md` exactly. A Request is never a listing; an Offer is never a bid; a Connection is never a chat; Talk is never a message.

---

## 2. Decision register

Decisions made by this document. Status `Proposed` needs Technical Lead sign-off. `Locked` means the user confirmed it before this draft was written.

| ID | Decision | Status |
|---|---|---|
| `AD-API-01` | All Admin traffic lives under `/v1/admin/…`. Marketplace paths never accept an Admin token, and Admin paths never accept a Customer or Vendor token. | Locked |
| `AD-API-02` | Marketplace resources are **shared** (`GET /v1/requests/{id}`, `GET /v1/offers/{id}`, `GET /v1/connections/{id}`) with **role-specific presenters**. Collections are role-specific (`GET /v1/me/requests`, `GET /v1/matches`, `GET /v1/me/offers`, `GET /v1/me/connections`). | Locked |
| `AD-API-03` | Admin RBAC is **coarse**: JWT `role = ADMIN` only. Super Admin / Operations / Analyst columns from `FR-ADM-002` are **not** modelled in v1. Every Admin endpoint is equally available to every Admin. | Locked |
| `AD-API-04` | Type Subscriptions are **Admin-granted** after off-platform payment. Vendors have a read-only collection. There is no in-app checkout. | `[PROPOSED]` (product mechanism not in the SRS) |
| `AD-API-05` | Monetary amounts are JSON **strings** of decimal AED (`"1250.00"`), never native floats. Weights are strings of grams (`"12.50"`). | `[PROPOSED]` |
| `AD-API-06` | State transitions are `POST` sub-resources (`/accept`, `/publish`, `/withdraw`), never a `PATCH` of `state`. | Locked (backend architecture §13.1) |
| `AD-API-07` | Offer `validityHours` allowed values follow `FR-VEN-013` (default **12 / 24 / 48** hours, never later than the parent Request hard expiry). The entity dictionary’s `24 / 48 / 72 / 168` is treated as stale pending SRS alignment — see §23. | `[PROPOSED]` |
| `AD-API-08` | Talk returns a constructed `wa.me` URL. The client opens it. The client then reports a `CONTACT_EVENT`. The server never calls WhatsApp. | Locked (`C-03`, SRS §7.2) |
| `AD-API-09` | `GET /v1/gold-rates` exists for all authenticated Customer and Vendor callers. **Production display of those rates to end users remains `[BLOCKED]`** on Yahoo Finance redistribution terms. Admin configuration is not blocked. | Locked as a legal gate, not a missing route |
| `AD-API-10` | Password-reset for Vendor (and Admin, via another Admin) is included. The SRS does not specify it; login with email/password (`FR-VEN-003`) is unusable without it. | `[ASSUMED]` |
| `AD-API-11` | Cursor pagination on every collection: `?limit=&cursor=`, returning `meta.nextCursor`. `limit` default 20, max 50 (Admin lists max 100). | `[PROPOSED]` (style is SRS/`NFR-002`; numbers are not) |
| `AD-API-12` | Internal Admin notes are a nested resource `POST /v1/admin/{collection}/{id}/notes`. | `[PROPOSED]` |
| `AD-API-13` | Google Sign-In is the **only** login for Customer, Vendor, and Admin. Clients exchange a verified Google ID token at `POST /v1/auth/google/session` (alias `POST /v1/auth/firebase/session`) for a Karat Hive `SessionBundle`. Domain routes accept **only** the Karat Hive access token. Unbound Google identity → `401 UNAUTHENTICATED` (no auto-provision). Admin still cannot self-register. | Locked (`adr/0010`, 6 Sep 2026) |

---

## 3. Conventions

### 3.1 Base URL, versioning, content type

| Aspect | Rule |
|---|---|
| Scheme | HTTPS only in hosted environments. |
| Version | Path prefix `/v1`. Breaking change → `/v2` (`NFR-027`). A deprecated version stays live ≥ 6 months. |
| Content type | `application/json; charset=utf-8` on every request with a body and every response except file downloads (signed URLs, CSV/XLSX exports). |
| Headers in | `Authorization: Bearer <accessJwt>`, `Accept-Language: en \| ar`, `Idempotency-Key: <uuid>` on mutating calls, `X-Request-Id` optional (server generates if absent). |
| Headers out | `X-Request-Id`, `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`. Deprecated versions add `Deprecation` and `Sunset`. |
| Locale | Error `message` and notification copy are localised server-side from `USER.preferred_language`, falling back to `Accept-Language` (`NFR-024`, `NFR-022`). Money and dates are **not** formatted server-side. |

### 3.2 Envelope

Success:

```json
{
  "data": {},
  "meta": {
    "requestId": "8c2e1a60-4b11-4f0a-9c3d-0f6a2b1c9d70",
    "serverTime": "2026-09-01T12:00:00Z",
    "nextCursor": null
  }
}
```

Error:

```json
{
  "error": {
    "code": "OFFER_ALREADY_ACCEPTED",
    "message": "This Offer has already been accepted.",
    "details": []
  },
  "meta": {
    "requestId": "8c2e1a60-4b11-4f0a-9c3d-0f6a2b1c9d70",
    "serverTime": "2026-09-01T12:00:00Z"
  }
}
```

`meta.serverTime` is on **every** response. Clients compute clock offset from it and must not use the device clock for the 48-hour Request countdown or Offer validity (`C-07`, frontend architecture §10).

`data` is an object for a single resource and an array for a collection. Empty collections return `"data": []` with `nextCursor: null`, never `404`.

`details` is an array of `{ "path": "body.weightGrams", "code": "OUT_OF_RANGE", "message": "…" }` for validation failures.

### 3.3 Idempotency

Every `POST`, `PATCH`, `PUT`, `DELETE` accepts `Idempotency-Key`. It is **required** (HTTP 400 `IDEMPOTENCY_KEY_REQUIRED`) on:

- `POST /v1/requests/{id}/publish`
- `POST /v1/requests/{id}/offers`
- `POST /v1/offers/{id}/accept`
- `POST /v1/offers/{id}/revise`
- `POST /v1/media/upload-intent`
- every Admin mutation that changes account or verification state

Replay within 24 hours of the same key + route + caller + body hash returns the stored response verbatim (same status, same body). Same key, different body → `409 IDEMPOTENCY_KEY_REUSED`.

### 3.4 Authentication and authorisation

Login is Google Sign-In for every role (`AD-API-13`, [`adr/0010`](adr/0010-google-signin-only-login.md)). The SRS §7.5 OTP/password/2FA wording is superseded for marketplace login until the next SRS rewrite.

| Actor | Mechanism | Session inactivity | Access JWT TTL `[PROPOSED]` |
|---|---|---|---|
| Customer | Google ID token → `POST /v1/auth/google/session` → Karat Hive `SessionBundle`. New users complete `POST /v1/auth/register/customer` (Google token or OTP phone proof). | 30 days (`FR-CUS-002`) | 15 minutes |
| Vendor | Same Google session exchange. New shops complete `POST /v1/auth/register/vendor`. | 14 days | 15 minutes |
| Admin | Same Google session exchange. **No self-registration** — Admin row must already exist (seed or another Admin). | 60 minutes (`FR-ADM-001`) | 15 minutes |

OTP may still prove a mobile number (register / change-mobile). Password login and Admin 2FA routes remain in this catalogue as **leftover** until removed (`Backend-Gap-Tasks` G2-A15).

Access JWT claims `[PROPOSED]`: `sub` (user id), `role` (`CUSTOMER` \| `VENDOR` \| `ADMIN`), `ver` (token version). **No** entitlement, vendor state, or subscription claim — those are read from PostgreSQL per request (backend §14.2). Suspension takes effect on the next call (`FR-ADM-016`, `FR-SYS-002`).

Refresh tokens are hashed, rotating, single-use. Presenting a rotated token invalidates the family (`401 REFRESH_REUSE_DETECTED`).

Authorisation is three layers, all server-side (`FR-SYS-003`):

1. **Role** — a Customer cannot hit an Offer-submission route.
2. **Account state** — a Vendor who is not `VERIFIED` **and** `ACTIVE` is confined to the Awaiting-Approval shell (`BR-002`). Marketplace collections return `403 VENDOR_NOT_ACTIVE`.
3. **Relationship** — this Customer owns this Request; this Vendor is in this Request’s match set **and** holds an active Type Subscription for its type (`FR-VEN-031`); these two parties share a Connection.

A Vendor also needs an **active Type Subscription** for the Request’s type to submit an Offer (`BR-002`, `FR-VEN-031`). Missing entitlement → `403 SUBSCRIPTION_REQUIRED`.

### 3.5 Masking (`BR-006`, `BR-007`, `BR-008`, `FR-SYS-003`, `NFR-013`)

Masked fields are **absent from the JSON object** — not `null`, not `""`, not present-and-ignored. Presenters are role- and relationship-specific (`AD-BE-08`).

| Viewer | Resource | Absent until / unless |
|---|---|---|
| Vendor | Request (no accepted Offer of theirs) | Customer name, mobile, email, exact address, photo |
| Customer | Offer (not accepted) | Vendor legal name, trading name, contact person, mobile, email, address, logo that identifies the shop |
| Vendor | Competing Offers | Always absent. Only `offerCount` on the parent Request. |
| Either party | Connection of which they are not a party | `404` (not `403`) — existence is not confirmed |
| Admin | Anything | Unmasked. KYC document **bytes** are still behind a separately audited signed URL (`NFR-015`). |

A Customer’s aggregate rating is visible to Vendors and Admins only (`BR-018`). It is absent from any payload whose viewer is another Customer.

### 3.6 Identifiers, time, money, language

| Kind | Wire format |
|---|---|
| Resource id | UUID string |
| Request reference | `KH-RQ-YYYY-nnnnnn` (server-assigned at publish, `FR-CUS-014`) |
| Timestamps | ISO-8601 UTC with `Z`. Display conversion to GST is a client concern (`BR-021`, `C-02`). |
| Money | Decimal string, AED, 2 places (`AD-API-05`) |
| Weight | Decimal string, grams, 2 places |
| Karat | `"24K"` \| `"22K"` \| `"21K"` \| `"18K"` (Admin-configurable list, `FR-ADM-030`) |
| Language | `en` \| `ar` |

### 3.7 HTTP status usage

| Status | When |
|---|---|
| 200 | GET/PATCH/POST that returns the existing resource (including idempotent replay) |
| 201 | POST that created a new resource |
| 204 | DELETE with no body |
| 400 | Schema / `IDEMPOTENCY_KEY_REQUIRED` / malformed |
| 401 | Missing/expired/invalid token, OTP failure, 2FA failure |
| 403 | Authenticated but not permitted (role, account state, relationship, publish-gate, subscription) |
| 404 | Unknown id **or** existence concealed by masking |
| 409 | Conflict: uniqueness, illegal state transition, idempotency-key reuse with different body |
| 422 | Semantically invalid (bullion below AED 500, contact details in notes, media not `CLEAN`) |
| 429 | Rate limit |
| 503 | Gold-rate feed required and unavailable (bullion publish only) |

---

## 4. Shared types

Types below are the wire shapes. Field names are camelCase. Enums match SRS §5 / §6.

### 4.1 Primitive aliases

```
UUID          = string   // 8-4-4-4-12 hex
DateTime      = string   // ISO-8601 UTC
Money         = string   // decimal AED, 2 places
WeightGrams   = string   // decimal grams, 2 places
Cursor        = string   // opaque, unguessable
```

### 4.2 Enumerations

```
UserType            = CUSTOMER | VENDOR | ADMIN
AccountState        = ACTIVE | SUSPENDED | DEACTIVATED
VendorVerification  = REGISTERED | PENDING_VERIFICATION | VERIFIED | REJECTED
VendorAccountState  = REGISTERED | PENDING_VERIFICATION | VERIFIED | ACTIVE | SUSPENDED | REJECTED | DEACTIVATED
RequestType         = FIND_ORNAMENT | SELL_OLD_GOLD | GOLD_COIN | GOLD_BULLION
Direction           = BUY | SELL
RequestState        = DRAFT | PUBLISHED | OFFERS_RECEIVED | ACCEPTED | CLOSED | EXPIRED | CANCELLED | REMOVED
OfferState          = PENDING | ACCEPTED | REJECTED | EXPIRED | WITHDRAWN | WITHDRAWN_BY_SYSTEM
ConnectionState     = ACTIVE | CLOSED
ReviewState         = PENDING_MODERATION | PUBLISHED | REJECTED | REDACTED | WITHDRAWN
SubscriptionState   = ACTIVE | GRACE | EXPIRED | CANCELLED
MediaPurpose        = REQUEST_IMAGE | OFFER_IMAGE | PROFILE_PHOTO | VENDOR_LOGO | VENDOR_SHOP_PHOTO | KYC_DOCUMENT | EXPORT_ARTEFACT
MediaState          = PENDING_UPLOAD | PENDING_PROCESSING | READY | QUARANTINED | FAILED
DocumentType        = TRADE_LICENCE | EMIRATES_ID | VAT_CERT | TRADING_PERMIT | TENANCY | OTHER
Karat               = 24K | 22K | 21K | 18K
OrnamentType        = RING | CHAIN | BANGLE | NECKLACE | EARRING | BRACELET | PENDANT | OTHER
Condition           = NEW | LIKE_NEW | USED | DAMAGED          // SELL_OLD_GOLD
OAuthProvider       = GOOGLE | APPLE
AbuseEntityType     = REQUEST | OFFER | CONNECTION | REVIEW
ContactChannel      = WHATSAPP | PHONE
ClosedBy            = CUSTOMER | VENDOR | ADMIN
```

`VendorAccountState` is the union of verification and marketplace-access states from SRS §5.4, returned as a single `vendorLifecycle` on Vendor-facing `Me` so the client can route to the Awaiting-Approval shell without a second call.

### 4.3 Pagination query

```
limit?:  integer  // default 20, min 1, max 50 (Admin max 100)
cursor?: Cursor
```

### 4.4 Masked vs revealed parties

```
MaskedCustomer = {
  label: string                 // stable per-Request pseudonym, e.g. "Customer · Dubai"
  region: RegionSummary
  connectionCount: integer      // completed Connections (trust signal)
  rating?: RatingSummary        // absent for Customer viewers (BR-018); present for Vendor/Admin
}

MaskedVendor = {
  label: string                 // e.g. "Verified Jeweller · Deira"
  region: RegionSummary
  rating: RatingSummary
  connectionCount: integer
}

RevealedCustomer = {
  displayName: string
  mobileNumber: string          // E.164
  region: RegionSummary
  photoUrl?: string             // signed URL
  memberSince: DateTime
  connectionCount: integer
  rating?: RatingSummary        // Vendor/Admin only
}

RevealedVendor = {
  tradingName: string
  legalBusinessName: string
  contactPersonName: string
  mobileNumber: string
  businessEmail: string
  businessAddress: string
  region: RegionSummary
  logoUrl?: string
  rating: RatingSummary
  connectionCount: integer
}

RatingSummary = {
  average: string               // 1 decimal, e.g. "4.6"
  count: integer
  distribution: { "1": int, "2": int, "3": int, "4": int, "5": int }
  limitedHistory: boolean       // true when count < 3 (FR-CUS-031, FR-SYS-012)
}
```

### 4.5 Taxonomy summaries

```
CategorySummary = { id: UUID, nameEn: string, nameAr: string, parentId?: UUID, isActive: boolean, displayOrder: integer, icon?: string }
RegionSummary   = { id: UUID, nameEn: string, nameAr: string, parentId?: UUID, isActive: boolean, displayOrder: integer }
```

### 4.6 Media reference (after processing)

```
MediaRef = {
  id: UUID
  key: string                   // object key, unguessable UUID
  state: MediaState
  purpose: MediaPurpose
  contentType: string
  byteSize: integer
  displayOrder: integer
  thumbnailUrl?: string         // signed, only when state = READY
  displayUrl?: string           // signed, only when state = READY
}
```

KYC documents never include `thumbnailUrl` / `displayUrl` on Customer or Vendor payloads. Admins fetch a separately audited URL (§21.4).

### 4.7 Request (role presenters)

Common fields (always present for an authorised viewer):

```
RequestBase = {
  id: UUID
  reference?: string            // absent on DRAFT
  requestType: RequestType
  direction: Direction
  state: RequestState
  category: CategorySummary
  region: RegionSummary
  notes?: string
  weightGrams?: WeightGrams
  weightIsApproximate: boolean
  purityKarat?: Karat
  ornamentType?: OrnamentType
  condition?: Condition
  denominationGrams?: WeightGrams
  quantity?: integer
  mintOrRefiner?: string
  budgetMin?: Money
  budgetMax?: Money
  budgetIsFlexible: boolean
  indicativeValue?: Money
  publishedAt?: DateTime
  expiresAt?: DateTime
  offerCount: integer           // Vendors see the count only (BR-008)
  media: MediaRef[]             // max 5; READY derivatives only
  createdAt: DateTime
  updatedAt: DateTime
}
```

Presenter variants:

```
RequestForCustomer = RequestBase & {
  cancellationReason?: string
  acceptedOfferId?: UUID
  unreadOfferCount: integer     // PENDING offers with viewedByCustomerAt = null; on GET /v1/me/requests rows and GET /v1/requests/{id} (SAM-GAP-1 / CBG-01)
  offers?: OfferForCustomer[]   // only on GET /requests/{id} for the owner, not on list rows
}

RequestForVendor = RequestBase & {
  customer: MaskedCustomer      // NEVER RevealedCustomer
  viewedAt?: DateTime
  myOffer?: OfferSummary        // if this Vendor holds one
  // no competing offer array, no customer identity fields
}

RequestForAdmin = RequestBase & {
  customer: RevealedCustomer
  acceptedOfferId?: UUID
  cancellationReason?: string
  matchCount: integer
}
```

### 4.8 Offer (role presenters)

```
OfferTerms = {
  offeredPrice: Money
  makingCharges?: Money
  ratePerGram?: Money
  deliveryTimeframe?: string
  warrantyTerms?: string
  vendorNote?: string
  validityHours: integer        // 12 | 24 | 48 (AD-API-07)
  media: MediaRef[]             // max 3
}

OfferForCustomer = {
  id: UUID
  requestId: UUID
  state: OfferState
  terms: OfferTerms
  vendor: MaskedVendor          // NEVER RevealedVendor until this Offer is ACCEPTED *and* viewed via the Connection
  submittedAt: DateTime
  expiresAt: DateTime
  decidedAt?: DateTime
  revisionCount: integer
}

OfferForVendor = {
  id: UUID
  requestId: UUID
  request: RequestForVendor     // parent as it currently stands
  state: OfferState
  terms: OfferTerms
  submittedAt: DateTime
  expiresAt: DateTime
  decidedAt?: DateTime
  declineReason?: DeclineReason
  revisionCount: integer
  awardedElsewhere: boolean     // true when REJECTED because a competitor was accepted; never includes winning price (BR-008)
  connectionId?: UUID           // when ACCEPTED
}

OfferForAdmin = OfferForVendor & {
  vendor: RevealedVendor
  customer: RevealedCustomer
  winningOfferId?: UUID         // when this Offer lost to a competitor
}

DeclineReason = PRICE_TOO_HIGH | TERMS_UNSUITABLE | NO_LONGER_REQUIRED | OTHER
```

### 4.9 Connection

```
TalkPayload = {
  waUrl: string                 // https://wa.me/<digits>?text=<urlencoded>
  mobileNumber: string          // copyable E.164
  prefilledMessage: string      // already localised
  available: boolean            // false when Connection is CLOSED
}

ConnectionForParty = {
  id: UUID
  state: ConnectionState
  request: RequestBase          // structural snapshot; identity via the party objects below
  acceptedOffer: OfferTerms & { id: UUID, submittedAt: DateTime }
  identityRevealedAt: DateTime
  closedAt?: DateTime
  closedBy?: ClosedBy
  talk: TalkPayload
  myReview?: ReviewSummary
  counterpartyReview?: ReviewSummary   // only PUBLISHED
  createdAt: DateTime
}

ConnectionForCustomer = ConnectionForParty & { vendor: RevealedVendor }
ConnectionForVendor   = ConnectionForParty & { customer: RevealedCustomer }

ConnectionForAdmin = {
  id: UUID
  state: ConnectionState
  customer: RevealedCustomer
  vendor: RevealedVendor
  request: RequestForAdmin
  acceptedOffer: OfferForAdmin
  identityRevealedAt: DateTime
  contactEvents: ContactEvent[]
  closedAt?: DateTime
  closedBy?: ClosedBy
  createdAt: DateTime
}

ContactEvent = {
  id: UUID
  initiatedBy: CUSTOMER | VENDOR
  channel: ContactChannel
  occurredAt: DateTime
}
```

---

## 5. Error catalogue

Closed enumeration. Unknown codes must not be invented by clients. `message` is already localised.

### 5.1 Generic

| Code | HTTP | Meaning |
|---|---|---|
| `VALIDATION_FAILED` | 400 | Body/query failed schema. See `details`. |
| `IDEMPOTENCY_KEY_REQUIRED` | 400 | Required key missing. |
| `IDEMPOTENCY_KEY_REUSED` | 409 | Same key, different body. |
| `UNAUTHENTICATED` | 401 | Missing or invalid Karat Hive access token; or Google session exchange with an unbound / unmatched identity (`AD-API-13`). |
| `TOKEN_EXPIRED` | 401 | Access token past TTL; refresh. |
| `REFRESH_REUSE_DETECTED` | 401 | Rotated refresh presented; family revoked. |
| `FORBIDDEN` | 403 | Generic authorisation failure. |
| `NOT_FOUND` | 404 | Unknown or concealed. |
| `CONFLICT` | 409 | Generic uniqueness / state clash. |
| `RATE_LIMITED` | 429 | Token bucket exhausted. |
| `INTERNAL` | 500 | Unexpected. No internals in `message` (`NFR-024`). |

### 5.2 Identity and access

| Code | HTTP | Meaning |
|---|---|---|
| `OTP_INVALID` | 401 | Wrong code. |
| `OTP_EXPIRED` | 401 | Past 5 minutes. |
| `OTP_RATE_LIMITED` | 429 | > 5 issuances / number / hour (`FR-CUS-001`). |
| `MOBILE_ALREADY_REGISTERED` | 409 | Direct the caller to login. |
| `EMAIL_ALREADY_REGISTERED` | 409 | |
| `ACCOUNT_SUSPENDED` | 403 | Message distinguishes suspension (`FR-CUS-002`). |
| `ACCOUNT_DEACTIVATED` | 403 | |
| `ACCOUNT_LOCKED` | 423 | Vendor: 5 failures / 15 min (`FR-VEN-003`). Admin: 3 failures / 30 min (`FR-ADM-001`). |
| `OAUTH_REQUIRED` | 403 | Publish without the one-time binding (`BR-001`). |
| `OAUTH_ALREADY_BOUND` | 409 | |
| `OAUTH_TOKEN_INVALID` | 401 | Provider token failed server-side verify. |
| `TWO_FACTOR_REQUIRED` | 401 | Admin password accepted; 2FA pending. |
| `TWO_FACTOR_INVALID` | 401 | |
| `VENDOR_NOT_ACTIVE` | 403 | Not `VERIFIED`+`ACTIVE`. Shell only (`BR-002`). |
| `SUBSCRIPTION_REQUIRED` | 403 | No active Type Subscription for this Request type (`FR-VEN-031`). |
| `PASSWORD_POLICY` | 400 | Failed `NFR-012`. |

### 5.3 Requests, Offers, Connections

| Code | HTTP | Meaning |
|---|---|---|
| `REQUEST_NOT_PUBLISHABLE` | 422 | Mandatory fields, media not `CLEAN`, or bullion floor. |
| `BULLION_BELOW_MINIMUM` | 422 | Indicative value < configured floor (`BR-010`). |
| `GOLD_RATE_UNAVAILABLE` | 503 | Bullion publish requires a rate (`FR-CUS-013`). |
| `CONCURRENT_REQUEST_LIMIT` | 409 | > 10 live Requests (`FR-CUS-005` `[ASSUMED]`). |
| `STRUCTURAL_FIELD_IMMUTABLE` | 409 | Type/direction/weight/purity/quantity after publish (`BR-014`). |
| `REQUEST_NOT_CANCELLABLE` | 409 | Already `ACCEPTED` (`BR-013`). |
| `CONTACT_DETAILS_IN_TEXT` | 422 | Notes or vendor note tripped `BR-022`. |
| `OFFER_NOT_OPEN` | 409 | Parent Request not `PUBLISHED`/`OFFERS_RECEIVED`. |
| `OFFER_ALREADY_PENDING` | 409 | One non-terminal Offer per Vendor per Request (`BR-009`). |
| `OFFER_REVISION_LIMIT` | 409 | Already revised 3 times (`FR-VEN-014`). |
| `OFFER_NOT_PENDING` | 409 | Revise/withdraw/accept/decline against a terminal Offer. |
| `OFFER_EXPIRED` | 409 | Server-side expiry at accept time (`FR-SYS-004`). |
| `OFFER_ALREADY_ACCEPTED` | 409 | Concurrent second accept (`BR-011`). |
| `NOT_IN_MATCH_SET` | 403 | Vendor is not matched to this Request. |
| `CONNECTION_CLOSED` | 409 | Talk / close against a closed Connection. |
| `NOT_A_PARTY` | 403 | Review or Talk without a Connection. |
| `REVIEW_ALREADY_EXISTS` | 409 | One per party per Connection (`BR-017`). |
| `REVIEW_EDIT_WINDOW_CLOSED` | 409 | Past 14 days (`FR-CUS-030`). |
| `MEDIA_NOT_READY` | 422 | Parent publish blocked until `CLEAN`/`READY` (`FR-SYS-009`). |
| `MEDIA_QUARANTINED` | 422 | Malware scan failed. |
| `MEDIA_TYPE_REJECTED` | 422 | Content inspection failed. |
| `UPLOAD_NOT_COMPLETED` | 409 | `complete` called before the PUT, or HEAD mismatch. |

### 5.4 Admin

| Code | HTTP | Meaning |
|---|---|---|
| `ILLEGAL_VENDOR_TRANSITION` | 409 | e.g. approve a Vendor not in `PENDING_VERIFICATION`. |
| `TAXONOMY_IN_USE` | 409 | Delete attempted; deactivate instead (`BR-019`). |
| `SETTING_OUT_OF_RANGE` | 400 | Failed `allowed_range`. |
| `EXPORT_IN_PROGRESS` | 409 | Duplicate export of the same report. |
| `ADMIN_SELF_REGISTRATION_FORBIDDEN` | 404 | Any unauthenticated Admin-create path. Treated as not found, not advertised. |

---

## 6. Route index

Auth column: `Pub` public · `C` Customer · `V` Vendor (`ACTIVE`) · `Vshell` Vendor in Awaiting-Approval · `A` Admin · `CV` either marketplace role.

Mutating routes require `Idempotency-Key`; a `*` marks it mandatory.

| Method | Path | Auth | FR | Tag |
|---|---|---|---|---|
| GET | `/health` | Pub | — | |
| GET | `/ready` | Pub | — | |
| POST | `/v1/auth/google/session` | Pub | CUS-001, CUS-002, VEN-003, ADM-001 | `AD-API-13` |
| POST | `/v1/auth/firebase/session` | Pub | CUS-001, CUS-002, VEN-003, ADM-001 | alias of google/session |
| POST | `/v1/auth/otp/request` | Pub | CUS-001, CUS-002, VEN-001 | phone proof, not login |
| POST | `/v1/auth/otp/verify` | Pub | CUS-001, CUS-002, VEN-001 | phone proof, not login |
| POST | `/v1/auth/register/customer` | Pub | CUS-001 | `[ASSUMED]` |
| POST | `/v1/auth/register/vendor` | Pub | VEN-001 | `[ASSUMED]` |
| POST | `/v1/auth/login/password` | Pub | — | leftover; remove G2-A15 |
| POST | `/v1/auth/admin/2fa/setup` | A | — | leftover; remove G2-A15 |
| POST | `/v1/auth/admin/2fa/confirm` | A | — | leftover; remove G2-A15 |
| POST | `/v1/auth/admin/2fa/verify` | Pub (challenge) | — | leftover; remove G2-A15 |
| POST | `/v1/auth/oauth/bind` | C | CUS-001, BR-001 | not login (`AD-API-13`) |
| POST | `/v1/auth/refresh` | Pub (refresh cookie/body) | CUS-002, VEN-003, ADM-001 | |
| POST | `/v1/auth/logout` | C/V/A | CUS-002 | |
| GET | `/v1/auth/sessions` | C/V/A | VEN-027 | |
| DELETE | `/v1/auth/sessions/{id}` | C/V/A | VEN-027 | |
| POST | `/v1/auth/password` | V/A | VEN-027 | |
| POST | `/v1/auth/password/reset/request` | Pub | VEN-003 | `[ASSUMED]` `AD-API-10` |
| POST | `/v1/auth/password/reset/confirm` | Pub | VEN-003 | `[ASSUMED]` `AD-API-10` |
| POST | `/v1/devices` | C/V | SYS-008 | `[PROPOSED]` |
| DELETE | `/v1/devices/{id}` | C/V | SYS-008 | `[PROPOSED]` |
| GET | `/v1/me` | C/V/A | CUS-003, VEN-024, ADM-001 | |
| PATCH | `/v1/me` | C/V | CUS-003, VEN-024 | |
| POST | `/v1/me/mobile/change` | C/V | CUS-003 | |
| POST | `/v1/me/deactivate` | C/V | CUS-004 | `[ASSUMED]` |
| POST | `/v1/me/deletion-requests` | C | CUS-004, NFR-019 | `[ASSUMED]` |
| POST | `/v1/me/deletion-requests/{id}/confirm` | C | CUS-004, NFR-019 | `[ASSUMED]` |
| GET | `/v1/me/settings` | C/V | CUS-034, VEN-027 | `[ASSUMED]` (C) |
| PATCH | `/v1/me/settings` | C/V | CUS-034, VEN-027 | |
| GET | `/v1/categories` | C/V/A | ADM-024, CUS-005, VEN-025 | |
| GET | `/v1/regions` | C/V/A | ADM-025, CUS-005, VEN-025 | |
| GET | `/v1/platform-config` | C/V | ADM-030 | `[PROPOSED]` |
| GET | `/v1/gold-rates` | C/V | CUS-018, SYS-010 | `[BLOCKED]` display |
| POST* | `/v1/media/upload-intent` | C/V | CUS-007, VEN-002, SYS-009 | |
| POST | `/v1/media/{key}/complete` | C/V | SYS-009 | |
| DELETE | `/v1/media/{key}` | C/V | CUS-007 | |
| POST | `/v1/requests` | C | CUS-005, CUS-015 | `[ASSUMED]` draft |
| GET | `/v1/me/requests` | C | CUS-005, CUS-028 | |
| GET | `/v1/requests/{id}` | C/V | CUS-016, VEN-010, SYS-003 | |
| PATCH | `/v1/requests/{id}` | C | CUS-015, CUS-016 | `[ASSUMED]` |
| POST* | `/v1/requests/{id}/publish` | C | CUS-014, BR-001 | |
| POST | `/v1/requests/{id}/cancel` | C | CUS-017 | `[ASSUMED]` |
| POST | `/v1/requests/{id}/duplicate` | C | SYS-005 | `[PROPOSED]` |
| GET | `/v1/requests/{id}/offers` | C | CUS-019, CUS-021 | `[ASSUMED]` filter |
| GET | `/v1/matches` | V | VEN-008, VEN-009, SYS-002 | `[ASSUMED]` filter |
| POST | `/v1/matches/{requestId}/viewed` | V | VEN-010 | |
| GET | `/v1/filter-presets` | V | VEN-009 | `[ASSUMED]` |
| POST | `/v1/filter-presets` | V | VEN-009 | `[ASSUMED]` |
| PATCH | `/v1/filter-presets/{id}` | V | VEN-009 | `[ASSUMED]` |
| DELETE | `/v1/filter-presets/{id}` | V | VEN-009 | `[ASSUMED]` |
| GET | `/v1/me/dashboard` | V | VEN-004–007 | |
| POST* | `/v1/requests/{id}/offers` | V | VEN-012, VEN-013, VEN-015 | `[ASSUMED]` validity |
| GET | `/v1/me/offers` | V | VEN-016–019, VEN-023 | |
| GET | `/v1/offers/{id}` | C/V | CUS-022, VEN-010 | `[ASSUMED]` (C) |
| GET | `/v1/offers/{id}/vendor-rating` | C | CUS-031 | `[ASSUMED]` |
| POST* | `/v1/offers/{id}/revise` | V | VEN-014 | `[ASSUMED]` |
| POST | `/v1/offers/{id}/withdraw` | V | VEN-014 | `[ASSUMED]` |
| POST* | `/v1/offers/{id}/accept` | C | CUS-023, SYS-006, SYS-007 | |
| POST | `/v1/offers/{id}/decline` | C | CUS-026 | `[ASSUMED]` |
| GET | `/v1/me/connections` | C/V | CUS-027, VEN-020 | `[ASSUMED]` (C) |
| GET | `/v1/connections/{id}` | C/V | CUS-024, VEN-021 | |
| POST | `/v1/connections/{id}/close` | C/V | CUS-027, VEN-020 | |
| POST | `/v1/connections/{id}/contact-events` | C/V | CUS-025, VEN-022 | |
| POST | `/v1/connections/{id}/reviews` | C/V | CUS-029, VEN-028 | |
| GET | `/v1/me/reviews` | C/V | CUS-030, VEN-029 | `[ASSUMED]` |
| PATCH | `/v1/reviews/{id}` | C/V | CUS-030 | `[ASSUMED]` |
| POST | `/v1/reviews/{id}/withdraw` | C/V | CUS-030 | `[ASSUMED]` |
| POST | `/v1/reviews/{id}/response` | V | VEN-029 | `[ASSUMED]` |
| POST | `/v1/reviews/{id}/flag` | V | VEN-029 | `[ASSUMED]` |
| GET | `/v1/notifications` | C/V | CUS-032, VEN-026 | `[ASSUMED]` (C) |
| POST | `/v1/notifications/{id}/read` | C/V | CUS-032 | |
| POST | `/v1/notifications/read-all` | C/V | CUS-032 | `[PROPOSED]` |
| GET | `/v1/notifications/unread-count` | C/V | CUS-032, VEN-026 | `[PROPOSED]` |
| POST | `/v1/abuse-reports` | C/V | CUS-033, VEN-030 | `[ASSUMED]` |
| GET | `/v1/me/vendor` | Vshell | VEN-024 | |
| PATCH | `/v1/me/vendor` | Vshell | VEN-024, BR-004 | |
| GET | `/v1/me/vendor/documents` | Vshell | VEN-002 | `[ASSUMED]` |
| POST | `/v1/me/vendor/documents` | Vshell | VEN-002 | `[ASSUMED]` |
| POST | `/v1/me/vendor/resubmit` | Vshell | VEN-002 | `[ASSUMED]` |
| PUT | `/v1/me/vendor/categories` | V | VEN-025 | `[ASSUMED]` |
| PUT | `/v1/me/vendor/regions` | V | VEN-025 | `[ASSUMED]` |
| PATCH | `/v1/me/vendor/availability` | V | VEN-025 | `[ASSUMED]` |
| GET | `/v1/me/subscriptions` | Vshell | VEN-031 | read-only |
| GET | `/v1/me/vendor/performance` | V | VEN-023 | |
| GET | `/v1/me/vendor/performance/export` | V | VEN-023 | `[ASSUMED]` |
| GET | `/v1/admin/dashboard` | A | ADM-003–009 | |
| GET | `/v1/admin/customers` | A | ADM-010 | |
| GET | `/v1/admin/customers/{id}` | A | ADM-011 | |
| POST | `/v1/admin/customers/{id}/suspend` | A | ADM-012 | `[ASSUMED]` |
| POST | `/v1/admin/customers/{id}/reactivate` | A | ADM-012 | `[ASSUMED]` |
| POST | `/v1/admin/customers/{id}/erasure` | A | CUS-004, NFR-019 | `[ASSUMED]` |
| GET | `/v1/admin/vendors` | A | ADM-013 | |
| GET | `/v1/admin/vendors/{id}` | A | ADM-014 | |
| GET | `/v1/admin/vendors/{id}/documents/{docId}/url` | A | ADM-014, NFR-015 | |
| GET | `/v1/admin/verification-queue` | A | ADM-015 | |
| POST | `/v1/admin/vendors/{id}/verify` | A | ADM-015 | |
| POST | `/v1/admin/vendors/{id}/reject` | A | ADM-015 | |
| POST | `/v1/admin/vendors/{id}/request-info` | A | ADM-015 | |
| POST | `/v1/admin/vendors/{id}/activate` | A | ADM-016 | |
| POST | `/v1/admin/vendors/{id}/suspend` | A | ADM-016 | |
| POST | `/v1/admin/vendors/{id}/reactivate` | A | ADM-016 | |
| POST | `/v1/admin/vendors/{id}/deactivate` | A | ADM-016 | |
| POST | `/v1/admin/vendors/{id}/subscriptions` | A | VEN-031 | `[PROPOSED]` `AD-API-04` |
| PATCH | `/v1/admin/vendors/{id}/subscriptions/{requestType}` | A | VEN-031 | `[PROPOSED]` |
| GET | `/v1/admin/requests` | A | ADM-017 | |
| GET | `/v1/admin/requests/{id}` | A | ADM-018 | |
| POST | `/v1/admin/requests/{id}/remove` | A | ADM-019 | `[ASSUMED]` |
| GET | `/v1/admin/offers` | A | ADM-020 | |
| GET | `/v1/admin/offers/{id}` | A | ADM-021 | |
| GET | `/v1/admin/connections` | A | ADM-022 | |
| GET | `/v1/admin/connections/{id}` | A | ADM-023 | |
| POST | `/v1/admin/connections/{id}/close` | A | ADM-023 | |
| GET | `/v1/admin/categories` | A | ADM-024 | |
| POST | `/v1/admin/categories` | A | ADM-024 | |
| PATCH | `/v1/admin/categories/{id}` | A | ADM-024 | |
| POST | `/v1/admin/categories/{id}/deactivate` | A | ADM-024 | |
| GET | `/v1/admin/regions` | A | ADM-025 | |
| POST | `/v1/admin/regions` | A | ADM-025 | |
| PATCH | `/v1/admin/regions/{id}` | A | ADM-025 | |
| POST | `/v1/admin/regions/{id}/deactivate` | A | ADM-025 | |
| GET | `/v1/admin/reviews` | A | ADM-026 | |
| POST | `/v1/admin/reviews/{id}/approve` | A | ADM-026 | |
| POST | `/v1/admin/reviews/{id}/reject` | A | ADM-026 | |
| POST | `/v1/admin/reviews/{id}/redact` | A | ADM-026 | |
| GET | `/v1/admin/reports/{name}` | A | ADM-027 | |
| POST | `/v1/admin/exports` | A | ADM-028 | `[ASSUMED]` |
| GET | `/v1/admin/exports/{id}` | A | ADM-028 | `[ASSUMED]` |
| GET | `/v1/admin/announcements` | A | ADM-029 | |
| POST | `/v1/admin/announcements` | A | ADM-029 | |
| POST | `/v1/admin/announcements/{id}/cancel` | A | ADM-029 | |
| GET | `/v1/admin/settings` | A | ADM-030 | |
| PATCH | `/v1/admin/settings/{key}` | A | ADM-030, BR-020 | |
| GET | `/v1/admin/gold-rates` | A | ADM-031 | |
| GET | `/v1/admin/gold-rates/history` | A | ADM-031, SYS-010 | |
| POST | `/v1/admin/gold-rates/override` | A | ADM-031 | |
| GET | `/v1/admin/abuse-reports` | A | ADM-032 | `[ASSUMED]` |
| GET | `/v1/admin/abuse-reports/{id}` | A | ADM-032 | `[ASSUMED]` |
| POST | `/v1/admin/abuse-reports/{id}/resolve` | A | ADM-032 | `[ASSUMED]` |
| GET | `/v1/admin/audit-log` | A | ADM-033, SYS-011 | `[ASSUMED]` |
| GET | `/v1/admin/admins` | A | ADM-002 | `[ASSUMED]` coarse |
| POST | `/v1/admin/admins` | A | ADM-002 | `[ASSUMED]` coarse |
| POST | `/v1/admin/admins/{id}/suspend` | A | ADM-002 | `[ASSUMED]` |
| POST | `/v1/admin/admins/{id}/revoke` | A | ADM-002 | `[ASSUMED]` |
| POST | `/v1/admin/admins/{id}/password-reset` | A | ADM-002 | `[PROPOSED]` |
| POST | `/v1/admin/{collection}/{id}/notes` | A | ADM-011, ADM-018 | `[PROPOSED]` `AD-API-12` |

System jobs (fan-out, expiry, rate poll, media processing, rating aggregation, PDPL erasure) have **no public HTTP surface**. They run as workers inside the monolith (`NFR-009`, backend §11).

---

## 7. Health

### `GET /health`

Liveness. No auth. Returns `{ "data": { "status": "ok" } }` if the process is up. Does not touch PostgreSQL.

### `GET /ready`

Readiness. No auth. 200 only if PostgreSQL accepts a connection and (in `api` role) migrations are current. 503 otherwise. Used by the load balancer. `[PROPOSED]`

---

## 8. Authentication and sessions

Screens: `CUS-S01`, `VEN-S01`, `VEN-S04`, `ADM-S01`.

### `POST /v1/auth/google/session` · `POST /v1/auth/firebase/session` (`AD-API-13`, `adr/0010`)

Public. `@RevealsIdentity`. Exchanges a verified Google ID token (Firebase Auth) for a Karat Hive `SessionBundle`. Does **not** create a User. Both paths are identical; `firebase/session` is an alias kept for existing clients.

```
body: { idToken: string }       // also accepts token | firebaseToken
200 data: SessionBundle
```

Behaviour:

1. Verify the Google ID token server-side (issuer, audience, signature, expiry).
2. Look up an existing `oauth_binding` for the subject. If bound and the User is not soft-deleted → issue `SessionBundle`.
3. Else, if `email` is present **and** `emailVerified === true`, match an existing User by email, upsert the Google binding, audit `OAUTH_BOUND`, issue `SessionBundle`.
4. Else, if a verified E.164 `phone_number` is present, match by mobile the same way.
5. Else → `401 UNAUTHENTICATED`. No auto-provision. The client must call the matching register route (Customer or Vendor) with terms/privacy and a real mobile.

Errors: `UNAUTHENTICATED` (missing/invalid/expired token, or unbound identity), `TOKEN_EXPIRED` (Google token past TTL), `ACCOUNT_SUSPENDED` / `ACCOUNT_DEACTIVATED` are enforced on subsequent domain calls, not on this exchange when the User row is still issued a session — suspended Users receive those codes from `AuthGuard` on `/v1/me` and marketplace routes.

Rate-limited with the auth bucket (per IP / per subject). Domain routes after exchange accept **only** the Karat Hive access token; a Google bearer on `GET /v1/me` is `401 UNAUTHENTICATED`.

There is **no** `POST /v1/auth/oauth/login`. Google session exchange is the login (`AD-API-13`).

### `POST /v1/auth/otp/request`

Issues an SMS OTP. Rate-limited per number and per IP (`FR-CUS-001` AC2, SRS §7.5).

```
body: { mobileNumber: string, purpose: REGISTER_CUSTOMER | REGISTER_VENDOR | LOGIN | CHANGE_MOBILE }
201 data: { challengeId: UUID, expiresAt: DateTime, retryAfterSeconds: integer }
```

Errors: `OTP_RATE_LIMITED`, `MOBILE_ALREADY_REGISTERED` (when `purpose = REGISTER_*` and the number is live), `NOT_FOUND` (when `purpose = LOGIN` and the number is unknown — **do not** distinguish “unknown” from “wrong” beyond a generic failure if that would enumerate accounts; `[PROPOSED]`: LOGIN against an unknown number still returns 201 with a dummy `challengeId` that will fail verify, to avoid enumeration).

OTP TTL: 5 minutes. Max 5 issuances per number per hour.

### `POST /v1/auth/otp/verify`

```
body: { challengeId: UUID, code: string }
```

When `purpose` was `LOGIN` or a completed `REGISTER_*` that already created the user, returns a session:

```
200 data: SessionBundle
SessionBundle = {
  accessToken: string
  accessExpiresAt: DateTime
  refreshToken: string
  refreshExpiresAt: DateTime
  user: Me
}
```

When `purpose` was `REGISTER_CUSTOMER` / `REGISTER_VENDOR`, returns `{ challengeId, mobileVerified: true }` and the client proceeds to the register endpoint, sending `challengeId`.

Errors: `OTP_INVALID`, `OTP_EXPIRED`.

### `POST /v1/auth/register/customer` `[ASSUMED]` (`FR-CUS-001`)

```
body: {
  challengeId?: UUID             // verified OTP phone proof — xor firebaseToken
  firebaseToken?: string         // verified Google identity (AD-API-13)
  displayName: string            // 1–100
  email?: string
  preferredLanguage: en | ar
  defaultRegionId?: UUID
  termsVersion: string
  privacyVersion: string
}
201 data: SessionBundle          // accountState = ACTIVE
```

Exactly one of `challengeId` or `firebaseToken` is required. Acceptance of ToS/Privacy is persisted with version + timestamp. Duplicate mobile → `MOBILE_ALREADY_REGISTERED`. Google completer still requires a real E.164 mobile (OTP or verified Google phone).

### `POST /v1/auth/register/vendor` `[ASSUMED]` (`FR-VEN-001`)

```
body: {
  challengeId?: UUID             // verified OTP phone proof — xor firebaseToken
  firebaseToken?: string         // verified Google identity (AD-API-13)
  legalBusinessName: string
  tradingName: string
  tradeLicenceNumber: string
  licenceExpiryDate: string      // YYYY-MM-DD
  businessAddress: string
  contactPersonName: string
  businessEmail: string
  regionId: UUID
  categoryIds: UUID[]            // ≥ 1
  servedRegionIds: UUID[]        // ≥ 1
  termsVersion: string
  privacyVersion: string
}
201 data: SessionBundle          // vendorLifecycle = PENDING_VERIFICATION
```

The session is real; marketplace collections will return `403 VENDOR_NOT_ACTIVE`. KYC documents are uploaded next via the media pipeline. Role is the route, never inferred from the Google token. **No Admin register via Google.**

### `POST /v1/auth/login/password`

Vendor email+password (`FR-VEN-003`) and Admin email+password (`FR-ADM-001`) share this route. The server branches on `user_type`.

```
body: { email: string, password: string }
```

Vendor `ACTIVE` / `PENDING_VERIFICATION` / `VERIFIED` → `200 SessionBundle`.
Vendor `REJECTED` / `SUSPENDED` / `DEACTIVATED` → `403` with the matching account-state code.
Admin → `401 TWO_FACTOR_REQUIRED` with `{ challengeId, expiresAt }` (password verified, 2FA not yet).
> *[DEVIATION AD-API: 2FA deferred — checkpoint-1]*: Admin login returns `200 SessionBundle` directly in Checkpoint-1; 2FA endpoints are deferred. Built in Checkpoint-1.
Five consecutive Vendor failures → `423 ACCOUNT_LOCKED` (15 minutes) and a security notification.
Three consecutive Admin failures → `423 ACCOUNT_LOCKED` (30 minutes) and an audit entry (`FR-ADM-001`).

### `POST /v1/auth/admin/2fa/verify`

```
body: { challengeId: UUID, code: string }     // TOTP or SMS
200 data: SessionBundle
```

Every attempt is audited with IP and user agent (`FR-SYS-011`).

Admin 2FA enrolment (first login after provisioning) is `POST /v1/auth/admin/2fa/setup` (authenticated, returns `{ otpauthUri, backupCodes }`) and `POST /v1/auth/admin/2fa/confirm`. `[PROPOSED]` — the SRS requires 2FA but not the enrolment wire format.

### `POST /v1/auth/oauth/bind`

Customer only. Server verifies the provider identity token; a client-supplied profile is never trusted (backend §15.4).

```
body: { provider: GOOGLE | APPLE, identityToken: string }
200 data: { bound: true, provider: OAuthProvider, boundAt: DateTime }
```

Errors: `OAUTH_TOKEN_INVALID`, `OAUTH_ALREADY_BOUND`. Binding is one-time; subsequent publishes do not re-prompt (`FR-CUS-001` AC6).

There is **no** `POST /v1/auth/oauth/login`. Login is `POST /v1/auth/google/session` (`AD-API-13`). This bind route remains only as a one-time publish-gate helper until the SRS `BR-001` rewrite; new Google-session users already carry a binding from exchange or register.

### `POST /v1/auth/refresh`

```
body: { refreshToken: string }
200 data: SessionBundle          // new refresh; old is revoked
```

Reuse of a rotated token → `401 REFRESH_REUSE_DETECTED` and the whole family is revoked.

### `POST /v1/auth/logout`

```
body: { refreshToken?: string, allDevices?: boolean }
204
```

Invalidates the presented refresh token (or the whole family when `allDevices`). The access token is short-lived; logout is not complete until the refresh is revoked (`FR-CUS-002` AC3).

### `GET /v1/auth/sessions` · `DELETE /v1/auth/sessions/{id}`

Lists active refresh-token families (device label, last IP, last used). Revoke one. (`FR-VEN-027` AC2; offered to Customers as well `[PROPOSED]`.)

### `POST /v1/auth/password`

Vendor (and Admin, for self-change) set or change email/password.

```
body: { currentPassword?: string, newPassword: string }
204
```

Password policy: `NFR-012`. Setting a password the first time omits `currentPassword`.

### `POST /v1/auth/password/reset/request` · `…/confirm` `[ASSUMED]` `AD-API-10`

Email a one-time reset token (Vendor). Confirm sets a new password and revokes all sessions. Admin password reset is performed by another Admin (`POST /v1/admin/admins/{id}` does not set a password in the body; a separate `POST /v1/admin/admins/{id}/password-reset` emails the Admin). `[PROPOSED]`

### `POST /v1/devices` · `DELETE /v1/devices/{id}` `[PROPOSED]`

Registers an APNs/FCM token for push (`FR-SYS-008`).

```
body: { platform: IOS | ANDROID, pushToken: string, deviceLabel?: string }
201 data: { id: UUID }
```

---

## 9. Current user (`/v1/me`)

### `GET /v1/me`

```
Me = {
  id: UUID
  userType: UserType
  accountState: AccountState
  mobileNumber: string
  mobileVerifiedAt: DateTime
  email?: string
  emailVerifiedAt?: DateTime
  preferredLanguage: en | ar
  createdAt: DateTime
  lastLoginAt?: DateTime
  oauthBound: boolean                  // Customers
  customer?: CustomerProfile
  vendor?: VendorMe
  admin?: { displayName: string }
}

CustomerProfile = {
  displayName: string
  photoUrl?: string
  defaultRegion?: RegionSummary
  rating?: RatingSummary               // never returned to another Customer
  reviewCount: integer
  connectionCount: integer
  lifetimeRequestCount: integer
}

VendorMe = {
  lifecycle: VendorAccountState
  verificationState: VendorVerification
  tradingName: string
  legalBusinessName: string
  awaitingApproval: boolean            // true unless lifecycle = ACTIVE
  awaitingApprovalReason?: string      // e.g. PENDING_DOCUMENTS, PENDING_ADMIN, CATEGORIES_REQUIRED
  rating: RatingSummary
  reviewCount: integer
  offersSubmittedCount: integer
  offersAcceptedCount: integer
  awayMode: boolean
}
```

`GET /v1/me` is the **only** marketplace endpoint a non-`ACTIVE` Vendor may call besides KYC/profile/document routes, sessions, and notifications about verification. Everything else is `403 VENDOR_NOT_ACTIVE`.

### `PATCH /v1/me`

Customer: `displayName`, `email`, `preferredLanguage`, `defaultRegionId`, `photoMediaKey`.
Vendor (non-sensitive): see `PATCH /v1/me/vendor`. This route still accepts `preferredLanguage`.

Email change sends a confirmation link; the new value is pending until verified (`FR-CUS-003` AC4). `[PROPOSED]` pending field: `emailPending`.

### `POST /v1/me/mobile/change`

```
body: { challengeId: UUID }            // purpose = CHANGE_MOBILE, OTP of the *new* number
200 data: Me
```

### `POST /v1/me/deactivate` `[ASSUMED]` (`FR-CUS-004`)

Closes all `PUBLISHED` / `OFFERS_RECEIVED` Requests, blocks login. Vendors: equivalent of a self-requested deactivation; Admin still owns the terminal `DEACTIVATED` state (`FR-ADM-016`). `[PROPOSED]` for Vendor self-deactivation: same route, `403` if any `ACTIVE` Connection exists.

### `POST /v1/me/deletion-requests` `[ASSUMED]` (`FR-CUS-004`, `NFR-019`)

Two-step: this call creates a pending request; a follow-up `POST /v1/me/deletion-requests/{id}/confirm` with a fresh OTP commits it. Refused while a Connection was created in the preceding 30 days (`FR-CUS-004` AC2). Completes within 30 days via the worker; Admin receives a completion certificate.

### `GET /v1/me/settings` · `PATCH /v1/me/settings`

```
Settings = {
  preferredLanguage: en | ar
  defaultRegionId?: UUID
  quietHours?: { start: string, end: string, timezone: "Asia/Dubai" }   // HH:MM
  defaultFilterPresetId?: UUID          // Vendor
  notifications: {
    [category: string]: { inApp: boolean, push: boolean, email: boolean }
  }
}
```

Security-critical categories cannot be disabled (`FR-CUS-032` AC4, `FR-SYS-008` AC2). Notification preference changes are honoured within one minute (`FR-CUS-034` AC2).

---

## 10. Taxonomy and platform config

Active nodes only for Customer/Vendor. Admins use `/v1/admin/categories` (includes inactive).

### `GET /v1/categories` · `GET /v1/regions`

Returns the two-level tree. No pagination (bounded reference data).

### `GET /v1/platform-config` `[PROPOSED]`

Read-only snapshot of the settings a client needs to render forms without an Admin round-trip. Sourced from `PLATFORM_SETTING` (`FR-ADM-030`).

```
data: {
  requestLifetimeHours: integer         // default 48 (C-07)
  offerValidityHours: integer[]         // default [12, 24, 48]
  defaultOfferValidityHours: integer    // 24
  bullionMinimumAed: Money              // "500.00"
  maxConcurrentLiveRequests: integer    // 10
  maxRequestImages: integer             // 5
  maxOfferImages: integer               // 3
  maxImageBytes: integer
  acceptedImageTypes: string[]
  karatList: Karat[]
  maxOfferRevisions: integer            // 3
  requestExpiryWarningHours: integer    // 6
}
```

`BR-020`: a setting change never retroactively alters existing Requests or Offers. Clients must not cache this for longer than `meta.serverTime` + 5 minutes. `[PROPOSED]`

---

## 11. Reference gold rates

### `GET /v1/gold-rates`

**Legal:** production **display** of these values to end users is `[BLOCKED]` on Yahoo Finance redistribution terms (SRS §7.4, A-06). The route is specified so clients and the indicative-value calculation have a contract. Until Legal signs off, a feature flag `goldRates.endUserDisplay` (platform setting) gates whether `rates` is populated or returned as `{ available: false, stale: true, reason: "DISPLAY_NOT_LICENSED" }`. Admin `/v1/admin/gold-rates` is not gated.

**Every** response shape of this route — the populated snapshot, the empty last-good case, and the display-not-licensed branch — carries both `available` (boolean) and `stale` (boolean). Clients (`CUS-S04`–`S07`) branch on those two flags only and never infer staleness from a timestamp (`CBG-02`). The display-not-licensed branch reports `available: false, stale: true`.

```
200 data: {
  available: boolean
  stale: boolean
  source: FEED | MANUAL_OVERRIDE
  sourceTimestamp: DateTime
  ingestedAt: DateTime
  staleAfter: DateTime
  rates: { karat: Karat, ratePerGramAed: Money }[]
  disclaimer: string            // already localised; "indicative, not a quotation"
}
```

Never returns `"0.00"` as a fabricated fallback (`FR-SYS-010` AC2). If no last-good value exists, `available = false` and `rates = []`.

Bullion publish (`POST /v1/requests/{id}/publish` with `GOLD_BULLION`) requires `available = true`; otherwise `503 GOLD_RATE_UNAVAILABLE`. Other Request types still publish (`FR-CUS-018` AC4).

---

## 12. Media

Sequence is backend §16 / SRS §7.6. Direct-to-storage PUT; the API never proxies 5 MB photographs (`NFR-005`).

```
POST /v1/media/upload-intent  →  { uploadUrl, objectKey, headers, expiresAt }
PUT  {uploadUrl}              →  storage (S3/R2/MinIO), not this API
POST /v1/media/{key}/complete →  HEAD verify, insert row, enqueue processing
```

### `POST /v1/media/upload-intent` *Idempotency-Key required*

```
body: {
  purpose: MediaPurpose
  contentType: string
  byteSize: integer
  parentType?: REQUEST | OFFER | VENDOR_PROFILE | VENDOR_DOCUMENT
  parentId?: UUID
}
201 data: {
  key: string
  uploadUrl: string             // pre-signed PUT, default 15 min (NFR-014)
  requiredHeaders: { [name: string]: string }   // Content-Type, x-amz-*
  maxBytes: integer
  expiresAt: DateTime
}
```

Authorisation:

| purpose | Who | Notes |
|---|---|---|
| `REQUEST_IMAGE` | Customer, parent owned, Request not terminal | max 5 per Request |
| `OFFER_IMAGE` | Vendor, parent owned or about to be created | max 3 per Offer |
| `PROFILE_PHOTO` | Customer | |
| `VENDOR_LOGO` / `VENDOR_SHOP_PHOTO` | Vendor (shell ok) | |
| `KYC_DOCUMENT` | Vendor (shell ok) | PDF/JPEG/PNG, max 10 MB (`FR-VEN-002`); **separate bucket** |
| `EXPORT_ARTEFACT` | never a client | Admin exports only |

The pre-signed PUT is constrained by content-type and max size. A client that PUTs a different type will fail `complete`.

### `POST /v1/media/{key}/complete`

No body. Server HEADs the object, verifies size and content-type, inserts the media row in `PENDING_PROCESSING`, emits outbox for the worker.

```
200 data: MediaRef              // state = PENDING_PROCESSING
```

Worker: magic-byte inspect → malware scan → strip all EXIF including GPS → re-encode → thumbnail → `READY` or `QUARANTINED` (`FR-SYS-009`). Originals are never served to counterparties before `READY`.

A Request cannot be published while any attached media is not `READY` (`MEDIA_NOT_READY`) or is `QUARANTINED`.

### `DELETE /v1/media/{key}`

Allowed while the parent is a `DRAFT` Request, a not-yet-submitted Offer, or an unprocessed KYC replace. `409` after publish.

KYC objects are never served to Customers or other Vendors. Every Admin download is individually audited (`NFR-015`).

---

## 13. Requests

Screens: `CUS-S02`–`CUS-S10`, `CUS-S17`.

Direction is fixed by type: `FIND_ORNAMENT` → `BUY`; `SELL_OLD_GOLD` → `SELL`; coins and bullion are caller-selected (`FR-CUS-005`).

### `POST /v1/requests`

Creates a `DRAFT`. Mandatory-field validation is **not** applied (`FR-CUS-015`).

```
body: {
  requestType: RequestType
  direction?: Direction          // required for GOLD_COIN, GOLD_BULLION; ignored otherwise
  categoryId?: UUID
  regionId?: UUID
  notes?: string
  weightGrams?: WeightGrams
  weightIsApproximate?: boolean
  purityKarat?: Karat
  ornamentType?: OrnamentType
  condition?: Condition
  denominationGrams?: WeightGrams
  quantity?: integer
  mintOrRefiner?: string
  budgetMin?: Money
  budgetMax?: Money
  budgetIsFlexible?: boolean
  gemstones?: { present: boolean, type?: string, count?: integer }   // FIND_ORNAMENT [ASSUMED] shape
  mediaKeys?: string[]           // 0–5, display order = array order
}
201 data: RequestForCustomer     // state = DRAFT, no reference yet
```

Notes are scanned for phone/email; a **warning** is returned in `meta.warnings` on save, and a **hard block** (`422 CONTACT_DETAILS_IN_TEXT`) on publish (`FR-VEN-011` AC4 `[ASSUMED]`, `BR-022`).

Drafts older than 30 days are purged by a worker after a T−3-day notification (`FR-CUS-015` AC4).

### `GET /v1/me/requests`

Customer collection. Query:

```
state?: RequestState[]           // default: DRAFT, PUBLISHED, OFFERS_RECEIVED, ACCEPTED
requestType?: RequestType
direction?: Direction
q?: string                       // reference
from?: DateTime
to?: DateTime
limit, cursor
```

`state` including terminal values is the History screen (`CUS-S17`, `FR-CUS-028`). History is read-only; the same list endpoint serves it.

Each row is `RequestForCustomer` **without** nested `offers` (use the offers sub-collection). Rows still carry `unreadOfferCount` (PENDING offers not yet marked viewed) so `CUS-S02` / `CUS-S11` can badge without fetching the offers (`SAM-GAP-1` / `CBG-01`; presenter-time aggregate, no denormalised column).

### `GET /v1/requests/{id}`

Shared resource, presenter selected by viewer:

| Viewer | Presenter | 404 when |
|---|---|---|
| Owning Customer | `RequestForCustomer` (offers nested on this GET) | not owner |
| Matched Vendor, Request `PUBLISHED` or `OFFERS_RECEIVED` | `RequestForVendor` | not in match set, or Request terminal to them |
| Winning Vendor after accept | `RequestForVendor` plus `connectionId` | other Vendors see `404` |
| Anyone else | `404` | |

Marking a match as viewed is **not** a side effect of this GET. The Vendor client calls `POST /v1/matches/{requestId}/viewed` when the detail screen is opened (`FR-VEN-010` AC5) so retries and prefetch do not decrement the New Requests count.

### `PATCH /v1/requests/{id}` `[ASSUMED]` (`FR-CUS-015`, `FR-CUS-016`)

**Draft:** any field, including `requestType` (changing type clears type-specific fields, `FR-CUS-005` AC1).

**Published / Offers received:** `notes`, `budget*`, `mediaKeys` only. Structural attributes → `409 STRUCTURAL_FIELD_IMMUTABLE` (`BR-014`). Every successful published edit versions internally and notifies Vendors holding a pending Offer (`FR-CUS-016` AC4).

**Accepted or terminal:** `409`.

### `POST /v1/requests/{id}/publish` *Idempotency-Key required*

Transitions `DRAFT` → `PUBLISHED`. Server-side validation of type-specific mandatory fields (`FR-CUS-014`).

Refused when:

- OAuth not bound → `403 OAUTH_REQUIRED` (`BR-001`)
- media not `READY` → `422 MEDIA_NOT_READY` / `MEDIA_QUARANTINED`
- contact details in notes → `422 CONTACT_DETAILS_IN_TEXT`
- live Request count ≥ configured max → `409 CONCURRENT_REQUEST_LIMIT`
- bullion indicative value < floor → `422 BULLION_BELOW_MINIMUM`
- bullion and no rate → `503 GOLD_RATE_UNAVAILABLE`

On success: stamps `publishedAt`, `expiresAt = publishedAt + requestLifetimeHours`, assigns `reference`, snapshots `indicativeValue` and `goldRateId`, emits outbox for fan-out (`FR-SYS-001`). Zero matches still publishes; `meta.matchCount = 0` so the client can tell the Customer (`FR-SYS-001` AC3).

```
200 data: RequestForCustomer
```

### `POST /v1/requests/{id}/cancel` `[ASSUMED]` (`FR-CUS-017`)

```
body: { reason?: string }        // configured list
200 data: RequestForCustomer     // state = CANCELLED
```

Allowed from `DRAFT`, `PUBLISHED`, `OFFERS_RECEIVED`. `ACCEPTED` → `409 REQUEST_NOT_CANCELLABLE`. Pending Offers become `WITHDRAWN_BY_SYSTEM`; those Vendors are notified.

### `POST /v1/requests/{id}/duplicate` `[PROPOSED]` (`FR-SYS-005` AC4)

From an `EXPIRED` or `CANCELLED` Request, creates a new `DRAFT` copying type-specific fields and media keys (media is re-attached, not re-uploaded). Does not copy Offers.

---

## 14. Match set (Vendor feed)

Screens: `VEN-S05`–`VEN-S08`. Auth: `ACTIVE` Vendor only.

The feed is **this Vendor’s match set**, not the world’s open Requests (`FR-SYS-002`, `FR-VEN-008`). Identity fields of the Customer are absent (`FR-VEN-011`).

### `GET /v1/matches`

```
query: {
  requestType?, direction?, categoryId?, regionId?,
  purityKarat?,
  weightMin?, weightMax?,
  budgetMin?, budgetMax?,
  publishedWithinHours?: integer
  includeResponded?: boolean     // default false (FR-VEN-008 AC3)
  q?: string                     // reference + notes (FR-VEN-009 AC3)
  sort?: NEWEST | EXPIRING | HIGHEST_VALUE | FEWEST_OFFERS   // default NEWEST
  presetId?: UUID                // saved filter (FR-VEN-009 AC4)
  limit, cursor
}
200 data: RequestForVendor[]
```

Default excludes Requests this Vendor has already offered on. `offerCount` is the only competitive context (`BR-008`).

Search uses PostgreSQL `pg_trgm` (`AD-BE-11`). No Elasticsearch (`C-12`).

### `POST /v1/matches/{requestId}/viewed`

```
204
```

Sets `REQUEST_MATCH.viewed_at` if currently null. Idempotent. Decrements the New Requests dashboard count (`FR-VEN-005`, `FR-VEN-010` AC5).

### Filter presets `[ASSUMED]` (`FR-VEN-009`, `VEN-S07`)

```
FilterPreset = {
  id: UUID
  name: string
  filters: object                // same keys as GET /matches, minus pagination
  createdAt: DateTime
}

GET    /v1/filter-presets
POST   /v1/filter-presets        body: { name, filters }
PATCH  /v1/filter-presets/{id}
DELETE /v1/filter-presets/{id}
```

### `GET /v1/me/dashboard` (`FR-VEN-004`–`007`)

```
data: {
  newRequests: { count: integer, preview: RequestForVendor[] }     // up to 3
  pendingOffers: { count: integer, expiringWithin24h: integer }
  activeConnections: { count: integer, noTalkCount: integer }
  rating: RatingSummary
  goldRates?: GoldRatePayload    // same object as GET /gold-rates; subject to the same display flag
  subscriptions: Subscription[]
}
```

Counts reflect server state; the client may poll on focus. `NFR-003` (30 s) is a freshness SLO, not a push channel.

---

## 15. Offers

Screens: `CUS-S11`–`CUS-S14`, `VEN-S09`–`VEN-S11`, `VEN-S14`.

### `POST /v1/requests/{id}/offers` *Idempotency-Key required*

Vendor submits against a matched, open Request (`FR-VEN-012`).

```
body: {
  offeredPrice: Money            // mandatory
  validityHours: integer         // 12 | 24 | 48, default 24; capped by Request remaining life (FR-VEN-013)
  makingCharges?: Money
  ratePerGram?: Money
  deliveryTimeframe?: string     // max 100
  warrantyTerms?: string
  vendorNote?: string
  mediaKeys?: string[]           // 0–3
}
201 data: OfferForVendor         // state = PENDING
```

Refused when:

- Vendor not `VERIFIED`+`ACTIVE` → `403 VENDOR_NOT_ACTIVE`
- no Type Subscription for this Request type → `403 SUBSCRIPTION_REQUIRED`
- not in match set → `403 NOT_IN_MATCH_SET`
- Request not open → `409 OFFER_NOT_OPEN`
- already holds a `PENDING` Offer → `409 OFFER_ALREADY_PENDING` (client should revise, `BR-009`)
- contact details in `vendorNote` → `422 CONTACT_DETAILS_IN_TEXT`

On success the parent Request moves `PUBLISHED` → `OFFERS_RECEIVED` if it was the first Offer. Customer is notified (`FR-SYS-008`). **Vendor identity is not in the Customer payload** (`BR-006`).

A previous Offer in a terminal state on the same Request does **not** block a new submission if the Request is still open (`FR-VEN-015` AC2).

### `GET /v1/me/offers`

Vendor’s Offers (`FR-VEN-016`).

```
query: {
  tab?: PENDING | ACCEPTED | CLOSED   // CLOSED = REJECTED | EXPIRED | WITHDRAWN | WITHDRAWN_BY_SYSTEM
  requestType?, from?, to?, q?,
  limit, cursor
}
```

`tab=CLOSED` rows include `awardedElsewhere` and `declineReason` without winning price or winning Vendor (`FR-VEN-019`, `BR-008`).

### `GET /v1/requests/{id}/offers`

Customer, owner only (`FR-CUS-019`, `FR-CUS-021`).

```
query: {
  sort?: PRICE_ASC | PRICE_DESC | RATING | NEWEST | OLDEST | EXPIRING
  minRating?: string
  priceMin?, priceMax?,
  excludeExpiringWithinHours?: integer
  limit, cursor
}
```

Default sort: `PRICE_ASC` for `BUY`, `PRICE_DESC` for `SELL` (`FR-CUS-021` AC3). Each element is `OfferForCustomer` (masked Vendor). Comparison of 2–4 Offers (`FR-CUS-020`) is a **client composition** of this list; there is no dedicated compare endpoint.

### `GET /v1/offers/{id}`

| Viewer | Presenter |
|---|---|
| Owning Customer | `OfferForCustomer` |
| Owning Vendor | `OfferForVendor` |
| Anyone else | `404` |

### `GET /v1/offers/{id}/vendor-rating` `[ASSUMED]` (`FR-CUS-031`)

Customer, on an Offer they can see. Returns `RatingSummary` plus up to 10 most recent **published** review excerpts with abbreviated reviewer names. **No business identity.** Vendors with `< 3` reviews have `limitedHistory: true` and the client copy is “New vendor — limited rating history”.

### `POST /v1/offers/{id}/revise` *Idempotency-Key required* `[ASSUMED]` (`FR-VEN-014`)

```
body: OfferTerms                 // full replacement of terms
200 data: OfferForVendor         // revisionCount += 1, expiresAt reset, still PENDING
```

Max 3 revisions → `409 OFFER_REVISION_LIMIT`. Blocked unless `PENDING`. Previous terms stored on `OFFER_REVISION`. Customer is notified with previous and new price.

Expiry reset still cannot exceed the parent Request hard expiry (`FR-VEN-013` AC4).

### `POST /v1/offers/{id}/withdraw` `[ASSUMED]` (`FR-VEN-014`)

```
200 data: OfferForVendor         // state = WITHDRAWN
```

`PENDING` only. Customer notified.

### `POST /v1/offers/{id}/accept` *Idempotency-Key required*

Customer. This is the Acceptance transaction (`FR-CUS-023`, `FR-SYS-006`, `FR-SYS-007`, `BR-011`–`BR-013`). **One PostgreSQL transaction:**

1. `SELECT … FOR UPDATE` the parent Request (`AD-BE-09`)
2. Refuse if Offer not `PENDING`, expired, withdrawn, or Request not open
3. Offer → `ACCEPTED`; Request → `ACCEPTED`; all other `PENDING` Offers → `REJECTED`
4. Insert exactly one `CONNECTION` (`BR-012`) with `identity_revealed_at = now()`
5. Audit `IDENTITY_REVEALED`
6. Outbox: notify winner, notify losers (no winning price/identity, `BR-008`), notify Customer

```
body: { confirmation: "REVEAL_AND_CONNECT" }    // explicit; anything else 400
200 data: {
  offer: OfferForCustomer
  connection: ConnectionForCustomer             // identities present
}
```

Concurrent second accept → `409 OFFER_ALREADY_ACCEPTED`. Stale client against an expired Offer → `409 OFFER_EXPIRED` (enforced synchronously even if the expiry worker has not yet run, `FR-SYS-004` AC2).

Irreversible. There is no un-accept route.

### `POST /v1/offers/{id}/decline` `[ASSUMED]` (`FR-CUS-026`)

```
body: { reason?: DeclineReason, note?: string }
200 data: OfferForCustomer       // state = REJECTED
```

Does **not** close the Request. Other Offers remain. The Vendor is notified without competing prices. Reason is shown to the Vendor in aggregate form only.

---

## 16. Connections and Talk

Screens: `CUS-S15`, `CUS-S16`, `VEN-S12`, `VEN-S13`.

### `GET /v1/me/connections`

```
query: { state?: ACTIVE | CLOSED, limit, cursor }   // default ACTIVE first (FR-VEN-020 AC2)
```

Presenter: `ConnectionForCustomer` or `ConnectionForVendor`. Closed Connections remain readable (`FR-CUS-027` AC4, `FR-VEN-021` AC3`).

### `GET /v1/connections/{id}`

Party only; anyone else `404`. Returns the Talk payload already built (number normalised at profile capture, backend §15.5). Access to revealed Customer contact details is audited (`FR-VEN-021` AC4). Vendors have **no** bulk export (`NFR-016`).

`talk.waUrl` is `https://wa.me/<digits>?text=<urlencoded>` with platform name, Request reference, and a one-line Offer summary in the caller’s language (`FR-CUS-025`, `FR-VEN-022`). `talk.available` is false when `CLOSED`.

### `POST /v1/connections/{id}/close`

```
body: { reason?: string }
200 data: ConnectionForParty     // state = CLOSED
```

Either party. Identity access and history survive. Client is expected to prompt for a review (`FR-CUS-029`, `FR-VEN-028`); the API does not create a review here.

### `POST /v1/connections/{id}/contact-events`

Client reports that Talk or tap-to-call was invoked. **Conversation content is never accepted and must not be sent** (`NFR-017`).

```
body: { channel: WHATSAPP | PHONE }
201 data: ContactEvent
```

Allowed only while `ACTIVE` (`FR-VEN-022` AC3) → else `409 CONNECTION_CLOSED`. The server does not verify that WhatsApp actually opened.

There is no `GET` of conversation content. There is no WhatsApp webhook.

---

## 17. Reviews

Hold-for-approval (`FR-ADM-026`). A newly submitted review is `PENDING_MODERATION` and is **absent** from public aggregates and from the counterparty’s view until `PUBLISHED`.

### `POST /v1/connections/{id}/reviews`

```
body: { rating: 1 | 2 | 3 | 4 | 5, comment?: string }   // comment max 1000
201 data: Review
```

Author must be a party (`BR-016`). At most one per party (`BR-017`) → `409 REVIEW_ALREADY_EXISTS`. Customer reviews attribute `displayName` only; mobile is never exposed (`FR-CUS-029` AC6).

```
Review = {
  id: UUID
  connectionId: UUID
  authorType: CUSTOMER | VENDOR
  rating: integer
  comment?: string
  state: ReviewState
  vendorResponse?: { text: string, state: ReviewState }
  editableUntil: DateTime
  createdAt: DateTime
  publishedAt?: DateTime
}
```

Author sees their own review in any state. Counterparty sees it only when `PUBLISHED`.

### `GET /v1/me/reviews`

Reviews written by me, and (Vendor) reviews **published** about me (`FR-VEN-029`).

### `PATCH /v1/reviews/{id}` `[ASSUMED]` (`FR-CUS-030`)

Author, within 14 days. Re-enters `PENDING_MODERATION`. Past window → `409 REVIEW_EDIT_WINDOW_CLOSED`. All versions retained internally.

### `POST /v1/reviews/{id}/withdraw` `[ASSUMED]`

Author. State `WITHDRAWN`; excluded from aggregates (`FR-SYS-012`).

### `POST /v1/reviews/{id}/response` `[ASSUMED]` (`FR-VEN-029`)

Vendor, on a `PUBLISHED` review about them. Max 500 characters. Enters `PENDING_MODERATION`. One response per review.

### `POST /v1/reviews/{id}/flag` `[ASSUMED]`

Vendor, on a `PUBLISHED` review about them. Re-enters the Admin queue; remains visible until Admin action (`FR-VEN-029` AC3).

---

## 18. Notifications

Screens: `CUS-S19`, `VEN-S17`. In-app centre is the source of truth; push is best-effort (`FR-SYS-008` AC6). Retained 90 days.

### `GET /v1/notifications`

```
query: { unread?: boolean, limit, cursor }
data: [{
  id: UUID
  type: string                   // see trigger lists below
  title: string                  // already localised
  body: string
  deepLink: string               // client route, e.g. /requests/{id}
  isCritical: boolean
  readAt?: DateTime
  createdAt: DateTime
}]
```

Customer triggers (`FR-CUS-032`): first Offer, subsequent Offer, Request T−6 h, Request expired, Offer withdrawn/revised, review reminder, announcement.

Vendor triggers (`FR-VEN-026`): new matched Request, Offer accepted, Offer rejected, Offer T−6 h, Offer expired, Request edited, Request cancelled, verification outcome, KYC nearing expiry, new review, announcement.

### `POST /v1/notifications/{id}/read` · `POST /v1/notifications/read-all` · `GET /v1/notifications/unread-count`

Mark one / all. Unread count for badges. `read-all` and `unread-count` are `[PROPOSED]`.

---

## 19. Abuse reports

Screens: `CUS-S22`, `VEN-S21`. `[ASSUMED]` (`FR-CUS-033`, `FR-VEN-030`).

### `POST /v1/abuse-reports`

```
body: {
  entityType: AbuseEntityType
  entityId: UUID
  category: string               // see per-actor lists
  description: string
}
201 data: { id: UUID, state: OPEN, acknowledged: true }
```

Customer categories: `FRAUDULENT_OFFER | ABUSIVE_BEHAVIOUR | OFF_PLATFORM_SOLICITATION | MISLEADING_TERMS | OTHER`.
Vendor categories: `FRAUDULENT_REQUEST | ABUSIVE_BEHAVIOUR | UNREALISTIC_EXPECTATIONS | SUSPECTED_NON_GENUINE | OTHER`.

Reporter identity is never on any payload visible to the reported party. Customer: max 5 reports / 24 h (`FR-CUS-033` AC4) → `429 RATE_LIMITED`. A Request accumulating reports from 3 distinct Vendors is flagged for priority Admin review (`FR-VEN-030` AC4 `[ASSUMED]`) — worker-side, not a client concern.

There is no Customer/Vendor GET of others’ reports. The reporter does not receive a public tracking timeline in v1 beyond the 201 acknowledgement; resolution notification is pushed (`FR-ADM-032` AC4).

---

## 20. Vendor onboarding, profile and subscriptions

Screens: `VEN-S01`–`VEN-S03`, `VEN-S15`, `VEN-S16`, `VEN-S22`. Shell-permitted except where noted `ACTIVE`.

### `GET /v1/me/vendor` · `PATCH /v1/me/vendor`

```
VendorProfile = {
  legalBusinessName: string
  tradingName: string
  tradeLicenceNumber: string
  licenceExpiryDate: string
  businessAddress: string
  contactPersonName: string
  businessEmail: string
  logo?: MediaRef
  description?: string
  businessHours?: { [weekday: string]: { open: string, close: string, closed: boolean } }
  awayMode: boolean
  verificationState: VendorVerification
  verifiedAt?: DateTime
  lifecycle: VendorAccountState
  maskedPreview: MaskedVendor        // what Customers see pre-acceptance (FR-VEN-024 AC4)
  rating: RatingSummary
  offersSubmittedCount: integer
  offersAcceptedCount: integer
  categories: CategorySummary[]
  regions: RegionSummary[]
}
```

`PATCH` of `tradingName`, `description`, `logoMediaKey`, shop photos, `businessHours`, `contactPersonName`, `businessEmail` takes effect immediately.

`PATCH` of `legalBusinessName`, `tradeLicenceNumber`, or `businessAddress` does **not** take effect immediately: the change is stored as pending and `lifecycle` returns to `PENDING_VERIFICATION` (`BR-004`, `FR-VEN-024` AC2). Marketplace access is lost until Admin re-verifies (`BR-002`).

### Documents `[ASSUMED]` (`FR-VEN-002`)

```
GET  /v1/me/vendor/documents
POST /v1/me/vendor/documents
body: { documentType: DocumentType, mediaKey: string, expiryDate?: string }
```

Returned metadata never includes a download URL for the Vendor of the raw KYC object beyond a “you uploaded this” filename/status. Mandatory: `TRADE_LICENCE`, `EMIRATES_ID`. Optional: `VAT_CERT`, `TRADING_PERMIT`, `TENANCY`.

`POST /v1/me/vendor/resubmit` after `REJECTED` returns the account to `PENDING_VERIFICATION` (`FR-VEN-002` AC6, §5.4).

### Categories, Regions, availability `[ASSUMED]` (`FR-VEN-025`) — `ACTIVE` to change; required before first activation

```
PUT   /v1/me/vendor/categories     body: { categoryIds: UUID[] }    // ≥ 1
PUT   /v1/me/vendor/regions        body: { regionIds: UUID[] }      // ≥ 1
PATCH /v1/me/vendor/availability   body: { awayMode?: boolean, businessHours?: … }
```

Changes apply to Requests published thereafter, not retroactively (`FR-VEN-025` AC2). An account cannot become `ACTIVE` without ≥ 1 Category and ≥ 1 Region (`FR-VEN-025` AC1). `awayMode` suspends new-request notifications only; it does not deactivate the account.

`PUT` responses include `{ estimatedMatchVolume?: integer }` when the platform can estimate (`FR-VEN-025` AC4). `[PROPOSED]` algorithm: count of currently `PUBLISHED`/`OFFERS_RECEIVED` Requests matching the new set. Indicative only.

### `GET /v1/me/subscriptions` — read-only (`FR-VEN-031`, `AD-API-04`)

```
Subscription = {
  requestType: RequestType
  state: SubscriptionState
  periodStart: DateTime
  periodEnd: DateTime
  priceAed: Money                // snapshot
  graceEndsAt?: DateTime
}
```

There is **no** Vendor POST to subscribe. Entitlements are granted by Admin after off-platform payment. The dashboard “upgrade/subscribe path” (`FR-VEN-031` AC4) is a deep link to support / WhatsApp / an Admin-configured URL in `platform-config.subscriptionContactUrl`. `[PROPOSED]`

### `GET /v1/me/vendor/performance` (`FR-VEN-023`)

```
query: { from?, to?, requestType?, categoryId?, regionId? }
data: {
  offersSubmitted: integer
  acceptanceRate: string         // decimal
  averageResponseMinutes: integer
  averageOfferedVsAccepted?: string   // aggregated; never another Vendor's identity or price (BR-008)
  byOutcome: { state: OfferState, count: integer }[]
}
```

### `GET /v1/me/vendor/performance/export` `[ASSUMED]` (`FR-VEN-023` AC3)

Returns `{ downloadUrl, expiresAt }` to a signed CSV in the exports bucket. Vendor’s own records only.

---

## 21. Admin (`/v1/admin`)

All routes require `role = ADMIN` (`AD-API-01`, `AD-API-03`). A Customer or Vendor token on any of these paths is `404` (not `403`) so the Admin surface is not advertised. An Admin token on a marketplace path is `403 FORBIDDEN`.

Self-registration does not exist. `POST /v1/auth/register/admin` is not defined; an unauthenticated hit is `404 ADMIN_SELF_REGISTRATION_FORBIDDEN`.

Coarse RBAC: `FR-ADM-002` Super / Operations / Analyst differentiation is **deferred**. `FR-ADM-030` AC5 (“commercial-impact settings require Super Admin”) is implemented as **any Admin + explicit `confirm: true`** until roles land. `[PROPOSED]`

Admin list GETs are audited when they expose personal data in bulk (`FR-ADM-010` AC5). KYC document URL issuance is audited per access (`NFR-015`).

Shared Admin list query: `q`, `from`, `to`, `limit` (default 20, max 100), `cursor`, plus the filters named per endpoint. Admin list reads may use a replica (`NFR-008`, backend §12.8); detail and all mutations use the primary.

Internal notes (`AD-API-12`):

```
POST /v1/admin/{customers|vendors|requests|offers|connections}/{id}/notes
body: { text: string }
201 data: { id: UUID, text, authorAdminId, createdAt }
```

Notes are Admin-only, attributed and timestamped (`FR-ADM-011` AC3).

### 21.1 Dashboard (`ADM-S02`, `FR-ADM-003`–`009`)

```
GET /v1/admin/dashboard?range=TODAY|7D|30D|90D|CUSTOM&from=&to=
data: {
  customers: { total, newInPeriod, activeInPeriod, suspended }
  vendors: { total, pendingVerification, verifiedOrActive, suspended, rejected, oldestPendingAgeHours }
  requests: { createdInPeriod, byType, byDirection, byState, withAtLeastOneOffer, expiredWithZeroOffers }
  offers: { submittedInPeriod, byState, meanPerRequest, meanMinutesToFirst, acceptanceRate, expiryRate }
  connections: { createdInPeriod, active, closed, meanMinutesRequestToConnection, talkUsedProportion }
  queues: { pendingVerifications, openAbuseReports, reviewsPendingModeration }
  platform: { indicativeGoldWeightTransacted, meanRequestValue, funnel, byCategory, byRegion }
}
```

Figures that derive from indicative values are labelled in `meta.disclaimer`. The platform has no authoritative settlement data (`BR-015`).

### 21.2 Customers (`ADM-S03`, `ADM-S04`, `FR-ADM-010`–`012`)

```
GET /v1/admin/customers
  filters: accountState, regionId, activityLevel=ACTIVE|DORMANT, q (name|mobile|email)
  columns: RevealedCustomer + accountState, registeredAt, requestCount, connectionCount, rating

GET /v1/admin/customers/{id}
  data: profile, requests[], offersReceived[], connections[], reviewsWritten[], reviewsReceived[],
        abuseReports[], notes[], oauthBound, lastLoginAt
  Opening the record is audited.

POST /v1/admin/customers/{id}/suspend          [ASSUMED] FR-ADM-012
  body: { reasonCode: string, reasonText: string }
  Immediate: block login, close PUBLISHED/OFFERS_RECEIVED Requests, WITHDRAWN_BY_SYSTEM on pending Offers,
  notify Customer and affected Vendors.

POST /v1/admin/customers/{id}/reactivate
  Restores login. Does not restore closed Requests.

POST /v1/admin/customers/{id}/erasure          [ASSUMED] NFR-019
  body: { reasonText: string }
  Enqueues the PDPL job (backend §12.7). Returns { jobId, status: QUEUED }.
  Completion certificate is a later GET /v1/admin/exports/{id}.
```

### 21.3 Vendors — list, detail, verification, access (`ADM-S05`–`S07`, `FR-ADM-013`–`016`)

```
GET /v1/admin/vendors
  filters: verificationState, accountState, regionId, categoryId, q (business name|licence|mobile)
  default sort for PENDING_VERIFICATION: oldest first (FR-ADM-015 AC8; no SLA)

GET /v1/admin/vendors/{id}
  data: VendorProfile unmasked, documents[], verificationHistory[], categories, regions,
        offers[], connections[], reviews[], performance, subscriptions[], notes[]

GET /v1/admin/vendors/{id}/documents/{docId}/url
  200 data: { url, expiresAt }     // 15 min signed GET
  Every call audited (NFR-015). Bytes never inline in the detail JSON.

GET /v1/admin/verification-queue
  Vendors in PENDING_VERIFICATION, oldest first, with oldestWaitingHours.

POST /v1/admin/vendors/{id}/verify
  body: { rationale: string }                        // mandatory
  → verificationState VERIFIED. ACTIVE still requires Categories + Regions (FR-ADM-015 AC5, §5.4).
  If those are already declared, the same transaction advances to ACTIVE.

POST /v1/admin/vendors/{id}/reject
  body: { rationale: string }                        // sent to the Vendor; resubmission allowed

POST /v1/admin/vendors/{id}/request-info
  body: { message: string }
  Remains PENDING_VERIFICATION; Vendor sees the message in the shell.

POST /v1/admin/vendors/{id}/activate | suspend | reactivate | deactivate
  body: { reasonCode: string, reasonText: string }

  suspend: immediate. Blocks Requests and new Offers; withdraws PENDING Offers and notifies
           those Customers. Does NOT close ACTIVE Connections (FR-ADM-016 AC2).
  deactivate: terminal. Removed from future matching (FR-SYS-002).
  reactivate (from SUSPENDED): full access, no re-verification, if KYC unexpired.
```

All of the above are audited with acting Admin, reason, before/after.

### 21.4 Type Subscription grant `[PROPOSED]` `AD-API-04`

Payment is off-platform. Admin records the entitlement the Vendor paid for.

```
POST /v1/admin/vendors/{id}/subscriptions
body: {
  requestType: RequestType
  periodStart: DateTime
  periodEnd: DateTime
  priceAed: Money
  paymentReference?: string      // off-platform receipt / invoice id
}
201 data: Subscription           // state = ACTIVE

PATCH /v1/admin/vendors/{id}/subscriptions/{requestType}
body: { state?: GRACE | EXPIRED | CANCELLED, periodEnd?: DateTime, reasonText: string }
```

Upgrades (new type, or replacing EXPIRED) take effect immediately; downgrades/cancellations take effect at period end unless Admin forces `EXPIRED` (`FR-VEN-031` AC5). One non-terminal row per `(vendor, requestType)`.

### 21.5 Requests, Offers, Connections (`ADM-S08`–`S13`, `FR-ADM-017`–`023`)

Admin presenters are fully unmasked. Admin **cannot** alter a Customer’s requirements or a Vendor’s price (`FR-ADM-018` AC3, `FR-ADM-021` AC3).

```
GET /v1/admin/requests
  filters: requestType, direction, state, categoryId, regionId, valueMin, valueMax,
           zeroOffers=true, q (reference|notes)

GET /v1/admin/requests/{id}
  data: RequestForAdmin, media, matchedVendors[] (identity + eligible),
        offers[] (OfferForAdmin), transitions[], connection?

POST /v1/admin/requests/{id}/remove          [ASSUMED] FR-ADM-019
  body: { reasonCode, reasonText, policyClause?: string }
  Request → REMOVED (terminal, retained). Pending Offers → WITHDRAWN_BY_SYSTEM.
  Customer notified with policy clause. Never hard-deleted.

GET /v1/admin/offers
  filters: state, vendorId, requestType, priceMin, priceMax

GET /v1/admin/offers/{id}
  data: OfferForAdmin, revisionHistory[], transitions[], parent Request, winningOfferId?

GET /v1/admin/connections
  default filter state=ACTIVE
  filters: state, regionId, categoryId, noContact=true
  48h-without-Talk is a derived flag (FR-ADM-022 AC3)

GET /v1/admin/connections/{id}
  data: ConnectionForAdmin, both reviews, linked abuse reports
  Conversation content is structurally absent (NFR-017).

POST /v1/admin/connections/{id}/close
  body: { reasonText: string }     // notifies both parties
```

### 21.6 Taxonomy (`ADM-S14`, `ADM-S15`, `FR-ADM-024`, `FR-ADM-025`) — [BUILT - Checkpoint-1]

```
GET / POST / PATCH  /v1/admin/categories
POST                /v1/admin/categories/{id}/deactivate
GET / POST / PATCH  /v1/admin/regions
POST                /v1/admin/regions/{id}/deactivate
```

Create/rename/reorder/activate/deactivate. Two-level hierarchy. `nameEn` and `nameAr` mandatory. Category `icon` is optional (`VARCHAR(100)`). In-use categories cannot be deleted (`BR-019`) → `409 TAXONOMY_IN_USE`. Deactivate hides from new selection; existing associations remain. Changes apply to subsequent Requests only. Built and audited via `AuditWriter`.

Regions: identical implementation at `/v1/admin/regions` (emirate → area).

There is no DELETE route (deactivate only).

### 21.7 Review moderation (`ADM-S16`, `FR-ADM-026`)

Hold-for-approval is mandatory, not a toggle.

```
GET /v1/admin/reviews
  filters: state=PENDING_MODERATION|FLAGGED|PUBLISHED, authorType

POST /v1/admin/reviews/{id}/approve
POST /v1/admin/reviews/{id}/reject     body: { rationale: string }   // sent to author
POST /v1/admin/reviews/{id}/redact     body: { rationale: string, redactedComment: string }
                                                             // original retained internally
```

Approve/reject/redact recomputes aggregates (`FR-SYS-012`) within 60 seconds via outbox. Vendor responses use the same three actions. Every decision is audited.

### 21.8 Reports and exports (`ADM-S17`, `FR-ADM-027`, `FR-ADM-028`)

```
GET /v1/admin/reports/{name}
  name = acquisition | vendor-league | request-volume | offer-competitiveness |
         funnel | liquidity-gaps | rating-distribution
  query: from, to, regionId, categoryId
  200 data: { name, generatedAt, rows: object[], series: object[] }

POST /v1/admin/exports                         [ASSUMED] FR-ADM-028
  body: { reportName, format: CSV | XLSX | PNG, filters: object, purpose: string }
  202 data: { id, status: QUEUED }
  Personal-data exports are watermarked with Admin, timestamp, purpose, and audited (NFR-016).
  > 50,000 rows always asynchronous.

GET /v1/admin/exports/{id}
  200 data: { status: QUEUED | RUNNING | READY | FAILED, downloadUrl?: string, expiresAt?: DateTime }
```

### 21.9 Announcements (`ADM-S18`, `FR-ADM-029`)

```
GET  /v1/admin/announcements
POST /v1/admin/announcements
body: {
  titleEn, titleAr, bodyEn, bodyAr,
  audience: { userTypes?: UserType[], accountStates?: AccountState[], regionIds?: UUID[], categoryIds?: UUID[] },
  channels: { inApp: boolean, push: boolean, email: boolean },
  critical: boolean,                 // overrides recipient preferences
  scheduledFor?: DateTime
}
POST /v1/admin/announcements/{id}/cancel     // only before dispatch begins
```

Delivery stats `{ sent, delivered, opened }` are on the GET detail. Copy is delivered in each recipient’s preferred language.

### 21.10 Platform settings (`ADM-S19`, `FR-ADM-030`)

```
GET   /v1/admin/settings
PATCH /v1/admin/settings/{key}
body: { value: JSON, confirm?: boolean }
```

Minimum keys: `bullion.minimum_value_aed`, `offer.validity_hours_options`, `offer.default_validity_hours`, `request.lifetime_hours` (product default 48, `C-07`), `request.max_concurrent_live`, `purity.karat_list`, `media.max_images`, `media.max_bytes`, `subscription.products` (per Request type: price, period, grace). Review moderation mode is **not** a setting — hold-for-approval is fixed.

Each GET row: `{ key, value, dataType, allowedRange, requiresConfirmation, lastChangedBy, lastChangedAt }`.

`BR-020`: applies only to entities created after the change. Commercial-impact keys require `confirm: true` (`AD-API-03`). Every change is audited with before/after.

### 21.11 Gold rates (`ADM-S20`, `FR-ADM-031`)

```
GET  /v1/admin/gold-rates              // current + feed health (last success, consecutive failures, stale)
GET  /v1/admin/gold-rates/history      // cursor-paginated; reconstructs any past indicative value
POST /v1/admin/gold-rates/override
body: { karat: Karat, ratePerGramAed: Money, reason: string, expiresAt: DateTime }
```

Override is per purity, mandatory reason, explicit expiry; feed resumes afterwards. Poll interval and staleness threshold are platform settings, not this body. Feed failover and overrides are audited.

Not blocked on Yahoo redistribution — this is operator configuration. End-user **display** remains `[BLOCKED]` (`AD-API-09`).

### 21.12 Abuse queue (`ADM-S21`, `FR-ADM-032`) `[ASSUMED]`

```
GET  /v1/admin/abuse-reports           // OPEN | UNDER_REVIEW first; severity then age
GET  /v1/admin/abuse-reports/{id}      // reporter (Admin only), reported party, linked entity
POST /v1/admin/abuse-reports/{id}/resolve
body: { resolution: DISMISS | WARN | SUSPEND | DEACTIVATE, rationale: string }
```

`SUSPEND` / `DEACTIVATE` compose the corresponding account action in the same transaction. Reporter is notified that it was resolved; resolution detail and reporter identity are never sent to the reported party.

### 21.13 Audit log (`ADM-S22`, `FR-ADM-033`) `[ASSUMED]`

```
GET /v1/admin/audit-log
  filters: actorUserId, action, entityType, entityId, from, to, ip
  data: [{ id, actorUserId, action, entityType, entityId, before, after, ip, userAgent, occurredAt }]
```

Append-only. There is no PATCH or DELETE, including for Admins (`FR-SYS-011` AC3). Access to this endpoint is itself audited (`FR-ADM-033` AC3). Retention ≥ 24 months (`NFR-021`).

### 21.14 Admin user management (`ADM-S23`, `FR-ADM-002`) `[ASSUMED]` · coarse (`AD-API-03`)

```
GET  /v1/admin/admins
POST /v1/admin/admins
body: { email: string, displayName: string }
201  { id, email, displayName, accountState: ACTIVE }
     Temporary password emailed; 2FA enrolment required before first session is fully privileged.
     No `role` field.

POST /v1/admin/admins/{id}/suspend
POST /v1/admin/admins/{id}/revoke          // terminal; audit trail of past actions is retained
POST /v1/admin/admins/{id}/password-reset
```

An Admin cannot revoke their own last remaining active Admin account. `[PROPOSED]` guard.

---

## 22. FR → route traceability

Every FR in SRS §4 maps to at least one route or to a worker (no HTTP). `[ASSUMED]` FRs from Appendix B.3 are included, not skipped.

### 22.1 Customer

| FR | Routes / mechanism |
|---|---|
| CUS-001 | `POST /v1/auth/google/session`, `POST /v1/auth/register/customer`; OTP for phone proof; publish gate on `POST /v1/requests/{id}/publish` |
| CUS-002 | `POST /v1/auth/google/session`, `POST /v1/auth/refresh`, `POST /v1/auth/logout`, `GET/DELETE /v1/auth/sessions` |
| CUS-003 | `GET/PATCH /v1/me`, `POST /v1/me/mobile/change` |
| CUS-004 | `POST /v1/me/deactivate`, `POST /v1/me/deletion-requests`, `POST /v1/admin/customers/{id}/erasure` |
| CUS-005–013 | `POST/PATCH /v1/requests`, `GET /v1/platform-config`, `GET /v1/gold-rates`, media pipeline |
| CUS-014 | `POST /v1/requests/{id}/publish` |
| CUS-015 | `POST /v1/requests`, `PATCH /v1/requests/{id}` (draft) |
| CUS-016 | `PATCH /v1/requests/{id}` (published, limited fields) |
| CUS-017 | `POST /v1/requests/{id}/cancel` |
| CUS-018 | `GET /v1/gold-rates` (display `[BLOCKED]`) |
| CUS-019–021 | `GET /v1/requests/{id}/offers` |
| CUS-022 | `GET /v1/offers/{id}` |
| CUS-023 | `POST /v1/offers/{id}/accept` |
| CUS-024 | presenter on `GET /v1/connections/{id}` |
| CUS-025 | `talk` on Connection + `POST /v1/connections/{id}/contact-events` |
| CUS-026 | `POST /v1/offers/{id}/decline` |
| CUS-027 | `GET /v1/me/connections`, `POST /v1/connections/{id}/close` |
| CUS-028 | `GET /v1/me/requests?state=…` |
| CUS-029 | `POST /v1/connections/{id}/reviews` |
| CUS-030 | `PATCH /v1/reviews/{id}`, `POST /v1/reviews/{id}/withdraw` |
| CUS-031 | `GET /v1/offers/{id}/vendor-rating` |
| CUS-032 | `GET /v1/notifications*` |
| CUS-033 | `POST /v1/abuse-reports` |
| CUS-034 | `GET/PATCH /v1/me/settings` |

### 22.2 Vendor

| FR | Routes / mechanism |
|---|---|
| VEN-001 | `POST /v1/auth/register/vendor` |
| VEN-002 | media `purpose=KYC_DOCUMENT`, `GET/POST /v1/me/vendor/documents`, `POST /v1/me/vendor/resubmit` |
| VEN-003 | `POST /v1/auth/google/session` (`AD-API-13`); shell enforced as `403 VENDOR_NOT_ACTIVE` |
| VEN-004–007 | `GET /v1/me/dashboard` |
| VEN-008–009 | `GET /v1/matches`, `/v1/filter-presets*` |
| VEN-010 | `GET /v1/requests/{id}` (vendor presenter), `POST /v1/matches/{id}/viewed` |
| VEN-011 | presenter rule on every Vendor Request/Offer payload |
| VEN-012–013 | `POST /v1/requests/{id}/offers` |
| VEN-014 | `GET /v1/offers/{id}` (current terms), `POST /v1/offers/{id}/revise`, `/withdraw` |
| VEN-015 | uniqueness → `409 OFFER_ALREADY_PENDING` |
| VEN-016–019 | `GET /v1/me/offers` |
| VEN-020–021 | `GET /v1/me/connections`, `GET /v1/connections/{id}` |
| VEN-022 | Talk payload + `POST /v1/connections/{id}/contact-events` |
| VEN-023 | `GET /v1/me/vendor/performance`, `/export` |
| VEN-024 | `GET/PATCH /v1/me/vendor` |
| VEN-025 | `PUT /v1/me/vendor/categories`, `/regions`, `PATCH …/availability` |
| VEN-026 | `GET /v1/notifications*` |
| VEN-027 | `GET/PATCH /v1/me/settings`, sessions, `POST /v1/auth/password` |
| VEN-028 | `POST /v1/connections/{id}/reviews` |
| VEN-029 | `GET /v1/me/reviews`, `POST /v1/reviews/{id}/response`, `/flag` |
| VEN-030 | `POST /v1/abuse-reports` |
| VEN-031 | `GET /v1/me/subscriptions` (read); Admin grant in §21.4 |

### 22.3 Admin

| FR | Routes / mechanism |
|---|---|
| ADM-001 | `POST /v1/auth/google/session` (`AD-API-13`). No self-registration. Password + 2FA leftover until G2-A15. |
| ADM-002 | `/v1/admin/admins*` (coarse, no role column) |
| ADM-003–009 | `GET /v1/admin/dashboard` |
| ADM-010–012 | `/v1/admin/customers*` |
| ADM-013–016 | `/v1/admin/vendors*`, `/verification-queue` |
| ADM-017–019 | `/v1/admin/requests*` |
| ADM-020–021 | `/v1/admin/offers*` |
| ADM-022–023 | `/v1/admin/connections*` |
| ADM-024 | `/v1/admin/categories*` |
| ADM-025 | `/v1/admin/regions*` |
| ADM-026 | `/v1/admin/reviews*` |
| ADM-027–028 | `/v1/admin/reports/{name}`, `/v1/admin/exports*` |
| ADM-029 | `/v1/admin/announcements*` |
| ADM-030 | `/v1/admin/settings*` |
| ADM-031 | `/v1/admin/gold-rates*` |
| ADM-032 | `/v1/admin/abuse-reports*` |
| ADM-033 | `GET /v1/admin/audit-log` |

### 22.4 System (no HTTP, or enforced on existing routes)

| FR | Mechanism |
|---|---|
| SYS-001 | Outbox worker after publish |
| SYS-002 | Match materialisation; enforced on `GET /v1/matches` and Offer submit |
| SYS-003 | Presenters; release-gate tests. Direct identity GETs do not exist. |
| SYS-004 | Expiry worker ≤ 5 min + synchronous check on accept |
| SYS-005 | Expiry worker; T−6 h notification; `POST /v1/requests/{id}/duplicate` |
| SYS-006–007 | Inside `POST /v1/offers/{id}/accept` transaction |
| SYS-008 | Notification worker; in-app persisted regardless of push |
| SYS-009 | Media worker after `complete` |
| SYS-010 | Gold-rate poll worker; `GET /v1/gold-rates` reads the snapshot |
| SYS-011 | Append-only writer, same transaction as the action |
| SYS-012 | Worker after review moderation |

### 22.5 Coverage statement

- **110** functional requirements in SRS v1.3 §4 are traced above.
- **37** Appendix B.3 `[ASSUMED]` FRs have full schemas, not stubs.
- Screens in Appendix C each have a primary route in §6. Comparison (`CUS-S12`) is client-side over `GET /v1/requests/{id}/offers`. Image capture (`CUS-S08`) is a client camera/gallery over the media pipeline.
- Business rules `BR-001`–`BR-022` are enforced as errors in §5, not as client filters.

---

## 23. Open items and spec tensions

These are recorded so implementation does not silently resolve them.

| Item | Kind | Impact on this inventory |
|---|---|---|
| Yahoo Finance redistribution to end users | `[BLOCKED]` Legal | `GET /v1/gold-rates` exists; `goldRates.endUserDisplay` feature flag. Indicative value and bullion floor still need a rate server-side. |
| Object-storage residency for KYC (`NFR-020`) | `[BLOCKED]` Infra | Does not change paths. Signed URLs and the KYC bucket policy stay as specified. Adapter swap is config (`adr/0008`). |
| Admin data-grid build-or-buy (`AD-FE-12`) | `[BLOCKED]` Frontend | No API impact. Admin list contracts in §21 are grid-agnostic. |
| `FR-ADM-002` Super / Ops / Analyst | Deferred by `AD-API-03` | Coarse `ADMIN`. Revisit before any permission split; identifiers on Admin routes stay stable. |
| Offer validity options: `FR-VEN-013` (12/24/48) vs entity dictionary (24/48/72/168) | Spec tension | Inventory follows `FR-VEN-013` (`AD-API-07`). Align SRS §6 on the next revision. |
| Type Subscription commercial flow | `[PROPOSED]` `AD-API-04` | Admin-grant, Vendor read-only. If in-app payment is later required, add routes under `/v1/me/subscriptions` without reusing these identifiers for a different meaning. |
| Password reset | `[ASSUMED]` `AD-API-10` | Leftover with password login. Remove with G2-A15 after Google session is the only login. |
| Password login + Admin 2FA routes | Leftover (`adr/0010`) | Still listed in §6/§8; delete under G2-A15. |
| Biometric unlock (`FR-CUS-002` AC5) | Client-only | No API. Convenience layer over an existing session. |
| Dashboard live-update without refresh (`FR-CUS-019` AC4, `NFR-003`) | `[PROPOSED]` | v1 is pull-to-refresh + focus refetch. No WebSocket/SSE (would not need a broker, but is out of v1 scope). |
| Chart PNG export (`FR-ADM-028` AC1) | `[ASSUMED]` | Export `format=PNG` is specified; rendering is an Admin-worker concern. |
| Enumeration-safe OTP login | `[PROPOSED]` | Dummy `challengeId` on unknown LOGIN numbers. |

---

## Appendix A — Revision history

| Version | Date | Change |
|---|---|---|
| 0.1 | 1 Sep 2026 | Initial inventory against SRS v1.3 and backend architecture §13–§16. Locked: `AD-API-01`–`03`, shared resources, coarse Admin, full `[ASSUMED]` schemas. |
| 0.2 | 7 Sep 2026 | `AD-API-13`: Google session exchange (`POST /v1/auth/google/session` + firebase alias) is the only login. §3.4, §5.1, §6, §8, §22 updated. Password/2FA marked leftover (G2-A15). G2-D02. |
| 0.3 | 8 Sep 2026 | Sync to the Checkpoint-1 Customer presenters. §4.7 `RequestForCustomer` gains `unreadOfferCount: integer` (PENDING offers not yet viewed) on `GET /v1/me/requests` rows and `GET /v1/requests/{id}` — `SAM-GAP-1` / `CBG-01`, verified against `request.presenter.ts`. §11 `GET /v1/gold-rates`: recorded that every response shape, the display-not-licensed branch included, carries both `available` and `stale` (`CBG-02`), verified against `gold-rate.presenter.ts`. No route added. |

## Appendix B — Sign-off

| Role | Signs off on | Status |
|---|---|---|
| Technical Lead | Every `[PROPOSED]` `AD-API-*` row in §2 | Pending |
| Product Owner | Appendix B.3 `[ASSUMED]` FRs that this inventory schemas in full | Pending (SRS) |
| Legal | Yahoo Finance end-user display (`AD-API-09`) | Pending |

---

*End of document. Authoritative OpenAPI is generated from code (`NFR-030`) once the monolith exists; this file is the pre-code catalogue and must be diffed against that OpenAPI at first implementation.*
