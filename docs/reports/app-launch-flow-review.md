# App launch / login flow — review findings

Status: **discussion only** — no fixes yet.  
Implementation: [`guest-launch-plan.md`](../../apps/kh_mobile/karat_hive/docs/guest-launch-plan.md) · [`guest-launch-tasks.md`](../../apps/kh_mobile/karat_hive/docs/guest-launch-tasks.md)  
Scope: walk use cases one step at a time; record how it works now + suggestions.

---

## Plan change (agreed direction)

**Cold start = Guest as Customer → Guest Landing Page.**  
Login is optional until the user needs an account action.

```
Splash
  → token alive + Customer  → Customer Dashboard
  → token alive + Vendor    → Vendor Dashboard
  → no token / new          → Guest Landing Page (Customer mode)
```

### Guest Landing Page (target)

- 4 services: Find jewellery | Sell my gold | Coins | Bullion
- Login control (corner / subtle)
- “How this works” for each of the 4
- “Register as a Jeweller” — present but not prominent

---

## How it works **now** (gap vs new plan)

| Area | Today | New plan |
|------|--------|----------|
| Cold start | Splash → Customer Google onboarding | Splash → **Guest Landing** |
| Guest browsing | None | Browse 4 services + how-it-works |
| Returning Customer | Google session → Customer home (my Requests) | Token alive → Customer Dashboard |
| Returning Vendor | Only if already on vendor routes / session | Token alive → Vendor Dashboard |
| Jeweller entry | Vendor login/register screens; hard to find from cold start | Subtle “Register as Jeweller” on Guest |
| Login | Forced before anything useful | Corner Login on Guest |

Old findings F1–F7 (forced Google-first, dual new-user paths, vendor OTP/password, etc.) still true until this plan is implemented.

---

## Suggestions (discussion)

### S1 — What “guest” can do without login — **AGREED**
Guest can open any of the 4 services, read “How this works,” and walk the create flow.  
**Login required at publish** (and for private areas: My Requests, Connections, etc.).

### S2 — Guest Landing vs Customer Dashboard
**Suggest:** keep them different.
- **Guest Landing** = discover + educate (4 services + how it works).
- **Customer Dashboard** = signed-in home (my Requests, etc. — today’s CUS-S02).  
Do not overload one screen for both.

### S3 — Login placement
**Suggest:** top-right **Log in** (text button). Familiar, not competing with the 4 service cards.  
After Login success: Customer → Dashboard; Vendor → Vendor path; new Google → Customer signup (Jeweller stays on the subtle link).

### S4 — “How this works”
**Suggest:** one short pattern for all 4 (expandable under each card, or a sheet). Same steps shape: post → get offers → accept → talk on WhatsApp. Only type-specific bits change (e.g. bullion minimum).

### S5 — Register as Jeweller
**Suggest:** footer link or overflow/menu — not a big button next to the 4 services.  
Copy: “Are you a jeweller? Register here.”  
Goes to Vendor signup (not Vendor login). Returning jewellers use the corner **Log in**.

### S6 — Token restore order (important)
On launch: splash → if saved session valid, route by role **before** showing Guest.  
Only show Guest when there is no live session. Matches your Vendor/Customer “already logged in” rules.

### S7 — Open product question
If a **Vendor** opens the app with **no** live token: they see Guest (Customer). Good.  
When they tap **Log in** with a Vendor Google/account → go to Vendor Dashboard (or awaiting), **not** Customer signup. Confirm this.

---

## Step 2 — Guest taps a service — **AGREED: login at publish**

### Target behaviour
1. Guest taps one of the 4 services on Guest Landing.
2. Sees “How this works” (or can open it).
3. Can fill the create flow as far as draft/compose.
4. On **Publish** → Login (then return to finish publish if possible).
5. Private tabs (My Requests, Connections, Alerts, Profile) → Login if tapped while guest.

### How it is now
- No guest session; create routes sit behind signed-in Customer shell.
- Request type + create screens exist for the 4 types; publish assumes an authenticated Customer.

### Findings
| ID | Finding |
|----|---------|
| F8 | Need a real **Guest** session state (not SignedOut → onboarding). |
| F9 | Create flow must work without a token until Publish. |
| F10 | After Login-at-publish: return user to the same draft and complete publish (or ask them to confirm once). |
| F11 | Draft without login — **AGREED: in-memory only** (lost if app is killed). Local draft later if needed. |

---

## Step 3 — Log in (corner + at publish)

### Target behaviour
Two doors to the same Login:
1. **Corner Log in** on Guest Landing (browse, no draft).
2. **Publish** while guest → Login, then resume the in-memory create form and publish.

After Login:
- Existing **Customer** → continue as Customer (if from publish → finish publish; if from corner → Customer Dashboard or back to Guest/create context).
- Existing **Vendor** → Vendor Dashboard (or awaiting). Publish draft does not apply (Vendor does not publish Customer Requests).
- **New Google** (no account) → Customer signup (name / mobile / OTP / terms), then same resume rules.
- **Blocked** → blocked / lockout screen.

### How it is now
- Login is Google on Customer onboarding (forced at cold start).
- Vendor login is a separate screen (OTP / password / Google).
- No “return to publish after login” path.
- Dual new-user paths still exist (inline completion vs role chooser).

### Findings
| ID | Finding |
|----|---------|
| F12 | Need one Login entry used by corner button and by Publish gate. |
| F13 | After login-at-publish, must **resume the same in-memory form** and publish — or user re-enters everything. |
| F14 | If a **Vendor** logs in from Publish gate, do not try to publish their Customer draft — clear draft, go Vendor home, explain briefly. |
| F15 | New users: prefer **Customer signup by default** from Guest/Publish; Jeweller stays on subtle Register link (no role chooser in the middle of publish). |

### Suggestions
1. **One Login screen** — Google primary (match Customer story). Keep Vendor OTP/password out of this door unless we still need them for old Vendor accounts.
2. **Publish gate** — modal or full screen: “Log in to publish” → Google → on success, auto-continue publish when role is Customer.
3. **Corner Log in** — same screen; on success with no draft → Customer Dashboard (or Guest if we want them to keep browsing — prefer Dashboard for returning Customers).
4. **No role chooser on publish path** — Guest is Customer-mode; signup completes as Customer. Vendor only via “Register as Jeweller.”

### Open question for Step 3 — **AGREED**
Corner Log in as Customer → **Customer Dashboard**.

---

## Step 4 — Register as Jeweller

### Target behaviour
- On Guest Landing: subtle link (footer / menu), e.g. “Are you a jeweller? Register here.”
- Not next to the 4 service cards; not competing with Log in.
- Starts **Vendor signup** (not Vendor login).
- Returning jewellers use corner **Log in** → Vendor Dashboard / awaiting.

### How it is now
- Vendor register screen exists (`/vendor/register`).
- Vendor login has OTP, password, and Google.
- Cold start does not surface Jeweller entry; SignedOut sends users to Customer Google onboarding.
- Auth completer can send unbound Google users to Vendor register — conflicts with Guest-first Customer default.

### Findings
| ID | Finding |
|----|---------|
| F16 | Need a quiet but findable Jeweller entry on Guest Landing only (and maybe Login footer). |
| F17 | Vendor signup vs Vendor login must stay clear: Register link = new shop; Log in = existing. |
| F18 | After Vendor register: today’s awaiting / KYC / active gates still apply — Guest plan should not skip them. |
| F19 | Mid create → Register as Jeweller — **AGREED: drop draft** (no confirm dialog for now). |

### Suggestions
1. **Placement:** footer under the 4 cards + how-it-works — small text link, not a filled button.
2. **Copy:** “Are you a jeweller? Register here.”
3. **Flow:** Guest → Vendor register (business details, etc.) → existing awaiting/KYC path when submitted.
4. **Log in** still finds existing Vendors; do not force them through Register.

---

## Step 5 — Returning user (token restore)

### Target behaviour
On every launch:
1. Splash while checking saved session.
2. **Customer + token alive** → Customer Dashboard.
3. **Vendor + token alive** → Vendor Dashboard (or awaiting / KYC if not fully active — keep today’s vendor gates).
4. **No token / expired / refresh failed** → Guest Landing.
5. Never show Guest flash if a valid session exists (splash covers the check).

### How it is now
- Splash exists; session restore via Firebase Google and/or stored tokens.
- SignedOut → Customer onboarding (not Guest Landing).
- SignedIn Customer → Customer home; Vendor lifecycle → home or awaiting.
- Blocked Customer → blocked screen.
- Dead/expired session often becomes SignedOut → onboarding.

### Findings
| ID | Finding |
|----|---------|
| F20 | Replace SignedOut default target: **Guest Landing**, not Google onboarding. |
| F21 | Vendor “dashboard” means active home; non-active still uses awaiting/KYC — say that clearly in the plan. |
| F22 | Expired token → Guest; user Logs in again (corner). No silent stay on Dashboard. |
| F23 | Admin / unknown role on mobile: today falls toward customer onboarding — decide Guest vs hard stop. |

### Suggestions
1. Splash → restore → role home **or** Guest. No onboarding as default.
2. Vendor restore: **active** → Vendor Dashboard; else → existing awaiting/KYC screens (unchanged rules).
3. Refresh failure → clear session → Guest Landing.
4. **F23 suggest:** unknown/non-mobile role → Guest Landing + Log in (or a short “use the admin portal” if we detect Admin). Prefer Guest for simplicity.

### Open question for Step 5 — **AGREED**
Vendor token alive but not active → **awaiting / KYC** (not Guest).

---

## Step 6 — Errors, blocked, cancel

### Target behaviour (edge cases)

| Case | Behaviour |
|------|-----------|
| Google cancel / dismiss | Stay where they were (Guest or Publish-gate Login). No error scream. |
| Network fail on Login | Short error on Login; retry. Guest form kept in memory if from Publish. |
| Account blocked / suspended | Blocked / lockout screen. Not Guest Dashboard. |
| Login-at-publish → Customer OK | Resume in-memory form → publish. |
| Login-at-publish → Vendor | Drop draft → Vendor home / awaiting. Short note optional later. |
| Login-at-publish → new user | Customer signup → then resume publish. |
| Login-at-publish → user backs out | Stay guest; keep in-memory form. |
| App killed mid guest create | Form gone (in-memory agreed). |
| Publish API fails after login | User is logged in; show error on create; they can retry publish. |

### How it is now
- Cancel Google often returns to idle onboarding.
- Lockout codes exist on Customer onboarding.
- AuthBlocked → blocked screen.
- No publish-gate resume; no Guest-stable cancel path.

### Findings
| ID | Finding |
|----|---------|
| F24 | Publish-gate Login must be dismissible without wiping the in-memory form. |
| F25 | Blocked users must not land on Guest as if anonymous; show blocked state. |
| F26 | After Login-at-publish as Customer — **AGREED: auto-publish**. If publish fails, stay logged in and show error on the form. |

### Suggestions
1. Cancel / back from Login → previous screen; **keep** guest form.
2. Blocked → dedicated blocked UI (today’s screen is fine).
3. Vendor from publish gate: drop draft, go awaiting/home — no publish attempt.

---

## Full consensus (frozen)

### Launch
1. Splash checks session.
2. Customer + live token → Customer Dashboard.
3. Vendor + live token → Vendor Dashboard if active; else awaiting / KYC.
4. Else → Guest Landing (Customer mode).

### Guest Landing
- 4 services: Find jewellery | Sell my gold | Coins | Bullion.
- “How this works” for each.
- Corner **Log in**.
- Subtle **Register as Jeweller** (footer).

### Guest create
- Open any service and fill the flow without login.
- Draft **in-memory only**.
- **Login at Publish**.
- After Customer login-at-publish → **auto-publish**.
- Cancel/back from Login → keep form.
- Register as Jeweller mid-create → **drop draft**.

### Log in outcomes
| Who | From corner Log in | From Publish gate |
|-----|--------------------|-------------------|
| Customer | Customer Dashboard | Auto-publish |
| Vendor | Vendor home / awaiting | Drop draft → Vendor home / awaiting |
| New Google | Customer signup → Dashboard | Customer signup → auto-publish |
| Blocked | Blocked screen | Blocked screen |

### Explicit non-goals (for now)
- No local draft persistence.
- No role chooser in the publish path.
- No big Jeweller CTA on Guest Landing.
