# VEN-S09 · Submit Offer

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-012`, `FR-VEN-013`, `FR-VEN-015` |

## Purpose

Submit a priced, time-limited Offer against a matched open Request.

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
| Validity period | Input | Yes | **12 h / 24 h / 48 h** (FR default set); default 24 h | Options longer than Request remaining life not offered |
| Absolute expiry | System | — | computed | Never later than Request hard expiry |
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

### SRS tension

- FR-VEN-013 options: **12 / 24 / 48 h**. Entity `OFFER.validity_hours` lists **24 / 48 / 72 / 168**. Resolve before build; document choice in settings (ADM-S19).

## Empty / error / edge states

- Request closed; already has PENDING; subscription missing; contact details in note.

## Related screens

VEN-S10 · VEN-S08 · VEN-S11
