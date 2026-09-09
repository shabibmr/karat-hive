# Admin Portal review — Part 2: Flutter/Dart engineering review

| | |
|---|---|
| **Product** | Karat Hive |
| **Surface** | Flutter Web Admin Portal (`apps/kh_admin`) |
| **HEAD** | `88802985d39a4679724875d900275fa038d3bb89` (`main` = `origin/main`) — abbreviated `8880298` in source notes |
| **Dates** | Flutter/Dart review 9 September 2026 |
| **Status** | Part 2 of 4, split by category from [`comprehensive-review.md`](comprehensive-review.md) at HEAD `8880298`. Snapshot against the Flutter/Dart checklist and Architecture-Frontend. Nothing here is a plan of record. |
| **Does not override** | SRS v1.3 · `API-Route-Inventory.md` · `Architecture-Frontend.md` · `Architecture-Backend.md` · `Admin-App-Completion-Plan.md` |
| **Does not mint** | `FR-*`, `AD-FE-*`, `AD-API-*`, `ADM-S*`, `ADM-C-*`, `SAM-GAP-*`, `ADM-INS-*` — those are cited, not replaced |
| **Decision prefix in this part** | `E1`–`E30` — Flutter/Dart enhancements, local to this review. Cites `ADM-INS-*` where the inspection register already owns a fact. |

This is **part 2 of 4** split from [`comprehensive-review.md`](comprehensive-review.md); the combined document remains the single-file reading and is unchanged. Sibling parts: [carve](comprehensive-review-carve-v1.md) · [simplification](comprehensive-review-simplification-v1.md) · [synthesis](comprehensive-review-synthesis-v1.md). Section numbering (§3, §3.3.x) is inherited from the parent so internal cross-references still resolve. For how this review relates to the carve and simplification passes, see §0 in [carve-v1](comprehensive-review-carve-v1.md); the three-way unification is [synthesis-v1](comprehensive-review-synthesis-v1.md) §5.

Companion, **not** part of this folder: [`docs/inspection/`](../inspection/README.md) (`ADM-INS-01`–`87`). Where a fact appears in both an inspection ID and a review finding, the inspection ID remains authoritative for standards and spec conformance. This document repeats the *quantity* and the *named replacement*, not a second verdict.

**Line numbers** below are artefacts of HEAD `8880298` and will not survive further edits. Use identifiers (`E9`, `ADM-INS-19`) to re-find work.

---

## 3. Flutter/Dart engineering review

Canonical source: [`docs/Admin-Flutter-Dart-Code-Review.md`](../../../../docs/Admin-Flutter-Dart-Code-Review.md). The file in this folder is a move stub.

The portal is a working feature-first Flutter Web app: login, shell, and live routes for ADM-S01–S19 and S21–S23 (ADM-S20 gold rates remain a placeholder). The gaps below are against the Flutter/Dart checklist and Architecture-Frontend, not “the app does not exist.”

### 3.1 Executive summary

The architecture **shape** is right: `lib/features/<name>/{controller,model,presentation,repository}`, Riverpod providers, a typed `ApiClient`, a design-token `ThemeExtension`, `go_router` auth redirect, and EN/AR `gen-l10n` scaffolding. CI already runs `flutter analyze`, `flutter test`, and `flutter build web` for this package.

What is not right is **consistency and depth**. List state is boolean soup instead of `AsyncValue`. Presentation files are 600–1,400 lines. Tables are fully built, not virtualised. User-facing English is still hardcoded on most Group C screens. Analyzer settings are stock `flutter_lints` with two rules *disabled*. Web token policy, idle timeout, Semantics, and global error capture are missing. Several Firebase SDKs are on the bundle and unused.

#### Scorecard

| # | Area | Verdict | Worst gap |
|---|---|---|---|
| 1 | Project health | **Partial** | Uneven feature recipe; Melos exclusion; unused Firebase |
| 2 | Dart language | **Partial** | Broad `on Object catch` + `e.toString()`; relative imports |
| 3 | Widgets | **Fail** | God `build()` methods; `_build*` helpers; hardcoded colours |
| 4 | State management | **Partial** | Lists: `isLoading`/`error` flags; details: `AsyncValue` |
| 5 | Performance | **Fail** | `KhDataTable` + outer `SingleChildScrollView`; no `deferred as` |
| 6 | Testing | **Partial** | Good unit/widget coverage; no goldens, e2e, request-list screen, or several controllers |
| 7 | Accessibility | **Fail** | Zero `Semantics`; row 44; sidebar 38; offer Inspect 30 |
| 8 | Platform / responsive | **Partial** | Desktop breakpoint exists; `MediaQuery.of`; no keyboard conventions |
| 9 | Security | **Fail** | Web persists access+refresh; seed password default; unmasked logs |
| 10 | Packages | **Partial** | Unused Firestore/Messaging/Analytics; stale major versions |
| 11 | Navigation | **Partial** | Auth guard exists; untyped string routes; leftover placeholder map |
| 12 | Error handling | **Fail** | No `FlutterError.onError`; raw exceptions in UI; dashboard fail-open |
| 13 | Internationalization | **Fail** | ARB exists; most chrome and Group C copy is English literals |
| 14 | Dependency injection | **Partial** | Riverpod graph is the DI; widgets still `ref.read` repositories |
| 15 | Static analysis | **Fail** | No strict-casts/inference/raw-types; `riverpod_lint` unused |

**7 Fail · 8 Partial · 0 Pass.**

### 3.2 What already works (do not regress)

| Strength | Evidence |
|---|---|
| Feature-first modules (`AD-FE-08`) | `lib/features/*/{controller,model,presentation,repository}` |
| Repositories wrap Dio; UI does not call Dio | e.g. `RequestRepository`, `VendorRepository`, `apiClientProvider` |
| Detail screens use `AsyncValue` | verification, taxonomy, dashboard, request/offer/vendor/customer/connection detail |
| Token attach + single-flight 401 refresh | `ApiClient._send`, `SessionController.silentRefresh` |
| Typed error envelope exists | `ApiException` (`code`, `message`, `requestId`) |
| Design tokens for the dark canvas | `KhThemeExtension`, `KhColors.dark`, `buildKhAdminTheme()` |
| Auth redirect on `GoRouter` | `RouterNotifier.redirect` |
| `mounted` checks on many async UI paths | login, verification dialogs, list search debounce |
| Tests per most features | `test/features/*` controller + repository + screen |
| CI job for this package | `.github/workflows/frontend.yml` `admin` job |
| No `print()` in `lib/` | `debugPrint` only (still unfiltered — see §3.3.9) |
| Platform URL open isolated | `core/platform/open_url_web.dart` / `open_url_stub.dart` |
| Hover on table rows | `KhDataTable` `InkWell.hoverColor` |

### 3.3 Findings by checklist section

Each finding cites evidence. Where the inspection register already owns the fact, the `ADM-INS-*` ID is given so this review does not renumber it.

#### 3.3.1 General project health — Partial

**Folder structure is consistent at the top level and inconsistent inside features.** Checkpoint-1 verticals (vendors list, requests, offers, taxonomy, verification) use `@freezed` models, generated JSON, and URL query helpers. Later screens (customers, connections, abuse, audit, moderation, settings, announcements, admin-users) hand-roll `copyWith` / `==` / `fromJson` and skip URL state (`ADM-INS-05`, `ADM-INS-50`).

Empty shells remain:

- `lib/features/gold_rate/{controller,model,presentation,repository}/` — ADM-S20 is deferred; nav still registers `/gold-rates` as a placeholder (`ADM-INS-21`, `ADM-INS-51`).
- `lib/features/auth/{controller,model,repository}/` — login lives in `presentation/` only; session lives in `lib/core/auth/`.

`kh_admin` is **excluded from the Melos workspace** (`pubspec.yaml` at repo root, `AD-FE-02`). It cannot import `kh_domain` / `kh_design_system` / `kh_l10n` and reimplements tokens, chips, and party fields (`ADM-INS-53`).

`pubspec.yaml` pulls `cloud_firestore`, `firebase_messaging`, and `firebase_analytics`. `FirestoreService` is unused (`ADM-INS-41`). FCM: background handler is registered in `main()`; `initializeForegroundHandler` is **never called**, so foreground messages and tap-to-invalidate never run (`ADM-INS-08`, `ADM-INS-42`). `FirebaseAnalyticsObserver` / `getObserver()` is never attached to `GoRouter`. `cupertino_icons` is unused on a web-first admin canvas.

**Enhance:** one list-feature recipe (freezed model + `AsyncValue`/sealed list state + URL helper + ARB keys + screen/controller/repo tests). Delete or hide gold-rate until ADM-S20. Drop unused Firebase packages until `AD-FE-10` is implemented. Plan Melos inclusion as a dedicated slice so `kh_domain` masking types can land.

#### 3.3.2 Dart language pitfalls — Partial

| Pattern | Where | Why it matters |
|---|---|---|
| `on Object catch (e)` then `e.toString()` | vendor/request/offer/customer/connection/audit list controllers; request/customer detail | Catches `Error` (bugs) and shows Dio/envelope text (`ADM-INS-60`). **27** `on Object catch` sites |
| `catch` without `on` | **68** sites: query-param helpers, session, dashboard queues, login, Firebase, logout | Swallows failures; URL updates no-op (`ADM-INS-62`); dashboard queues look empty (`ADM-INS-61`); `AuthRepository.logout` is best-effort swallow |
| Relative imports in `lib/` | entire `lib/` | Tests use `package:kh_admin/...`; production does not (`ADM-INS-16`) |
| `Future.microtask(refresh)` in `Notifier.build()` | six list controllers | Side-effect in `build()`; races with the first frame; prefer `ref.listen` / explicit load / `AsyncNotifier` |
| `late final TextEditingController` | every list screen | Acceptable if initialised in `initState`; prefer constructor init |
| Identity as `String?` | `OfferParentRequestSummary.customerName` / `customerMobile` / `customerEmail` | Compiles a pre-acceptance widget against fields it must never have (`ADM-INS-06`, `AD-FE-07`) |
| `DateTime.now()` as parse fallback / age | verification wait hours, vendor licence expiry, audit range | Device clock, not `meta.serverTime` (`ADM-INS-07`) |

`ApiClient.get` returns `Future<dynamic>`. Call sites downcast. That is implicit `dynamic` at the transport boundary. A generated OpenAPI client (`AD-FE-06`, deferred) or typed `get<T>` would close it.

**Enhance:** map `on ApiException catch` to a user-facing `error.code` catalogue; never `e.toString()` in state. Enable `avoid_catches_without_on_clauses`. Switch list controllers to `AsyncNotifier` (or a sealed `ListViewState`). Convert `lib/` to `package:kh_admin` imports. Capture `meta.serverTime` in `ApiClient` and inject a clock.

#### 3.3.3 Widget best practices — Fail

Largest presentation files (generated l10n excluded):

| File | Lines |
|---|---|
| `request_detail_screen.dart` | 1,484 |
| `offer_detail_screen.dart` | 1,388 |
| `announcements_screen.dart` | 1,210 |
| `vendor_detail_screen.dart` | 1,075 |
| `platform_settings_screen.dart` | 1,059 |
| `customer_detail_screen.dart` | 1,022 |
| `audit_screen.dart` | 882 |
| `connection_detail_screen.dart` | 819 |

These mix layout, dialogs, mutations, copy, and formatting in one `State` class (`ADM-INS-22`). Private `_build*` helpers stay in the same file, so they do not get `const` constructors or independent rebuild boundaries.

Theming is token-based **until it is not**: `Colors.white` / `Colors.black` on action buttons (vendor/customer/request detail, login, verification dialogs) (`ADM-INS-18`). Inline `TextStyle(fontSize: 12.0)` on offer list and connection detail bypasses `kh.typography`.

`KhDataTable` uses a `for` loop over every row inside a `Column` (`ADM-INS-13`). List screens wrap that table in another vertical `SingleChildScrollView` (`ADM-INS-70`). `GlobalKey<FormState>` usage is appropriate (forms, not tree identity).

**Enhance:** split each god screen into header / summary / timeline / actions / dialogs widgets. Extract `KhDataTable` rows to a lazy viewport (see §3.3.5). Ban raw `Colors.*` and raw `TextStyle` via lint + review. Prefer `context.kh.colors.onPrimary` for button foregrounds.

#### 3.3.4 State management (Riverpod) — Partial

**Two recipes coexist.**

Detail / dashboard / taxonomy / verification: `AsyncNotifier` + `AsyncValue` — loading, data, and error are exclusive. This matches `AD-FE-03`.

Lists: a single class with `isLoading`, `isLoadingMore`, `error`, and `items` (`VendorListState` and twins). `isLoading && error != null` is representable (`ADM-INS-19`). Customers/abuse/audit/announcements/admin-users duplicate that shape by hand instead of freezed.

`SessionController` is a `StateNotifier`; list controllers are `Notifier`; some later features are `StateNotifier` again (abuse, announcements, admin users). One Riverpod generation would reduce ceremony.

`Notifier.build()` scheduling `Future.microtask(refresh)` is a side effect inside the provider build. `AsyncNotifier.build()` returning the fetch is the idiomatic replacement.

Presentation calls the repository on verification document open (`verification_detail_pane.dart` `ref.read(verificationRepositoryProvider).fetchDocumentUrl`) (`ADM-INS-11`). Controllers should own that.

Screens `ref.watch` the whole list state, so a filter-chip tweak rebuilds the table (`ADM-INS-73`). Use `select`.

No `ProviderObserver` / error observer.

**Enhance:** shared `AdminCursorListState<T, F>` (sealed or `AsyncValue` + pagination metadata). One `AdminCursorListController` base. Document-open goes through `VerificationController`. `ref.watch(listProvider.select((s) => s.items))` vs filters. Add a `ProviderObserver` that reports to the logger (once logging exists).

#### 3.3.5 Performance — Fail

| Issue | Evidence | Spec |
|---|---|---|
| Every table cell is in the tree | `KhDataTable` `for` rows | Architecture-Frontend §17.3; `ADM-INS-13` |
| Nested scroll prevents lazy build | list screens wrap the table in `SingleChildScrollView` | `ADM-INS-70` |
| Eager route imports | `app_router.dart` imports every screen, including `fl_chart` via reports | §16.2 / §17.4; `ADM-INS-37` |
| Client-side filter of one page | `RequestRepository.fetchRequests` filters after fetch; `hasMore` follows unfiltered cursor | `ADM-INS-46` |
| Export poll 400 ms × 40 | `ReportsRepository.pollInterval` | `ADM-INS-71` — **FIXED** in simplification Tier-0 as `ADM-SMP-44` ([simplification-v1](comprehensive-review-simplification-v1.md) §4.7) |
| `MediaQuery.of(context).size.width` | `kh_admin_scaffold.dart` | Prefer `MediaQuery.sizeOf`; `ADM-INS-17` |
| No image decode bounds | KYC / vendor documents | `ADM-INS-72` |
| Extra SDKs on first load | Firestore, Messaging, Analytics, `fl_chart` | `ADM-INS-41`, `ADM-INS-42` |
| No first-load budget in CI | `frontend.yml` `admin` job builds web, does not measure | `ADM-INS-84` |

`ListView.builder` appears in the taxonomy tree only. Admin tables are the hot path.

**Enhance:** replace `KhDataTable`’s `Column`+`for` with a vertical `ListView.builder` (fixed `itemExtent` from `kh.spacing.tableRowHeight`) inside the horizontal scroller; drop the outer `SingleChildScrollView`. Deferred-load reports, audit, announcements. Push list filters to the API (backend follow-up) instead of shrinking the page. Poll exports on 1–2 s. Track compressed main-js size in CI.

#### 3.3.6 Testing — Partial

Present: API client, session, most query-params, most feature controller/repository/screen tests, shared widget tests, one responsive test. No mocktail/mockito — tests use hand fakes and `ProviderScope` overrides. That isolation style is healthy.

**Feature coverage (controller / repository / screen):**

| Feature | Controller | Repository | Screen |
|---|---|---|---|
| abuse, admin_users, announcements, connections, customers, moderation, settings, verification | yes | yes | yes |
| offers, vendors | list only | yes | list **and** detail |
| audit | **no** | yes | yes |
| dashboard, reports | **no** | yes | yes |
| taxonomy | yes | **no** | yes |
| requests | list only | yes | **neither** list nor detail screen (`request_detail_parse_test.dart` is model JSON only) |
| gold_rate | n/a (empty) | n/a | n/a |

Also untested: `request_detail_controller`, `offer_detail_controller`, `vendor_detail_controller`, `verification_query_params` (the other query-param helpers *are* tested).

Missing against Architecture-Frontend §20 and the Flutter checklist:

| Gap | ID |
|---|---|
| No LTR/RTL (or 200% text scale) goldens for `KhStatusChip`, `KhDataTable`, `KhMetricCard`, `KhScreenHeader` | `ADM-INS-01` |
| No `test/features/requests/request_list_screen_test.dart` (empty/error) | `ADM-INS-39` |
| No `integration_test` / seeded Chrome click-through | `ADM-INS-80` |
| No coverage gate on business logic | — |
| Two analyzer warnings in tests | unused import in `announcements_screen_test.dart`; unused fake params in `platform_settings_controller_test.dart` |

Boolean-soup list controllers are not tested for exclusive state transitions (loading→error, retry).

**Enhance:** add the missing request-list widget test first (cheap). Then audit/dashboard/reports controller tests and taxonomy repository tests. Goldens for the four shared widgets in LTR, RTL, and 200% text scale. One integration_test for login → dashboard → one list → detail. Fail CI on `flutter analyze` warnings in this package (keep the job scoped to `apps/kh_admin`).

#### 3.3.7 Accessibility — Fail

| Check | Result |
|---|---|
| `Semantics` / `semanticLabel` / `ExcludeSemantics` | **Zero** matches in `lib/` (`ADM-INS-12`) |
| Hit targets ≥ 48 px | Tokens: `tableRowHeight: 44`, `buttonHeight: 36`, `inputHeight: 40`. Worse: sidebar row **38**, offer Inspect `minimumSize: Size(60, 30)`, table `IconButton`s with 18 px icons (`ADM-INS-63`) |
| `SelectionArea` for canvas copy-paste | Absent |
| In-app find (Ctrl+F is a no-op on canvas) | Absent (`ADM-INS-36`) |
| Keyboard: Esc / Enter / row focus | Absent |
| Color not sole state indicator | Status chips have labels — good |
| Focus order | Untested |

Dense admin tables can stay dense, but icon-only actions, sidebar items, and the offer Inspect control still need a 48 px minimum (padding around a smaller visual is enough).

**Enhance:** wrap icon buttons in `Semantics(button: true, label: …)`. Add `SelectionArea` at the scaffold body. Raise interactive targets to 48. Add a list find field bound to the existing `q` filter.

#### 3.3.8 Platform and responsive design — Partial

This is a **Flutter Web** product that still carries Android/iOS/Windows/Linux/macOS runners from `flutter create`. Fine for local, irrelevant for production.

The shell breakpoint `kDesktopBreakpoint = 1280` and compact top bar at 600 are documented and tested (`test/responsive/admin_responsive_test.dart`). Hover exists on table rows. `SafeArea` is not used (web desktop); not a defect.

Gaps: the shell mixes `MediaQuery.of(context).size.width` (sidebar breakpoint) with `MediaQuery.sizeOf` (compact top bar) — prefer `sizeOf` / `widthOf` everywhere (`ADM-INS-17`); physical `Alignment.centerLeft` / `centerRight` on the scaffold and two detail screens (`ADM-INS-03`); `dart:html` in `open_url_web.dart` (`avoid_web_libraries_in_flutter`, `deprecated_member_use`) instead of `package:web`; no `Shortcuts` / focus traversal policy. Sidebar already uses `ListView.separated`; tables do not (`KhDataTable` has **16** call sites, all eager).

**Enhance:** directional alignment everywhere. Replace `dart:html` with `package:web` (or `url_launcher`). Add a portal `Shortcuts` map (Esc closes dialog, `/` focuses find). Keep desktop-first; do not invest in mobile Admin layouts beyond the existing drawer.

#### 3.3.9 Security — Fail

| Check | Result |
|---|---|
| Tokens in `FlutterSecureStorage` | Same `FlutterSecureStorage()` on every platform — **no `kIsWeb` branch, no `WebOptions`**. Web backend is localStorage. Architecture-Frontend §18.1 wants access token **in memory only** (`ADM-INS-09`) |
| Idle timeout 60 min + warning | Missing (`FR-ADM-001` AC4; `ADM-INS-30`) |
| Seed password in source | `DevAuthConfig` default `'AdminSecret123!'` (`ADM-INS-45`) |
| Logs mask PII/tokens | No; FCM and Google sign-in `debugPrint` payloads (`ADM-INS-10`) |
| HTTPS enforced | Default `KH_API_BASE` is `http://localhost:3000`; no prod check that the base is `https://` |
| KYC document open | Presentation fetches URL then `window.open` (`ADM-INS-48`); bearer-less `/v1/media/<key>` still a risk if signed URLs are not used |
| API keys in Dart | Google web client ID is in `web/index.html` **and** `firebase_auth_service.dart` (`kIsWeb ? '132845…' : null`). Expected for GIS, not a server secret. Firebase keys live in `firebase_options.dart` |
| Multi-tab logout | Not observed until 401 (`ADM-INS-85`) |
| Password login still on ADM-S01 | `loginWithPassword` + email/password form; `adr/0010` is Google-only (`ADM-INS-31` is SRS vs ADR conflict — keep password behind `KH_DEV_AUTOLOGIN` only) |

**Enhance (P0):** stop persisting tokens on `kIsWeb`; keep access in memory; re-auth on reload. Implement idle timer + warning dialog. Gate password login to the autologin define. Replace `debugPrint` with a logger that redacts `Authorization`, emails, mobiles. In production flavour, refuse non-HTTPS bases.

#### 3.3.10 Packages and dependencies — Partial

`flutter pub get` reported **41** packages with newer versions incompatible with current constraints. Notable majors behind: `flutter_riverpod` 2.6.1 (3.x available), `go_router` 14 (18 available), `flutter_secure_storage` 9 (11 available), `flutter_lints` 5 (6 available). Do not jump Riverpod 3 in the same slice as list-state unification.

`custom_lint` and `riverpod_lint` are in `dev_dependencies` and **not enabled** in `analysis_options.yaml` (`ADM-INS-15`).

`fl_chart` is justified by ADM-S17 but is eager-loaded (`ADM-INS-37`).

Firestore on a product whose constraint is **no secondary datastore** (`C-12`, `AD-FE-09`) is a policy smell, not just bundle weight. (Dead `FirestoreService` / `FirebaseAnalyticsService` deleted in simplification Tier-0 as `ADM-SMP-30` — see [simplification-v1](comprehensive-review-simplification-v1.md) §4.7; packages may still be in `pubspec.yaml`.)

**Enhance:** enable `custom_lint` + `riverpod_lint` now (cheap). Remove unused Firebase packages. Schedule a dedicated dependency-upgrade PR after list-state work. Do not add Redis/Kafka/Elasticsearch; do not keep Firestore “just in case.”

#### 3.3.11 Navigation and routing — Partial

One `GoRouter` with a shell and an auth `redirect` — good. Dialogs correctly use `Navigator.pop` (local overlay), not a second routing style.

Gaps (`ADM-INS-04`, `ADM-INS-33`, `ADM-INS-51`):

- Paths are magic strings (`'/vendors'`, `'/requests'`), duplicated in `kAdminNavItems` and `GoRoute` tables.
- `state.pathParameters['id'] ?? ''` — empty id still builds the detail screen.
- Query params (filters, cursor, selected id) wired only for vendors/requests/offers/verification/taxonomy; cursor/sort never encoded even there.
- Leftover `...kAdminNavItems.where(not registered) → _GenericPlaceholderScreen` existed only for gold rates; the exclusion list was a second source of truth. **FIXED** in simplification Tier-0 (`ADM-SMP-32` / `ADM-SMP-60` — see [simplification-v1](comprehensive-review-simplification-v1.md) §4.7) by reading `isLive`.

**Enhance:** typed routes (`go_router` 14 still supports `GoRoute` + a `AdminRoutes` class of constants; typed routes package can wait). Reject empty `:id`. Encode cursor + selected id on every list. Replace the placeholder spread with a single explicit gold-rate route or hide the nav item.

#### 3.3.12 Error handling — Fail

| Framework hook | Present? |
|---|---|
| `FlutterError.onError` | No (`ADM-INS-12`) |
| `PlatformDispatcher.instance.onError` | No |
| `ErrorWidget.builder` (release) | No |
| `runZonedGuarded` / Crashlytics / Sentry | No |
| Riverpod `ProviderObserver` | No |

Login maps `ApiException` codes to ARB strings (with English fallbacks) — the best error UX in the app. List controllers do the opposite: `e.toString()`. Dashboard queues return `[]` on any throw (`ADM-INS-61`), so a down verification API looks like an empty queue. Firebase init failure is swallowed and the app still runs (`ADM-INS-86`).

**Enhance:** install global handlers in `main()` that log (redacted) and show `ErrorWidget` with a retry, not the red screen. Map `ApiException.code` in one helper used by every controller. Dashboard queues should carry a per-source error chip, not vanish. Fail closed on Firebase init if Google Sign-In is the only production login.

#### 3.3.13 Internationalization — Fail

`l10n.yaml` + `app_en.arb` / `app_ar.arb` + generated delegates in `MaterialApp.router` — setup is correct. Generated API has **412 keys** (359 getters + 53 parameterized); `app_ar.arb` has the same key set. Partial **call-site** use: login, dashboard, taxonomy, vendors, verification, offers, requests, reports — typically as `l10n?.key ?? 'English fallback'` rather than required `AppLocalizations.of(context)!`.

**No `AppLocalizations` import** in: customers, connections, abuse, audit, admin_users, announcements, moderation, settings, and `kh_admin_scaffold.dart` (nav titles are English constants: `'Dashboard'`, `'Gold Rates'`, `'Soon'`, `'Sign Out'`). Login still hardcodes `'Administrative Portal'` and `'Sign in with Google'` next to ARB fallbacks (`ADM-INS-02`). RTL physical alignments remain (`ADM-INS-03`). No hardcoded-string lint. Dates/times are not obviously Gulf Standard Time (`BR-021`) — device/local formatting plus `DateTime.now()` (`ADM-INS-07`).

**Enhance:** lint hardcoded strings (the mobile workspace already has this habit). Move shell, lists, and dialogs to ARB before adding more screens. Use `AlignmentDirectional` and `EdgeInsetsDirectional`. Format instants via server time + `Asia/Dubai` display.

#### 3.3.14 Dependency injection — Partial

Riverpod **is** the DI container. `ApiClient`, `TokenStorage`, repositories, and controllers are providers. Tests override them. That matches `AD-FE-03`.

Gaps: the only confirmed presentation→repository call is `verification_detail_pane.dart` `fetchDocumentUrl` (`ADM-INS-11`). Other screens go through controllers. `SessionController` still `new`s collaborators inside the provider rather than taking interfaces at the boundary (testable today via constructor — keep that). No flavour-specific provider graph (`dev`/`staging`/`prod`) (`ADM-INS-81`). Firestore/FCM/Analytics providers exist with no consumers. Repositories are concrete classes only (no `abstract` interfaces); Riverpod overrides still make them testable.

**Enhance:** presentation never reads a repository provider — only controllers. Environment via `--dart-define-from-file` (already the Architecture-Frontend rule). Do not add GetIt.

#### 3.3.15 Static analysis — Fail

Current `analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml
analyzer:
  errors:
    invalid_annotation_target: ignore
    unused_element: ignore
```

Missing vs the checklist and Architecture-Frontend §19.2 (`ADM-INS-15`):

- `strict-casts`, `strict-inference`, `strict-raw-types`
- `always_use_package_imports`, `unawaited_futures`, `avoid_catches_without_on_clauses`, `prefer_final_locals` (explicit)
- hardcoded-strings / no-`DateTime.now()` lints named in Architecture-Frontend
- `custom_lint` plugin for `riverpod_lint`
- `unused_element: ignore` hides dead code (`ADM-SMP-33`)

A workspace `flutter analyze` reported **two kh_admin test warnings** and no `lib/` issues — because the config is too loose to see the problems in this review.

**Enhance:** copy the mobile package’s stricter analyzer as the baseline, then turn on one rule group per PR so the first strict pass is reviewable.

### 3.4 Suggested enhancements (`E1`–`E30`)

Grouped by payoff. Each item is a slice that can merge independently. Do not treat this as a rewrite of `Admin-App-Completion-Plan.md`.

#### P0 — correctness, security, user-visible failure

| # | Enhancement | Closes |
|---|---|---|
| E1 | Web: access token in memory only; do not persist refresh on `kIsWeb`; re-auth on reload | `ADM-INS-09` |
| E2 | 60-minute idle timeout + warning dialog; activity listener on pointer/keyboard | `ADM-INS-30` |
| E3 | Map `ApiException` in one helper; list controllers `on ApiException`; never `e.toString()` in UI | `ADM-INS-60` |
| E4 | Dashboard queue sources fail **closed** (error chip / retry), not `[]` | `ADM-INS-61` |
| E5 | `FlutterError.onError` + `PlatformDispatcher.onError` + release `ErrorWidget.builder` | `ADM-INS-12` |
| E6 | Redacting logger; delete payload `debugPrint` in FCM / Google sign-in | `ADM-INS-10` |
| E7 | Password form only when `KH_DEV_AUTOLOGIN`; production path is Google Sign-In (`adr/0010`) | `ADM-INS-31` (product), login UX |
| E8 | Hide or remove Gold Rates nav until ADM-S20; delete empty feature dirs | `ADM-INS-21`, `ADM-INS-51` |

#### P1 — architecture consistency (stops the recipe from forking further)

| # | Enhancement | Closes |
|---|---|---|
| E9 | Shared cursor-list kernel: sealed/`AsyncValue` state + controller + URL codec | `ADM-INS-19`, `ADM-INS-20`, `ADM-INS-23` |
| E10 | Strict `analysis_options.yaml` + enable `riverpod_lint` | `ADM-INS-15` |
| E11 | `package:kh_admin` imports in `lib/` | `ADM-INS-16` |
| E12 | Split god detail screens (request/offer/vendor/customer first) | `ADM-INS-22` |
| E13 | Virtualised `KhDataTable` + remove outer `SingleChildScrollView` | `ADM-INS-13`, `ADM-INS-70` |
| E14 | ARB-only user-visible strings for shell + remaining lists; directional insets | `ADM-INS-02`, `ADM-INS-03` |
| E15 | `MaskedParty` / `RevealedParty` (or import `kh_domain` once Melos includes this app) | `ADM-INS-06`, `ADM-INS-53` |
| E16 | `ApiClient` keeps `meta.serverTime`; injected clock; no `DateTime.now()` for ages | `ADM-INS-07` |
| E17 | Presentation never calls repositories (verification documents via controller) | `ADM-INS-11` |
| E18 | Request list widget test (empty/error/loading); then audit/dashboard/reports controllers and taxonomy repository | `ADM-INS-39` |

#### P2 — product completeness and operability

| # | Enhancement | Closes |
|---|---|---|
| E19 | URL-encode filters **and** cursor on every list | `ADM-INS-33` |
| E20 | Server-side filters (stop page-local `where`); coordinate with admin API gaps | `ADM-INS-34`, `ADM-INS-46` |
| E21 | Dashboard date range, trends, drill-down query | `ADM-INS-32` |
| E22 | Abuse actions: warn / suspend / deactivate | `ADM-INS-38` |
| E23 | Deferred imports for reports / audit / announcements; drop unused Firebase | `ADM-INS-37`, `ADM-INS-41`, `ADM-INS-42` |
| E24 | Semantics + 48 px targets + `SelectionArea` + in-app find | `ADM-INS-12`, `ADM-INS-36`, `ADM-INS-63` |
| E25 | LTR+RTL goldens at 100% and 200% text scale | `ADM-INS-01` |
| E26 | Flavours `dev`/`staging`/`prod`; HTTPS-only prod base; contract-version / 426 screen | `ADM-INS-81`, `ADM-INS-82` |
| E27 | FCM (or 30 s poll) invalidates list providers | `ADM-INS-08` |
| E28 | Integration_test login → dashboard → list → detail; first-load size budget in CI | `ADM-INS-80`, `ADM-INS-84` |
| E29 | Signed-URL KYC open; `cacheWidth` when thumbnails exist | `ADM-INS-48`, `ADM-INS-72` |
| E30 | Customer list access audit call (`FR-ADM-010` AC5) | `ADM-INS-40` |

### 3.5 Recommended first implementation slice

If only one PR follows the Flutter/Dart review, do **E3 + E5 + E10 + E18**: typed API errors in list controllers, global Flutter error hooks, strict analyzer, and the missing request-list widget test. That slice does not change product scope, does not fight `AD-FE-12` (still `[BLOCKED]`), and makes every later screen inherit a safer default.

Do **not** mix E9 (list kernel) with a Riverpod 3 upgrade. Do **not** resolve `AD-FE-12` (buy vs build grid) inside a cleanup PR. Do **not** silently implement ADM-S20.

### 3.6 Flutter-checklist items folded into enhancements (no new `ADM-INS-*`)

This review does not add `ADM-INS-*` IDs. Flutter-checklist items that the register did not emphasise, treated here as enhancements rather than new IDs:

| Checklist item | Treatment |
|---|---|
| `Future.microtask(refresh)` in `Notifier.build()` | Fold into E9 (`AsyncNotifier`) |
| Mixed `StateNotifier` / `Notifier` / `AsyncNotifier` | Fold into E9 |
| `ApiClient.get` → `dynamic` | Fold into `AD-FE-06` / typed `get<T>` |
| Deprecated `dart:html` | Fold into E8/platform cleanup |
| `cupertino_icons` unused | Fold into E23 |
| Test-only analyzer warnings | Fold into E10 |
| `ProviderObserver` absent | Fold into E5 |
| `buttonHeight: 36` / `tableRowHeight: 44` | Fold into E24 (`ADM-INS-63`) |

Reserved register slots (`ADM-INS-24`–`29`, `49`, `54`–`59`, `64`–`69`, `74`–`79`, `88`–`89`) stay reserved. If Product wants these Flutter-engine notes in the register, mint there — not here.
