# Guest-first launch — design

| | |
|---|---|
| **Source** | Frozen consensus in [`app-launch-flow-review.md`](app-launch-flow-review.md) (mirrored at `docs/reports/app-launch-flow-review.md`) |
| **Does not override** | SRS v1.3 · `adr/0010` · Architecture-Frontend · domain invariants |
| **App** | `apps/kh_mobile/karat_hive` only. No backend change unless a lookup/create API refuses unauthenticated compose (call out; do not silently invent routes). |
| **Prefix** | `GL-*` — Guest Launch. Stable, never reused. |
| **Register** | [`guest-launch-tasks.md`](guest-launch-tasks.md) — orchestrator ticks status there |
| **Date** | 11 September 2026 |

This is the engineer-facing design. The consensus document stays frozen. Product rules below are copied from that consensus; do not reopen them in implementation PRs.

---

## Goal

Cold start is **Guest as Customer**. Login is optional until Publish (or a private action). Returning users with a live token skip Guest.

```
Splash
  → Customer + live token     → Customer Dashboard (CUS-S02)
  → Vendor + live token
       active                 → Vendor Dashboard
       else                   → awaiting / KYC (unchanged)
  → else                      → Guest Landing
```

---

## Frozen product rules (do not reopen)

- Guest browses 4 services + “How this works” and **fills the create flow**.
- **Login at Publish**, then **auto-publish** for Customer.
- Guest draft is **in-memory only** (lost on process kill).
- Corner Log in as Customer → **Customer Dashboard**.
- Register as Jeweller mid-create → **drop draft** (no confirm).
- Cancel/back from Login → stay put; **keep** form.
- Blocked → blocked screen, not Guest.
- Vendor from Publish gate → drop draft → Vendor home / awaiting.
- New Google from Guest/Publish → **Customer signup** (no role chooser on this path).
- No local draft persistence. No big Jeweller CTA. No role chooser in the publish path.

---

## How it works today (gap)

| Area | Today |
|------|--------|
| Signed-out default | `AppGuards.redirect(SignedOut)` → `/customer/onboarding` (`customerOnboarding`) |
| Guest | None |
| Create routes | Mounted under **Customer shell** (`router.dart` branch 0: `...requestCreateRoutes`). Paths: `/customer/requests/create` plus `ornament` / `sell-gold` / `coins` / `bullion` / `images` / `review` |
| Lookups | `RequestCreateController.loadLookups()` also calls `me()` — fails without a session |
| Dual new-user path | Onboarding inline completion **and** `/auth/complete` role chooser (`AuthCompleterScreen`) **and** `/customer/register` |
| Login-at-publish | `PublishGate` / `oauth_publish_gate_banner.dart` is OAuth-bound for **already signed-in** Customers, not Guest |
| Guard after login | Signed-in Customer on unauth routes → `customerHome` — would **steal** a pending publish |
| Create controller | `requestCreateControllerProvider` is a keep-alive `NotifierProvider` (not `autoDispose`) |
| Vendor login | Separate `/vendor/login` (OTP / password / Google). `AppGuards.login` is this path |
| Unknown / Admin | `SignedIn` with neither Customer nor Vendor → `customerOnboarding` (F23) |

---

## Key design

### 1. Session: SignedOut *is* Guest

Do **not** add a new `Guest` session type unless tests become unreadable. Treat `SignedOut` as Guest. Change the default redirect from `customerOnboarding` to a new `guestLanding` route (`/guest`).

Keep splash-first restore so Guest does not flash when a token is valid.

`UnboundGoogle` (Google known, no KH account): from Guest/Publish, send to **Customer signup/completion**, not `/auth/complete`. Keep `/auth/complete` unused on this path (or retire later; not in GL scope to delete unless tests demand it). `UnboundGoogle` is empty today — it does **not** carry the Firebase ID token. GL-42/GL-43 must keep that token across the redirect to `customerRegister` (see recorded choice).

`AuthBlocked` stays blocked.

Unknown / Admin role: Guest Landing (simplicity; F23).

### 2. Guest Landing (new screen)

New unauth route: `/guest` (`AppGuards.guestLanding`).

- Four cards: Find jewellery | Sell my gold | Coins | Bullion.
- Each card: short “How this works” (same shape: post → offers → accept → WhatsApp; type-specific extras).
- AppBar action: **Log in** (text).
- Footer: “Are you a jeweller? Register here.” → existing Vendor register (`AppGuards.register`).

**No Customer bottom nav** on Guest. Private tabs (Requests, Connections, Alerts, Profile) exist only after Customer login. That matches “Guest Landing ≠ Dashboard”.

Tap a service → that type’s **create compose** screen (skip the CUS-S03 type picker, or pass the type in). Create routes must be allowed while `SignedOut`.

### 3. One Login, two doors

Reuse one Google-primary Login: today’s Customer onboarding Google step, stripped of “this is the home screen” behaviour.

**Recorded path:** Guest corner and Publish-gate Login reuse `/customer/onboarding`. Do **not** send Guest to `AppGuards.login` (`/vendor/login`). Do not add a third `/login` path.

**Pending-publish steal doors (GL-15):** `SignedIn` Customer + pending on `splash`, `customerOnboarding`, or `customerRegister` (any unauth route used as Login/signup) must stay on / return to create — not Dashboard. Today `_customerRedirect` sends any Customer on an unauth route to `customerHome`, and splash restore uses `homeFor` → Dashboard. Overlay (GL-47) keeps the user on a create path (GL-14), but (a) splash restore mid-login and (b) new-Google → `customerRegister` (GL-17/GL-43) both leave create. Special-casing `AppGuards.login` misses the real doors; that constant stays the Vendor OTP path only.

| Door | After Customer | After Vendor | After new Google | After blocked |
|------|----------------|--------------|------------------|---------------|
| Corner Log in | Customer Dashboard | Vendor home / awaiting | Customer signup → Dashboard | Blocked |
| Publish gate | Auto-publish | Drop draft → Vendor home / awaiting | Customer signup → auto-publish | Blocked |

Publish-gate Login is **dismissible**. Must **not** dispose the in-memory create controller.

**Vendor OTP/password:** leave on `/vendor/login` for now; Guest corner Log in is Google-first. Do not put OTP/password on Guest Login unless a later task says so.

### 4. Pending-publish intent (load-bearing)

Router refresh on `SignedIn` will otherwise yank the user to Dashboard.

Add a small in-memory holder, e.g. `PendingPublishIntent` / flag on `RequestCreateController`:

- Set when Guest taps Publish.
- Login overlay/route must **not** `autoDispose` the create notifier (it is already a keep-alive `Notifier` — keep it that way; do not navigate in a way that recreates the container).
- Guard exception: if intent is set **and** role is Customer, allow create routes; then auto-call `publish()` once.
- Clear intent on: success, Vendor login, Jeweller register, explicit cancel of create, sign-out.
- If user dismisses Login: clear **only** the “show login” overlay, not the form. Keep intent until successful publish or create cancelled (they can tap Publish again).

### 5. Guest compose vs server draft

Today `publish()` requires `saveDraft()` (POST `/v1/requests`) then POST publish. Guest cannot do that.

**Sequence after Customer login-at-publish:**

1. Upload any **local** images (picked files kept on the controller; no server keys until now).
2. `saveDraft()`.
3. `publish()` with the existing idempotency key helper.
4. On API fail: user is logged in; stay on review/compose; show error; they retry Publish (already authed — no second Login).

**Lookups while Guest:** `loadLookups()` must **not** require `me()`. Config / categories / regions / gold rates: use if the API allows unauth; if `me()` 401s, ignore it and leave `canCreateRequest` true. Cap-blocked UI is a signed-in concern.

**Images:** pick/capture locally; skip `deleteMedia`/upload until authed. Do not call authenticated media APIs as Guest.

**Bullion floor / rates:** same client validation as today, using whatever rates payload is public; if rates missing, keep today’s “compose allowed, publish may refuse” behaviour.

### 6. Jeweller register

Footer on Guest Landing → `/vendor/register`. On entry: `RequestCreateController` reset (drop draft). After submit: existing awaiting/KYC guards — **do not skip**.

### 7. Customer onboarding screen

Stop using CUS-S01 as the signed-out home. Reuse its Google + completion widgets from Login / new-user signup. Do not maintain two completion forms (onboarding `_CompletionView` vs `CustomerRegisterScreen`).

**Recorded choice (GL-42):** `CustomerCompletionController` is the single Customer signup implementation. `CustomerRegisterScreen` hosts it (thin wrapper). UnboundGoogle from Guest/Publish goes to `AppGuards.customerRegister`. `auth_completer_screen.dart` stays on disk; it is not linked from Guest, Login, or Publish.

**Token handoff (GL-42/GL-43):** `CustomerCompletionController.begin()` requires `firebaseIdToken`. The completion provider is **`AutoDisposeNotifierProvider`** — unlike keep-alive `requestCreateControllerProvider`. Today the token lives on onboarding `OnboardingNeedsCompletion` and is seeded only by `_CompletionView`. Leaving onboarding for `customerRegister` can dispose that form and drop the Google token, so new-Google from Publish cannot complete signup. Keep the Firebase ID token across the UnboundGoogle redirect (session field, onboarding controller, or a small holder). `CustomerRegisterScreen` must `begin()` with it. Do **not** rely on `_CompletionView` still being mounted.

### 8. Tests (required)

Update `test/app/guards_test.dart` (SignedOut → guest landing, pending-publish exception, Vendor restore unchanged).

Add:

- Guest landing widget test (4 services, Log in, jeweller footer).
- Publish-gate: dismiss keeps form; Customer auto-publish path (controller-level is enough if widget is heavy).
- Vendor from publish gate drops draft.
- New Google from publish → completion then publish intent still set.

No backend/e2e required for GL unless a public lookup is proven missing — then a **blocked** task, not a silent mock.

---

## Recorded engineering choices

| Item | Choice | Why |
|------|--------|-----|
| **GL-11 create routes** | **Lift** `requestCreateRoutes` out of `CustomerShell`’s `StatefulShellRoute` and register them as top-level `GoRoute`s on `routerProvider` (sibling of Unauth / Customer / Vendor shells). | Duplicate paths under UnauthShell fight go_router. Guest must not see Customer bottom nav. Create is a flow, not a tab. Customer tab branches stay SignedIn-only. |
| **Login body** | Reuse `/customer/onboarding` as the Google-primary Login. `AppGuards.login` stays Vendor OTP. GL-15 steal doors are `splash` / `customerOnboarding` / `customerRegister`, not `AppGuards.login`. | Avoid colliding with `AppGuards.login` (`/vendor/login`). No extra path. |
| **GL-42 signup** | `CustomerCompletionController` only. `CustomerRegisterScreen` wraps it and `begin()`s with the Firebase ID token. Keep the token across UnboundGoogle → `customerRegister` (session field, onboarding controller, or small holder). Completion is AutoDispose — do not rely on `_CompletionView`. | One form from UnboundGoogle. Completer unused on this path. New Google → signup → auto-publish needs the token. |
| **Intent holder** | New in-memory provider (e.g. `pending_publish_intent.dart`). Not a session type. Not persisted. | Guards must read it; create controller must set/clear it. |
| **Guest UI package** | `lib/features/auth/presentation/guest_landing_screen.dart` (not a new `features/guest/` package unless files overflow). | Landing is an unauth auth-feature screen. |

---

## Files likely touched (app work, later waves)

| Area | Files |
|------|--------|
| Guards / routes | `lib/app/guards.dart`, `lib/app/router.dart`, `lib/features/auth/routes.dart`, `lib/features/request_create/routes.dart` |
| Session | `lib/app/session/session_controller.dart` (redirect target; UnboundGoogle may need a token field if that is the chosen holder) |
| Guest UI | **[NEW]** `lib/features/auth/presentation/guest_landing_screen.dart` |
| Login | Slim `customer_onboarding_screen` / shared Google login; publish-gate overlay |
| Create | `lib/features/request_create/controller/request_create_controller.dart`, `request_create_state.dart`, review/publish screen |
| Intent | **[NEW]** e.g. `lib/features/request_create/pending_publish_intent.dart` |
| Signup | `customer_completion_controller` / `customer_register_*` (wrapper + `begin()` with token) |
| l10n | `packages/kh_l10n` ARB keys for guest copy |
| Tests | `test/app/guards_test.dart` + new guest/publish-gate tests |

---

## Out of scope

- Local draft persistence.
- Guest Customer bottom nav / “preview dashboard”.
- Changing Vendor KYC/awaiting rules.
- Admin portal.
- Backend identity-masking / WhatsApp / settlement rules.
- Rewriting SRS CUS-S01 (note the product change; do not silently restate the SRS).
- Unifying Vendor OTP/password into Guest Login.
- Deleting `auth_completer_screen.dart` (leave file; unlink from Guest/Login/Publish).

---

## Risks

1. **Guard steal** after login — pending-publish exception is mandatory. Real doors: `splash` / `customerOnboarding` / `customerRegister`, not `AppGuards.login`.
2. **Lookups/`me()` 401** — Guest create must not block on `me()`.
3. **Media upload auth** — local files until login.
4. **Provider dispose** — Login as a full `go()` that drops create state would violate in-memory draft. Prefer modal / extra route **inside** the same stack, or a root keep-alive create provider (already `Notifier`, not autoDispose — still killed if the `ProviderScope` is; it is app-level, so **route change is OK** as long as we do not `reset` the notifier). Verify with a test that fields survive pushing Login.
5. **Dual signup UIs** — collapse to one or guests hit the wrong form.
6. **Firebase token drop** — `UnboundGoogle` is empty; completion is AutoDispose. Must hand off the token to `customerRegister` without `_CompletionView`.

---

## Waves

| Wave | Tasks | Meaning |
|------|--------|---------|
| 0 | GL-00…GL-02 | Documents (this run) |
| 1 | GL-03…GL-24 | Routing & session (placeholder Guest OK) |
| 2 | GL-25…GL-34 | Guest Landing UI |
| 3 | GL-35…GL-49 | Login doors |
| 4 | GL-50…GL-64 | Guest compose + auto-publish |
| 5 | GL-65…GL-70 | Jeweller, blocked, retire old home |
| 6 | GL-71…GL-79 | Verify (+ blocked unauth-lookup probes) |

Atomic tasks, deps, and done-when live only in [`guest-launch-tasks.md`](guest-launch-tasks.md). Do not invent extra `GL-*` ids.

---

## Suggested PR slices (after docs)

1. **PR A** — GL-03…GL-24 routing, intent, placeholder Guest, guard tests.
2. **PR B** — GL-25…GL-34 Guest Landing UI + l10n + tap-to-create.
3. **PR C** — GL-35…GL-49 Login doors + overlay.
4. **PR D** — GL-50…GL-64 guest compose + auto-publish.
5. **PR E** — GL-65…GL-76 jeweller, blocked, retire old home, verify.
6. **PR F** (only if needed) — GL-77…GL-79 backend gaps.

Each PR independently testable. Do not mix Vendor KYC rewrites.

---

## Manual checklist (Wave 6 / GL-76)

**Signed off:** 11 September 2026 (Wave 6 orchestrator pass).

| Case | Expected | Result | Evidence |
|------|----------|--------|----------|
| Cold start, no token | Guest Landing | Pass | Chrome `http://localhost:7357/#/guest`: title Karat Hive; a11y finds Log in + 4 type cards + jeweller footer. Screenshot `build/gl76_guest_landing.png`. |
| Customer + live token | Customer Dashboard; no Guest flash | Pass | `guards_test`: SignedIn Customer without intent → Dashboard; SessionLoading → splash first. |
| Vendor active + live token | Vendor Dashboard | Pass | `guards_test`: active → vendor shell / home. |
| Vendor awaiting / KYC + live token | awaiting / KYC (not Guest) | Pass | `guards_test`: pendingVerification / rejected / verified → awaiting or KYC, not `/guest`. |
| Guest compose | Fill create without login; in-memory only | Pass | Chrome: ornament card → Find An Ornament compose (Save draft / Continue; no login wall). `guest_lookups_media_test` + landing overlay/publish units. |
| Login-at-publish as Customer | Auto-publish | Pass | `guest_publish_test`: upload→draft→publish once; pending cleared on success. |
| Cancel Login from publish gate | Stay guest; form kept | Pass | `guest_publish_overlay_test`: overlay dismiss keeps notes / guest. |
| Jeweller register mid-create | Draft dropped; Vendor register | Pass | `guest_landing_screen_test`: mid-create jeweller clears type/notes/weight → `/vendor/register`. |
| Blocked account | Blocked screen, not Guest | Pass | `guards_test` GL-69; `customer_onboarding_controller_test` GL-68 → `AuthBlocked`. |

---

## Open questions

None from product (consensus frozen).

Engineering only: GL-77…GL-79 (public lookups). If unknown at coding time, Guest lookups tolerate 401 and those tasks stay `[~]`. If a probe fails, link a backend follow-up; do not fake client success.
