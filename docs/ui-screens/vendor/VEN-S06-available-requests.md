# VEN-S06 · Available Requests feed

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-008` |

## Purpose

Browse open matched Requests (Category + Region + subscription type); Customer identity masked.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Dashboard; nav Requests |
| Exit | VEN-S07 filters; VEN-S08 detail |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Request type | Display | — | enum | |
| Direction | Display | — | BUY / SELL | |
| Weight or quantity | Display | — | — | |
| Purity | Display | — | karat | |
| Budget (if stated) | Display | — | AED | |
| Region | Display | — | — | |
| Thumbnail | Display | — | image | |
| Time since publication | Display | — | relative | |
| Offer count already received | Display | — | integer | **Not** competitor prices |
| Request expiry | System | — | countdown | |
| Already responded marker | Display | Conditional | — | Excluded by default |
| Include already responded | Filter / Sort | No | toggle | |
| Open detail | Action | — | — | → VEN-S08 |
| Open filters | Action | — | — | → VEN-S07 |
| Infinite scroll pagination | System | — | — | 1000+ capable |

## Validation & rules

- Only matched Requests in PUBLISHED / OFFERS_RECEIVED.
- Customer identity absent from payload (`BR-006`, `NFR-013`).

## Empty / error / edge states

- No matches; suggest broaden Categories/Regions or subscription.

## Related screens

VEN-S07 · VEN-S08 · VEN-S16 · VEN-S22
