# VEN-S18 · Settings

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-027` |

## Purpose

App preferences, security credentials/sessions, legal links.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Nav Settings |
| Exit | Preferences applied |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Language | Input | Yes | en / ar | RTL for ar |
| Notification prefs by category | Input | No | toggles | |
| Notification channel prefs | Input | No | push / email | |
| Quiet hours | Input | No | time window | |
| Default filter preset (Requests) | Input | No | named preset | From VEN-S07 |
| Set / change email password | Input | No | password | Credential for email login |
| Active sessions list | Display | — | device/session | |
| Revoke session | Action | — | — | Per session |
| Vendor agreement link | Action | — | — | |
| Privacy Policy link | Action | — | — | |
| Support contact | Action | — | — | |
| App version | Display | — | string | |
| Logout | Action | — | — | |

## Validation & rules

- Notification prefs honoured by dispatch (with quiet hours).

## Empty / error / edge states

- No extra sessions.

## Related screens

VEN-S07 · VEN-S17
