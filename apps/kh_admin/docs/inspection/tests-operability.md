# Admin Flutter — Tests and operability gaps

| | |
|---|---|
| **Inventory** | Tests, flavours, CI budgets, runtime plumbing |
| **IDs** | `ADM-INS-80`–`87` (net-new) |
| **Register** | [`REGISTER.md`](REGISTER.md) |
| **HEAD** | `8880298` · 8 September 2026 |

`test/` already covers `core/api`, `core/auth`, query-params, most feature controller/repository/screen files, and `test/responsive/admin_responsive_test.dart`. Gaps below are against Architecture-Frontend §20 / §19, not “no tests”.

---

## 1. Net-new tests / ops findings

### ADM-INS-80 · no integration / e2e; seeded click-through open

Architecture-Frontend §20; `ADM-C-10`. No `integration_test`. Completion plan §6 still wants seeded Chrome click-through + screenshots for S05–S11.

### ADM-INS-81 · no flavours

Architecture-Frontend §19.1: `dev` / `staging` / `prod`. Actual: one app, `--dart-define=KH_API_BASE`.

### ADM-INS-82 · no contract version / Sunset / 426

Architecture-Frontend §19.4; `NFR-027`. `api_client.dart`: bearer + 401 retry only. No contract-version header, no `Deprecation`/`Sunset` prompt, no HTTP 426 blocking upgrade screen.

### ADM-INS-83 · unknown enums defaulted silently (hand parsers)

Architecture-Frontend §19.4 item 4: tolerate unknown enum values. Freezed models sometimes use `@JsonKey(unknownEnumValue: …)`. Hand `fromJson` often falls through to a default without a visible unknown state.

### ADM-INS-84 · no Admin first-load budget in CI

Architecture-Frontend §17.4: measured initial-load budget, tracked in CI.

### ADM-INS-85 · multi-tab logout

Architecture-Frontend §16.4: multiple tabs independent. Each tab has its own Flutter state; shared `FlutterSecureStorage` (**ADM-INS-09**) means logout in one tab is not observed in another until the next 401.

### ADM-INS-86 · Firebase init failure swallowed

`main.dart` `catch (e)` + `debugPrint`. Admin can look up with Auth broken. Related: **ADM-INS-12**, **ADM-INS-42**.

### ADM-INS-87 · draft PR / GIF still open

`ADM-C-14`. Completion tasks: commit on slice; GIF/PR still open.

---

## 2. Already numbered

| Topic | ID |
|---|---|
| Goldens LTR+RTL | **ADM-INS-01** |
| Request list screen test | **ADM-INS-39** |
| Idle timeout unimplemented (hence untested) | **ADM-INS-30** |
| Web token policy | **ADM-INS-09** |
| Strict `flutter analyze` | **ADM-INS-15** |
| Dashboard queue banner | **ADM-INS-61** |
| KYC new-tab | **ADM-INS-48** |
| Seed password | **ADM-INS-45** |

Keep the DEV AUTO-LOGIN badge when `KH_DEV_AUTOLOGIN` is on.

---

## 3. Counts

8 net-new (`ADM-INS-80`–`87`). Worst: **ADM-INS-80**.
