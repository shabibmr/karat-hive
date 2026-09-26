# ADM-S05 · Vendor list

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-013` |

## Purpose

Browse/search Vendors with verification and performance columns.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Nav; dashboard |
| Exit | ADM-S06; ADM-S07 |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Column: business name | Display | — | trading/legal | |
| Column: trade licence number | Display | — | — | |
| Column: Region | Display | — | — | |
| Column: Categories | Display | — | — | |
| Column: verification state | Display | — | — | |
| Column: account state | Display | — | — | |
| Column: registration date | Display | — | — | |
| Column: Offer count | Display | — | — | |
| Column: acceptance rate | Display | — | — | |
| Column: aggregate rating | Display | — | — | |
| Filter: verification state | Filter / Sort | No | — | |
| Filter: account state | Filter / Sort | No | — | |
| Filter: Region / Category | Filter / Sort | No | — | |
| Filter: registration date | Filter / Sort | No | — | |
| Sort: waiting time (pending) | Filter / Sort | No | oldest first | Queue fairness |
| Search | Filter / Sort | No | name / licence / mobile | |
| Open detail | Action | — | — | → ADM-S06 |

## Validation & rules

— 

## Empty / error / edge states

- No matches.

## Related screens

ADM-S06 · ADM-S07
