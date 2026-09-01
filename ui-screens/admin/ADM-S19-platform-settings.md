# ADM-S19 · Platform settings

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-030`, `BR-020` |

## Purpose

Configure operational parameters without deploy; non-retroactive changes.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Config nav (Super Admin for commercial impact) |
| Exit | Confirm change; audit |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Gold Bullion minimum value (AED) | Input | Yes | decimal | Default 500 |
| Offer validity options | Input | Yes | set of hours | **Align with FR vs entity tension** |
| Default Offer validity | Input | Yes | from options | Default 24 h in FR |
| Request hard-expiry duration | Input | Yes | hours | Default 48 h |
| Max concurrent PUBLISHED Requests / Customer | Input | Yes | integer | Default 10 |
| Supported karat purities | Input | Yes | list | 24/22/21/18K default |
| Image max count | Input | Yes | integer | Default 5 |
| Image max size | Input | Yes | MB | Default 10 |
| Subscription product per Request type | Input | Yes | price, period, grace | Four products |
| Review moderation mode | Display | — | hold-for-approval | Fixed; not toggle |
| Current value / permitted range / effect copy | Display | — | per setting | |
| Super Admin confirmation | Action | Conditional | commercial impact | |
| Save change | Action | — | — | Audit: before/after, Admin, time |

## Validation & rules

- Changes apply only to entities created after change (`BR-020`).
- Every change audit-logged.

### SRS tension

Document resolved Offer validity option-set here once PO chooses FR-VEN-013 vs entity dictionary.

## Empty / error / edge states

- Out-of-range values blocked.

## Related screens

ADM-S20 · ADM-S22 · VEN-S09 / VEN-S22
