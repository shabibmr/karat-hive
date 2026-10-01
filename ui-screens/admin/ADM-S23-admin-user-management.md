# ADM-S23 · Admin user management

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-002`, `AD-API-03` |

## Purpose

Provision Admin accounts; suspend/revoke. No self-registration. Admin access is coarse in v1 — there are no roles (`AD-API-03`).

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Admin nav |
| Exit | Created/suspended Admin |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Admin list | Display | — | name, email, state | |
| Email | Input | Yes | email | The Google account email the new Admin will sign in with |
| Name | Input | Yes | string | |
| Create Admin | Action | — | — | No self-register path anywhere. No password is sent — the Admin signs in with Google (`adr/0010`) |
| Suspend Admin | Action | — | — | |
| Revoke Admin | Action | — | — | Audit trail of past actions retained |

## Validation & rules

- Shared accounts prohibited by policy.
- Mutating actions always attributed to named Admin.
- Cannot delete audit trail of past actions.

## Empty / error / edge states

- Duplicate email; revoking the last active Admin (`[PROPOSED]` guard).

## Related screens

ADM-S01 · ADM-S22
