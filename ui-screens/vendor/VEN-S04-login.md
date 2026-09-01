# VEN-S04 · Login

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-003` |

## Purpose

Authenticate Vendor; route to Awaiting Approval shell or full app by state.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Cold start Vendor mode |
| Exit | VEN-S03 or VEN-S05 |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Mobile number | Input | Conditional | E.164 | OTP path |
| OTP | Input | Conditional | numeric | |
| Business email | Input | Conditional | email | If password set |
| Password | Input | Conditional | secret | |
| Login | Action | — | — | |
| Register link | Action | — | — | → VEN-S01 |
| Lockout message | Display | Conditional | — | 5 fails → 15 min lock |

## Validation & rules

- Allowed: PENDING_VERIFICATION, VERIFIED (pre-ACTIVE), ACTIVE.
- Refused: REJECTED, SUSPENDED, DEACTIVATED — state-appropriate message.
- Session idle expiry: 14 days.

## Empty / error / edge states

- Failed auth; lockout; suspended messaging.

## Related screens

VEN-S01 · VEN-S03 · VEN-S05
