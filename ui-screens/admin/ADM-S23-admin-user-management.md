# ADM-S23 · Admin user management

| | |
|---|---|
| **User** | Platform Admin (Super Admin) |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-002` |

## Purpose

Provision Admin accounts with roles; suspend/revoke. No self-registration.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Super Admin only nav |
| Exit | Created/suspended Admin |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Admin list | Display | — | name, email, role, state | |
| Email | Input | Yes | email | Create |
| Name | Input | Yes | string | |
| Role | Input | Yes | Super Admin · Operations Admin · Read-only Analyst | |
| Temporary password / invite | System | — | — | Implementation detail |
| Create Admin | Action | Super only | — | No self-register path anywhere |
| Suspend Admin | Action | Super only | — | |
| Revoke Admin | Action | Super only | — | Audit trail of past actions retained |
| Role description | Display | — | permissions summary | Analyst: no mutations |

## Validation & rules

- Shared accounts prohibited by policy.
- Mutating actions always attributed to named Admin.
- Cannot delete audit trail of past actions.

## Empty / error / edge states

- Duplicate email; last Super Admin protection (recommended).

## Related screens

ADM-S01 · ADM-S22
