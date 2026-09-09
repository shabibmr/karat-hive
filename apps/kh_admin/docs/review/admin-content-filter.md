# Admin content filter — what is admin-specific, what is common

| | |
|---|---|
| **HEAD** | `8880298` · 8 September 2026 |
| **Status** | Analysis. **Not the plan of record.** Verified against the tree; line ranges are inclusive and correct at this HEAD. |
| **Method** | Every section of every source document classified ADMIN-ONLY / COMMON / EXCLUDED |
| **Index** | [`README.md`](README.md) · the proposal is [`carve-plan.md`](carve-plan.md) |

> Line numbers here are an artefact of *this* HEAD and will not survive an SRS version bump.
> The manifest proposed in [`carve-plan.md`](carve-plan.md) §2.2 anchors by section number
> and identifier instead. Use these ranges to do the work now, not to re-find it later.

---

## 1. Admin-only material — the whole of it

| Source | Lines | Content |
|---|---|---|
| `docs/Requirements-Spec-v1.3.md` | 1184–1644 | **`FR-ADM-001…033`** — 33 requirements |
| | 220–227 | §3.3 Platform Admin persona |
| | 1909–1932 | §5.4 Vendor account state machine — drives ADM-S05–S07 verify / activate / suspend |
| | 2278–2304 | `AUDIT_LOG` + `PLATFORM_SETTING` entity dictionary |
| | 2791–2818 | Appendix C.3 — the `ADM-S01…S23` screen table (rows 2795–2817) |
| `docs/API-Route-Inventory.md` | 664–723 | **60 admin route-index rows** — ≈41 % of the whole API surface |
| | 1694–1991 | **§21, the admin API chapter** — 14 subsections, one per screen group |
| | 381–388 · 430–438 · 466–489 | `RequestForAdmin` · `OfferForAdmin` · `ConnectionForAdmin` presenters |
| | 558–568 | §5.4 admin error codes |
| | 2052–2073 | §22.3 `FR-ADM` → route traceability |
| `docs/Architecture-Frontend.md` | 178–183 · 347–350 · 604–618 · **619–654** · 682–687 · 756–766 · 805–822 | §4.2 why admin is a separate app · §7.4 admin shell · §15.2 keyboard / a11y release gate · **§16 the entire Flutter Web chapter incl. `AD-FE-12`** · §17.4 web perf · §21.1 blockers · Appendix A screen→module map |
| `ui-screens/admin/` | 23 files | Field-level inventory per screen (~1,050 lines) |
| `ui-screens/admin/README.md` | 33 | Roles, primary destinations, the unmasked-identity rule |
| `ui-screens/Karat_Hive_UI_Design_Context.md` | 2264–2327 · 2854–2865 | §79 Admin Portal · §80 Admin Dashboard · §81 Admin motion · §104 admin animation budget |
| `docs/Admin-App-Completion-Plan.md` | 142 | Plan of record |
| `docs/Admin-App-Completion-Tasks.md` | 60 | `ADM-C-*` register |
| `docs/Admin-Backend-Followup-Tasks.md` | 54 | `ADM-C-70…76` |
| `docs/admin-backend-api-gaps.md` | 120 | `BUG-ADM-01`, `GAP-ADM-01…08`, route↔screen matrix |
| `docs/Admin-Checkpoint-1-Taxonomy-Plan.md` + `-Tasks.md` + `.csv` | 258 + 304 | Checkpoint-1 history — condense, do not copy whole |
| `docs/Screen-API-Map.md` | 113–146 + `SAM-GAP-9/10/12/13` | Admin screen → endpoint coverage |

### 1.1 `FR-ADM` sub-group ranges

| Lines | Sub-section | Requirements |
|---|---|---|
| 1188–1218 | 4.3.1 Access control | `001` (1192), `002` `[ASSUMED]` (1206) |
| 1219–1305 | 4.3.2 Dashboard and platform statistics | `003`–`009` |
| 1306–1350 | 4.3.3 Customer management | `010`, `011`, `012` `[ASSUMED]` |
| 1351–1411 | 4.3.4 Vendor management | `013`–`016` |
| 1412–1502 | 4.3.5 Request / Offer / Connection oversight | `017`–`023` (`019` `[ASSUMED]`) |
| 1503–1644 | 4.3.6 Taxonomy, content, configuration | `024`–`033` (`028`, `032`, `033` `[ASSUMED]`) |

6 of 33 are `[ASSUMED]` and need Product Owner sign-off: `002`, `012`, `019`, `028`, `032`,
`033`. Series totals for context — `FR-CUS` 34, `FR-VEN` 31, `FR-ADM` 33, `FR-SYS` 12 = 110.

### 1.2 §21 admin API subsection map

| Lines | Subsection | Screens / FRs |
|---|---|---|
| 1694–1715 | Preamble — 404-not-403 for non-admin tokens, no self-registration, coarse RBAC (`AD-API-03`), list auditing, shared admin list query (`limit` **max 100**), internal notes (`AD-API-12`) | cross-cutting |
| 1716–1732 | 21.1 Dashboard | ADM-S02 · `FR-ADM-003…009` |
| 1733–1758 | 21.2 Customers | ADM-S03/S04 · `FR-ADM-010…012` |
| 1759–1799 | 21.3 Vendors — list, detail, verification, access | ADM-S05–S07 · `FR-ADM-013…016` |
| 1800–1820 | 21.4 Type Subscription grant `[PROPOSED]` `AD-API-04` | `FR-VEN-031` |
| 1821–1857 | 21.5 Requests, Offers, Connections | ADM-S08–S13 · `FR-ADM-017…023` |
| 1858–1872 | 21.6 Taxonomy — **`[BUILT · Checkpoint-1]`** | ADM-S14/S15 · `FR-ADM-024/025` |
| 1873–1888 | 21.7 Review moderation | ADM-S16 · `FR-ADM-026` |
| 1889–1907 | 21.8 Reports and exports | ADM-S17 · `FR-ADM-027/028` |
| 1908–1924 | 21.9 Announcements | ADM-S18 · `FR-ADM-029` |
| 1925–1938 | 21.10 Platform settings | ADM-S19 · `FR-ADM-030` |
| 1939–1951 | 21.11 Gold rates | ADM-S20 · `FR-ADM-031` |
| 1952–1962 | 21.12 Abuse queue `[ASSUMED]` | ADM-S21 · `FR-ADM-032` |
| 1963–1972 | 21.13 Audit log `[ASSUMED]` | ADM-S22 · `FR-ADM-033` |
| 1973–1991 | 21.14 Admin user management `[ASSUMED]`, coarse | ADM-S23 · `FR-ADM-002` |

---

## 2. Common material the admin surface genuinely needs

Under `SDC-05` this is carved once into `docs/core/` rather than inlined per surface.

| Source | Lines | Why needed |
|---|---|---|
| `CONTEXT.md` | all 131 | Ubiquitous language and the `_Avoid_` lists — admin screens name every domain entity |
| root `CLAUDE.md` | — | Authority chain, identifier systems, status tags, domain invariants, fixed stack, live open decisions |
| SRS | 62–91 · 118–190 · 228–253 · 1645–1815 · 1816–1945 · 1992–2304 · 2305–2318 · 2361–2394 · 2395–2463 | Conventions · constraints (`C-01/02/04/05/09/10/12/13`) · §3.4 permissions matrix · `FR-SYS-002/003/010/011/012` · `BR-001…022` · state machines · entity dictionary · §7.1 Admin Portal ≥1280 px · §7.5 API + §7.6 storage · NFRs (`002`, `008`, `013`, `014`, `015`, `019`–`025`, `027`, `029`, `030`) |
| API Inventory | 55–76 · 90–163 · 190–207 · 250–256 · 490–530 · 2099–2119 | `AD-API-01…13` · envelope · idempotency · auth · status codes · pagination (**admin `limit` max 100**) · generic + identity errors · open tensions |
| Arch-Frontend | 108–126 · 192–313 · 318–323 · 339–356 · 357–439 · 440–493 · 494–550 · 573–597 · 655–666 · 678–681 · 688–738 · 739–755 | `AD-FE-01…14` · package/feature structure · layers + Riverpod · go_router · design system · data layer + interceptors · masking-as-type · freshness · media · l10n / RTL · budgets · security · build · testing |
| Arch-Backend | 123–158 · 390–425 · 430–479 · 533–574 · 628–631 · 647–671 · 678–709 · 722–753 · 826–846 · 857–862 | Invariants · `AD-BE-01…16` · request lifecycle · **masking pipeline incl. §9.5 "admin always sees identity"** · outbox + event catalogue · volumes · `pg_trgm` search semantics · erasure · replica reads · envelope / errors / idempotency / pagination / rate-limit · auth paths, tokens, authorisation model · platform settings · **audit field set** · UTC↔GST |
| `docs/Physical-Data-Model.md` | 22–55 · 56–87 · 111–135 · 198–209 | Conventions · table ownership (`admin_note`, `announcement`, `export_job` are the admin-write surface) · DB-enforced rules · Supabase RLS posture |
| `ui-screens/component-widgets.md` | `SH-FND-*` · `SH-DOM-03/08/09` · `SH-TAX-01/02` · `SH-MED-03/04` · `SH-ID-02/03` | Shared widget contracts the admin screens reference |
| `ui-screens/Karat_Hive_UI_Design_Context.md` | 114–160 · 409–498 · 499–592 · 1362–1429 · 1724–1786 · 2417–2515 · 2536–2551 · 2930–2980 | Palette / tokens · M3 + shape + borders · typography · status / empty / loading systems · responsive + RTL + a11y · consistency, spacing, buttons · dialogs · copywriting |
| `docs/adr/0001`–`0010` | ~100 total | All ten are short and all bear on admin |

### 2.1 Minimum backend read-set for an admin frontend developer

≈300 of `Architecture-Backend.md`'s 1,116 lines: §2.3 (123–135) · §3 (136–158) · §8.2
(390–425) · §9.1–9.5 (430–479) · §11.1–11.2 (533–574) · §12.4/12.6/12.7/12.8 (628–631,
647–671) · §13.2–13.6 (678–709) · §14.1/14.2/14.4 (722–737, 742–753) · §17.1/17.2/17.5
(826–846, 857–862).

---

## 3. Excluded — deliberately

- SRS §4.1 Customer FR (258–743) and §4.2 Vendor FR (744–1183) — **except** `FR-VEN-002`
  (KYC, @764) and `FR-VEN-031` (subscriptions, @1169), which ADM-S07 and the subscription
  grant depend on.
- API Inventory §13–§17, §19, §20 — customer/vendor route chapters. Exception: 1660–1674
  (`/v1/me/subscriptions`, `AD-API-04`).
- Arch-Frontend §4.3 dual-mode · §7.2 mobile shell · §13.1/13.3/13.4 push · §15.1 · §17.2.
- Arch-Backend §5 deployment · §6 runtime · §10 acceptance transaction · §12.1/12.3/12.5 ·
  §19 reliability · §21 source layout · Appendix B.
- `ui-screens/customer/`, `ui-screens/vendor/` · `ui-mock/` · `docs/old/` ·
  `Requirements-raw.txt`.
- `Vendor-App-Completion-*` · `Backend-Gap-*` · `Backend-Implementation-Plan.md` ·
  `Template-Lock-Review-Plan.md` · `checkpoint-customer-mode-tasks.md`.
- `Async-Contract.md` — except the admin-emitting events, folded into `02-Admin-API-Contract.md`.

---

## 4. Cross-document quick reference

| Admin concern | SRS v1.3 | API Inventory | Arch-Frontend | Arch-Backend |
|---|---|---|---|---|
| Screen list (23) | 2791–2818 | §21 subsections | Appx A 805–822 | — |
| Requirements (33) | 1184–1644 | §22.3 2052–2073 | — | Appx A 1020–1058 |
| Routes (60) | — | 664–723 index · 1694–1991 detail | — | §7.1 296–338 |
| RBAC / auth | §3.4 228–253 · `FR-ADM-001/002` | §3.4 140–163 · `AD-API-01/03/13` | §7.3 339–346 | §14.1/14.2/14.4 |
| Envelope / errors | §7.5 2361–2375 | §3.2 · §5.1/5.2/5.4 | §6.3 304–313 | §13.2 678–691 |
| Pagination | `NFR-002` | §4.3 250–256 · §21 preamble | §9.6 434–439 | §13.4 696–699 |
| Masking (admin exemption) | `BR-006`–`008` · `FR-SYS-003` | §3.5 · `*ForAdmin` presenters | §10 440–493 | **§9.5 474–479** |
| Audit log | `FR-SYS-011` · `FR-ADM-033` · `AUDIT_LOG` 2278 | §21.13 | Appx A `audit` module | §17.2 841–846 |
| Data grid (`AD-FE-12`) | note @2846 | §23 @2107 | **§16.1 623–633** | — |
| Platform settings | `FR-ADM-030` · `BR-020` · `PLATFORM_SETTING` 2293 | §21.10 | — | §17.1 826–840 |
| Already built | — | §21.6 `[BUILT · Checkpoint-1]` | `AD-FE-02` @110 | — |

---

## 5. Two scope caveats

- **ADM-S20 (gold-rate configuration) is deferred** from the current build
  (`Architecture-Frontend.md` line 819; `SAM-GAP-11` withdrawn). The backend exists in
  `AdminGoldRateController`; the UI is out of scope pending Yahoo Finance redistribution
  terms.
- **`FR-ADM-002` role differentiation is deferred.** v1 RBAC is a flat `role = ADMIN`
  (`AD-API-03`; inventory lines 62 and 1700), so ADM-S23 ships with no Role selector
  (`SAM-GAP-13`) — even though `ui-screens/admin/README.md` still documents three roles.
  That tension is live and should be carried into `01-Admin-Requirements.md`, not silently
  resolved.
