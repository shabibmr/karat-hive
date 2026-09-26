# ADM-S03 · Customer list

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-010` |

## Purpose

Browse/search all Customers (personal data; access audited).

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Nav; dashboard panel |
| Exit | ADM-S04 detail |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Column: name | Display | — | — | |
| Column: mobile | Display | — | — | |
| Column: Region | Display | — | — | |
| Column: registration date | Display | — | — | |
| Column: Request count | Display | — | — | |
| Column: Connection count | Display | — | — | |
| Column: aggregate rating | Display | — | — | |
| Column: account state | Display | — | — | |
| Filter: account state | Filter / Sort | No | — | |
| Filter: Region | Filter / Sort | No | — | |
| Filter: registration date range | Filter / Sort | No | — | |
| Filter: activity level | Filter / Sort | No | — | |
| Search | Filter / Sort | No | name / mobile / email | |
| Pagination | System | — | — | 100k+ capable |
| Open detail | Action | — | — | → ADM-S04 |

## Validation & rules

- List access logged (`FR-SYS-011`).

## Empty / error / edge states

- No matches.

## Related screens

ADM-S04
