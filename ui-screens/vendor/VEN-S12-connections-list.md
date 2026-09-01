# VEN-S12 · Connections list

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-020` |

## Purpose

List Connections from accepted Offers; active first, then closed.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Dashboard Connections panel; nav |
| Exit | VEN-S13 detail |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Section Active / Closed | Display | — | — | Active first |
| Customer (revealed summary) | Display | — | name | |
| Request reference | Display | — | string | |
| Agreed Offer terms | Display | — | price | |
| Connection date | Display | — | datetime | |
| Talk | Action | Conditional | ACTIVE | Shortcut |
| Open detail | Action | — | — | → VEN-S13 |
| Empty state | Display | — | — | |

## Validation & rules

- Close Connection available on detail; prompts feedback.

## Empty / error / edge states

- No Connections yet.

## Related screens

VEN-S13 · VEN-S19
