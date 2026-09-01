# CUS-S02 · Home

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-005` (entry), related open Requests |

## Purpose

Landing surface for the Customer’s live Requests and entry into create / offers / connections.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | After login; bottom-nav Home |
| Exit | CUS-S03 create; CUS-S10 request detail; CUS-S11 offers; CUS-S16 connections |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| My Requests list | Display | — | cards/rows | Active non-terminal Requests |
| Request thumbnail | Display | — | image | First media |
| Request type | Display | — | enum label | |
| Direction | Display | — | BUY / SELL | |
| State | Display | — | PUBLISHED, OFFERS_RECEIVED, … | |
| Offer count | Display | — | integer | Unread offers distinguished if available |
| Expiry countdown / hard expiry | System | — | datetime | 48 h from publish |
| Reference | Display | — | e.g. KH-RQ-… | When published |
| Quick create CTA | Action | — | — | → CUS-S03 |
| Open Request | Action | — | — | → CUS-S10 |
| View Offers (per Request) | Action | — | — | → CUS-S11 |
| Empty state — no Requests | Display | — | — | Prompt to create first Request |

## Validation & rules

- Max **10** concurrent `PUBLISHED` Requests (create may be blocked).
- Drafts may appear if draft feature is used (CUS-S09 / FR-CUS-015).

## Empty / error / edge states

- No live Requests: explanatory empty state + create CTA.

## Related screens

CUS-S03 · CUS-S10 · CUS-S11 · CUS-S17 History
