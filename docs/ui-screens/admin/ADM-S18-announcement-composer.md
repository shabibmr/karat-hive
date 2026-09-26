# ADM-S18 · Announcement composer

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-029` |

## Purpose

Compose, target, schedule, and measure platform announcements.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Nav Announcements |
| Exit | Sent / scheduled list |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Audience: user type | Input | Yes | Customer / Vendor / both | |
| Audience: account state | Input | No | multi | |
| Audience: Region | Input | No | multi | |
| Audience: Category | Input | No | multi | Vendors primarily |
| Channel: in-app | Input | No | boolean | |
| Channel: push | Input | No | boolean | |
| Channel: email | Input | No | boolean | |
| Title/body English | Input | Yes | text | |
| Title/body Arabic | Input | Yes | text | Delivered by preferred language |
| Critical flag | Input | No | boolean | Overrides user notification prefs |
| Schedule datetime | Input | No | UTC/GST | Optional future send |
| Send now | Action | — | — | |
| Cancel scheduled | Action | Conditional | before dispatch | |
| Delivery stats | Display | — | sent / delivered / opened | Per announcement |

## Validation & rules

- At least one channel selected (assumed).
- Critical: service outage / policy change class.

## Empty / error / edge states

- Zero audience; cancel after start of dispatch.

## Related screens

ADM-S02
