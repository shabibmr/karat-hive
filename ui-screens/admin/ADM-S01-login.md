# ADM-S01 · Login — Google Sign-In

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-001`, `FR-ADM-002`, `NFR-012`, [`adr/0010`](../../docs/adr/0010-google-signin-only-login.md) |

## Purpose

Authenticate Admins with Google Sign-In; short idle session. Only an Admin account already provisioned by another Admin (ADM-S23) can sign in.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Portal URL; idle timeout; logout |
| Exit | ADM-S02 Dashboard, or the deep link the Admin was sent away from |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Sign in with Google | Action | — | Google provider | Only login (`adr/0010`). No email/password, no 2FA |
| Not-an-Admin message | Display | Conditional | — | Google account has no provisioned Admin row |

## Validation & rules

- The Google account's email must match a provisioned Admin. Signing in never creates an Admin.
- Session idle: 60 minutes.
- All login attempts audit-logged (IP, UA).

## Empty / error / edge states

- Google sign-in cancelled; Google account not an Admin (`401 UNAUTHENTICATED`); Admin suspended or revoked.

## Related screens

ADM-S02 · ADM-S22 · ADM-S23
