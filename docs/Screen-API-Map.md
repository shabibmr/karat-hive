# Karat Hive — Screen → API Map

| | |
|---|---|
| **Product** | Karat Hive — request-driven gold marketplace (UAE) |
| **Document** | Screen-to-endpoint coverage map (pre-code completeness check) |
| **Version** | 0.1 |
| **Status** | Draft — `[PROPOSED]`. Read alongside `docs/API-Route-Inventory.md`. |
| **Date** | 1 September 2026 |
| **Source of truth** | [`ui-screens/`](../ui-screens/) (67 screen files) · [`docs/API-Route-Inventory.md`](API-Route-Inventory.md) · [`docs/Requirements-Spec-v1.3.md`](Requirements-Spec-v1.3.md) |
| **Identifier prefix** | `SAM-GAP-nn` — gaps found by *this* document. Stable, never reused. |

---

## 1. Why this document exists

The [API Route Inventory](API-Route-Inventory.md) is organised **by resource**. The screen
inventory is organised **by user journey**. Neither view, on its own, proves that every
screen can be built: a screen needs a call for its **initial load**, a call for **each
action**, and a defined response for **each empty / error state** it renders.

This document is the join. Each of the 67 screens is mapped to:

- **Load / list** — what populates the screen on entry (`GET`s).
- **Actions** — the endpoint behind every `Action`-kind field in the screen file.
- **Empty / error** — the endpoint behaviour or error `code` (from Route Inventory §5)
  behind every row in the screen's *Empty / error / edge states* section.

Where a screen needs something the inventory does not provide, it is recorded in
[§6 Findings](#6-findings) as `SAM-GAP-nn`. **Gaps surface here, not in the generated
OpenAPI** — by then the contract is frozen.

Method: every screen file under `ui-screens/` was read and diffed against the Route Index
(`API-Route-Inventory.md` §6) and the FR → route traceability (§22).

---

## 2. Legend

| Mark | Meaning |
|---|---|
| `GET /v1/…` | Endpoint from the Route Inventory, verified present in §6 |
| *client* | No API call — client-side navigation, composition, or device capability |
| `→ CODE` | Error surfaced as this `error.code` (Route Inventory §5) |
| ⚠️ `SAM-GAP-n` | Screen need not satisfied by the current inventory — see §5 |

Auth context is inherited from the screen's user (Customer / Vendor / Vendor-shell /
Admin) and is not repeated per row.

---

## 3. Mobile — Customer (`CUS-S01` … `CUS-S22`)

| Screen | Load / list | Actions | Empty / error |
|---|---|---|---|
| **CUS-S01** Onboarding | *client* (cold start) | `POST /v1/auth/otp/request` · `POST /v1/auth/otp/verify` · `POST /v1/auth/register/customer` · `POST /v1/auth/oauth/bind` · `POST /v1/auth/logout` · biometric *client* | wrong/expired OTP `→ OTP_INVALID` / `OTP_EXPIRED` · `→ OTP_RATE_LIMITED` · duplicate number `→ MOBILE_ALREADY_REGISTERED` · `→ ACCOUNT_SUSPENDED` / `ACCOUNT_DEACTIVATED` |
| **CUS-S02** Home | `GET /v1/me/requests` (default active states) | quick-create *client* → CUS-S03 · open Request *client* → CUS-S10 · view Offers *client* → CUS-S11 | no Requests → `data: []` (empty state) · unread-offer badge ⚠️ `SAM-GAP-1` |
| **CUS-S03** Request type selection | `GET /v1/platform-config` (`maxConcurrentLiveRequests`) | continue *client* | concurrent-limit block — client compares `GET /v1/me/requests` count vs config; hard stop is `→ CONCURRENT_REQUEST_LIMIT` at publish ⚠️ `SAM-GAP-2` |
| **CUS-S04** Create — Find An Ornament | `GET /v1/categories` · `GET /v1/regions` · `GET /v1/gold-rates` · `GET /v1/platform-config` | `POST /v1/requests` (draft) · `PATCH /v1/requests/{id}` · save draft = `PATCH` · continue *client* → CUS-S09 | field errors `→ VALIDATION_FAILED` (`details[]`) · notes phone/email → `meta.warnings` on save · rate unavailable → `gold-rates.available:false` (compose still allowed) |
| **CUS-S05** Create — Sell Old Gold | as CUS-S04 | as CUS-S04 | as CUS-S04; valuation suppressed when `gold-rates.available:false` |
| **CUS-S06** Create — Gold Coins | as CUS-S04 | as CUS-S04 | `quantity ≤ 0` `→ VALIDATION_FAILED` |
| **CUS-S07** Create — Gold Bullion | as CUS-S04 (rate **required**) | as CUS-S04 | below floor `→ BULLION_BELOW_MINIMUM` (returns threshold + computed value) · no rate `→ GOLD_RATE_UNAVAILABLE` · stale rate → `gold-rates.stale:true` |
| **CUS-S08** Image capture | — | `POST /v1/media/upload-intent` → PUT to storage → `POST /v1/media/{key}/complete` · remove = `DELETE /v1/media/{key}` · reorder = `mediaKeys[]` order on `PATCH /v1/requests/{id}` | failed upload → retry client-side · `→ MEDIA_TYPE_REJECTED` · `→ UPLOAD_NOT_COMPLETED` · post-processing `→ MEDIA_QUARANTINED` |
| **CUS-S09** Request review & publish | `GET /v1/requests/{id}` | `POST /v1/requests/{id}/publish` · save draft = `PATCH /v1/requests/{id}` · bind = `POST /v1/auth/oauth/bind` | `→ OAUTH_REQUIRED` · `→ MEDIA_NOT_READY` · `→ CONTACT_DETAILS_IN_TEXT` · `→ CONCURRENT_REQUEST_LIMIT` · `→ BULLION_BELOW_MINIMUM` · `→ GOLD_RATE_UNAVAILABLE` · validation summary `→ REQUEST_NOT_PUBLISHABLE` |
| **CUS-S10** Request detail (my Request) | `GET /v1/requests/{id}` (owner presenter, offers nested) | `PATCH /v1/requests/{id}` (save edits) · `POST /v1/requests/{id}/cancel` · view Offers *client* → CUS-S11 · open Connection *client* → CUS-S15 ⚠️ `SAM-GAP-3` | structural edit `→ STRUCTURAL_FIELD_IMMUTABLE` · cancel after accept `→ REQUEST_NOT_CANCELLABLE` · zero Offers → empty state on nested `offers: []` |
| **CUS-S11** Offers list | `GET /v1/requests/{id}/offers` (sort/filter query) | open Offer *client* → CUS-S13 · compare *client* → CUS-S12 · live update = client poll | no Offers → `data: []` + Request `expiresAt` · unread marker ⚠️ `SAM-GAP-1` |
| **CUS-S12** Offer comparison | *client* composition over `GET /v1/requests/{id}/offers` | `POST /v1/offers/{id}/accept` · open detail *client* → CUS-S13 | must select 2–4 → *client* guard |
| **CUS-S13** Offer detail | `GET /v1/offers/{id}` · `GET /v1/offers/{id}/vendor-rating` | `POST /v1/offers/{id}/accept` · `POST /v1/offers/{id}/decline` · report → `POST /v1/abuse-reports` ⚠️ `SAM-GAP-4` | stale accept `→ OFFER_EXPIRED` / `OFFER_NOT_PENDING` · terminal Offer → read-only from `state` |
| **CUS-S14** Accept confirmation | *client* (carries Offer id) | `POST /v1/offers/{id}/accept` `{confirmation:"REVEAL_AND_CONNECT"}` | `→ OFFER_EXPIRED` · `→ OFFER_ALREADY_ACCEPTED` · `→ OFFER_NOT_PENDING` · `→ OFFER_NOT_OPEN` |
| **CUS-S15** Connection detail | `GET /v1/connections/{id}` (Talk payload embedded) | `POST /v1/connections/{id}/contact-events` · `POST /v1/connections/{id}/close` · Talk = open `talk.waUrl` *client* · copy number *client* · review *client* → CUS-S18 · report → `POST /v1/abuse-reports` | not a party `→ NOT_FOUND` · closed → `talk.available:false` · WhatsApp missing → copy fallback *client* |
| **CUS-S16** Connections list | `GET /v1/me/connections` (ACTIVE first) | Talk *client* · open detail *client* → CUS-S15 | none → `data: []` |
| **CUS-S17** History | `GET /v1/me/requests?state=<terminal set>` | open historical Request *client* → CUS-S10 | none → `data: []` · pagination via `meta.nextCursor` |
| **CUS-S18** Leave review | `GET /v1/connections/{id}` (`myReview`) | `POST /v1/connections/{id}/reviews` · edit = `PATCH /v1/reviews/{id}` · withdraw = `POST /v1/reviews/{id}/withdraw` | `→ REVIEW_ALREADY_EXISTS` · `→ REVIEW_EDIT_WINDOW_CLOSED` · `→ NOT_A_PARTY` |
| **CUS-S19** Notification centre | `GET /v1/notifications` | `POST /v1/notifications/{id}/read` · `POST /v1/notifications/read-all` · open deep link *client* | none → `data: []` |
| **CUS-S20** Profile | `GET /v1/me` | `PATCH /v1/me` · `POST /v1/me/mobile/change` (+ `POST /v1/auth/otp/request` purpose `CHANGE_MOBILE`) | invalid email `→ VALIDATION_FAILED` · OTP failure `→ OTP_INVALID` |
| **CUS-S21** Settings | `GET /v1/me/settings` | `PATCH /v1/me/settings` · `POST /v1/me/deactivate` · `POST /v1/me/deletion-requests` (+ `…/{id}/confirm`) · logout = `POST /v1/auth/logout` · legal/support links ⚠️ `SAM-GAP-5` | deletion blocked by recent Connection `→ FORBIDDEN` (`FR-CUS-004` AC2) |
| **CUS-S22** Report abuse | *client* (entity context) | `POST /v1/abuse-reports` | `→ RATE_LIMITED` (5 / 24 h) · entity type coverage ⚠️ `SAM-GAP-4` |

---

## 4. Mobile — Vendor (`VEN-S01` … `VEN-S22`)

Vendor-shell screens (`VEN-S01`–`S04`, and re-entry to `S02`/`S16`) are the only ones a
non-`ACTIVE` Vendor may call; everything else is `→ VENDOR_NOT_ACTIVE`.

| Screen | Load / list | Actions | Empty / error |
|---|---|---|---|
| **VEN-S01** Registration | `GET /v1/categories` · `GET /v1/regions` | `POST /v1/auth/otp/request` · `POST /v1/auth/otp/verify` · `POST /v1/auth/register/vendor` | duplicate mobile/licence `→ MOBILE_ALREADY_REGISTERED` / `CONFLICT` · OTP `→ OTP_INVALID` |
| **VEN-S02** KYC document upload | `GET /v1/me/vendor/documents` | `POST /v1/media/upload-intent` (`KYC_DOCUMENT`) → PUT → `POST /v1/media/{key}/complete` · `POST /v1/me/vendor/documents` · replace = `DELETE /v1/media/{key}` then re-upload · `POST /v1/me/vendor/resubmit` | format/size `→ MEDIA_TYPE_REJECTED` · missing mandatory docs `→ VALIDATION_FAILED` |
| **VEN-S03** Awaiting Approval shell | `GET /v1/me` (`vendor.lifecycle`, `awaitingApprovalReason`) ⚠️ `SAM-GAP-6` | re-upload *client* → VEN-S02 · complete Categories/Regions *client* → VEN-S16 ⚠️ `SAM-GAP-7` · support *client* · logout | rejected / more-info state from `GET /v1/me` |
| **VEN-S04** Login | *client* | `POST /v1/auth/otp/request` · `POST /v1/auth/otp/verify` · `POST /v1/auth/login/password` | `→ ACCOUNT_LOCKED` (5 / 15 min) · `→ ACCOUNT_SUSPENDED` / `ACCOUNT_DEACTIVATED` · rejected → state message from login 403 |
| **VEN-S05** Dashboard | `GET /v1/me/dashboard` | pull-to-refresh = re-`GET` · open panels *client* | zero counts → empty guidance from `count: 0` |
| **VEN-S06** Available Requests feed | `GET /v1/matches` | open detail *client* → VEN-S08 · open filters *client* → VEN-S07 · infinite scroll = `meta.nextCursor` | no matches → `data: []` (suggest broaden Categories/Regions/subscription) |
| **VEN-S07** Request filters & presets | `GET /v1/filter-presets` | `POST /v1/filter-presets` · `PATCH /v1/filter-presets/{id}` · `DELETE /v1/filter-presets/{id}` · apply = `GET /v1/matches?presetId=` · reset *client* | zero results → `data: []` + reset CTA |
| **VEN-S08** Request detail (masked) | `GET /v1/requests/{id}` (vendor presenter) | `POST /v1/matches/{requestId}/viewed` (on open) · Submit Offer *client* → VEN-S09 · Revise *client* → VEN-S10 · report → `POST /v1/abuse-reports` ⚠️ `SAM-GAP-4` | not in match set / terminal `→ NOT_FOUND` · closed since open → actions disabled from `state` |
| **VEN-S09** Submit Offer | `GET /v1/platform-config` (`offerValidityHours`) | `POST /v1/requests/{id}/offers` · media as CUS-S08 (`OFFER_IMAGE`) | `→ VENDOR_NOT_ACTIVE` · `→ SUBSCRIPTION_REQUIRED` · `→ NOT_IN_MATCH_SET` · `→ OFFER_NOT_OPEN` · `→ OFFER_ALREADY_PENDING` · `→ CONTACT_DETAILS_IN_TEXT` |
| **VEN-S10** Revise / withdraw Offer | `GET /v1/offers/{id}` (vendor presenter) | `POST /v1/offers/{id}/revise` · `POST /v1/offers/{id}/withdraw` | `→ OFFER_REVISION_LIMIT` · `→ OFFER_NOT_PENDING` |
| **VEN-S11** My Offers | `GET /v1/me/offers?tab=PENDING\|ACCEPTED\|CLOSED` | open detail *client* · revise/withdraw *client* → VEN-S10 · open Connection *client* → VEN-S13 (`connectionId`) | empty per tab → `data: []` |
| **VEN-S12** Connections list | `GET /v1/me/connections` | Talk *client* · open detail *client* → VEN-S13 | none → `data: []` |
| **VEN-S13** Connection detail | `GET /v1/connections/{id}` | `POST /v1/connections/{id}/contact-events` (`WHATSAPP` / `PHONE`) · `POST /v1/connections/{id}/close` · feedback *client* → VEN-S19 · report → `POST /v1/abuse-reports` | closed → `talk.available:false` · contact event on closed `→ CONNECTION_CLOSED` |
| **VEN-S14** Offer history & performance | `GET /v1/me/offers` (terminal) · `GET /v1/me/vendor/performance` | `GET /v1/me/vendor/performance/export` | no terminal Offers → `data: []` |
| **VEN-S15** Business profile | `GET /v1/me/vendor` | `PATCH /v1/me/vendor` | invalid email `→ VALIDATION_FAILED` · legal-identity edit → `lifecycle` returns to `PENDING_VERIFICATION` (`BR-004`) |
| **VEN-S16** Categories, Regions, hours | `GET /v1/me/vendor` · `GET /v1/categories` · `GET /v1/regions` | `PUT /v1/me/vendor/categories` · `PUT /v1/me/vendor/regions` · `PATCH /v1/me/vendor/availability` | zero categories/regions → cannot activate (`FR-VEN-025` AC1) · auth for pre-`ACTIVE` use ⚠️ `SAM-GAP-7` |
| **VEN-S17** Notification centre | `GET /v1/notifications` | `POST /v1/notifications/{id}/read` · open deep link *client* | none → `data: []` |
| **VEN-S18** Settings | `GET /v1/me/settings` · `GET /v1/auth/sessions` | `PATCH /v1/me/settings` · `POST /v1/auth/password` · `DELETE /v1/auth/sessions/{id}` · logout | `→ PASSWORD_POLICY` · no extra sessions → `data: []` |
| **VEN-S19** Leave customer feedback | `GET /v1/connections/{id}` | `POST /v1/connections/{id}/reviews` | `→ REVIEW_ALREADY_EXISTS` |
| **VEN-S20** My reviews & responses | `GET /v1/me/reviews` ⚠️ `SAM-GAP-8` | `POST /v1/reviews/{id}/response` · `POST /v1/reviews/{id}/flag` | no reviews → `data: []` · `→ CONFLICT` (one response per review) |
| **VEN-S21** Report abuse | *client* (entity context) | `POST /v1/abuse-reports` | entity type coverage ⚠️ `SAM-GAP-4` |
| **VEN-S22** Subscription by type | `GET /v1/me/subscriptions` · `GET /v1/platform-config` (`subscriptionContactUrl`) | subscribe/upgrade = deep link *client* (no in-app mutation, `AD-API-04`) | grace/expired → `state` on each `Subscription` row |

---

## 5. Web — Admin (`ADM-S01` … `ADM-S23`)


All paths under `/v1/admin`. A non-Admin token is `→ NOT_FOUND` (`AD-API-01`). Every
list GET that exposes personal data in bulk, and every mutation, is audited.

| Screen | Load / list | Actions | Empty / error |
|---|---|---|---|
| **ADM-S01** Login with 2FA | *client* | `POST /v1/auth/login/password` (password-only in Checkpoint-1; 2FA deferred) | `→ ACCOUNT_LOCKED` (3 / 30 min) · `→ UNAUTHENTICATED` |
| **ADM-S02** Dashboard | `GET /v1/admin/dashboard?range=` | open queue/metric *client* (pre-filtered) | zero-activity period → zero-valued payload |
| **ADM-S03** Customer list | `GET /v1/admin/customers` (filters, `q`) | open detail *client* → ADM-S04 | no matches → `data: []` |
| **ADM-S04** Customer detail | `GET /v1/admin/customers/{id}` (opening audited) | `POST /v1/admin/customers/{id}/notes` · `…/suspend` · `…/reactivate` · `…/erasure` | already suspended `→ CONFLICT` |
| **ADM-S05** Vendor list | `GET /v1/admin/vendors` | open detail *client* → ADM-S06 | no matches → `data: []` |
| **ADM-S06** Vendor detail | `GET /v1/admin/vendors/{id}` | `GET /v1/admin/vendors/{id}/documents/{docId}/url` (per-access audit) · `…/verify` · `…/reject` · `…/request-info` · `…/activate` `…/suspend` `…/reactivate` `…/deactivate` · `POST /v1/admin/vendors/{id}/subscriptions` · `PATCH …/subscriptions/{requestType}` · `…/notes` | illegal transition `→ ILLEGAL_VENDOR_TRANSITION` · expired KYC on reactivate `→ CONFLICT` |
| **ADM-S07** Verification queue | `GET /v1/admin/verification-queue` | `GET …/documents/{docId}/url` · `POST /v1/admin/vendors/{id}/verify` · `…/reject` · `…/request-info` | empty queue → `data: []` |
| **ADM-S08** Request list | `GET /v1/admin/requests` | open detail *client* → ADM-S09 | no matches → `data: []` |
| **ADM-S09** Request detail | `GET /v1/admin/requests/{id}` (matched Vendors, Offers, transitions) | `POST /v1/admin/requests/{id}/remove` · `POST /v1/admin/requests/{id}/notes` | already `REMOVED` `→ CONFLICT` |
| **ADM-S10** Offer list | `GET /v1/admin/offers` | open detail *client* → ADM-S11 | no matches → `data: []` |
| **ADM-S11** Offer detail | `GET /v1/admin/offers/{id}` (revisions, transitions, `winningOfferId`) | `POST /v1/admin/offers/{id}/notes` | — (read-only commercial terms by design) |
| **ADM-S12** Connection list | `GET /v1/admin/connections` (default `state=ACTIVE`, `noContact` flag) | open detail *client* → ADM-S13 | none → `data: []` |
| **ADM-S13** Connection detail | `GET /v1/admin/connections/{id}` (both reviews, linked abuse reports) | `POST /v1/admin/connections/{id}/close` · `POST /v1/admin/connections/{id}/notes` | already `CLOSED` `→ CONNECTION_CLOSED` |
| **ADM-S14** Category management | `GET /v1/admin/categories` (incl. inactive) | `POST /v1/admin/categories` · `PATCH /v1/admin/categories/{id}` · `POST /v1/admin/categories/{id}/deactivate` | in-use cannot be removed (deactivate only) · resolved `SAM-GAP-9` |
| **ADM-S15** Region management | `GET /v1/admin/regions` | `POST /v1/admin/regions` · `PATCH /v1/admin/regions/{id}` · `POST /v1/admin/regions/{id}/deactivate` | as ADM-S14 · resolved `SAM-GAP-9` |
| **ADM-S16** Review moderation | `GET /v1/admin/reviews?state=` | `POST /v1/admin/reviews/{id}/approve` · `…/reject` · `…/redact` (same three for Vendor responses) | empty queue → `data: []` |
| **ADM-S17** Reports & analytics | `GET /v1/admin/reports/{name}` | `POST /v1/admin/exports` (CSV/XLSX/PNG) → poll `GET /v1/admin/exports/{id}` | empty period → empty `rows`/`series` · `→ EXPORT_IN_PROGRESS` · export failed → `status:"FAILED"` |
| **ADM-S18** Announcement composer | `GET /v1/admin/announcements` | `POST /v1/admin/announcements` · `POST /v1/admin/announcements/{id}/cancel` | zero audience — no pre-send recipient count ⚠️ `SAM-GAP-10` · cancel after dispatch `→ CONFLICT` |
| **ADM-S19** Platform settings | `GET /v1/admin/settings` | `PATCH /v1/admin/settings/{key}` (`confirm:true` for commercial keys) | out-of-range `→ SETTING_OUT_OF_RANGE` |
| **ADM-S20** Gold rate configuration | — _(deferred; see SRS §7.4)_ | — _(deferred; see SRS §7.4)_ | Screen deferred — not in current Admin Portal build scope. |
| **ADM-S21** Abuse report queue | `GET /v1/admin/abuse-reports` | `GET /v1/admin/abuse-reports/{id}` · `POST /v1/admin/abuse-reports/{id}/resolve` | empty queue → `data: []` |
| **ADM-S22** Audit log viewer | `GET /v1/admin/audit-log` (access itself audited) | entry detail *client* (row is self-contained) ⚠️ `SAM-GAP-12` | no matches → `data: []` |
| **ADM-S23** Admin user management | `GET /v1/admin/admins` | `POST /v1/admin/admins` · `…/suspend` · `…/revoke` · `…/password-reset` | duplicate email `→ CONFLICT` · role selector vs coarse RBAC ⚠️ `SAM-GAP-13` |

---

## 6. Findings

Severity: **H** blocks a screen · **M** screen degrades or needs a client workaround ·
**L** cosmetic / already tracked elsewhere.

| ID | Sev | Screens | Gap | Suggested resolution |
|---|---|---|---|---|
| `SAM-GAP-1` | M | CUS-S02, CUS-S11 | Screens render an **unread-Offer marker** (per Request on Home, per Offer in the list). No payload carries per-Offer read state — `RequestForCustomer.offerCount` and `OfferForCustomer` have no `unreadCount` / `viewedAt`. | Add `unreadOfferCount` to `RequestForCustomer` list rows and `viewedByCustomerAt` to `OfferForCustomer`; or a lightweight `POST /v1/offers/{id}/viewed` mirroring `POST /v1/matches/{id}/viewed`. |
| `SAM-GAP-2` | L | CUS-S03 | Screen blocks *entry* to the create flow when the live-Request cap is hit, but the only signal is `→ CONCURRENT_REQUEST_LIMIT` at publish. Client must count `GET /v1/me/requests` itself. | Add `liveRequestCount` / `canCreateRequest` to `GET /v1/me` or `GET /v1/platform-config` response `meta`. Low cost, avoids a dead-end flow. |
| `SAM-GAP-3` | M | CUS-S10 | Screen offers a "Close Connection path" when the Request is `ACCEPTED`, i.e. it must deep-link to the Connection. `RequestForCustomer` exposes `acceptedOfferId?` but **not** `connectionId?` (the Vendor presenter does expose it). | Add `connectionId?` to `RequestForCustomer` when `state = ACCEPTED`. |
| `SAM-GAP-4` | M | CUS-S13, CUS-S22, VEN-S08, VEN-S21 | `AbuseEntityType = REQUEST \| OFFER \| CONNECTION \| REVIEW`. The report screens let a user report a **Vendor** (CUS-S22) or a **Customer** (VEN-S21) directly, with no Request/Offer/Connection in hand. | Extend `AbuseEntityType` with `VENDOR` and `CUSTOMER`, or require the client to always resolve to an Offer/Request/Connection id and document that constraint on the screens. |
| `SAM-GAP-5` | L | CUS-S21, VEN-S18 | Settings screens link to Terms of Service, Privacy Policy, and Support contact. No endpoint or config key returns these URLs; `GET /v1/platform-config` does not list them. | Add `legal: { termsUrl, privacyUrl }` and `supportContactUrl` to `GET /v1/platform-config`. (`subscriptionContactUrl` already lives there.) |
| `SAM-GAP-6` | M | VEN-S03 | The shell shows the Admin's free-text **"request more information" message**. `POST /v1/admin/vendors/{id}/request-info` stores a `message`, but no Vendor-facing read model surfaces it — `VendorMe` has only `awaitingApprovalReason` (an enum) and `GET /v1/me/vendor` returns `verificationState`, not the message. | Add `verificationMessage?: string` (latest Admin message) to `VendorMe` / `GET /v1/me/vendor`. |
| `SAM-GAP-7` | H | VEN-S03, VEN-S16 | `FR-VEN-025` AC1 and the VEN-S03 flow require a **VERIFIED-but-not-yet-ACTIVE** Vendor to set Categories and Regions in order to *become* `ACTIVE`. The Route Index marks `PUT /v1/me/vendor/categories` and `/regions` as auth **`V` (ACTIVE only)**, and Route Inventory §20 simultaneously says "required before first activation" — a contradiction. | Change the auth for `PUT /v1/me/vendor/categories`, `PUT /v1/me/vendor/regions` and `PATCH /v1/me/vendor/availability` to allow the `VERIFIED` pre-`ACTIVE` state (a `Vshell`-plus variant), and align §20 wording. |
| `SAM-GAP-8` | M | VEN-S20 | Screen renders a **6-month rating trend chart**. `GET /v1/me/reviews` returns reviews; `GET /v1/me/vendor/performance` returns outcome counts. Neither returns a rating time series. | Add a `ratingTrend: { period, average, count }[]` block to `GET /v1/me/vendor/performance` (or a `?include=ratingTrend`). |
| `SAM-GAP-9` | L | ADM-S14, ADM-S15 | **RESOLVED (Checkpoint-1)**: Screen files listed a "Delete" action ("blocked if in use"); Route Inventory §21.6 states "There is no DELETE" (deactivate only). Screen files reworded to "Deactivate (in-use cannot be removed)", and Delete removed from UI. | Resolved in `ADM-S14-category-management.md` and `ADM-S15-region-management.md`. |
| `SAM-GAP-10` | L | ADM-S18 | Screen has a "zero audience" edge state, implying an audience-size preview before send. No endpoint estimates recipient count for a given `audience` filter. | Add `POST /v1/admin/announcements/preview` → `{ estimatedRecipients }`, or accept that the count only appears in post-send `deliveryStats`. |
| `SAM-GAP-11` | L | ADM-S20 | **Withdrawn** — ADM-S20 deferred from the current build; revisit when the gold-rate screen is scheduled. | **Withdrawn** — ADM-S20 deferred from the current build; revisit when the gold-rate screen is scheduled. |
| `SAM-GAP-12` | L | ADM-S22 | Screen's "Exit → Entry detail" implies a single-entry view. Only `GET /v1/admin/audit-log` (collection) exists. | Confirm the list row carries `before`/`after`/`ip`/`userAgent` in full (it does per §21.13) so detail is client-side; otherwise add `GET /v1/admin/audit-log/{id}`. |
| `SAM-GAP-13` | L | ADM-S23 | Screen has a **Role** selector (Super Admin / Operations / Analyst). `AD-API-03` defers `FR-ADM-002` roles; `POST /v1/admin/admins` has "No `role` field". Known tension (Route Inventory §23) — flagged here for screen alignment. | Remove the Role control from ADM-S23 for v1, or render it read-only as "Admin (coarse)". Revisit with `FR-ADM-002`. |

### Route-index hygiene (found while mapping — fixed in Route Inventory)

- `POST /v1/me/deletion-requests/{id}/confirm` was described in Route Inventory §9 but
  absent from the §6 Route Index table. **Added.**
- `GET /v1/offers/{id}` is used by VEN-S10 (revise) for the current-terms snapshot;
  §22.2 traced `VEN-014` only to `/revise` + `/withdraw`. **`GET /v1/offers/{id}` added to
  the `VEN-014` row.**

---

## 7. Coverage statement

- **67 / 67 screens** have a defined load path and a defined endpoint (or explicit
  *client* behaviour) for every `Action` field.
- **13 gaps** (`SAM-GAP-1` … `13`): **1 High** (`SAM-GAP-7`, a live contradiction),
  4 Medium, 8 Low. None require a new resource — all are additive fields, an auth-scope
  correction, one enum extension, or screen-file wording fixes.
- **2 route-index hygiene items** — fixed in `API-Route-Inventory.md` (see above).
- Every *Empty / error / edge state* row in the 67 screen files maps to either an empty
  collection (`data: []`, never `404`, per §3.2) or a named `error.code` in Route
  Inventory §5.

Re-run this diff whenever a screen file or the Route Inventory changes, and once more
against the generated OpenAPI at first implementation (`NFR-030`).

---

## Appendix A — Revision history

| Version | Date | Change |
|---|---|---|
| 0.1 | 1 Sep 2026 | Initial map of all 67 screens against API Route Inventory v0.1. 13 gaps recorded. |
