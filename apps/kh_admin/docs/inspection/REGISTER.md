# Admin Flutter inspection — finding register

| | |
|---|---|
| **Prefix** | `ADM-INS-nn` — Admin inspection finding. Stable, **never reused**. |
| **Surface** | `apps/kh_admin` |
| **HEAD** | `88802985d39a4679724875d900275fa038d3bb89` |
| **Date** | 8 September 2026 |
| **Status** | Snapshot. **Not the plan of record.** Does not override the SRS, Architecture-Frontend, or Admin-App-Completion-Plan. Does not renumber `ADM-C-*`, `ADM-FE-P*`, `GAP-ADM-*`, or `G2-*`. |
| **Does not mint** | `FR-*`, `AD-FE-*`, `ADM-S*`, `SAM-GAP-*` — those are cited, not replaced. |

Each finding has **one** ID. Axis narratives live in the sibling files; this register is the index. Cross-cutting facts are not given a second ID on the other axis.

Number ranges follow the `ADM-C-*` habit (gaps between groups are reserved, not unused mistakes):

| Range | Axis | Detail |
|---|---|---|
| `ADM-INS-01`–`19` | Standards (hard) | [`standards.md`](standards.md) |
| `ADM-INS-20`–`29` | Standards (smell, judgement) | [`standards.md`](standards.md) |
| `ADM-INS-30`–`49` | Spec | [`spec.md`](spec.md) |
| `ADM-INS-50`–`59` | Structure | [`structure.md`](structure.md) |
| `ADM-INS-60`–`69` | Quality | [`quality.md`](quality.md) |
| `ADM-INS-70`–`79` | Efficiency | [`efficiency.md`](efficiency.md) |
| `ADM-INS-80`–`89` | Tests / operability | [`tests-operability.md`](tests-operability.md) |

Kind: **hard** = documented-standard or spec miss; **judgement** = smell / inventory; **conflict** = two authority docs disagree (not a silent Flutter miss).

---

## 1. Standards — hard (`ADM-INS-01`–`19`)

| ID | Title | Cites | Primary evidence |
|---|---|---|---|
| **ADM-INS-01** | No LTR/RTL (or 200% type) goldens for shared widgets | `AD-FE-13`; Architecture-Frontend §8.3, §20 | `test/core/design/widgets/kh_widgets_test.dart` |
| **ADM-INS-02** | User-facing strings not ARB-only; no hardcoded-string lint | Architecture-Frontend §14, §19.2 | `kh_admin_scaffold.dart`; Group C screens; `l10n? ?? '…'` |
| **ADM-INS-03** | Physical `Alignment.centerLeft` / `centerRight` (RTL) | Architecture-Frontend §8.3 | scaffold; request/connection detail |
| **ADM-INS-04** | `GoRoute` paths untyped; `ChangeNotifier` bridge | `AD-FE-04` | `lib/core/router/app_router.dart` |
| **ADM-INS-05** | `freezed` only on early verticals | `AD-FE-05` | customers/audit/abuse/connections hand models |
| **ADM-INS-06** | No `MaskedParty` / `RevealedParty`; identity as `String?` | `AD-FE-07`; Architecture-Frontend §10 | `offer_detail.dart`; `request_list_item.dart` `'Unknown Customer'` |
| **ADM-INS-07** | `meta.serverTime` dropped; device clock for user-visible time | `AD-FE-11`; Architecture-Frontend §19.2 | `api_client.dart`; `verification_repository.dart`; `vendor_detail.dart` |
| **ADM-INS-08** | No list polling; FCM does not invalidate providers | `AD-FE-10`; `NFR-003` | `firebase_notification_service.dart` |
| **ADM-INS-09** | Access + refresh tokens persisted on web | Architecture-Frontend §18.1 | `token_storage.dart` |
| **ADM-INS-10** | Logs not PII/token-masked | Architecture-Frontend §18.2 | FCM `debugPrint`; Google sign-in traces |
| **ADM-INS-11** | Presentation calls repository | Architecture-Frontend §5.2, §6 | `verification_detail_pane.dart` `fetchDocumentUrl` |
| **ADM-INS-12** | No `Semantics`; no `FlutterError.onError` | Architecture-Frontend §15 | `lib/` (zero Semantics); `main.dart` |
| **ADM-INS-13** | `KhDataTable` not virtualised; `AD-FE-12` still `[BLOCKED]` | `AD-FE-12`; §17.3; `ADM-FE-P03` | `kh_data_table.dart` `for` rows |
| **ADM-INS-14** | CONTEXT.md `_Avoid_` slips (listing, chat) | CONTEXT.md | `FRAUDULENT_LISTING`; `Icons.chat` |
| **ADM-INS-15** | Analyzer not strict; `riverpod_lint` unused | Architecture-Frontend §19.2 | `analysis_options.yaml` |
| **ADM-INS-16** | `lib/` relative imports, not `package:kh_admin` | Architecture-Frontend §19.2 | `lib/**/*.dart` |
| **ADM-INS-17** | `MediaQuery.of(context).size` on the shell | Flutter MediaQuery guidance | `kh_admin_scaffold.dart` |
| **ADM-INS-18** | Hardcoded `Colors.white` / `Colors.black` | Architecture-Frontend §8 (tokens) | vendor/customer/request detail; login |
| **ADM-INS-19** | List controllers: `isLoading` + `error` boolean soup | `AD-FE-03` (`AsyncValue`) | `vendor_list_controller.dart` and twins |

Skipped as already allowed: `AD-FE-03` Riverpod in use; `AD-FE-06` OpenAPI client deferred; `AD-FE-09` no local DB; `print()` replaced by `debugPrint`.

---

## 2. Standards — smells (`ADM-INS-20`–`29`)

Judgement only. Repo standard wins.

| ID | Smell | Evidence |
|---|---|---|
| **ADM-INS-20** | Duplicated Code | Identical cursor-pagination notifiers (vendors/requests/offers); hand-rolled twins for customers/abuse/audit |
| **ADM-INS-21** | Speculative Generality | Empty `lib/features/gold_rate/{controller,model,presentation,repository}/`; empty `features/auth/{controller,model,repository}/` |
| **ADM-INS-22** | Divergent Change | `request_detail_screen.dart` ~1444 lines (layout + dialogs + mutations + copy) |
| **ADM-INS-23** | Shotgun Surgery | One new list filter touches a different recipe per feature (filters type ± URL helper ± client `where` ± chips ± l10n) |

`ADM-INS-24`–`29` reserved.

Primitive Obsession on party identity is **ADM-INS-06**, not a second smell ID.

---

## 3. Spec (`ADM-INS-30`–`49`)

| ID | Kind | Title | Cites | Primary evidence |
|---|---|---|---|---|
| **ADM-INS-30** | hard | No 60-minute idle timeout or warning | `FR-ADM-001` AC4; Architecture-Frontend §16.4 | `session_controller.dart` |
| **ADM-INS-31** | conflict | SRS still requires Admin TOTP/SMS 2FA; `adr/0010` rejects it | `FR-ADM-001` AC1; `adr/0010` | `login_screen.dart` `TODO ADM-S01 2FA` — **SRS rewrite debt, not a Flutter task** |
| **ADM-INS-32** | hard | Dashboard missing range, trends, drill-down filters | `FR-ADM-003`–`009` | `dashboard_stats.dart`; `dashboard_screen.dart` |
| **ADM-INS-33** | hard | List URL state missing on most screens; cursor/sort never encoded | Architecture-Frontend §16.3; `ADM-C-12` | customers/connections/audit/abuse/moderation/admin-users/reports |
| **ADM-INS-34** | hard | List filters thinner than SRS | `FR-ADM-010` AC2; `FR-ADM-013` AC2; `FR-ADM-017` AC2 | `customer_list_filters.dart`; `vendor_list_filters.dart`; request filter bar |
| **ADM-INS-35** | hard | Moderation / abuse are table+dialog, not list-detail-in-context | Architecture-Frontend (queue screens); ADM-S16, ADM-S21 | `moderation_screen.dart`; `abuse_screen.dart` |
| **ADM-INS-36** | hard | No in-app find; no portal-wide Esc/Enter/row-focus convention | Architecture-Frontend §16.4, §15.2 | list screens |
| **ADM-INS-37** | hard | No `deferred as` for reports / audit / announcements | Architecture-Frontend §16.2, §17.4 | `app_router.dart` eager imports |
| **ADM-INS-38** | hard | Abuse actions: resolve/dismiss only | `FR-ADM-032` AC3 | `abuse_screen.dart` |
| **ADM-INS-39** | hard | No request **list** widget test (empty/error) | Architecture-Frontend §20 | missing `test/features/requests/request_list_screen_test.dart` |
| **ADM-INS-40** | hard | Customer list access not logged | `FR-ADM-010` AC5 | banner only on `customer_list_screen.dart` |
| **ADM-INS-41** | judgement | Unused `FirestoreService` | `C-12`; `AD-FE-09` | `lib/core/firebase/firestore_service.dart` |
| **ADM-INS-42** | judgement | Analytics + Messaging pulled but not used as AD-FE-10 | — | `pubspec.yaml`; `main.dart` |
| **ADM-INS-43** | judgement | `SYSTEM OPERATIONAL` chip not in SRS | `FR-ADM-003` | `dashboard_screen.dart` |
| **ADM-INS-44** | judgement | Invented audit action/entity picklists | `FR-ADM-033` | `audit_screen.dart` |
| **ADM-INS-45** | judgement | Default seed password in source | Architecture-Frontend §18.4 | `dev_auth.dart` `AdminSecret123!` |
| **ADM-INS-46** | hard | Client-side filter of the loaded page; `hasMore` follows unfiltered cursor | `ADM-FE-P02`; `ADM-C-71` | `request_repository.dart`; `offer_repository.dart`; connections/abuse/audit/moderation/announcements |
| **ADM-INS-47** | hard | Request match set / timeline empty vs “not provided” | `FR-ADM-018`; `ADM-C-72` | `request_detail.dart` `TODO(backend)` |
| **ADM-INS-48** | hard | KYC document open still uses bearer-less `/v1/media/<key>` | completion plan §4; `ADM-C-74` | `verification_detail_pane.dart` |

`ADM-INS-49` reserved.

Spec facts already numbered on Standards (do **not** duplicate): idle-adjacent session store → **ADM-INS-09**; freshness → **ADM-INS-08**; device time → **ADM-INS-07**; goldens → **ADM-INS-01**.

**Not findings (implemented as specified):** ADM-S20 deferred (`SAM-GAP-11` withdrawn); ADM-S23 no Role selector (`SAM-GAP-13`); ADM-S18 EN+AR form present.

---

## 4. Structure (`ADM-INS-50`–`59`)

| ID | Kind | Title | Related | Evidence |
|---|---|---|---|---|
| **ADM-INS-50** | judgement | Uneven feature recipe (freezed/URL/l10n vs hand models) | ADM-INS-05, ADM-INS-23, ADM-INS-33 | Group A–C vs CP-1 verticals |
| **ADM-INS-51** | judgement | Router leftover `_GenericPlaceholderScreen` + dual nav source of truth | ADM-INS-04, ADM-INS-02 | `app_router.dart`; `kAdminNavItems` |
| **ADM-INS-52** | judgement | No shared admin Prisma-normaliser (`double.tryParse`, nested user) | `ADM-FE-P01` | each `*_repository.dart` |
| **ADM-INS-53** | judgement | `kh_admin` excluded from Melos; cannot import `kh_domain` / `kh_ui` | `AD-FE-02` | completion plan header; this package |

`ADM-INS-54`–`59` reserved.

God screens → **ADM-INS-22**. Empty shells → **ADM-INS-21**. Duplicated list kernel → **ADM-INS-20**. Presentation→repo → **ADM-INS-11**. Identity clumps → **ADM-INS-06**. Unused Firebase modules → **ADM-INS-41**, **ADM-INS-42**.

---

## 5. Quality (`ADM-INS-60`–`69`)

Net-new only. l10n → **ADM-INS-02**; analyzer → **ADM-INS-15**; tokens → **ADM-INS-09**; logs → **ADM-INS-10**; idle → **ADM-INS-30**; Semantics → **ADM-INS-12**; vocabulary → **ADM-INS-14**; identity types → **ADM-INS-06**; KYC tab → **ADM-INS-48**; colours → **ADM-INS-18**.

| ID | Kind | Title | Evidence |
|---|---|---|---|
| **ADM-INS-60** | hard | Broad `catch` then `e.toString()` shown to the user | list controllers |
| **ADM-INS-61** | hard | Dashboard queues fail **open** (`[]` on error) | `dashboard_controller.dart` `_omitQueueSource` |
| **ADM-INS-62** | judgement | Query-param helpers `catch (_)` and no-op | `vendor_query_params.dart` and twins |
| **ADM-INS-63** | judgement | Hit-target / SelectionArea / 48px not verified | Architecture-Frontend §15 |

`ADM-INS-64`–`69` reserved.

---

## 6. Efficiency (`ADM-INS-70`–`79`)

Virtualisation → **ADM-INS-13**. Client-side filter cost → **ADM-INS-46**. Deferred load → **ADM-INS-37**. Extra SDKs → **ADM-INS-41**, **ADM-INS-42**. `MediaQuery.of` → **ADM-INS-17**. `DateTime.now()` → **ADM-INS-07**. Polling absence → **ADM-INS-08**. Colours/const → **ADM-INS-18**.

| ID | Kind | Title | Evidence |
|---|---|---|---|
| **ADM-INS-70** | hard | List screens wrap `KhDataTable` in `SingleChildScrollView` (no lazy build) | `customer_list_screen.dart` and twins |
| **ADM-INS-71** | judgement | Export job poll every 400 ms | `reports_repository.dart` |
| **ADM-INS-72** | judgement | No `cacheWidth` / bounded decode when KYC thumbnails land | verification / vendor media |
| **ADM-INS-73** | judgement | `ref.watch` of whole list state (no `select`) | list screens |

`ADM-INS-74`–`79` reserved.

---

## 7. Tests / operability (`ADM-INS-80`–`89`)

Goldens → **ADM-INS-01**. Request list test → **ADM-INS-39**. Idle/token tests → **ADM-INS-30**, **ADM-INS-09**. Strict analyze → **ADM-INS-15**. Queue banner → **ADM-INS-61**. KYC click-through → **ADM-INS-48**. Seed password → **ADM-INS-45**.

| ID | Kind | Title | Cites | Evidence |
|---|---|---|---|---|
| **ADM-INS-80** | hard | No integration/e2e; seeded Chrome click-through still open | Architecture-Frontend §20; `ADM-C-10` | `test/` (no `integration_test`) |
| **ADM-INS-81** | hard | No `dev` / `staging` / `prod` flavours | Architecture-Frontend §19.1 | single `KH_API_BASE` define |
| **ADM-INS-82** | hard | No contract-version header, `Deprecation`/`Sunset`, or HTTP 426 screen | Architecture-Frontend §19.4; `NFR-027` | `api_client.dart` |
| **ADM-INS-83** | hard | Hand parsers default unknown enums silently | Architecture-Frontend §19.4 item 4 | non-freezed `fromJson` |
| **ADM-INS-84** | hard | No measured Admin first-load budget in CI | Architecture-Frontend §17.4 | CI |
| **ADM-INS-85** | judgement | Logout in one tab not observed in another until 401 | Architecture-Frontend §16.4 | shared `FlutterSecureStorage` |
| **ADM-INS-86** | hard | Firebase init failure swallowed; app still runs | — | `main.dart` `catch (e)` |
| **ADM-INS-87** | judgement | Draft PR / GIF still open | `ADM-C-14` | completion tasks |

`ADM-INS-88`–`89` reserved.

---

## 8. Counts

| Axis | Assigned | Reserved in range | Worst in axis |
|---|---|---|---|
| Standards hard | 19 (`01`–`19`) | — | **ADM-INS-06** identity types; **ADM-INS-01** goldens |
| Standards smells | 4 (`20`–`23`) | `24`–`29` | **ADM-INS-22** god detail screens |
| Spec | 19 (`30`–`48`) | `49` | **ADM-INS-32** dashboard; **ADM-INS-46** page-local filters |
| Structure | 4 (`50`–`53`) | `54`–`59` | **ADM-INS-50** uneven recipe |
| Quality | 4 (`60`–`63`) | `64`–`69` | **ADM-INS-60** raw exceptions |
| Efficiency | 4 (`70`–`73`) | `74`–`79` | **ADM-INS-70** nested scroll + **ADM-INS-13** |
| Tests / ops | 8 (`80`–`87`) | `88`–`89` | **ADM-INS-80** no e2e |

**62 IDs assigned.** Do not pick a single winner across axes.

Next unused ID: **ADM-INS-88** (ops) or **ADM-INS-24** (smell) or **ADM-INS-49** (spec), according to axis.
