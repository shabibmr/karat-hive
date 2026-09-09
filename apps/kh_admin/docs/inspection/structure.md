# Admin Flutter — Structure gaps

| | |
|---|---|
| **Inventory** | Module layout, layering, duplication, file size |
| **IDs** | `ADM-INS-50`–`53` (net-new). Related: `05`, `06`, `11`, `20`–`23`, `33`, `41`, `42` |
| **Register** | [`REGISTER.md`](REGISTER.md) |
| **HEAD** | `8880298` · 8 September 2026 |

Feature-first layout (`lib/features/<name>/{controller,model,presentation,repository}`) matches `AD-FE-08`. The gaps are **inside** that shape.

---

## 1. Net-new structure findings

### ADM-INS-50 · uneven feature recipe

Checkpoint-1 / adapted verticals and later Group A–C screens do not share one recipe.

| Concern | Early (vendors list, requests, offers, taxonomy, verification) | Later (customers, connections, abuse, audit, moderation, settings, announcements, admin-users) |
|---|---|---|
| Models | `@freezed` + `.g.dart` (**ADM-INS-05**) | Hand `copyWith` / `==` / `fromJson` |
| List state | Freezed notifier + flags (**ADM-INS-19**, **ADM-INS-20**) | Hand class + same flags |
| URL filters | Dedicated `*_query_params.dart` (**ADM-INS-33**) | None |
| l10n | Partial ARB (**ADM-INS-02**) | Mostly hardcoded English |
| Tests | Controller + repo + screen | Same, but request **list** screen missing (**ADM-INS-39**) |

### ADM-INS-51 · router leftover map

`app_router.dart`: live `GoRoute`s, then `...kAdminNavItems.where(not already registered)` → `_GenericPlaceholderScreen`. Gold-rate is the only honest leftover. The exclusion list is a second source of truth next to `kAdminNavItems`. Nav titles are English constants (**ADM-INS-02**). Routes untyped (**ADM-INS-04**). Query-param `catch (_)` (**ADM-INS-62**).

### ADM-INS-52 · no shared Prisma-normaliser

`ADM-FE-P01` allows repos to normalise raw Prisma maps. Each repo reimplements `double.tryParse`, nested `user` / `profile`, and `DateTime.now()` fallbacks (**ADM-INS-07**). No shared admin DTO helper.

### ADM-INS-53 · outside Melos

Completion plan: `kh_admin` excluded from the Melos workspace. Fights `AD-FE-02`. Cannot import `kh_domain` / `kh_ui_domain`; reimplements tokens, chips, and party fields (**ADM-INS-06**).

---

## 2. Already numbered (cite, do not re-mint)

| Topic | ID |
|---|---|
| God presentation files (`request_detail_screen.dart` ~1444 lines, etc.) | **ADM-INS-22** |
| Empty `gold_rate/` and `auth/{controller,model,repository}/` | **ADM-INS-21** |
| No shared list kernel | **ADM-INS-20** |
| Presentation → repository | **ADM-INS-11** |
| Identity data clumps | **ADM-INS-06** |
| Unused Firestore / Analytics / Messaging | **ADM-INS-41**, **ADM-INS-42** |
| Shotgun filter recipe | **ADM-INS-23** |

---

## 3. Counts

4 net-new (`ADM-INS-50`–`53`). Worst: **ADM-INS-50**.
