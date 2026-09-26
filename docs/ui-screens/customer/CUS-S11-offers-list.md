# CUS-S11 · Offers list

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-019`, `FR-CUS-021` |

## Purpose

List all Offers on a Request with sort/filter; Vendor identity remains masked.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | CUS-S10; notification deep link |
| Exit | CUS-S12 compare; CUS-S13 detail |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Parent Request summary | Display | — | type, ref, expiry | |
| Offer count | Display | — | integer | |
| Offered price (AED) | Display | — | decimal | |
| Vendor masked label | Display | — | e.g. Verified Jeweller · Region | **No** business name |
| Vendor aggregate rating | Display | — | 0–5 one decimal | Or “New vendor…” if &lt; 3 reviews |
| Vendor completed-connection count | Display | — | integer | |
| Offer submission time | Display | — | datetime | |
| Offer expiry / countdown | System | — | datetime | |
| Unread marker | Display | — | badge | |
| Select for compare | Input | No | multi-select 2–4 | |
| Sort | Filter / Sort | — | price asc/desc, rating, newest/oldest, expiring soonest | Default: lowest price for BUY, highest for SELL |
| Filter — min rating | Filter / Sort | No | number | |
| Filter — price range | Filter / Sort | No | AED min–max | |
| Filter — exclude expiring within window | Filter / Sort | No | duration | |
| Open Offer detail | Action | — | — | → CUS-S13 |
| Compare selected | Action | — | — | → CUS-S12 |
| Live update | System | — | — | New Offer without manual refresh |

## Validation & rules

- Vendor real identity never shown (`BR-006`).
- Sort/filter persist for session.

## Empty / error / edge states

- No Offers yet: empty state + Request expiry date.

## Related screens

CUS-S12 · CUS-S13 · CUS-S10
