# VEN-S16 · Categories, Regions, business hours

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-025` |

## Purpose

Declare Categories and Regions that drive matching; optional hours and away mode.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Onboarding to ACTIVE; settings/profile |
| Exit | Save; volume estimate |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Service Categories | Input | Yes | multi ≥1 | Cannot ACTIVE without |
| Served Regions | Input | Yes | multi ≥1 | Cannot ACTIVE without |
| Business hours | Input | No | per weekday open/close | |
| Away mode | Input | No | boolean | Suspends new-request notifications |
| Matched-Request volume estimate | System | — | estimate | Based on current selection |
| Save | Action | — | — | Applies to Requests published after change |

## Validation & rules

- Changes do not retroactively alter existing matches.
- Away mode ≠ account deactivation.

## Empty / error / edge states

- Zero categories/regions selected: cannot activate.

## Related screens

VEN-S03 · VEN-S15 · VEN-S05
