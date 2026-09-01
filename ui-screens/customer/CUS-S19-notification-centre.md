# CUS-S19 · Notification centre

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-032` |

## Purpose

In-app list of the last 90 days of notifications with read/unread and deep links to action screens.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Bell / push open |
| Exit | Deep-linked screen (Offers, Request, review, etc.) |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Notification list | Display | — | 90 days | |
| Title / body | Display | — | — | |
| Category | Display | — | offer, expiry, revision, review reminder, announcement, security | |
| Timestamp | Display | — | datetime | |
| Read / unread | Display | — | state | |
| Mark read | Action | — | — | |
| Open deep link | Action | — | — | Target screen |
| Empty state | Display | — | — | |

## Triggers (system-generated, not form fields)

First Offer; subsequent Offers; Request expiry in **6 h**; Request expired; Offer withdrawn/revised; review reminder; platform announcement. **No** Request extension offer.

## Validation & rules

- Push categories configurable in settings except security-critical.

## Empty / error / edge states

- Empty centre.

## Related screens

CUS-S21 Settings · target action screens
