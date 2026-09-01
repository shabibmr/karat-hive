# CUS-S03 · Request type selection

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-005` |

## Purpose

Choose exactly one Request Type before the type-specific create flow. Type cannot change after publish.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Home quick-create; create nav |
| Exit | CUS-S04 / S05 / S06 / S07 by type |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Request type | Input | Yes | Find An Ornament · Sell Old Gold · Buy/Sell Gold Coin(s) · Buy/Sell Gold Bullion | Single select |
| Type description | Display | — | copy per type | Helps choose correctly |
| Continue | Action | — | — | Opens type-specific form |

## Validation & rules

- Changing type **before** publish resets type-specific fields.
- Type immutable after publication (`BR-014`).

## Empty / error / edge states

- Concurrent published limit reached: block create with explanation.

## Related screens

CUS-S04 · CUS-S05 · CUS-S06 · CUS-S07
