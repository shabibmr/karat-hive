# VEN-S04 · Login

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-003`, [`adr/0010`](../../docs/adr/0010-google-signin-only-login.md) |

## Purpose

Authenticate a Vendor with Google Sign-In; route to the Awaiting Approval shell or the full app by state.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Corner Log in on Guest Landing (`CUS-S23`) for a returning jeweller |
| Exit | VEN-S03 or VEN-S05; unbound Google account → VEN-S01 |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Sign in with Google | Action | — | Google provider | Only login (`adr/0010`). No OTP, no password |
| Register link | Action | — | — | → VEN-S01 |

## Validation & rules

- Allowed: PENDING_VERIFICATION, REJECTED (to resubmit), ACTIVE.
- Refused: SUSPENDED, DEACTIVATED — state-appropriate message.
- Session idle expiry: 14 days.

## Empty / error / edge states

- Google sign-in cancelled; Google account not registered (→ VEN-S01); suspended messaging.

## Related screens

VEN-S01 · VEN-S03 · VEN-S05
