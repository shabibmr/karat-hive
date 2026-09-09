# Admin Flutter — Standards axis

| | |
|---|---|
| **Axis** | Does `apps/kh_admin` conform to documented frontend standards? |
| **IDs** | `ADM-INS-01`–`23` |
| **Register** | [`REGISTER.md`](REGISTER.md) |
| **HEAD** | `8880298` · 8 September 2026 |

Findings are **hard** unless labelled judgement (`ADM-INS-20`–`23`). Repo standard wins over the smell baseline.

---

## 1. Hard violations

### ADM-INS-01 · no LTR/RTL goldens

`AD-FE-13` / Architecture-Frontend §8.3 / §20. `test/core/design/widgets/kh_widgets_test.dart` asserts labels and colours only. No `matchesGoldenFile`, no LTR+RTL pair, no 200% text-scale pass for `KhStatusChip`, `KhDataTable`, `KhMetricCard`, or `KhScreenHeader`.

### ADM-INS-02 · user-facing strings not ARB-only

Architecture-Frontend §14. Hardcoded English (or `l10n? ?? '…'`):

| File | Example |
|---|---|
| `lib/core/shell/kh_admin_scaffold.dart` | Nav titles, `Karat Hive Portal`, `Confirm Sign Out` |
| `lib/features/admin_users/presentation/admin_users_screen.dart` | `Provision Admin` |
| `lib/features/customers/presentation/customer_list_screen.dart` | `Customer Management` |
| `lib/features/settings/model/platform_setting_item.dart` | `defaultDescription` |
| `lib/features/abuse/presentation/abuse_screen.dart` | `Resolve Abuse Report` |
| `lib/features/requests/presentation/request_detail_screen.dart` | `'Accepted Vendor: … · Customer: …'` |

No hardcoded-string lint in `analysis_options.yaml` (also **ADM-INS-15**).

### ADM-INS-03 · physical alignment (RTL)

Architecture-Frontend §8.3. Directional insets are mostly honoured; these are not:

| File | Pattern |
|---|---|
| `lib/core/shell/kh_admin_scaffold.dart` | `Alignment.centerLeft` (×2) |
| `lib/features/requests/presentation/request_detail_screen.dart` | `Alignment.centerRight` |
| `lib/features/connections/presentation/connection_detail_screen.dart` | `Alignment.centerRight` |

### ADM-INS-04 · untyped go_router

`AD-FE-04`. `lib/core/router/app_router.dart`: string `GoRoute` paths, `RouterNotifier extends ChangeNotifier`. Auth `redirect` exists. Path params are `state.pathParameters['id'] ?? ''`.

### ADM-INS-05 · freezed used inconsistently

`AD-FE-05`. Freezed + generated JSON: requests, offers, vendors **list**, taxonomy, verification. Hand-rolled `copyWith` / `==`: customers, vendor **detail**, audit, abuse, dashboard, connections, settings, announcements, admin users, moderation, reports.

### ADM-INS-06 · masking as a type

`AD-FE-07` / Architecture-Frontend §10. No `MaskedParty` / `RevealedParty`. Forbidden shape:

```dart
// lib/features/offers/model/offer_detail.dart
String? customerName,
String? customerMobile,
String? customerEmail,
```

Request list defaults identity to `'Unknown Customer'` (`request_list_item.dart`). Admin may display PII; the **type** still allows a pre-acceptance widget to compile against those fields.

### ADM-INS-07 · `meta.serverTime` unused

`AD-FE-11`. `ApiClient` unwraps `data` and drops `meta`. Device clock for user-visible ages:

| File | Use |
|---|---|
| `lib/features/verification/repository/verification_repository.dart` | wait hours via `DateTime.now().toUtc()` |
| `lib/features/vendors/model/vendor_detail.dart` | `isLicenceExpired` vs `DateTime.now()` |
| `lib/features/audit/presentation/audit_screen.dart` | range defaults |
| Many `fromJson` paths | `DateTime.now()` as parse fallback |

Architecture §19.2 also wants a CI lint banning `DateTime.now()` for user-visible time — absent (**ADM-INS-15**).

### ADM-INS-08 · no push invalidation, no list polling

`AD-FE-10` / `NFR-003`. `firebase_notification_service.dart` only `debugPrint`s FCM. No `ref.invalidate` of list providers. No 30-second list poll. Export job polling in reports is the only poll.

### ADM-INS-09 · web token storage

Architecture-Frontend §18.1. `token_storage.dart` writes access token, access expiry, refresh token, and refresh expiry to `FlutterSecureStorage` (on web, script-reachable). Spec: access token in memory only; reload re-authenticates.

### ADM-INS-10 · logs not masked

Architecture-Frontend §18.2. No masking logger. `debugPrint('FCM opened app from notification: ${message.data}')`; Google sign-in exceptions dump objects/stack traces (`firebase_auth_service.dart`, `main.dart`).

### ADM-INS-11 · presentation calls repository

Architecture-Frontend §5.2 / §6. `verification_detail_pane.dart` reads `verificationRepositoryProvider` and calls `fetchDocumentUrl`.

### ADM-INS-12 · no Semantics; no framework error hooks

Architecture-Frontend §15. Zero `Semantics` / `semanticLabel` under `lib/`. No `FlutterError.onError` / `PlatformDispatcher.instance.onError` / custom `ErrorWidget.builder`.

### ADM-INS-13 · `KhDataTable` not virtualised; `AD-FE-12` still `[BLOCKED]`

Facade is correct. Implementation is a `Column` of all rows (`for (var i = 0; i < rows.length; i++)`), not `TwoDimensionalScrollView`. Conflicts Architecture §17.3. Completion plan `ADM-FE-P03` recorded “build”; the architecture document still marks the decision `[BLOCKED]`. Nested scroll: **ADM-INS-70**.

### ADM-INS-14 · CONTEXT.md vocabulary

A Request is never a listing; Talk is never chat.

| File | Slip |
|---|---|
| `lib/features/requests/presentation/request_detail_screen.dart` | `FRAUDULENT_LISTING`; “Fraudulent or misleading listing”; `Icons.chat` |
| `lib/features/settings/model/platform_setting_item.dart` | “Minimum listing threshold…” |
| `lib/features/connections/presentation/connection_detail_screen.dart` | `Icons.chat_bubble_outline` |

### ADM-INS-15 · analyzer not a gate

Architecture-Frontend §19.2. `analysis_options.yaml` is stock `flutter_lints` plus `unused_element: ignore`. No `strict-casts` / `strict-inference` / `strict-raw-types`. `custom_lint` / `riverpod_lint` are in `pubspec.yaml` and not enabled.

### ADM-INS-16 · relative imports in `lib/`

Tests use `package:kh_admin/...`. Production `lib/` uses relative imports.

### ADM-INS-17 · `MediaQuery.of` for width

`kh_admin_scaffold.dart` uses `MediaQuery.of(context).size.width`. Use `MediaQuery.sizeOf`.

### ADM-INS-18 · hardcoded `Colors.*`

`Colors.white` / `Colors.black` in vendor/customer/request detail, login, verification dialogs — fights `KhColors`.

### ADM-INS-19 · boolean-soup list state

Dashboard uses `AsyncNotifier` / `AsyncValue` (`AD-FE-03`). List controllers use `isLoading` + `isLoadingMore` + `String? error` + `items`. Loading-with-error and stale rows are representable.

**Not flagged:** `AD-FE-03` Riverpod in use; `AD-FE-06` deferred; `AD-FE-09` no local DB; `print()` replaced by `debugPrint`.

---

## 2. Smell baseline (judgement)

### ADM-INS-20 · Duplicated Code

`VendorListController`, `RequestListController`, `OfferListController` — same cursor-pagination notifier. Customer/abuse/audit/moderation repeat a hand-rolled variant.

### ADM-INS-21 · Speculative Generality

Empty `lib/features/gold_rate/{controller,model,presentation,repository}/`. Empty `lib/features/auth/{controller,model,repository}/` (login is presentation-only; session is `lib/core/auth/`).

### ADM-INS-22 · Divergent Change

`request_detail_screen.dart` (~1444 lines) owns layout, notes, removal dialogs, match list, timeline, and copy. Same pattern: offer/vendor/customer/announcements detail.

### ADM-INS-23 · Shotgun Surgery

Adding one list filter requires a filters type, a query-params helper (sometimes), a repository client-side `where`, a screen chip row, and l10n — shape differs per feature.

---

## 3. Counts

19 hard (`ADM-INS-01`–`19`); 4 smells (`ADM-INS-20`–`23`). Worst: **ADM-INS-06**, **ADM-INS-01**.
