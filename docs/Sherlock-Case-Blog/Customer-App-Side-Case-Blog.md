# Sherlock Case Blog — Customer App Side

| | |
|---|---|
| **Case** | Customer App Side — Karat Hive dual-mode mobile, Customer half + Customer-facing backend |
| **Opened** | 11 September 2026 |
| **Work-tree** | `customer-app-theerkal` |
| **Categorisation** | **Screen-by-Screen** — signed off 11 Sep 2026 |
| **Scope** | `CUS-S01`…`CUS-S22` (palace as filed). **Lead:** `CUS-S23` Guest Landing now exists in inventory/`adr/0011` — palace amendment pending user sign-off. |
| **Out of scope** | Vendor screens (`VEN-*`), Admin Portal (`ADM-*`), Vendor feed/offers/onboarding UI |

---

## 1. The Case & Its Categorisation

**Status:** ✅ Solved.

**Mode:** Screen-by-Screen.

**Why:** Authoritative inventory is 22 `CUS-Snn` screens in [`ui-screens/customer/`](../../ui-screens/customer/), [`ui-mock/screens/customer/`](../../ui-mock/screens/customer/), and [`docs/Screen-API-Map.md`](../Screen-API-Map.md) §3. Feature/entity/workflow modes would hide a missing screen.

**Folded into CUS-S01 (not separate palace units):**

| Route | Widget | Why folded |
|---|---|---|
| `/customer/onboarding` | `CustomerOnboardingScreen` | Spec CUS-S01 |
| `/auth/complete` | `AuthCompleterScreen` | Unbound Google chooser; `adr/0010` split of CUS-S01 |
| `/customer/register` | `CustomerRegisterScreen` | Registration step of CUS-S01 |
| `/customer/blocked` | `AccountBlockedScreen` | Spec CUS-S01 “Exit blocked” |

**Host chrome, not a unit:** `CustomerShell` bottom nav. Observed first on CUS-S02 (first tab). Repeating it on S10/S16/S19/S20 would be the same evidence twice.

**Deduction:** 22 units filed at discovery. **Open lead:** `CUS-S23` Guest Landing landed after discovery (`adr/0011`, [`CUS-S23-guest-landing.md`](../../ui-screens/customer/CUS-S23-guest-landing.md)). Palace may need a 23rd unit. **Working hypothesis — needs the data** (user sign-off).

---

## 2. Master Unit Checklist (the Mind Palace)

Inspection order = inventory order. Jump allowed via wizard option 6.

| # | ID | Name | Tree (discovery only) | Status |
|---|---|---|---|---|
| 1 | CUS-S01 | Onboarding | Real screens wired | 🟡 Investigating |
| 2 | CUS-S02 | Home | Real file exists; **route mounts stub** | ⏳ Cold |
| 3 | CUS-S03 | Request type selection | Real, wired | ⏳ Cold |
| 4 | CUS-S04 | Create — Find An Ornament | Real, wired | ⏳ Cold |
| 5 | CUS-S05 | Create — Sell Old Gold | Stub wired | ⏳ Cold |
| 6 | CUS-S06 | Create — Gold Coins | Stub wired | ⏳ Cold |
| 7 | CUS-S07 | Create — Gold Bullion | Stub wired | ⏳ Cold |
| 8 | CUS-S08 | Image capture | Stub wired | ⏳ Cold |
| 9 | CUS-S09 | Review & publish | Stub wired | ⏳ Cold |
| 10 | CUS-S10 | Request detail (owner) | Real file exists; **route mounts stub** | ⏳ Cold |
| 11 | CUS-S11 | Offers list | Real file exists; **route mounts stub** | ⏳ Cold |
| 12 | CUS-S12 | Offer comparison | Real file exists; **route mounts stub** | ⏳ Cold |
| 13 | CUS-S13 | Offer detail | Stub wired | ⏳ Cold |
| 14 | CUS-S14 | Accept confirmation | Stub wired | ⏳ Cold |
| 15 | CUS-S15 | Connection detail | Real, wired | ⏳ Cold |
| 16 | CUS-S16 | Connections list | Real, wired | ⏳ Cold |
| 17 | CUS-S17 | History | Real file exists; **route mounts stub** | ⏳ Cold |
| 18 | CUS-S18 | Leave review | Stub wired | ⏳ Cold |
| 19 | CUS-S19 | Notification centre | Stub wired | ⏳ Cold |
| 20 | CUS-S20 | Profile | Stub wired | ⏳ Cold |
| 21 | CUS-S21 | Settings | Stub wired | ⏳ Cold |
| 22 | CUS-S22 | Report abuse | Real, wired | ⏳ Cold |

**Count:** 22 filed. **Solved 0 · Investigating 1 · Cold 21.** (+ possible CUS-S23 lead)

---

## 3. Unit Findings & Discrepancies Log

### CUS-S01 · Onboarding / Login / Customer signup

| Aspect | Status |
|---|---|
| A. Visible Components | 🟡 Investigating |
| B. Functions | ⏳ Cold |
| C. Business Rules | ⏳ Cold |
| D. Anything else | ⏳ Cold |

**Sources observed (Aspect A):**

| Surface | Path |
|---|---|
| Inventory | [`ui-screens/customer/CUS-S01-onboarding.md`](../../ui-screens/customer/CUS-S01-onboarding.md) |
| Flutter welcome + inline completion | [`customer_onboarding_screen.dart`](../../apps/kh_mobile/karat_hive/lib/features/auth/presentation/customer_onboarding_screen.dart) |
| Flutter role chooser | [`auth_completer_screen.dart`](../../apps/kh_mobile/karat_hive/lib/features/auth/presentation/auth_completer_screen.dart) |
| Flutter register | [`customer_register_screen.dart`](../../apps/kh_mobile/karat_hive/lib/features/auth/presentation/customer_register_screen.dart) |
| Flutter blocked | [`account_blocked_screen.dart`](../../apps/kh_mobile/karat_hive/lib/features/auth/presentation/account_blocked_screen.dart) |
| Mock | [`ui-mock/screens/customer/CUS-S01-onboarding.html`](../../ui-mock/screens/customer/CUS-S01-onboarding.html) |

#### A. Visible Components — observed

Four Flutter surfaces folded under this unit. Scaffold title varies (`appTitle` / `auth.registerCustomer` / `auth.chooseRole`).

**1. Welcome (`CustomerOnboardingScreen` → `_WelcomeView`)**

| Element | Copy / kind (EN) |
|---|---|
| Headline | `Welcome to Karat Hive` |
| Subtitle | `Request gold your way — buy ornaments, sell old gold, or order coins and bullion. Sign in to get started.` |
| Primary CTA | Filled button + `g_mobiledata` icon — `Continue with Google` (busy → spinner + `Signing in…`) |
| Biometric | `SwitchListTile` — `Unlock with biometrics` / Face ID·fingerprint hint |
| Lockout panel | Error-container card — `You can't sign in` + server message + support help |
| Inline error | `KhInlineError` on failure |
| Authenticated flash | `KhLoadingView` only |

**2. Inline completion (`_CompletionView` on same route)**

| Element | Notes |
|---|---|
| Headline / subtitle | Finish setup; name + mobile for WhatsApp |
| Display name | `Your name` |
| Mobile | phone keyboard |
| Terms | **One** checkbox: “I accept the Terms of Service and the Privacy Policy” |
| View Terms / View Privacy | Plain `Text` links under checkbox (not separate Privacy checkbox) |
| Required hint | Error-coloured text when terms unchecked |
| Send code CTA | `KhButton` |
| OTP step | `OtpField` + `Verify and continue` + `Change number` TextButton |
| Prove copy | `We sent a 6-digit code to {mobile}` |
| **Email field** | **Absent** on this surface |

**3. Auth completer (`/auth/complete`)**

| Element | Notes |
|---|---|
| Title / body | `auth.chooseRole` |
| Primary | Continue as Customer |
| Secondary | Continue as Vendor |
| Logout | TextButton |

**4. Customer register (`/customer/register`)**

| Element | Notes |
|---|---|
| Display name, optional email, mobile | Three `KhTextField`s |
| Terms + Privacy | **Two** `CheckboxListTile`s (unlike inline completion) |
| Create account CTA | Then OTP step: prove-mobile text + `OtpField` + Verify |

**5. Account blocked (`/customer/blocked`)**

| Element | Notes |
|---|---|
| Inline error | Suspended vs deactivated copy (distinct strings) |
| Logout | Secondary `KhButton` |

**Publish-gate strings exist in l10n** (`authPublishGateTitle` / Body / Action) — no dedicated widget found under auth presentation in this pass. Deferred to Functions if a gate surface appears on CUS-S09.

**Mock (before fix):** Still showed mobile+OTP as login, Apple/configured OAuth, and a “Login with mobile + OTP” action — contradicted inventory + `adr/0010`.

**Fix applied:** Rewrote [`CUS-S01-onboarding.html`](../../ui-mock/screens/customer/CUS-S01-onboarding.html) to Google-only login, OTP-as-proof, dual terms/privacy checkboxes, biometric, blocked exit display. Removed fake OTP-login CTA and Apple OAuth. **Confident.**

#### Discrepancies (surface only — behaviour later)

| ID | Finding | Confidence |
|---|---|---|
| S01-A1 | Welcome subtitle still says “Sign in to get started” while cold start is Guest Landing (`adr/0011` / CUS-S23). Copy fights guest-first. | Near certain. |
| S01-A2 | Inventory lists **two** accept checkboxes (Terms + Privacy). Inline `_CompletionView` merges into **one**. Register route keeps two. Inconsistent surfaces. | Confident. |
| S01-A3 | Inventory lists optional **Email** at register. Inline completion has no email field; `CustomerRegisterScreen` does. | Confident. |
| S01-A4 | Inventory lists **OAuth binding status** display. Not present on Welcome / Completer / Register / Blocked. | Near certain. |
| S01-A5 | `AuthCompleter` shows Customer vs Vendor chooser. Inventory + `adr/0011` say Guest/Publish path has no role chooser; Jeweller entry is Guest Landing footer. Completer may still be valid for unbound Google from other doors — surface exists either way. | Working hypothesis — needs Functions. |
| S01-A6 | Biometric: inventory “Input / Face ID”; Flutter is a **Switch**, mock is a **checkbox**. Cosmetic. | Confident. |

*(No Aspect B–D yet.)*

---

## 4. Open Leads & Technical Debt

- **Palace amendment:** Add `CUS-S23` Guest Landing as unit #23? Spec + ADR exist; Flutter / mock may not. Awaits wizard sign-off.
- Routes still mount stubs for S02, S10, S11, S12, S17, S05–S09, S13, S14, S18–S21.
- Backend `CBG-09`: `ConnectionController` missing `@RevealsIdentity()`.
- Backend `CBG-08`: nested `offers` on owner Request detail forced to `[]`.
- Spec CUS-S01 inventory updated for Google-only; SRS Appendix C / older rows may still lag (`adr/0010` follow-up).

---

## Revision

| Date | Turn | Note |
|---|---|---|
| 11 Sep 2026 | Categorisation | Case opened. Screen-by-Screen proposed. |
| 11 Sep 2026 | Unit Discovery | Categorisation signed off. 22 units filed. Extra auth routes folded into CUS-S01. |
| 11 Sep 2026 | CUS-S01 · A | Resume. Observed four Flutter surfaces + mock. Mock aligned to Google-only. Six surface discrepancies logged. CUS-S23 palace lead opened. |
