# CUS-S12 · Offer comparison

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-020` |

## Purpose

Side-by-side compare 2–4 Offers on differentiating attributes; accept from comparison.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | CUS-S11 with 2–4 selected |
| Exit | CUS-S14 accept; CUS-S13 detail |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Selected Offers (2–4 columns) | Display | Yes | — | |
| Price | Display | — | AED | Best value highlighted |
| Price delta vs low/high | Display | — | AED | |
| Making charges | Display | — | AED | |
| Delivery / readiness timeframe | Display | — | string | |
| Warranty / buy-back terms | Display | — | text | |
| Vendor rating | Display | — | aggregate | Masked Vendor |
| Vendor completed-connection count | Display | — | integer | |
| Accept Offer | Action | — | per column | → CUS-S14 |
| Open detail | Action | — | — | → CUS-S13 |

## Validation & rules

- “Best” numeric direction: lowest price for BUY, highest for SELL.
- Vendor identity remains masked throughout.

## Empty / error / edge states

- Must select 2–4; cannot compare 1 alone.

## Related screens

CUS-S11 · CUS-S13 · CUS-S14
