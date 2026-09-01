# CUS-S06 · Create Request — Gold Coins

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-011`, `FR-CUS-007`, `FR-CUS-009`, `FR-CUS-018` |

## Purpose

Compose a buy or sell Request for gold coins with denomination, quantity, and optional mint.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | CUS-S03 type = Gold Coins |
| Exit | CUS-S08 (if images); CUS-S09 |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Request type | Display | — | Gold Coin(s) | Locked |
| Direction | Input | Yes | BUY / SELL | User-selected |
| Category | Input | Yes | taxonomy | |
| Region | Input | Yes | taxonomy | |
| Coin denomination (g) | Input | Yes | e.g. 1, 2.5, 5, 10, 20, 50, 100 | |
| Quantity | Input | Yes | positive integer | |
| Total weight | System | — | denomination × quantity | Display only |
| Purity | Input | Yes | karat list | |
| Mint / brand | Input | No | string | |
| Packaging condition | Input | No | sealed / opened | |
| Budget (BUY) | Input | No | min/max AED + flexible | Optional for non-ornament BUY |
| Notes | Input | No | free text | |
| Images | Input | Conditional | 1–5 via CUS-S08 | Optional BUY; **mandatory SELL** |
| Reference gold rate | Display / System | — | AED/g | |
| Save draft | Action | — | — | |
| Continue to review | Action | — | — | → CUS-S09 |

## Validation & rules

- Direction mandatory.
- Image rule depends on direction.

## Empty / error / edge states

- Quantity ≤ 0 blocked.

## Related screens

CUS-S08 · CUS-S09
