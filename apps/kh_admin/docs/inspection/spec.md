# Admin Flutter — Spec axis

| | |
|---|---|
| **Axis** | Does `apps/kh_admin` implement what the originating specs asked for? |
| **IDs** | `ADM-INS-30`–`48` |
| **Register** | [`REGISTER.md`](REGISTER.md) |
| **HEAD** | `8880298` · 8 September 2026 |

Quote the spec, then the code. Do not rerank against [`standards.md`](standards.md). Overlapping facts keep their Standards ID (see §4).

**Not a miss:** ADM-S20 gold-rate. Completion plan §2 and withdrawn `SAM-GAP-11` defer it.

---

## 1. Spec asked for — missing or partial

### ADM-INS-30 · idle timeout

`FR-ADM-001` AC4 / Architecture-Frontend §16.4: sessions expire after 60 minutes of inactivity, with a warning. `session_controller.dart` has token restore, Google session exchange, and 401 refresh. No idle timer, no warning dialog.

### ADM-INS-31 · 2FA — SRS vs `adr/0010` (**conflict**, not a Flutter miss)

`FR-ADM-001` AC1 still says mandatory TOTP/SMS. `login_screen.dart` has `TODO ADM-S01 2FA`. `docs/adr/0010-google-signin-only-login.md` later rejects platform 2FA. Treat as SRS rewrite debt until the SRS is version-bumped.

### ADM-INS-32 · dashboard FR-ADM-003–009

| Requirement | Code |
|---|---|
| `FR-ADM-003` AC3 date-range (today / 7 / 30 / 90 / custom) | Absent on `dashboard_screen.dart` |
| `FR-ADM-003` AC4 drill-down with the same filter pre-applied | `context.go(metric.route)` with no query |
| `FR-ADM-004`–`008` trends / type-direction breakdowns | `dashboard_stats.dart` is six totals |
| `FR-ADM-009` figures consistent with Reports | No shared period |

### ADM-INS-33 · list URL addressability

Architecture-Frontend §16.3: filters, sort, page cursor, and selected id live in the URL.

| Wired | Missing |
|---|---|
| vendors, requests, offers, verification (`selectedId`), taxonomy | customers, connections, audit, abuse, moderation, admin-users, reports, settings, announcements |

Helpers: `lib/core/router/{vendor,request,offer,verification,taxonomy}_query_params.dart`. Cursor and sort are never encoded even on the wired lists. `ADM-C-12` covered only three lists.

### ADM-INS-34 · list filters thinner than SRS

| Spec | Actual |
|---|---|
| `FR-ADM-010` AC2 region / date / activity | `CustomerListFilters`: `q` + account state |
| `FR-ADM-013` AC2 region / category / date | `VendorListFilters`: `q` + verification + account |
| `FR-ADM-017` AC2 category / region / value / date | Request bar: type / direction / state / zero-offers. `categoryId` / `regionId` never applied, even client-side |

### ADM-INS-35 · queue interaction

Verification is list-detail-within-context (split pane). ADM-S16 moderation and ADM-S21 abuse are table + dialogs.

### ADM-INS-36 · in-app find and keyboard conventions

Architecture-Frontend §16.4 / §15.2: canvas kills Ctrl+F — in-app find on every list; Esc/Enter/row focus as portal convention. Not implemented.

### ADM-INS-37 · no deferred imports

Architecture-Frontend §16.2 / §17.4: reports, audit, announcements load on demand. `app_router.dart` imports every screen eagerly (`fl_chart` on first paint of login).

### ADM-INS-38 · abuse actions incomplete

`FR-ADM-032` AC3: dismiss, warn, suspend, or deactivate. `abuse_screen.dart`: resolve / dismiss only.

### ADM-INS-39 · no request list screen test

Architecture-Frontend §20. Most lists have `*_screen_test.dart`. No `test/features/requests/request_list_screen_test.dart`.

### ADM-INS-40 · PII list-access not logged

`FR-ADM-010` AC5: access to the list is logged. `customer_list_screen.dart` shows a banner. No API call that records list access.

---

## 2. Behaviour not asked for

### ADM-INS-41 · unused FirestoreService

`lib/core/firebase/firestore_service.dart` is never consumed. `C-12` / `AD-FE-09`: Postgres is the system of record.

### ADM-INS-42 · Analytics + Messaging unused as AD-FE-10

Pulled in `pubspec.yaml` and initialised from `main.dart`. Messaging does not `ref.invalidate`. Analytics observer is not on `MaterialApp.router`.

### ADM-INS-43 · `SYSTEM OPERATIONAL` chip

Not in `FR-ADM-003`. `dashboard_screen.dart`.

### ADM-INS-44 · invented audit picklists

`audit_screen.dart` action/entity enumerations are not an SRS list (`FR-ADM-033`).

### ADM-INS-45 · default seed password in source

`dev_auth.dart` default `AdminSecret123!`. Compile-time define is off by default (good); the secret is still in the tree.

---

## 3. Looks implemented — behaviour is wrong or stale

### ADM-INS-46 · client-side filter of one page

`ADM-FE-P02` allowed page-local filters while backend filters were thin. Repos still **omit** sending `requestType` / ranges / `categoryId` (`request_repository.dart`, `offer_repository.dart`, and connections/abuse/audit/moderation/announcements). `hasMore` follows the **unfiltered** cursor. `ADM-C-71` accept criterion was that Flutter can stop this.

### ADM-INS-47 · Request match set empty vs missing

`FR-ADM-018`: match set inspectable. `request_detail.dart` still has `TODO(backend)` and defaults `matchedVendors` / `timeline` to `[]`. Empty and “backend omitted the include” are indistinguishable. `ADM-C-72`.

### ADM-INS-48 · KYC document open unauthenticated

Completion plan §4 / `ADM-C-74`: `/v1/media/<key>` cannot attach Bearer in a new tab. `verification_detail_pane.dart` still opens a relative media path.

---

## 4. Same facts, Standards IDs (do not duplicate)

| Spec concern | ID |
|---|---|
| Web access-token persistence | **ADM-INS-09** |
| List freshness 30 s | **ADM-INS-08** |
| Device clock for ages | **ADM-INS-07** |
| LTR/RTL goldens | **ADM-INS-01** |

---

## 5. Implemented as specified (no ID)

- ADM-S23 no Role selector — `SAM-GAP-13` / `AD-API-03`.
- ADM-S18 EN+AR form present. `SAM-GAP-10` (pre-send audience count) remains a backend gap.
- ADM-S20 deferred.

---

## 6. Counts

19 spec IDs (`ADM-INS-30`–`48`). Worst miss: **ADM-INS-32**, **ADM-INS-33**. Worst wrong implementation: **ADM-INS-46**.
