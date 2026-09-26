# VEN-S15 · Business profile

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-024`, `BR-004` |

## Purpose

View/edit business profile; flag fields that trigger re-verification.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Nav Profile |
| Exit | Save; re-verification notice |

## Fields

### Editable without re-verification

| Field / UI element | Kind | Required | Notes |
|---|---|---|---|
| Trading name | Input | Yes | |
| Business description | Input | No | |
| Logo | Input | No | |
| Shop photographs | Input | No | |
| Business hours | Input | No | Per-weekday open/close JSON |
| Contact person | Input | Yes | |
| Business email | Input | Yes | |

### Require re-verification (BR-004)

| Field / UI element | Kind | Required | Notes |
|---|---|---|---|
| Legal business name | Input | Yes | → PENDING_VERIFICATION |
| Trade licence number | Input | Yes | |
| Registered address | Input | Yes | |

### Read-only

| Field / UI element | Kind | Notes |
|---|---|---|
| Verification status / date | Display | |
| Aggregate rating | Display | |
| Total Offers submitted | Display | |
| Total Connections | Display | |
| Masked public preview | Display | What Customers see pre-acceptance |
| Save | Action | |
| Preview public card | Action | Masked representation |

## Validation & rules

- Legal identity changes return account to PENDING_VERIFICATION.

## Empty / error / edge states

- Save blocked on invalid email.

## Related screens

VEN-S16 · VEN-S03 (if re-verify)
