# CUS-S17 · History

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-028` |

## Purpose

Read-only history of terminal Requests, Offers received, and outcomes.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Nav History |
| Exit | Historical Request / Offer / Connection views |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Request list (terminal) | Display | — | ACCEPTED, CLOSED, EXPIRED, CANCELLED | |
| Outcome per Request | Display | — | label | |
| Filter — Request type | Filter / Sort | No | enum | |
| Filter — direction | Filter / Sort | No | BUY / SELL | |
| Filter — date range | Filter / Sort | No | from–to | |
| Filter — outcome | Filter / Sort | No | states | |
| Search — Request reference | Filter / Sort | No | string | |
| Open historical Request | Action | — | — | Offers + accepted + Connection |
| Pagination | System | — | — | Performant at 500+ |

## Validation & rules

- Fully read-only; no edit/delete by Customer.

## Empty / error / edge states

- No history yet.

## Related screens

CUS-S10 (historical) · CUS-S15
