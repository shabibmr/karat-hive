# Request-Create / Media-Readiness — Review Fix Plan

Source: `/code-review xhigh` of the uncommitted changes (media readiness decoupled from publish, Guest Save draft, purge scripts). Items are ordered by priority. Every item is **PENDING**.

Constraints that bind the fixes: `BR-006`/`BR-007` (masking), `C-11`/`C-12` (outbox, no broker), `FR-SYS-009.5` (media scan gate), `FR-SYS-011` (append-only audit). Do not edit the SRS in place — see the versioning habit in `CLAUDE.md`.

## Status register

| ID | Priority | Area | Item | Status |
|---|---|---|---|---|
| RC-01 | P0 | Mobile | Persisted snapshot must record intent (publish vs save-draft) | PENDING |
| RC-02 | P0 | Mobile | Clear `pendingSaveDraftIntent` on sheet dismiss; fix branch ordering | PENDING |
| RC-03 | P0 | Backend | Replace QUARANTINED-only publish denylist with an allowlist | PENDING |
| RC-04 | P0 | Docs | Decide and record the media-gate relaxation (ADR + SRS bump) | PENDING |
| RC-05 | P1 | Backend | Make quarantine + detach atomic and retry-safe | PENDING |
| RC-06 | P1 | Backend | Notify Customer (and audit) when media is detached post-publish | PENDING |
| RC-07 | P1 | Backend | Owner/vendor presenters: serve only servable media, fail closed | PENDING |
| RC-08 | P1 | Mobile | Guest Save draft reconciles on sign-in, not on sheet close | PENDING |
| RC-09 | P1 | Mobile | Register upload future before the slot becomes `uploading` | PENDING |
| RC-10 | P1 | Mobile | Collision-proof placeholder keys; dedupe `mediaKeys` | PENDING |
| RC-11 | P1 | Mobile | One-shot / in-flight guard on `reconcilePendingSaveDraft` | PENDING |
| RC-12 | P1 | Mobile | My Requests: apply `tab` on every navigation; invalidate list | PENDING |
| RC-13 | P1 | Scripts | Harden purge script (env guard, audit log, bucket, counters) | PENDING |
| RC-14 | P1 | Scripts | Rewrite or delete `delete-users-shabib.ts` | PENDING |
| RC-15 | P2 | Mobile | Extract shared Guest Save-draft helper; remove dead state | PENDING |
| RC-16 | P2 | Tests | Cover the new paths | PENDING |

## P0

### RC-01 — Persist intent with the pending snapshot
- **Problem:** `_runPendingDraftRestore` (`request_create_controller.dart` ~L133) always calls `pendingPublishIntentProvider.setPending()`. A snapshot persisted by Save draft is published after relaunch + sign-in.
- **Fix:** add an `intent` field (`publish` | `saveDraft`) to the persisted snapshot (`pending_publish_intent.dart`). On restore, set only the matching provider. Treat a snapshot with no `intent` (written by an older build) as `saveDraft` — the safe default; never publish by inference.
- **Done when:** a Save draft → kill → relaunch → sign-in path ends in Drafts with no published Request.

### RC-02 — Stale save-draft flag
- **Problem:** `request_review_publish_screen.dart` ~L133 checks the save-draft flag first, and the flag is cleared only on success or Vendor sign-in.
- **Fix:** clear the flag whenever the sign-in sheet is dismissed without a session, and on screen dispose. Make Publish and Save draft mutually exclusive: starting one clears the other. Drop the initState reconcile for an already-signed-in user unless the flag was set in this screen's lifetime.
- **Done when:** cancel sheet → Publish → sign-in publishes; opening the review screen while signed in never redirects.

### RC-03 — Publish gate as allowlist
- **Problem:** `request.service.ts` ~L411 only blocks QUARANTINED, so FAILED, PENDING_UPLOAD and stuck PENDING_PROCESSING pass.
- **Fix:** allow `READY` and `PENDING_PROCESSING` only. Reject `PENDING_UPLOAD`, `FAILED`, `QUARANTINED` with distinct error codes. Add a sweeper on the existing scheduler (`platform/scheduler/`) that moves `PENDING_PROCESSING` older than N minutes to `FAILED` and detaches it (same path as RC-05/06). No queue worker (`C-11`).
- **Done when:** specs cover each state; a poisoned processing event cannot leave a live Request with unprocessed media for more than N minutes.

### RC-04 — Record the decision
- **Problem:** the relaxation of "Publication blocked unless CLEAN" is documented only in the route inventory, Async Contract and Screen-API-Map; the SRS and two copies of Architecture-Backend disagree.
- **Fix:** write an ADR (next number after `0014`) stating what is allowed, why, and the compensating controls (RC-03 sweeper, RC-06 notification). Then supersede the SRS per the versioning habit (new `-vN.N`, move old to `docs/old/`, update inbound refs, recompute Appendix B coverage). Reconcile `docs/Architecture-Backend.md` and `docs/architecture/Architecture-Backend.md` (L815, L820) and remove one copy's drift. If the Product Owner has not approved the relaxation, mark it `[ASSUMED]` and list it in Appendix B.3.
- **Done when:** no document claims publication is blocked on scan state while the code allows it, or the code is reverted.

## P1

### RC-05 — Atomic quarantine
- **Where:** `media-processing.service.ts` ~L60.
- **Fix:** run `updateByKey(state=QUARANTINED)` and `detachFromRequests` in one `withTx`. In `processUploaded`, when the media is already QUARANTINED, still run the (idempotent) detach before returning.

### RC-06 — Tell the Customer
- **Where:** `media-processing.service.ts` ~L63.
- **Fix:** on detach from a PUBLISHED / OFFERS_RECEIVED Request, write an audit entry and enqueue a notification through the outbox (add to `docs/Notification-Catalogue.md`). If the detach leaves a type that requires an image with zero images, flag the Request and decide whether to block new Offers — raise as an open decision, do not infer.
- **Docs:** fix `Screen-API-Map` CUS-S08, which still advertises `MEDIA_QUARANTINED` to the client.

### RC-07 — Presenters
- **Where:** `request.presenter.ts` ~L172, `request-vendor.presenter.ts`.
- **Fix:** one shared helper for "servable media" (state READY). Owner view returns `state` and omits or placeholders non-READY URLs. Vendor presenters fail **closed**: a missing `state` is excluded, and the Prisma selects must include `state`. Remove the three copies of the filter.

### RC-08 — Guest Save draft reconcile
- **Where:** `find_ornament_screen.dart` ~L62, `request_image_capture_screen.dart` ~L52–90.
- **Fix:** listen to the session provider (as the review screen does) and reconcile on `SignedIn`; close the sheet from the listener. Do not depend on `await showModalBottomSheet` returning or on `context.mounted` after routing. Folded into RC-15's shared helper.

### RC-09 — In-flight upload registry
- **Where:** `request_create_controller.dart` ~L794.
- **Fix:** register the upload future (or a completer) in `_uploadFutures` before setting the slot to `uploading`. `saveDraft()` must surface a failure when it cannot proceed, not return false silently. Make `_runUploadConvertedSlot` mark the slot `failed` on its early returns (`slot == null`, empty `uploadBytes`).

### RC-10 — Placeholder keys
- **Where:** `request_create_controller.dart` ~L569.
- **Fix:** generate the placeholder key from a monotonic counter or UUID, not `Object.hash(path ?? label, bytes.length)`. De-duplicate `mediaKeys` before PATCH/POST. Server-side, make the `RequestMedia` insert idempotent on `(requestId, mediaId)`.

### RC-11 — Reconcile guard
- **Where:** `request_create_controller.dart` ~L805.
- **Fix:** an in-flight future or `_saveDraftReconcileAttempted` flag, mirroring `_reconcileAttempted`. Reset on failure so the user can retry.

### RC-12 — My Requests navigation
- **Where:** `my_requests_screen.dart` ~L37; callers of `context.go('/customer/requests?tab=…')`.
- **Fix:** apply `initialTab` whenever the route parameter changes (`didUpdateWidget`), not once. Invalidate the open and drafts list providers on publish and on draft save before navigating.

### RC-13 — Purge script
- **Where:** `backend/scripts/purge-requests-offers-connections.ts`.
- **Fix:** dry-run by default; require `--apply` plus a typed confirmation of the DB host; refuse hosts not on an allowlist unless `--i-know-this-is-shared` is passed. Do not delete `audit_log` (`FR-SYS-011`) — if the audit trail must go, make that a separate flag with its own confirmation. Delete bucket objects for the removed media (or print the keys). Recompute `connectionCount`, `reviewCount`, `aggregateRating` for affected profiles.

### RC-14 — User-delete script
- **Where:** `backend/scripts/delete-users-shabib.ts`.
- **Fix:** take emails/UIDs as arguments, not constants; remove personal data from the repo (and from history if it was ever committed). Match Firebase UIDs to the Postgres users found; fail loudly on token or lookup errors; delete the dead `fbRes` call; do not delete `audit_log` (`actor_user_id` is already `SetNull`); delete or reassign owned Requests, Offers and media first, since the FKs are `Restrict`. Prefer deleting the script once the one-off is done.

## P2

### RC-15 — De-duplicate and prune
- Extract one controller method or shared widget for the Guest Save-draft flow (sheet → sign-in → reconcile → snackbar → `go(DRAFTS)`), used by the compose, photo and review screens.
- Remove `mediaKeysReady` and `mediaInFlight` if unused, derive `RequestCreateState.uploading` from `media.any(uploading)`, and drop the no-op `disabled: false` parameters on `_MosaicAddTile` and `_DashedAddTile`.

### RC-16 — Tests
| Test | Covers |
|---|---|
| Controller | `reconcilePendingSaveDraft` once-only; restore honours persisted intent (RC-01, RC-11) |
| Controller | `_waitForInFlightUploads` during conversion; early-return slot fails visibly (RC-09) |
| Controller | duplicate pick yields distinct keys (RC-10) |
| Widget | cancel sheet → Publish publishes (RC-02); sign-in closes sheet and saves (RC-08) |
| Widget | My Requests applies tab on re-entry and shows the new item (RC-12) |
| Backend spec | publish gate per media state (RC-03); sweeper |
| Backend spec | `detachFromRequests`, quarantine atomicity, retry after crash (RC-05, RC-06) |
| Backend spec | owner and vendor presenters with missing `state` (RC-07) |

## Suggested order
1. RC-01, RC-02 (small, user-visible, safe).
2. RC-03 + RC-04 together — the code and the docs must change in the same step, or the gate must be reverted.
3. RC-05, RC-06, RC-07 (one backend change set).
4. RC-08 – RC-12 (one mobile change set), with RC-15 folded in.
5. RC-13, RC-14 before anyone runs either script against shared data.
6. RC-16 alongside each step, not after.

## Open decisions to raise (not resolved here)
- Does the Product Owner accept publishing before the malware scan completes? (RC-04)
- Policy when post-publish detach leaves a Request with no required image. (RC-06)
- Sweeper timeout N for stuck `PENDING_PROCESSING`. (RC-03)
