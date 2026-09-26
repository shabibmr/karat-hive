# ADM-S22 · Audit log viewer

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-033`, `FR-SYS-011` |

## Purpose

Search immutable audit trail of security and administrative actions.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Compliance nav |
| Exit | Entry detail |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Filter: acting user | Filter / Sort | No | Admin/User | |
| Filter: action type | Filter / Sort | No | enum | |
| Filter: target entity | Filter / Sort | No | type + id | |
| Filter: date range | Filter / Sort | No | — | |
| Filter: source IP | Filter / Sort | No | — | |
| Entry: actor | Display | — | — | |
| Entry: action | Display | — | — | |
| Entry: target | Display | — | — | |
| Entry: before/after | Display | Conditional | — | Where applicable |
| Entry: IP / user agent | Display | — | — | |
| Entry: UTC timestamp | Display | — | — | |
| Edit/delete controls | — | — | **none** | Immutable even for Super Admin |

## Validation & rules

- Viewing audit log is itself audited.
- Retention ≥ 24 months (`NFR-021`).

## Empty / error / edge states

- No matches.

## Related screens

ADM-S01 (login events) · all mutating Admin screens
