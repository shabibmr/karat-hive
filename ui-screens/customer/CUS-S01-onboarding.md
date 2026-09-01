# CUS-S01 · Onboarding

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-001`, `FR-CUS-002` |

## Purpose

Register or sign in a Customer with UAE mobile OTP, capture basic profile, accept legal terms, and complete one-time OAuth before any Request can be published.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Cold start, logout, session expiry |
| Exit success (new) | Home (CUS-S02); OAuth may be deferred until first publish |
| Exit success (returning) | Home (CUS-S02) |
| Exit blocked | Suspended / deactivated account messages |

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
| OAuth provider (Google / Apple / configured) | Action | Conditional | provider button | **Once** before first Request publish (`BR-001`) |
| OAuth binding status | Display | — | bound / not bound | Shown when gate is hit |
| Login with mobile + OTP | Action | — | — | Returning Customer |
| Biometric unlock | Input | No | Face ID / fingerprint | Convenience over valid session |
| Logout (from session) | Action | — | — | Server token invalidate |

## Validation & rules

- OTP must match; expired OTP fails.
- Duplicate mobile → redirect to login.
- Suspended vs deactivated: distinct refusal messages.
- Session persists 30 days inactivity; then re-auth.
- Publish of Request refused without OAuth binding (server-side).

## Empty / error / edge states

- Wrong OTP; rate-limited OTP; already registered number.
- Account suspended / deactivated.

## Related screens

CUS-S02 Home · CUS-S09 (publish may re-prompt OAuth) · CUS-S21 Settings
