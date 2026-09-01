# ADM-S13 · Connection detail

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-023` |

## Purpose

Full Connection record for investigation; no WhatsApp conversation content.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | ADM-S12 |
| Exit | Close Connection admin action |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Customer (unmasked) | Display | — | full | |
| Vendor (unmasked) | Display | — | full | |
| Originating Request | Display | — | link | |
| Accepted Offer | Display | — | full terms | |
| Identity revealed at | Display | — | timestamp | |
| Contact initiation events | Display | — | time/channel | No content |
| Reviews (both parties) | Display | — | if any | |
| Linked abuse reports | Display | — | list | |
| Admin close Connection | Action | — | reason required | Notifies both parties |
| Conversation content | Display | — | **never available** | Off-platform |

## Validation & rules

- Close requires reason; audit log.

## Empty / error / edge states

- Already CLOSED.

## Related screens

ADM-S12 · ADM-S21
