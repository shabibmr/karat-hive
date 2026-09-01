# CUS-S13 · Offer detail

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-022`, `FR-CUS-031`, `FR-CUS-023`, `FR-CUS-026` |

## Purpose

Full Offer terms plus masked Vendor rating summary before Accept or Decline.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | CUS-S11 / CUS-S12 |
| Exit | CUS-S14 Accept; decline; CUS-S31 ratings subset; CUS-S22 report |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Offered price | Display | — | AED | |
| Making charges | Display | — | AED nullable | |
| Rate per gram | Display | — | AED/g nullable | |
| Delivery / readiness timeframe | Display | — | string | |
| Warranty / buy-back terms | Display | — | text | |
| Vendor free-text note | Display | — | text | |
| Supporting images (≤3) | Display | — | gallery | Vendor-attached |
| Validity / expiry | System | — | countdown | |
| Offer state | Display | — | PENDING / EXPIRED / … | Read-only if terminal |
| Vendor masked label | Display | — | e.g. Verified Jeweller · Deira · ★ 4.6 · 128 deals | |
| Aggregate rating | Display | — | 1 decimal | |
| Review count | Display | — | integer | |
| Star distribution | Display | — | 1–5 bars | |
| Completed-connection count | Display | — | integer | |
| Recent review excerpts (≤10) | Display | — | abbreviated names | e.g. Ahmed K. |
| New vendor notice | Display | Conditional | — | If &lt; 3 reviews |
| Mark as Interested (Accept) | Action | — | — | → CUS-S14 |
| Decline | Action | — | — | Optional reason |
| Decline reason | Input | No | price too high / terms unsuitable / no longer required / other | Aggregate to Vendor only |
| Report | Action | — | — | → CUS-S22 |

## Validation & rules

- No real Vendor business identity pre-acceptance.
- Expired/withdrawn: read-only with status time.

## Empty / error / edge states

- Stale accept attempt after expire/withdraw: clear error.

## Related screens

CUS-S14 · CUS-S11 · CUS-S22
