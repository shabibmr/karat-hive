# CUS-S01 · Login / Customer signup

| | |
|---|---|
| **User** | Guest completing login, or Customer / Vendor returning |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-001`, `FR-CUS-002`, [`adr/0010`](../../docs/adr/0010-google-signin-only-login.md), [`adr/0011`](../../docs/adr/0011-guest-first-landing.md) |

## Purpose

One Login used by Guest Landing’s corner **Log in** and by the CUS-S09 publish gate. Google is the only login (`adr/0010`). New Google users from this door complete as Customer. OTP proves a mobile number; it is not a login. Cold start is **not** this screen — that is `CUS-S23`.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | CUS-S23 corner Log in; CUS-S09 publish while Guest; logout; session expiry then Log in |
| Exit success (Customer, no draft) | Dashboard (CUS-S02) |
| Exit success (Customer, from publish) | Resume in-memory form → auto-publish (`adr/0011`) |
| Exit success (Vendor) | Vendor home / awaiting; drop any Customer draft |
| Exit success (new Google) | Customer signup (name / mobile OTP proof / terms) then same resume rules |
| Exit blocked | Suspended / deactivated account messages |
| Exit cancel | Previous screen; keep in-memory Guest form |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Mobile number | Input | Yes | UAE-format / E.164 | Unique among active accounts |
| Send OTP | Action | — | — | Max 5 OTP requests per number per hour |
| OTP code | Input | Yes | Numeric | Expires 5 minutes after issue |
| Display name | Input | Yes | string ≤ 100 | Registration only |
| Email | Input | No | email | Optional at register; verify later via link if supplied |
| Accept Terms of Service | Input | Yes | checkbox + version | Version id + timestamp stored |
| Accept Privacy Policy | Input | Yes | checkbox + version | Same |
| Create account / Continue | Action | — | — | Creates `ACTIVE` Customer and signs in |
| OAuth provider (Google) | Action | Yes | provider button | Only login (`adr/0010`). Same control for corner Log in and publish gate |
| OAuth binding status | Display | — | bound / not bound | Shown when the publish gate is hit |
| Login with mobile + OTP | — | — | — | **Not a login.** OTP is phone proof on Customer signup / mobile change |
| Biometric unlock | Input | No | Face ID / fingerprint | Convenience over valid session |
| Logout (from session) | Action | — | — | Server token invalidate |

## Validation & rules

- OTP must match; expired OTP fails.
- Duplicate mobile → redirect to login.
- Suspended vs deactivated: distinct refusal messages.
- Session persists 30 days inactivity; then re-auth.
- Publish of a Request is refused without a bound Google session (server-side, `BR-001`, `adr/0010`).
- Guest/Publish path has no role chooser (`adr/0011`). Jeweller signup is the Guest Landing footer, not this screen.

## Empty / error / edge states

- Wrong OTP; rate-limited OTP; already registered number.
- Account suspended / deactivated.

## Related screens

CUS-S23 Guest Landing · CUS-S02 Dashboard · CUS-S09 publish gate · CUS-S21 Settings
