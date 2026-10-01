# CUS-S24 · My Requests

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-015`, `FR-CUS-017`, `FR-CUS-019`, `FR-CUS-028` (History entry) |

## Purpose

The Customer's live Requests and drafts. Bottom-nav tab between Home and Connections. Terminal Requests live in History (`CUS-S17`), reached from this screen's app bar.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Bottom-nav My Requests (requires login); `?tab=OPEN` or `?tab=DRAFTS` deep link |
| Exit | CUS-S10 Request detail; resume draft → its create screen; CUS-S17 History (app bar) |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Segment | Filter / Sort | — | Open · Drafts | |
| Request row | Display | — | card | Thumbnail, type, direction, reference, state |
| Offer count | Display | — | integer | Unread marker from `unreadOfferCount` |
| Expiry countdown | System | — | datetime | 48 h from publish, from server time |
| Open Request | Action | — | — | → CUS-S10 |
| Resume draft | Action | — | — | → that type's create screen |
| History | Action | — | app bar | → CUS-S17 |

## Validation & rules

- Open = `PUBLISHED` and `ACCEPTED`; Drafts = `DRAFT`.
- Max **10** concurrent `PUBLISHED` Requests (platform setting).

## Empty / error / edge states

- No open Requests: empty state with a link to Home to start one.
- No drafts: empty state.

## Related screens

CUS-S02 · CUS-S10 · CUS-S11 · CUS-S17
