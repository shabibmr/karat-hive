# CUS-S02 · Home

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-005` (entry), `FR-CUS-018` |

## Purpose

Signed-in Customer home: brand, hero, and entry into the four Request types. Not Guest Landing (`CUS-S23`), and not the Request list — that is My Requests (`CUS-S24`). Keep them different (`adr/0011`).

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Live Customer token on launch; corner Log in as Customer (no draft); bottom-nav Home |
| Exit | CUS-S04…S07 create (per tile); CUS-S19 notifications (bell) |
| Not an entry | No live token (that is CUS-S23) |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Brand mark | Display | — | — | Tracked "KARAT HIVE" wordmark |
| Notifications bell | Action | — | unread badge | → CUS-S19 |
| Hero carousel | Display | — | slides | Display type on the photograph |
| Request-type tiles | Action | — | Find An Ornament · Sell Old Gold · Buy/Sell Gold Coin(s) · Buy/Sell Gold Bullion | 2 × 2 grid; each opens that type's create screen |
| How this works | Display | — | steps | |

## Validation & rules

- Home shows no Request list and no activity summary; live Requests are on My Requests (`CUS-S24`).
- The create flow, not Home, enforces the live-Request cap from `canCreateRequest` on `GET /v1/me` (`FR-CUS-005` AC5).

## Empty / error / edge states

- Gold rates unavailable: hero and tiles still render.

## Related screens

CUS-S23 · CUS-S24 · CUS-S04…S07 · CUS-S19
