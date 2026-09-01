# CUS-S18 · Leave review

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-029`, `FR-CUS-030` |

## Purpose

Rate and optionally comment on a Vendor for a Connection; held for Admin approval before display.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Close Connection prompt; 7-day reminder; CUS-S15 |
| Exit | Back to Connection; confirmation pending moderation |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Connection / Vendor context | Display | — | revealed name | Only party to Connection |
| Star rating | Input | Yes | 1–5 | |
| Comment | Input | No | text ≤ 1000 chars | |
| Submit | Action | — | — | → PENDING_MODERATION |
| Edit own review | Action | Conditional | within 14 days | Re-enters moderation |
| Withdraw review | Action | Conditional | — | Removes from public / aggregate |

## Validation & rules

- One review per Connection per party (`BR-017`).
- Only against Connection counterparty (`BR-016`).
- Never shows Customer mobile on reviews.
- Not visible to Vendor until Admin approves.

## Empty / error / edge states

- Already reviewed; edit window closed.

## Related screens

CUS-S15 · CUS-S16
