# Guest-first launch; login at publish

Cold start with no live session opens **Guest Landing** (`CUS-S23`) in Customer mode. Login is optional until the user publishes a Request or opens a private area. Google remains the only login (`adr/0010`).

**Why.** Product froze this on 11 September 2026 in [`docs/reports/app-launch-flow-review.md`](../reports/app-launch-flow-review.md). Forced Google onboarding before anything useful is the wrong first impression. Browse and compose first; account at the moment it is required.

**Launch**

1. Splash checks the saved session.
2. Customer + live token → Customer Dashboard (`CUS-S02`).
3. Vendor + live token → Vendor Dashboard if `ACTIVE`; else awaiting / KYC (unchanged).
4. Else → Guest Landing (`CUS-S23`). Never flash Guest when a valid session exists.

**Guest**

- May open any of the four Request Types, read “How this works,” and fill the create flow.
- Draft is **in-memory only**. Lost if the app is killed. No local persistence in this slice.
- **Login at Publish.** After a Customer login, **auto-publish**. Cancel/back from Login keeps the form.
- Private tabs (My Requests, Connections, Alerts, Profile) require login.
- Mid-create **Register as Jeweller** drops the draft. No confirm dialog in this slice.

**Log in outcomes**

| Who | Corner Log in on Guest | Publish gate |
|---|---|---|
| Customer | `CUS-S02` Dashboard | Auto-publish |
| Vendor | Vendor home / awaiting | Drop draft → Vendor home / awaiting |
| New Google | Customer signup → Dashboard | Customer signup → auto-publish |
| Blocked | Blocked screen | Blocked screen |

**Guest Landing vs Dashboard.** Separate screens. Guest educates (four services + how it works). `CUS-S02` is signed-in home (my Requests). Do not overload one screen.

**Jeweller entry.** Subtle footer on Guest Landing: “Are you a jeweller? Register here.” → Vendor signup (`VEN-S01`), not Vendor login. Returning jewellers use corner **Log in**. No large Jeweller CTA next to the four services. No role chooser on the publish path.

**What this amends.** `adr/0010` still owns *how* login works (Google only). This ADR owns *when* login is required and *where* a signed-out user lands. A Guest/Publish Google user completes as Customer; they do not pick a role in the middle of publish.

**What the code must stop doing.** `SignedOut` → `/customer/onboarding`. That default is Guest Landing. Create-flow routes must be reachable without a token until Publish.

**Non-goals (this slice).** Local draft persistence. Role chooser on the publish path. Big Jeweller CTA on Guest Landing.

**Follow-up docs.** SRS v1.3 Appendix C still lists 22 Customer screens and describes OTP-first onboarding. Until an SRS bump, this ADR, [`ui-screens/customer/CUS-S23-guest-landing.md`](../../ui-screens/customer/CUS-S23-guest-landing.md), and the Customer checkpoint / build plan are the working rule for launch.
