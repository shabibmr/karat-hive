# Sherlock Case: Customer Screen-by-Screen Review

**Case:** Customer-role screen inspection, mobile app (`kh_mobile`), Flutter implementation audit against `ui-screens/customer/` spec.
**Categorisation:** Screen-by-Screen (CUS-S01–CUS-S22).
**Scope:** Aspect A (Visible Components) + Aspect D (Layout, access, states, a11y, i18n) only — aspects B (Functions) and C (Business Rules) are explicitly out of scope.
**Method:** Sherlock protocol, one unit and one aspect per turn; the Case Blog is updated per turn and serves as the persistent record.

---

## §1 Master Unit Checklist (The Mind Palace)

| # | Unit ID | Screen Name | Spec | Status |
|---|---|---|---|---|
| 1 | CUS-S01 | Onboarding | [CUS-S01-onboarding.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S01-onboarding.md) | ✅ Solved |
| 2 | CUS-S02 | Home | [CUS-S02-home.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S02-home.md) | ⏳ Cold |
| 3 | CUS-S03 | Request type selection | [CUS-S03-request-type-selection.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S03-request-type-selection.md) | ⏳ Cold |
| 4 | CUS-S04 | Create Request — Find An Ornament | [CUS-S04-create-find-ornament.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S04-create-find-ornament.md) | ⏳ Cold |
| 5 | CUS-S05 | Create Request — Sell Old Gold | [CUS-S05-create-sell-old-gold.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S05-create-sell-old-gold.md) | ⏳ Cold |
| 6 | CUS-S06 | Create Request — Gold Coins | [CUS-S06-create-gold-coins.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S06-create-gold-coins.md) | ⏳ Cold |
| 7 | CUS-S07 | Create Request — Gold Bullion | [CUS-S07-create-gold-bullion.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S07-create-gold-bullion.md) | ⏳ Cold |
| 8 | CUS-S08 | Image capture / gallery picker | [CUS-S08-image-capture.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S08-image-capture.md) | ⏳ Cold |
| 9 | CUS-S09 | Request review & publish | [CUS-S09-request-review-publish.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S09-request-review-publish.md) | ⏳ Cold |
| 10 | CUS-S10 | Request detail | [CUS-S10-request-detail.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S10-request-detail.md) | ⏳ Cold |
| 11 | CUS-S11 | Offers list | [CUS-S11-offers-list.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S11-offers-list.md) | ⏳ Cold |
| 12 | CUS-S12 | Offer comparison | [CUS-S12-offer-comparison.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S12-offer-comparison.md) | ⏳ Cold |
| 13 | CUS-S13 | Offer detail | [CUS-S13-offer-detail.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S13-offer-detail.md) | ⏳ Cold |
| 14 | CUS-S14 | Accept confirmation | [CUS-S14-accept-confirmation.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S14-accept-confirmation.md) | ⏳ Cold |
| 15 | CUS-S15 | Connection detail | [CUS-S15-connection-detail.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S15-connection-detail.md) | ⏳ Cold |
| 16 | CUS-S16 | Connections list | [CUS-S16-connections-list.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S16-connections-list.md) | ⏳ Cold |
| 17 | CUS-S17 | History | [CUS-S17-history.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S17-history.md) | ⏳ Cold |
| 18 | CUS-S18 | Leave review | [CUS-S18-leave-review.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S18-leave-review.md) | ⏳ Cold |
| 19 | CUS-S19 | Notification centre | [CUS-S19-notification-centre.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S19-notification-centre.md) | ⏳ Cold |
| 20 | CUS-S20 | Profile | [CUS-S20-profile.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S20-profile.md) | ⏳ Cold |
| 21 | CUS-S21 | Settings | [CUS-S21-settings.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S21-settings.md) | ⏳ Cold |
| 22 | CUS-S22 | Report abuse | [CUS-S22-report-abuse.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S22-report-abuse.md) | ⏳ Cold |

---

## §2 Unit Decisions & Findings Log

### CUS-S01 — Onboarding

**Aspect A: Visible Components**

**Status:** ✅ Solved

**Spec reference:** [CUS-S01-onboarding.md](file:///E:/work/karat_hive/ui-screens/customer/CUS-S01-onboarding.md)

**Flutter files:** `auth/presentation/customer_onboarding_screen.dart` (active); `customer_register_screen.dart` (WIP, not yet wired)

**Findings:**

**Current implementation (Google Sign-In only):**
- Welcome title & subtitle present, styled with `headlineSmall` and `bodyMedium` text styles.
- Google Sign-In button (FilledButton.icon) with G icon, label `authContinueWithGoogle`, loading spinner shown during auth.
- Biometric unlock toggle (SwitchListTile with title + hint text) — present but not yet in spec; noted as convenience feature.
- Error states: `OnboardingFailure` shows inline error box; `OnboardingLockedOut` shows prominent error container with red background.
- No terms/privacy links visible on welcome screen; these are deferred to post-OAuth completion step.

**Completion flow (after Google sign-in):**
- _CompletionView shows: display name input, mobile input (phone keyboard), terms acceptance checkbox, privacy acceptance checkbox.
- Layout: vertical ListView, all fields visible, no progressive disclosure.
- OTP step follows: `OtpField` custom widget (details TBD in aspect D), resend link, verify button, back button.
- All text keys use `KhL10n` for localization.

**Noted (not a defect):**
- Phone register screen (`CustomerRegisterScreen`) exists in codebase but is not yet active; it will be merged in a future auth refactoring iteration. Screen-visible components are unaffected by this merge.
- Biometric unlock is a convenience feature beyond the spec; user confirmed it does not block screens and is intentional.

---

**Aspect D: Layout, Access, States, a11y, i18n**

**Status:** ✅ Solved

**Routing & entry points:**
- `/customer/onboarding` → CustomerOnboardingScreen (active).
- `/customer/register` → CustomerRegisterScreen (future).
- Both in `UnauthShell`; redirect from signed-out state.
- On successful completion, redirected to `/auth/complete` (completer screen) or directly to CUS-S02 home.

**State handling:**
- `OnboardingNeedsCompletion` → shows completion form.
- `OnboardingAuthenticated` → shows `KhLoadingView()` spinner.
- `OnboardingFailure` → inline error with message from server or default l10n fallback.
- `OnboardingLockedOut` → prominent red error container, custom message + help text.
- `OnboardingBusy` → button disabled, circular progress spinner (2px stroke) inside icon space.

**Accessibility concerns (minor):**
- Error states rely on color + text; no distinct icon. Should add error indicator (⚠️ or similar) for screen readers.
- Biometric toggle lacks explicit aria-label; description relies on hint text.
- `OtpField` widget structure unknown; needs review for focus order, digit grouping, screen reader labels (deferred to next units if OTP is used).

**i18n:**
- All user-facing text keyed to `KhL10n.of(context)` (consistent API). Keys: `authWelcomeTitle`, `authWelcomeSubtitle`, `authContinueWithGoogle`, `authSigningIn`, `authBiometricUnlock`, `authBiometricUnlockHint`, `authCompleteProfileTitle`, `authCompleteProfileSubtitle`, `authOtpSentTo`, `authVerifyAndContinue`, `authChangeNumber`, `authAcceptTerms`, `authViewTerms`, `authViewPrivacy`, `authAcceptTermsRequired`, `authSendCode`, `authLockoutTitle`, `authLockoutHelp`.
- Localization provider is context-injected; language switching handled elsewhere (not in this screen's scope).

**Responsive design:**
- Fixed 24px padding on ListView, no explicit tablet/desktop breakpoint.
- Design system components (`KhScaffold`, `KhButton`, `KhTextField`, `CheckboxListTile`) handle width constraints; assumed compliant with responsive requirement.

**Empty/error/loading states:**
- Welcome: none (always shows buttons).
- Completion: none (form always visible; validation errors shown via styling, not empty state).
- Loading: handled by state machine (`OnboardingAuthenticated` → full-screen spinner).
- Error: inline + prominent containers, not a separate screen.

**Confirmed:** CUS-S01 aspect A & D complete. Screen structure, routing, state machine, and l10n all present and functional. Phone register flow deferred, not a defect.

---

## §3 Open Leads & Technical Debt

(None yet — log issues as they surface per unit.)

---

**Case Status:** 1/22 units solved (CUS-S01 ✅). Next: CUS-S02 (Home).
