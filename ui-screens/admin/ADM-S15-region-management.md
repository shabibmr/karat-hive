# ADM-S15 · Region management

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-025`, `BR-019` |

## Purpose

Manage geographic matching taxonomy (emirate → area).

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Config nav |
| Exit | Save |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Region tree | Display | — | emirate → area | |
| Name (English) | Input | Yes | string | |
| Name (Arabic) | Input | Yes | string | |
| Active flag | Input | Yes | boolean | |
| Create | Action | — | — | |
| Rename | Action | — | — | |
| Activate / Deactivate | Action | — | — | |
| Delete | Action | Conditional | — | Blocked if in use |

## Validation & rules

- Matching uses Regions; taxonomy changes apply to Requests published thereafter.

## Empty / error / edge states

- In-use delete blocked.

## Related screens

ADM-S14
