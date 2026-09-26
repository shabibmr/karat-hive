# CUS-S20 · Profile

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-003` |

## Purpose

View and edit Customer profile attributes and account meta.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Nav Profile |
| Exit | Save; CUS-S21 |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Display name | Input | Yes | string ≤ 100 | |
| Email | Input | No | email | Verify via confirmation link if set |
| Profile photo | Input | No | image URL | |
| Preferred language | Input | Yes | en / ar | RTL for ar |
| Default Region | Input | No | Region FK | |
| Mobile number | Input | Yes | E.164 | Change requires OTP on **new** number |
| OTP for new mobile | Input | Conditional | OTP | On mobile change |
| Account created at | Display | — | datetime | |
| Lifetime Request count | Display | — | integer | |
| Save | Action | — | — | Persist immediately |

## Validation & rules

- Profile changes do not unmask identity on already-published Requests.
- Email syntax validation.

## Empty / error / edge states

- Invalid email; OTP failure on mobile change.

## Related screens

CUS-S21 · CUS-S01
