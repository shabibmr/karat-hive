# Pending review findings — vendor-fix session (2026-09-09)

Source: `/code-review high all uncommitted changes`, session "vendor-fix" (105c0986-2ebb-462e-8f23-38d1cc9ca695), branch `feat/vendor-app-completion`. Re-verified against current code 2026-09-09; fixed items dropped, only open items below. Suggested fix order top to bottom.

## 1. Password policy mismatch
Backend (`backend/src/modules/identity/domain/password-policy.ts:3,28-32`): min 12 chars + lowercase + uppercase + digit + breached-password check, no symbol required.
Mobile client (`apps/kh_mobile/karat_hive/lib/features/profile_settings/presentation/settings_screen.dart:584-591`): min 8 chars + uppercase + digit + symbol, no lowercase check.
Rule sets do not match — a password valid on one side can be rejected on the other.

## 2. ~~Possible double-audit race in abuse auto-flagging~~ (Resolved)
~~`backend/src/modules/abuse/application/abuse.service.ts:51-103` runs a `$transaction` with no explicit isolation level (defaults to Postgres Read Committed). It reads `isEntityFlagged` (`abuse.repository.ts:124-134`) then writes via `flagAllReportsForEntity`/`updateMany` (`abuse.repository.ts:136-145`) with no `SELECT ... FOR UPDATE`, unique constraint, or serializable guard. Two concurrent reports hitting the 3-reporter threshold at nearly the same instant could both read `alreadyFlagged=false` and each emit an `ABUSE_REPORT_AUTO_FLAGGED` audit entry.~~
*Resolved: Added row-level lock (`SELECT id FROM request WHERE id = ${requestId}::uuid FOR UPDATE`) via `AbuseRepository.lockRequest` inside the transaction before auto-flag evaluation.*

## 3. ~~GST timezone bug — session "last active" times~~ (Resolved)
~~`settings_screen.dart:733-741` (`_formatDateTime`, used at line 749 for "Last active") calls `dt.toLocal()` instead of `GstFormatter`. Same class of bug already fixed for the business-profile "verified on" date (`business_profile_screen.dart:415`), not yet applied here.~~
*Resolved: Switched `_formatDateTime` in `settings_screen.dart` to use `GstFormatter.toGst(dt)` to format 'dd/MM/yyyy HH:mm' in GST (UTC+4).*

## 4. ~~`abortOnError: false` weakens test DI-error detection~~ (Dismissed as false positive / working as designed)
~~Set in `backend/test/integration/helpers.ts:36` and `backend/test/integration/customer-app.helpers.ts:64` when constructing the Nest testing app — suppresses dependency-injection wiring errors at startup instead of failing tests loudly.~~
*Dismissed: `abortOnError: false` is required in tests so Nest rethrows errors to Vitest instead of abruptly killing the test process with `process.abort()`.*

## 5. ~~Locked notification category hardcoded in two places~~ (Resolved)
Backend: `backend/src/modules/settings/domain/locked-notification-categories.ts:5` — `LOCKED_NOTIFICATION_CATEGORIES = new Set(['security'])`.
Flutter: `packages/kh_ui_domain/lib/src/notification_preference_matrix.dart:7` — `kLockedNotificationCategories = {'security'}`.
*Resolved: Explicitly cross-referenced both files with a design contract note documenting that the duplication is intentional to allow for offline UI rendering while maintaining independent backend enforcement.*
