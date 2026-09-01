# CUS-S05 · Create Request — Sell Old Gold

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-010`, `FR-CUS-007`, `FR-CUS-008`, `FR-CUS-018` |

## Purpose

Compose a `SELL` Request for gold jewellery the Customer owns, soliciting purchase Offers.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | CUS-S03 type = Sell Old Gold |
| Exit | CUS-S08; CUS-S09 |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Request type | Display | — | Sell Old Gold | Locked |
| Direction | Display | — | SELL | Fixed |
| Category | Input | Yes | taxonomy | |
| Region | Input | Yes | taxonomy | |
| Ornament type | Input | Yes | same set as ornament | Spec |
| Weight (g) | Input | Yes | 0.10–5000.00 | |
| Weight is approximate | Input | No | boolean | |
| Purity | Input | Yes | 24K…18K | |
| Reference gold rate | Display / System | — | AED/g | |
| Indicative valuation | System | — | AED | weight × rate; labelled estimate, not an offer |
| Item condition | Input | No | excellent / good / fair / damaged | |
| Has original invoice / hallmark cert | Input | No | boolean | |
| Notes | Input | No | free text | |
| Images of **actual** item (1–5) | Input | Yes | via CUS-S08 | Stock/catalogue not acceptable — advised in flow |
| Save draft | Action | — | — | |
| Continue to review | Action | — | — | → CUS-S09 |

## Validation & rules

- ≥1 real-item image mandatory.
- Direction not user-editable.

## Empty / error / edge states

- Rate missing: suppress valuation display; still allow compose where possible.

## Related screens

CUS-S08 · CUS-S09
