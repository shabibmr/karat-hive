# VEN-S16 · Served Regions, business hours

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-025`, [`adr/0014`](../../docs/adr/0014-remove-category-taxonomy-entity.md) |

## Purpose

Declare the Regions the Vendor serves (their default feed filter), plus availability. Regions never gate matching or activation. There is no Category picker. (The file name keeps the old "categories" wording so links stay stable.)

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Vendor profile / settings |
| Exit | Save |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Served Regions | Input | Yes | multi ≥1 | Default Region filter on VEN-S06 |
| Business hours | Input | No | per weekday open/close | |
| Away mode | Input | No | boolean | Suspends new-request notifications |
| Save | Action | — | — | Takes effect immediately |

## Validation & rules

- At least one Region when saving.
- Away mode ≠ account deactivation.
- Matching depends on VERIFIED + ACTIVE + Type Subscription only (`BR-002`).

## Empty / error / edge states

- No Region selected: save blocked.

## Related screens

VEN-S15 · VEN-S05 · VEN-S06
