# CUS-S10 · Request detail (my Request)

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-016`, `FR-CUS-017`, `FR-CUS-019` (entry to offers) |

## Purpose

View own Request state and Offer count, or cancel while still open. A published Request cannot be edited (`FR-CUS-016`, retired).

## Entry / exit

| Direction | Path |
|---|---|
| Entry | My Requests (CUS-S24); notifications; history |
| Exit | CUS-S11 Offers; cancel |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Reference | Display | — | string | |
| State | Display | — | state machine | |
| Type / direction | Display | — | immutable after publish | Structural lock |
| Weight, purity, quantity | Display | — | immutable after publish | `BR-014` |
| Region | Display | — | — | |
| Notes | Display | — | text | |
| Budget min/max / flexible | Display | Conditional | AED | |
| Images | Display | Conditional | gallery | |
| Offer count | Display | — | integer | |
| Expiry | System | — | countdown | |
| View Offers | Action | — | — | → CUS-S11 |
| Cancel Request | Action | — | — | Optional reason from list |
| Cancellation reason | Input | No | configured list | Analytics |
| Close Connection path | Action | Conditional | — | If ACCEPTED → Connection flow |

## Validation & rules

- No edit after publish; Cancel is the only mutating action while PUBLISHED.
- Cancel blocked once ACCEPTED; only close Connection (`BR-013`).
- Cancel → pending Offers `WITHDRAWN_BY_SYSTEM`.

## Empty / error / edge states

- Zero Offers empty state with expiry date (via offers list).

## Related screens

CUS-S11 · CUS-S15 · CUS-S17
