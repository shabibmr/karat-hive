# CUS-S16 · Connections list

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-027` |

## Purpose

List active and past Connections so the Customer can return to Talk and history.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Nav; post-accept |
| Exit | CUS-S15 detail |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Section: Active | Display | — | list | First |
| Section: Closed | Display | — | list | Read-only entries |
| Vendor revealed identity (summary) | Display | — | business name | |
| Request reference | Display | — | string | |
| Accepted Offer terms summary | Display | — | price | |
| Connection date | Display | — | datetime | |
| Talk (active) | Action | — | — | Shortcut |
| Open detail | Action | — | — | → CUS-S15 |
| Empty state | Display | — | — | No connections yet |

## Validation & rules

- Closed Connections permanently accessible read-only.

## Empty / error / edge states

- Empty list with explanation.

## Related screens

CUS-S15 · CUS-S18
