# ADM-S01 · Login with 2FA

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-001`, `NFR-012` |

## Purpose

Authenticate Admins with email/password and mandatory 2FA; short idle session.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Portal URL |
| Exit | ADM-S02 Dashboard |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Email | Input | Yes | email | |
| Password | Input | Yes | secret | Policy NFR-012 |
| TOTP / SMS 2FA code | Input | Yes | OTP | Mandatory |
| Login | Action | — | — | |
| Lockout message | Display | Conditional | — | 3 fails → 30 min + security alert |

## Validation & rules

- Session idle: 60 minutes.
- All login attempts audit-logged (IP, UA).

## Empty / error / edge states

- Invalid credentials; 2FA fail; lockout.

## Related screens

ADM-S02 · ADM-S22
