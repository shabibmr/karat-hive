# Admin Flutter — Quality gaps

| | |
|---|---|
| **Inventory** | Analyzer, state shape, i18n, a11y, security, errors, vocabulary |
| **IDs** | `ADM-INS-60`–`63` (net-new) |
| **Register** | [`REGISTER.md`](REGISTER.md) |
| **HEAD** | `8880298` · 8 September 2026 |

---

## 1. Net-new quality findings

### ADM-INS-60 · broad catch, raw exception strings

List controllers: `on Object catch (e)` then `e.toString()` (strip `Exception:`). Users can see Dio / envelope text. Typed path is `ApiException` (`api_exception.dart`).

### ADM-INS-61 · dashboard queues fail open

`dashboard_controller.dart` `_omitQueueSource` returns `[]` on any throw. A down verification API looks like an empty queue. Independent sources are good; silence is not.

### ADM-INS-62 · query-param helpers swallow errors

`vendor_query_params.dart` (and request/offer/taxonomy/verification twins): `catch (_)` when `GoRouterState.of` fails. Tests pass; production URL updates no-op.

### ADM-INS-63 · hit targets / SelectionArea unverified

Architecture-Frontend §15: 48px targets, SelectionArea for canvas copy-paste. Dense table rows and icon buttons are not measured. (Semantics / global errors: **ADM-INS-12**. In-app find: **ADM-INS-36**.)

---

## 2. Already numbered

| Topic | ID |
|---|---|
| Analyzer not strict; riverpod_lint unused | **ADM-INS-15** |
| Hardcoded English / `l10n? ??` | **ADM-INS-02** |
| RTL physical alignment | **ADM-INS-03** |
| Boolean-soup list state | **ADM-INS-19** |
| Web token persist | **ADM-INS-09** |
| Unmasked logs | **ADM-INS-10** |
| Idle timeout | **ADM-INS-30** |
| `FlutterError.onError` / Semantics | **ADM-INS-12** |
| Firebase init swallowed | **ADM-INS-86** |
| Seed password in source | **ADM-INS-45** |
| KYC new-tab Bearer | **ADM-INS-48** |
| CONTEXT.md listing/chat | **ADM-INS-14** |
| Hardcoded `Colors.*` | **ADM-INS-18** |
| Identity as `String?` | **ADM-INS-06** |

---

## 3. Counts

4 net-new (`ADM-INS-60`–`63`). Worst net-new: **ADM-INS-60**.
