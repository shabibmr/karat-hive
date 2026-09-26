# CUS-S14 · Accept confirmation

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-023`, `BR-011`, `BR-013` |

## Purpose

Explicit confirmation that accepting (UI: **Mark as Interested**) reveals identities irreversibly and rejects other Offers.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | CUS-S12 or CUS-S13 Accept |
| Exit confirm | CUS-S15 Connection detail |
| Exit cancel | Back to detail/list |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Offer summary (price, key terms) | Display | — | — | Masked Vendor still |
| Irreversibility warning | Display | — | copy | Identities will be revealed; cannot undo |
| Competing Offers outcome notice | Display | — | — | Other pending Offers will be rejected |
| Confirm Mark as Interested | Action | Yes | — | Irreversible |
| Cancel | Action | — | — | No state change |

## Validation & rules

- Only one Offer per Request may be ACCEPTED.
- Refuse if Offer expired/withdrawn since render.
- Concurrent second accept fails clearly.

## Empty / error / edge states

- Race: Offer no longer PENDING.

## Related screens

CUS-S15 · CUS-S13
