# Vendor onboarding audit — 2026-09-20

Scope: mobile (`kh_mobile`) + backend (`vendor-onboarding` / `identity`) + SRS/BR alignment (`Requirements-Spec-v1.4`, Screen-API-Map, `adr/0010`). Read-only.

## Happy path (as implemented)

| Step | Screen | API | Outcome |
|---|---|---|---|
| 1 | Guest → Vendor Login (`VEN-S04`) | `POST /v1/auth/google/session` | Bound → shell by lifecycle; unbound → register |
| 2 | Vendor Register (`VEN-S01`) | `POST /v1/auth/register/vendor` | Session; profile `PENDING_VERIFICATION` |
| 3 | Awaiting (`VEN-S03`) | `GET /v1/me/vendor` (poll 15s) | CTAs by `awaitingApprovalReason` |
| 4 | KYC upload (`VEN-S02`) | Media intent → PUT → complete → `POST …/documents`; `PATCH …/me/vendor` | Docs attached; stay in shell |
| 5 | Admin verify (`ADM-S07`) | `POST …/admin/vendors/{id}/verify` | → `VERIFIED` (+ `activatedAt` if taxonomy already set) |
| 6 | Categories/Regions (`VEN-S16`) | `PUT …/categories`, `PUT …/regions` (`VERIFIED` stage) | Sets `activatedAt` → lifecycle `ACTIVE` |
| 7 | Subscriptions (`VEN-S22`) | Admin grant; vendor read-only | Required for match/offer (`BR-002`) — **after** ACTIVE |

Guards: `AppGuards` (usability mirror) + `VendorAccessGuard` (server). Non-ACTIVE vendors stay in awaiting shell.

---

## Verdict

Routing and server shell gating for the core path are **mostly sound**. Several **high-severity functional holes** break Google re-login, licence/expiry integrity, and subscription entitlement time. Docs gaps **SAM-GAP-6/7 look resolved in code** but Screen-API-Map still lists them open.

---

## Issues (priority order)

### P0 — Bugs

| ID | Finding | Evidence | Fix |
|---|---|---|---|
| **VO-01** | ~~**Vendor register never binds Google.**~~ **Fixed 2026-09-20.** Register body now includes `firebaseToken` from `UnboundGoogle`; vendor login calls `markUnboundGoogle`. | Was: `toRegisterBody` omitted token. Now: `RegisterFormState.firebaseIdToken` → `firebaseToken`; login hand-off + register screen seed. | Tests: `register_form_state_test`, `vendor_register_controller_test`, `vendor_login_controller_test`. |
| **VO-02** | ~~**Shared placeholder trade licence `PENDING_UPLOAD`.**~~ **Fixed 2026-09-20.** Empty licence at register now sends unique `PENDING_<hex>` (under 50 chars). | Was: shared `PENDING_UPLOAD`. Now: `provisionalTradeLicenceNumber()`. | Real licence still collected on KYC. |
| **VO-03** | ~~**KYC licence expiry collected but not persisted.**~~ **Fixed 2026-09-20.** `submitKyc` patches `licenceExpiryDate`; TRADE_LICENCE attach forwards expiry when already filled; backend PATCH accepts the field and treats it as BR-004 reverify. | Was: UI-only expiry. Now: profile + optional document expiry. | Register still uses provisional `2028-01-01` until KYC. |

### P1 — Risks / rule gaps

| ID | Finding | Status |
|---|---|---|
| **VO-04** | Subscription `periodEnd` / grace not enforced in eligibility | **Fixed 2026-09-20** — `computeSubscriptionState` in offer/matching; hourly `subscription-expiry-sweep` |
| **VO-05** | Typed mobile marked verified on vendor register | **Fixed 2026-09-20** — `mobileVerifiedAt` only on OTP or Firebase phone |
| **VO-06** | BR-004 re-verify bypasses state machine | **Fixed 2026-09-20** — `VERIFIED→PENDING_VERIFICATION` + `canTransition` in `patchProfile` |
| **VO-07** | Incomplete ACTIVE shell on offer/subscription routes | **Fixed 2026-09-20** — `VendorAccessGuard` ACTIVE + `activatedAt` in offer eligibility |
| **VO-08** | Weak client mobile validation | **Fixed 2026-09-20** — E.164 via `looksLikeE164` |
| **VO-09** | Synthetic email / placeholder address | **Fixed 2026-09-20** — real email/address required |

### P2 — Gaps / UX / hygiene

| ID | Finding | Status |
|---|---|---|
| **VO-10** | WhatsApp never sent | **Fixed** — `contactWhatsApp` on register + profile (+ migration) |
| **VO-11** | Logo picker cosmetic | **Fixed** — post-register `VENDOR_LOGO` upload → `logoMediaKey` |
| **VO-12** | Terms / Privacy `onTap` empty | **Fixed** — `platformConfig` URLs via `openExternalUrl` |
| **VO-13** | KYC no hydrate | **Fixed** — `hydrateFromExisting()` |
| **VO-14** | Resubmit fire-and-forget | **Fixed** — SnackBar on failure |
| **VO-15** | Wrong Request types on subscriptions UI | **Fixed** — four SRS types only |
| **VO-16** | Stale `login_screen_test` | **Fixed** |
| **VO-17** | No vendor register controller tests | **Partial** — controller unit tests added; no full e2e |
| **VO-18** | OpenAPI ↔ Zod drift | **Fixed** — schemas aligned (hand-edited OpenAPI; regen needs `npm install`) |
| **VO-19** | `REGISTERED` unused | **Documented** — reserved; create stays `PENDING_VERIFICATION` |
| **VO-20** | `regionId` not copied to `servedRegionIds` | **Fixed** — register fills `[regionId]` when served empty |

### Docs status (verified against code)

| Doc item | Code status |
|---|---|
| **SAM-GAP-6** (Admin more-info message) | **Likely resolved** — `verificationMessage` on `VendorMe` presenter + awaiting UI |
| **SAM-GAP-7** (Categories/Regions auth for VERIFIED) | **Likely resolved** — `@VendorStageRequired('VERIFIED')` on taxonomy controller |
| **adr/0010** vs SRS VEN-S04 OTP/password | ADR wins in product; SRS/Screen-API-Map still describe OTP/password login |
| OTP deferred | Intentional temporary bypass (Claude.md); do not harden as permanent |

---

## Must-pass checklist (audit)

| # | Rule | Status |
|---|---|---|
| 1 | Google-first create binds OAuth (`adr/0010`) | **Pass** — VO-01 fixed |
| 2 | New vendor → non-marketplace shell until ACTIVE | **Pass** (guards + most shell APIs) |
| 3 | Mandatory KYC: trade licence + Emirates ID | **Pass** (attach + UI ready gate) |
| 4 | Manual Admin verify only (`BR-003`) | **Pass** |
| 5 | VERIFIED + Categories/Regions → ACTIVE (`FR-VEN-025`) | **Pass** (server taxonomy) |
| 6 | Match/Offer needs VERIFIED + ACTIVE + type sub (`BR-002`) | **Pass** — VO-04, VO-07 fixed |
| 7 | Shell enforced server-side (`NFR-013`) | **Pass** — VO-07 fixed |
| 8 | Legal identity edit → re-verify (`BR-004`) | **Pass** — VO-06 fixed |
| 9 | Admin request-info message visible (`VEN-S03`) | **Pass** in code; update SAM-GAP-6 |
| 10 | Licence uniqueness / expiry integrity | **Pass** — VO-02, VO-03 fixed |

---

## Key files

**Mobile:** `lib/app/guards.dart`, `features/auth/{vendor_login_*,vendor_register_*,register_form_state.dart}`, `features/onboarding/{awaiting_*,kyc_*,vendor_me_*,onboarding_repository.dart}`, `features/profile_settings/categories_regions_*`

**Backend:** `modules/identity/application/registration.service.ts`, `modules/vendor-onboarding/**`, `edge/auth/auth.guard.ts`, `prisma/schema.prisma`

**Docs:** `docs/Screen-API-Map.md` §4 + SAM-GAP-6/7, `docs/Requirements-Spec-v1.4.md` FR-VEN-001…025 / BR-002…004, `docs/adr/0010`

---

## Suggested fix order

1. **VO-01** Google bind on vendor register (+ test)  
2. **VO-03** Persist KYC licence expiry  
3. **VO-02** Remove shared `PENDING_UPLOAD` licence  
4. **VO-04** / **VO-07** Subscription time + ACTIVE guards  
5. **VO-05** / **VO-06** Verified-mobile honesty + BR-004 machine  
6. Close doc drift (SAM-GAP-6/7, OpenAPI, VEN-S04 vs ADR-0010)  
7. Test debt: register controller, hydrate KYC, retire stale login test  
