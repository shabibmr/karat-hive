# VEN-S09 · Submit Offer

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-012`, `FR-VEN-013`, `FR-VEN-015`, [`adr/0015`](../../docs/adr/0015-offers-live-with-their-request.md) |

## Purpose

Submit a priced Offer against a matched open Request. The Offer expires with the Request.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | VEN-S08 |
| Exit | VEN-S11 Pending; back to detail |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Parent Request summary | Display | — | masked Customer | |
| Offered price (AED) | Input | Yes | decimal | |
| Weight (g) | Input | Yes | decimal | Prefilled from the Request when stated |
| Karat | Input | Yes | 24K / 22K / 21K / 18K | Prefilled from the Request when stated |
| Expiry | System | — | = Request hard expiry | Not chosen by the Vendor (`FR-VEN-013`) |
| Making charges | Input | No | AED | |
| Rate per gram | Input | No | AED/g | |
| Delivery / readiness timeframe | Input | No | string ≤ 100 | |
| Warranty / buy-back terms | Input | No | text | |
| Supporting images (≤3) | Input | No | JPEG/PNG | |
| Free-text note | Input | No | text | Scanned for contact details — block if found |
| Submit | Action | — | — | → PENDING |

## Validation & rules

- Vendor must be VERIFIED + ACTIVE + subscribed for Request type.
- At most one PENDING Offer per Request (`BR-009`).
- Note contact-detail scan (`BR-022`).
- A sent Offer cannot be changed; the Vendor withdraws it (VEN-S10) and submits again.

## Empty / error / edge states

- Request closed; already has PENDING; subscription missing; contact details in note.

## Related screens

VEN-S10 · VEN-S08 · VEN-S11
