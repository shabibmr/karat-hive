# CUS-S04 · Create Request — Find An Ornament

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-006`, `FR-CUS-007`, `FR-CUS-008`, `FR-CUS-009`, `FR-CUS-018` |

## Purpose

Compose a `BUY` Request for a jewellery piece Vendors can source or match.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | CUS-S03 type = Find An Ornament |
| Exit | CUS-S08 images; CUS-S09 review & publish |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Request type | Display | — | Find An Ornament | Locked |
| Direction | Display | — | BUY | Fixed; not editable |
| Category | Input | Yes | taxonomy pick | Matching |
| Region | Input | Yes | taxonomy pick | Default from profile optional |
| Ornament type | Input | Yes | ring, chain, bangle, necklace, earring, bracelet, pendant, other | |
| Weight (g) | Input | Conditional | decimal 0.10–5000.00, 2 dp | Spec capture |
| Weight is approximate | Input | No | boolean | Surfaced to Vendors |
| Purity | Input | Conditional | 24K, 22K, 21K, 18K | Configured karat list |
| Reference gold rate (selected purity) | Display / System | — | AED/g + updated_at | Indicative; stale marking |
| Gemstone presence | Input | No | boolean / flag | |
| Gemstone type | Input | No | string / enum | If presence |
| Gemstone count | Input | No | integer | If presence |
| Budget mode | Input | Yes | max only · min–max range | Mandatory for this type |
| Budget max (AED) | Input | Yes | decimal | |
| Budget min (AED) | Input | Conditional | decimal | If range; must be &lt; max |
| Budget flexible | Input | No | boolean | Offers outside range still considered |
| Notes | Input | No | free text | Contact-detail scan warning |
| Images (1–5) | Input / Action | Yes | via CUS-S08 | ≥1 mandatory |
| Save draft | Action | — | — | No mandatory validation |
| Continue to review | Action | — | — | → CUS-S09 |

## Validation & rules

- Inline errors per field; publish blocked until clear.
- At least one reference image mandatory.
- Notes scanned for phone/email (policy circumvention).

## Empty / error / edge states

- Rate unavailable: suppress indicative valuation; create not blocked for ornament.

## Related screens

CUS-S08 · CUS-S09 · CUS-S03
