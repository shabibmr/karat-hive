# CUS-S10 · Request detail (my Request)

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-016`, `FR-CUS-017`, `FR-CUS-019` (entry to offers) |

## Purpose

View own Request state, Offer count, edit allowed fields, or cancel while still open.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Home; notifications; history |
| Exit | CUS-S11 Offers; edit sub-flow; cancel |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Reference | Display | — | string | |
| State | Display | — | state machine | |
| Type / direction | Display | — | immutable after publish | Structural lock |
| Weight, purity, quantity | Display | — | immutable after publish | `BR-014` |
| Category / Region | Display | — | — | |
| Notes | Input | No | text | Editable while PUBLISHED / OFFERS_RECEIVED |
| Budget min/max / flexible | Input | Conditional | AED | Editable pre-acceptance |
| Images | Input | Conditional | add/remove/reorder | Editable pre-acceptance |
| Offer count | Display | — | integer | |
| Expiry | System | — | countdown | |
| View Offers | Action | — | — | → CUS-S11 |
| Save edits | Action | — | — | Notifies Vendors with pending Offers |
| Cancel Request | Action | — | — | Optional reason from list |
| Cancellation reason | Input | No | configured list | Analytics |
| Close Connection path | Action | Conditional | — | If ACCEPTED → Connection flow |

## Validation & rules

- Edit blocked after Offer accepted.
- Cancel blocked once ACCEPTED; only close Connection (`BR-013`).
- Cancel → pending Offers `WITHDRAWN_BY_SYSTEM`.

## Empty / error / edge states

- Zero Offers empty state with expiry date (via offers list).

## Related screens

CUS-S11 · CUS-S15 · CUS-S17
