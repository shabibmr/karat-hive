# VEN-S19 · Leave customer feedback

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-028` |

## Purpose

Rate/review a Customer on a Connection; hold-for-approval; Customer ratings not public to other Customers.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Close Connection; VEN-S13 |
| Exit | Pending moderation confirmation |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Customer / Connection context | Display | — | revealed name | |
| Star rating | Input | Yes | 1–5 | |
| Comment | Input | No | ≤ 1000 chars | |
| Submit | Action | — | — | PENDING_MODERATION |

## Validation & rules

- One review per Connection per party.
- Aggregates visible to Vendors/Admins only (`BR-018`).
- Admin approval required before any display.

## Empty / error / edge states

- Already reviewed.

## Related screens

VEN-S13 · VEN-S12
