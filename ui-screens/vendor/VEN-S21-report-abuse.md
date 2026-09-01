# VEN-S21 · Report abuse

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-030` |

## Purpose

Report a Request or Customer for abuse/fraud/time-wasting.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Request detail; Connection |
| Exit | Acknowledgement |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Reported entity | Display / Input | Yes | Request / Customer | Context pre-fill |
| Category | Input | Yes | fraudulent request / abusive behaviour / unrealistic expectations / suspected non-genuine item / other | |
| Free text | Input | Yes | text | |
| Submit | Action | — | — | Admin queue |
| Acknowledgement | Display | — | — | |

## Validation & rules

- Customer not told who reported them.
- 3 distinct Vendor reports on a Request → auto-flag priority Admin review.

## Empty / error / edge states

- Rate limits if any (Customer side has 5/24h; Vendor not specified — treat fairly).

## Related screens

VEN-S08 · VEN-S13
