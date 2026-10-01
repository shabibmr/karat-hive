# ADM-S15 · Region management

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-025`, `BR-019` |

## Purpose

Manage the flat Region list used for display and Vendor feed filtering (`adr/0014`). Regions do not gate matching.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Config nav |
| Exit | Save |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Region list | Display | — | flat, by display order | Seeded with the seven Emirates |
| Name (English) | Input | Yes | string | |
| Name (Arabic) | Input | Yes | string | |
| Display order | Input | Yes | integer | |
| Active flag | Input | Yes | boolean | |
| Create | Action | — | — | |
| Rename | Action | — | — | |
| Activate / Deactivate | Action | — | — | Deactivate (in-use cannot be removed) |

## Validation & rules

- Regions are display and filter only; they never gate matching (`FR-SYS-002`).

## Empty / error / edge states

- In-use regions cannot be removed (deactivate only).

## Related screens

ADM-S19
