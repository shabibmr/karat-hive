# CUS-S03 · Request type selection

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-005` |

## Purpose

The premier visual frontage of Karat Hive. A luxury digital salon facade presenting the 4 marketplace trading avenues with Art Deco metallic cards, direction indicators, and trust signals.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | CUS-S23 service card; Home quick-create; create nav |
| Exit | CUS-S04 / S05 / S06 / S07 by type |
| Guest | Allowed. No login until CUS-S09 Publish (`adr/0011`) |

## Fields & Visual Elements

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Salon Hero Header | Display | — | Eyebrow + title + subhead | Art Deco diamond badge + luxury editorial copy |
| Request type cards | Input | Yes | 4 bespoke cards | Bespoke Art Deco icon frames, dual borders, gradient background |
| Direction / Category pill | Display | — | BUY · BESPOKE / SELL · INSTANT / etc. | Clear direction badge on each card |
| Highlights chips | Display | — | Feature tags | e.g. [Custom Designs], [24K / 999.9], [Sealed Packs] |
| Type description | Display | — | Refined copy per type | Detailed purpose and scope |
| Trust assurance footer | Display | — | Shield badge row | 100% Identity Masking · 48h Window · Verified UAE Jewellers |
| Continue / Card tap | Action | — | — | Selects type and opens type-specific flow |

## Validation & rules

- Changing type **before** publish resets type-specific fields.
- Type immutable after publication (`BR-014`).

## Empty / error / edge states

- Concurrent published limit reached: block create with explanation.

## Related screens

CUS-S04 · CUS-S05 · CUS-S06 · CUS-S07
