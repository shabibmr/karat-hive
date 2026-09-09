# Admin Flutter — Efficiency gaps

| | |
|---|---|
| **Inventory** | Rebuilds, lists, filters, bundle, time |
| **IDs** | `ADM-INS-70`–`73` (net-new) |
| **Register** | [`REGISTER.md`](REGISTER.md) |
| **HEAD** | `8880298` · 8 September 2026 |

Architecture-Frontend §16–§17 is the bar: canvas web, deferred rarely used areas, virtualised tables, measured first-load budget.

---

## 1. Net-new efficiency findings

### ADM-INS-70 · nested `SingleChildScrollView` around the table

List screens wrap `KhDataTable` in a vertical `SingleChildScrollView` (`customer_list_screen.dart` and twins). Combined with **ADM-INS-13** (`for` every row), every cell widget is in the tree. Architecture §17.3 wants lazy lists with fixed extents.

### ADM-INS-71 · export poll 400 ms

`reports_repository.dart` `pollInterval = Duration(milliseconds: 400)`. Aggressive for a job that may take seconds.

### ADM-INS-72 · no bounded image decode

KYC / vendor documents open via URL. No `cacheWidth` / `cacheHeight`. Harmless while there are few in-app thumbnails; required when signed URLs land (**ADM-INS-48**).

### ADM-INS-73 · `ref.watch` of whole list state

Filter-chip tweaks rebuild the table. No `provider.select((s) => s.items)` vs `filters`. God `build()` methods (**ADM-INS-22**) amplify this. `MediaQuery.of` on the shell is **ADM-INS-17**.

---

## 2. Already numbered

| Topic | ID |
|---|---|
| `KhDataTable` not virtualised | **ADM-INS-13** |
| Client-side page filter + unfiltered cursor | **ADM-INS-46** |
| No `deferred as` / eager `fl_chart` | **ADM-INS-37** |
| Unused Firestore / Messaging / Analytics weight | **ADM-INS-41**, **ADM-INS-42** |
| `MediaQuery.of` | **ADM-INS-17** |
| No 30 s list poll | **ADM-INS-08** |
| `DateTime.now()` fallbacks | **ADM-INS-07** |
| Hardcoded colours blocking `const` | **ADM-INS-18** |
| First-load budget not in CI | **ADM-INS-84** |

---

## 3. Counts

4 net-new (`ADM-INS-70`–`73`). Worst: **ADM-INS-70** with **ADM-INS-13**.
