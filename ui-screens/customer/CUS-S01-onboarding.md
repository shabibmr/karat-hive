# CUS-S01 · Onboarding

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-001`, `FR-CUS-002` |

## Purpose

Register or sign in a Customer with Google Sign-In (`adr/0010`), capture basic profile, accept legal terms, and complete one-time OAuth before any Request can be published. *(Phone Authentication & OTP and Biometric Sign-in are hidden per review — preserved for future reference)*.

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
| OAuth provider (Google) | Action | Yes | Google button | Primary sign-in / authentication (`adr/0010`, `BR-001`) |
| OAuth binding status | Display | — | bound / not bound | Shown when gate is hit |
| Display name | Input | Yes | string ≤ 100 | Registration only |
| Email | Input | No | email | Optional at register; verify later via link if supplied |
| Accept Terms of Service | Input | Yes | checkbox + version | Version id + timestamp stored |
| Accept Privacy Policy | Input | Yes | checkbox + version | Same |
| Create account / Continue | Action | — | — | Creates `ACTIVE` Customer and signs in |
| Logout (from session) | Action | — | — | Server token invalidate |
| Mobile number | Input | Yes | UAE-format / E.164 | *Hidden per review (preserved)* |
| Send OTP | Action | — | — | *Hidden per review (preserved)* |
| OTP code | Input | Yes | Numeric | *Hidden per review (preserved)* |
| Login with mobile + OTP | Action | — | — | *Hidden per review (preserved)* |
| Biometric unlock | Input | No | Face ID / fingerprint | *Hidden per review (preserved)* |

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
