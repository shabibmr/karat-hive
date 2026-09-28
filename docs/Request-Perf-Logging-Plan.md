# Plan: timing logs for the Customer "Publish Request" flow

## Context

Publishing a Request feels slow even though raw network latency is only ~126 ms (DB) and ~150 ms (object storage). Reading the code, the delay is probably not one slow call. It is likely many sequential round trips plus a polling wait. The goal is to add timing logs on both sides, so one real publish gives a per-phase breakdown instead of a guess. **Logs only. No behaviour changes.**

### What the code does today (hypotheses the logs should confirm or reject)

| # | Phase | Where | Suspected cost |
|---|---|---|---|
| 1 | Photo prep: AVIF conversion on device (skipped on web) | `request_create_controller.dart` `_prepareForUpload` | CPU, possibly seconds per photo |
| 2 | Per-photo upload: intent → PUT to OCI → complete, then **PATCH the draft after every photo** (`_syncDraftMediaKeys`) | `kh_media/media_uploader.dart`, controller `_uploadConvertedSlot` | 4 HTTP calls per photo |
| 3 | `publish()` saves the draft again first (`saveDraft` → PATCH) | controller `publish()` | 1 HTTP call |
| 4 | Server media processing is async. `media.uploaded` goes to the outbox, and **`outbox.drain` only ticks every 5 s** (`backend/src/main.ts:67`). Processing then does getObject, clean, putObject, thumbnail putObject and a DB update | `media-processing.service.ts` | **0–5 s wait + ~1 s work** |
| 5 | Until then, publish returns `MEDIA_NOT_READY` and the client **sleeps 2 s and retries** (up to 30 times) | controller `_publishWhenMediaReady` | **likely the main cost: several seconds** |
| 6 | Each publish call runs about 12–15 sequential DB round trips at ~126 ms each: auth-guard user lookup, rate-limit bucket, idempotency claim/update, findById, OAuth check, platform config, live count, gold rate, and a transaction with update + outbox + audit | `auth.guard.ts`, `rate-limit.service.ts`, `idempotency.interceptor.ts`, `request.service.ts:359` | ~1.5–2 s per attempt |

## Approach

Use the existing `x-request-id` header, which the Flutter Dio interceptor already sets and the backend already reads (`edge/request-id.ts`). That lets you match each client log line to its server log line.

### Backend (`backend/src`)

1. **New helper `platform/perf/perf-timer.ts`**: a small `PerfTimer` with `lap(label)` and `done()`. `done()` writes one line through Nest `Logger`, e.g. `[Perf] request.publish rid=… total=1830ms findRequest=128 oauth=126 config=0 liveCount=127 goldRate=125 tx=512`. Logging only happens when a new env flag is on: `PERF_LOG` in `config/env.ts` (zod boolean, default `false`). I'll set `PERF_LOG=true` in the local `.env`.
2. **Per-HTTP-request line**: add a Fastify `onResponse` hook in `main.ts` using `reply.elapsedTime`. It logs `method url status ms rid`, and covers guards and interceptors too.
3. **Edge costs**: time the DB work in `AuthGuard` (`findUserForViewer`), `RateLimitGuard` (`limiter.take`) and `IdempotencyInterceptor` (claim + update).
4. **`RequestService.publish`**: one lap per numbered step already in the method (findById, OAuth, config, liveCount, validation, gold rate, transaction). Also log **which media are not READY** when it throws `MEDIA_NOT_READY`.
5. **`MediaService.complete`**: laps for findByKey, headObject, and the transaction.
6. **`MediaProcessingService.processUploaded`**: laps for load, getObject, clean, putObject, thumbnail put, and DB update. Also log **queue wait = now − outbox event `createdAt`**, which directly measures the 5 s drain delay.
7. **`OutboxDispatcher.drainBatch`**: batch size plus per-event handler duration.
8. **`RequestService.update`** (draft PATCH): total plus the syncMedia / transaction laps.

### Flutter

1. **New `PerfLog` helper in `packages/kh_core`** (next to `app_logger.dart`, exported from the package). It wraps a `Stopwatch` with `lap()` / `done()` and uses `debugPrint` so output shows in the `flutter run` console. It is enabled when `kDebugMode || bool.fromEnvironment('KH_PERF_LOG')`, so it is silent in release builds unless opted in.
2. **Dio `_ChainInterceptor`** (`kh_core/lib/src/api_client.dart`): store the start time in `options.extra`. In `onResponse` / `onError`, log `METHOD path status ms rid=<x-request-id>`. This covers every API call, including publish retries and draft PATCHes.
3. **One timed flow per user action.** Each flow is a `PerfLog`, printed to the console and saved to Firestore (step 5):

| Flow (`flow` field) | Starts | Ends | Phases (laps) | Code |
|---|---|---|---|---|
| `request.image_attach` | photo picked (`addPickedImage`) | slot has a server key, or fails | prepare (AVIF, native only), intent, PUT (+ bytes), complete, draft PATCH (`_syncDraftMediaKeys`) | `request_create_controller.dart`, `kh_media/media_uploader.dart` `uploadBytes` |
| `request.save_draft` | `saveDraft()` called directly (Save as draft) | POST/PATCH returns | create or patch, total | controller `saveDraft` |
| `request.continue` | wizard **Continue** (`persistAndGo`) | next step shown | saveDraft, total | controller `persistAndGo` |
| `request.publish` | `publish()` | success or error | flushLocalMedia, saveDraft, each publish attempt, retry sleeps; counters: `publishAttempts`, `mediaNotReadyCount`, `retrySleepMs` | controller `publish` / `_publishWhenMediaReady` |
| `request.open_draft` | a DRAFT is opened from My Requests → Drafts | detail data shown, **and** when all photo thumbnails have finished loading | getMine API, first render, images loaded (+ count). Resuming into the wizard (`loadFromRequest`) gets its own lap | `owner_request_detail_controller.dart` `build`, `owner_request_detail_screen.dart`, controller `loadFromRequest` |
| `request.open_published` | a published/live Request is opened (My Requests or History) | same as above | same as above | same files; `flow` is chosen by `req.state` once the response arrives |

   - To avoid double-counting, `saveDraft` only starts its own `request.save_draft` flow when it's called directly. When `continue` or `publish` call it, it shows up as a lap inside those flows.
   - "Images loaded" is measured by listening to each thumbnail's `ImageStream` in the detail screen, since photo bytes come through the backend (`GET /v1/media/:key` → `resolveMediaUrlOrStream`). If there are no photos, the flow ends at first render.

4. **Backend side of "open"**: add laps to `RequestService.getById` (findById, match/profile lookups, present) and `MediaService.resolveMediaUrlOrStream` (findByKey, thumbnail head, signed URL **or** full `getObject` stream, plus the byte count). Streaming photo bytes through the backend from OCI can easily be the slowest part of opening a Request.

5. **Save each flow summary to Firestore** so it survives on web, where browser-console logs are lost when the tab closes. `kh_mobile` already depends on `cloud_firestore` and reads `app_config/environment` (`lib/core/firebase/firestore_config_service.dart`). Add a small `PerfLogSink` in `lib/core/firebase/`, following that service's pattern. When the flag is on, each finished flow (success or failure) writes **one** document to the `perf_logs` collection:
   - fields: `flow` (see the table), `platform` (web/android/ios), `appFlavor`, `createdAt` (server timestamp), `totalMs`, `phases` (map of phase → ms), flow counters (`photoCount`, `photoBytes`, `publishAttempts`, `mediaNotReadyCount`, `retrySleepMs`, `imagesLoaded`), `outcome` (ok / error code), `requestIds` (list of `x-request-id` values made during the flow, to match against backend stdout logs), `requestId` (the Request's UUID).
   - **No PII**: no user id, email, phone number or Request content. Ids are opaque UUIDs only.
   - Fire-and-forget (`unawaited`, 3 s timeout, errors swallowed), so the Firestore write can never slow down or break publishing.
   - Only runs when perf logging is enabled (`kDebugMode || KH_PERF_LOG`). Normal release users write nothing.
   - **Firestore security rules**: there is no `firestore.rules` in the repo, so rules are managed in the Firebase console. You'll need to allow creating (not reading or updating) documents in `perf_logs`, e.g. `match /perf_logs/{id} { allow create: if true; allow read, update, delete: if false; }`, or restrict creates to `request.auth != null` if every test user signs in through Firebase. I won't change the console rules myself.
   - Note: this is a dev diagnostics sink, not a second system of record. Postgres stays the only record store (`C-12`). The backend's timings stay in its stdout logs and can be joined to these documents on `requestIds`.

If `hardcoded_strings_lint` flags the log strings, add `// ignore` comments at those call sites. They are developer diagnostics, not UI copy.

## Files touched

- Backend: `src/platform/perf/perf-timer.ts` (new), `src/config/env.ts`, `src/main.ts`, `src/edge/auth/auth.guard.ts`, `src/edge/rate-limit/rate-limit.guard.ts`, `src/edge/idempotency/idempotency.interceptor.ts`, `src/modules/requests/application/request.service.ts`, `src/modules/media/application/media.service.ts` (complete + resolveMediaUrlOrStream), `src/modules/media/application/media-processing.service.ts`, `src/platform/outbox/outbox.dispatcher.ts`, `.env` (local only)
- Flutter: `packages/kh_core/lib/src/perf_log.dart` (new) + export, `packages/kh_core/lib/src/api_client.dart`, `packages/kh_media/lib/src/media_uploader.dart`, `apps/kh_mobile/karat_hive/lib/features/request_create/controller/request_create_controller.dart`, `apps/kh_mobile/karat_hive/lib/features/request_manage/controller/owner_request_detail_controller.dart`, `.../request_manage/presentation/owner_request_detail_screen.dart`, `apps/kh_mobile/karat_hive/lib/core/firebase/perf_log_sink.dart` (new, plus a Riverpod provider that tests can override with a no-op)

The perf helper lives in `platform/`, so any module can import it without breaking the lint-enforced module boundaries.

## Verification

1. Backend: `npm run lint`, `npm run typecheck` (or `tsc --noEmit`) and `npm test`. Existing specs must pass, and with `PERF_LOG` unset the output must be unchanged.
2. Flutter: `dart analyze` (workspace script), plus `flutter test` for `kh_core`, `kh_media` and the `request_create` tests.
3. End to end: restart the backend with `PERF_LOG=true`. Run the app in debug. Attach 1–2 photos, tap Continue through the wizard, save as a draft, open the draft from My Requests → Drafts, publish it, then open the published Request. Each action should produce exactly one flow line. Collect the `[Perf]` lines from both consoles and join them on `rid`. Also repeat on web (`flutter run -d chrome`, or a web build with `--dart-define=KH_PERF_LOG=true`), then check that a `perf_logs` document shows up in the Firebase console and that its `requestIds` match lines in the backend log.
4. Report back a timeline table (phase → ms), confirm or reject hypotheses 4–6, and only then propose fixes. Candidate fixes to discuss later, not in this change: an immediate outbox drain / `LISTEN/NOTIFY` after media complete, fewer sequential queries in publish, dropping the per-photo draft PATCH.
