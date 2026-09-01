# CUS-S07 · Create Request — Gold Bullion

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-012`, `FR-CUS-013`, `FR-CUS-007`, `FR-CUS-018` |

## Purpose

Compose a buy or sell Request for gold bullion bars, enforcing the AED 500 minimum indicative value.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | CUS-S03 type = Gold Bullion |
| Exit | CUS-S08; CUS-S09 |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Request type | Display | — | Gold Bullion | Locked |
| Direction | Input | Yes | BUY / SELL | |
| Category | Input | Yes | taxonomy | |
| Region | Input | Yes | taxonomy | |
| Bar weight (g) | Input | Yes | decimal | |
| Quantity | Input | Yes | positive integer | |
| Total weight | System | — | bar × qty | |
| Purity | Input | Yes | default 999 / 24K; editable | |
| Refiner / brand | Input | No | string | |
| Serial / assay certificate present | Input | No | boolean | |
| Budget (BUY) | Input | No | AED range | Optional |
| Notes | Input | No | free text | |
| Images | Input | Conditional | 1–5 | Optional BUY; **mandatory SELL** |
| Reference gold rate | Display / System | — | AED/g | **Required** for min-value check |
| Indicative value | System | — | total weight × rate | Compared to floor |
| Minimum value threshold | Display | — | default AED 500 | Platform setting |
| Save draft | Action | — | — | |
| Continue to review | Action | — | — | Blocked if value &lt; floor |

## Validation & rules

- Indicative value ≥ platform bullion minimum (default AED 500) or publish refused (`BR-010`).
- Enforced server-side.
- If no rate available: ask Customer to retry shortly (cannot evaluate floor).

## Empty / error / edge states

- Below-minimum message shows threshold + computed value.
- Stale rate: visual stale marker.

## Related screens

CUS-S08 · CUS-S09
