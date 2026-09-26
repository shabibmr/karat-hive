# CUS-S22 · Report abuse

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-033` |

## Purpose

Report an Offer, Vendor, or Connection for abuse; feeds Admin abuse queue.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Offer detail; Connection detail |
| Exit | Acknowledgement; back |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Reported entity type | Input | Yes | Offer / Vendor / Connection | Context may pre-fill |
| Linked entity id / summary | Display | — | — | |
| Category | Input | Yes | fraudulent offer / abusive behaviour / off-platform solicitation / misleading terms / other | |
| Free text | Input | Yes | text | Details |
| Submit | Action | — | — | → Admin queue |
| Acknowledgement | Display | — | — | Reporter notified of receipt |

## Validation & rules

- Max 5 reports per Customer per 24 hours.
- Reported party not told reporter identity.

## Empty / error / edge states

- Rate limit exceeded.

## Related screens

CUS-S13 · CUS-S15
