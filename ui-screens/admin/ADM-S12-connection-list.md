# ADM-S12 · Connection list

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-022` |

## Purpose

Browse Connections (default active); flag failed introductions (no Talk).

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Nav; dashboard |
| Exit | ADM-S13 |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Column: Customer | Display | — | unmasked | |
| Column: Vendor | Display | — | unmasked | |
| Column: Request reference | Display | — | — | |
| Column: agreed price | Display | — | AED | |
| Column: connection date | Display | — | — | |
| Column: Talk usage | Display | — | yes/no / count | CONTACT_EVENT |
| Column: state | Display | — | ACTIVE / CLOSED | |
| Filters: state, date range, Region, Category, no contact initiated | Filter / Sort | No | — | Default active |
| Flag: no Talk after 48 h | Display | Conditional | — | Failed introduction signal |
| Open detail | Action | — | — | → ADM-S13 |

## Validation & rules

— 

## Empty / error / edge states

- No Connections.

## Related screens

ADM-S13
