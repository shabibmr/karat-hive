# VEN-S20 · My reviews & responses

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-029` |

## Purpose

View published reviews about this Vendor; respond once; flag unfair reviews.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Profile / ratings entry |
| Exit | Response pending moderation |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Aggregate rating | Display | — | 1 decimal | |
| Review count | Display | — | integer | |
| Star distribution | Display | — | bars | |
| Rating trend (6 months) | Display | — | chart | |
| Review list (published) | Display | — | author abbreviated, text, stars | |
| Public response | Input | No | ≤ 500 chars; one per review | Hold-for-approval |
| Submit response | Action | — | — | |
| Flag as unfair | Action | — | on published review | Re-enters Admin queue; stays visible until Admin acts |

## Validation & rules

- Responses moderated like reviews (`FR-ADM-026`).

## Empty / error / edge states

- No reviews yet; limited history.

## Related screens

VEN-S15
