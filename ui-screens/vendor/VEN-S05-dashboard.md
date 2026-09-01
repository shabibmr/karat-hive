# VEN-S05 · Dashboard

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-004`, `FR-VEN-005`, `FR-VEN-006`, `FR-VEN-007`, `FR-VEN-031` |

## Purpose

ACTIVE landing: business snapshot and action counts (new Requests, pending Offers, active Connections).

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Login ACTIVE; tab Home |
| Exit | VEN-S06 / S11 / S12; subscription |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| New Requests count | Display | — | integer | Matched, unviewed, no Offer yet |
| New Requests preview (≤3) | Display | — | type, weight/qty, budget, Region, age | |
| Open New Requests | Action | — | — | → VEN-S06 |
| Pending Offers count | Display | — | integer | PENDING only |
| Expiring soon flag | Display | Conditional | within 24 h | On pending panel |
| Open Pending Offers | Action | — | — | → VEN-S11 Pending |
| Active Connections count | Display | — | integer | ACTIVE Connections |
| No Talk yet flag | Display | Conditional | — | Follow-up cue |
| Open Connections | Action | — | — | → VEN-S12 |
| Reference gold rate per karat | Display / System | — | AED/g + timestamp | Indicative |
| Vendor aggregate rating | Display | — | 1 decimal | Own |
| Type subscription summary | Display | — | active entitlements + renewals | → VEN-S22 |
| Pull-to-refresh | Action | — | — | ≤30 s server lag |

## Validation & rules

- Counts refresh on focus and pull-to-refresh.
- Only ACTIVE Vendors see this screen.

## Empty / error / edge states

- Zero counts with empty guidance.

## Related screens

VEN-S06 · VEN-S11 · VEN-S12 · VEN-S22
