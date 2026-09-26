# VEN-S14 · Offer history & performance

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-023` |

## Purpose

Terminal Offer history with aggregate performance metrics (no competitor identities).

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Nav History / Profile area |
| Exit | Export; open historical Offer |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Filter — date range | Filter / Sort | No | — | |
| Filter — Request type | Filter / Sort | No | — | |
| Filter — Category | Filter / Sort | No | — | |
| Filter — Region | Filter / Sort | No | — | |
| Filter — outcome | Filter / Sort | No | terminal states | |
| Offers submitted (period) | Display | — | integer | Aggregate |
| Acceptance rate | Display | — | % | |
| Average response time | Display | — | Request publish → Offer submit | |
| Avg offered vs accepted (when lost) | Display | — | aggregated only | No peer identity (`BR-008`) |
| History list rows | Display | — | terminal Offers | |
| Export CSV | Action | — | — | Own records |

## Validation & rules

- Comparative figures aggregated only.

## Empty / error / edge states

- No terminal Offers in period.

## Related screens

VEN-S11
