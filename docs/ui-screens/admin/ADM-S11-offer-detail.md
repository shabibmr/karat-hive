# ADM-S11 · Offer detail

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-021` |

## Purpose

Full Offer terms, revisions, state history; read-only commercial terms.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | ADM-S10; Request detail |
| Exit | Parent Request; winning Offer link |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| All Offer terms | Display | — | price, charges, rate/g, delivery, warranty, note | |
| Attached images | Display | — | — | |
| Revision history | Display | — | snapshots | |
| State-transition history | Display | — | — | |
| Parent Request | Display / Action | — | link | |
| Winning Offer link | Display | Conditional | Admin-only | If rejected due to competitor accept |
| Internal note | Input | No | text | Cannot modify commercial terms |

## Validation & rules

- Read-only for price/terms.

## Empty / error / edge states

— 

## Related screens

ADM-S10 · ADM-S09
