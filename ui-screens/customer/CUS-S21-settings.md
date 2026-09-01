# CUS-S21 · Settings

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-034`, `FR-CUS-004` |

## Purpose

Application preferences, legal links, account deactivation/deletion.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Nav Settings |
| Exit | Preference applied; logout; account closed |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Language | Input | Yes | English / Arabic | Immediate + RTL |
| Notification category toggles | Input | No | per category | Security-critical **cannot** disable |
| Default Region | Input | No | Region | May overlap profile |
| Terms of Service link | Action | — | — | |
| Privacy Policy link | Action | — | — | |
| Support contact | Action | — | — | |
| App version | Display | — | string | |
| Biometric unlock | Input | No | on/off | |
| Logout | Action | — | — | |
| Deactivate account | Action | — | confirm | Closes PUBLISHED Requests; blocks login |
| Request permanent deletion | Action | — | two-step confirm | Refused if Connection in last 30 days |

## Validation & rules

- Deletion anonymises PII within 30 days; analytics retain anonymised Requests/Offers.
- Reviews of deleted users → “Deleted user”.

## Empty / error / edge states

- Deletion blocked by recent Connection.

## Related screens

CUS-S20 · CUS-S01
