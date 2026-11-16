# iOS push notification setup (Firebase Cloud Messaging)

Bundle ID: `com.karathive.app`. The app code is already wired (permission request, token registration, foreground banner, tap navigation, sign-out cleanup). This runbook covers the external setup that code can't do.

## What the app already contains

| Piece | Location |
|---|---|
| Push Notifications entitlement (`aps-environment`) | `ios/Runner/Runner.entitlements` |
| `CODE_SIGN_ENTITLEMENTS` build setting | `ios/Runner.xcodeproj/project.pbxproj` |
| `UIBackgroundModes` → `remote-notification` | `ios/Runner/Info.plist` |
| Permission + token registration | `lib/app/notifications/device_registration_binder.dart` |
| Foreground banner + tap navigation | `lib/app/notifications/push_navigation_binder.dart` |
| Device deletion on sign-out | `lib/app/session/session_controller.dart` |

## Prerequisites

- Paid Apple Developer Program membership.
- **Account Holder** or **Admin** role (other roles cannot see Certificates, Identifiers & Profiles → Keys).
- Access to the Firebase project that contains the iOS app `com.karathive.app`.

## Steps

### 1. Create the APNs authentication key (Apple)

1. Open <https://developer.apple.com/account/resources/authkeys/list>.
2. Click **+**, name the key (e.g. `Karat Hive APNs`), tick **Apple Push Notifications service (APNs)**.
3. **Continue → Register → Download** the `.p8` file. It can be downloaded **once**; store it in a password manager or secrets vault.
4. Record the **Key ID** (in the filename `AuthKey_<KEYID>.p8`) and the **Team ID** (Membership details).

One `.p8` key covers sandbox and production, does not expire, and works for every app under the team.

### 2. Enable the Push Notifications capability on the App ID

1. **Certificates, Identifiers & Profiles → Identifiers → `com.karathive.app`**.
2. Tick **Push Notifications**, then **Save**.
3. Regenerate any provisioning profile used for signing so it includes the capability. If Codemagic uses automatic signing with the App Store Connect key, re-running the build regenerates it.

### 3. Upload the key to Firebase

1. Firebase Console → **Project settings → Cloud Messaging**.
2. Under **Apple app configuration**, select the iOS app `com.karathive.app`.
3. **APNs Authentication Key → Upload**: choose the `.p8`, enter the **Key ID** and **Team ID**.

### 4. Confirm `GoogleService-Info.plist`

Confirm the iOS app in Firebase uses bundle ID `com.karathive.app` and that the `GoogleService-Info.plist` in `ios/Runner/` belongs to that app.

### 5. Build and sign

- Push does not work on the iOS Simulator for APNs-delivered messages. Use a **real device**.
- Run a TestFlight or ad-hoc build from Codemagic.
- Confirm the signed build's entitlement is `aps-environment = production` for App Store/TestFlight builds. The repo file says `development`; Xcode's managed signing normally swaps it at export. Verify with:
  `codesign -d --entitlements :- Runner.app` on the exported build.

### 6. Test on a device

| Check | Expected |
|---|---|
| Sign in on a fresh install | iOS permission prompt appears; allow it |
| Backend `devices` table | A row exists for the user with platform `IOS` and the FCM token |
| Send a test message (Firebase Console → Messaging → Send test message, paste the device token) with the app in the **foreground** | Floating snackbar with title and body; tapping it opens the target screen |
| Same message with the app in the **background** | System notification; tapping opens the target screen |
| Same message with the app **killed** | System notification; tapping launches the app and opens the target screen after the session resolves |
| Sign out | The device row is deleted; no further pushes arrive for that user |
| Sign in again | One row for the device (registration is an idempotent upsert) |

Tap navigation reads `data.deepLink` (or `data.deep_link`) from the FCM message. Test messages must include it, e.g. a role-agnostic path that `NotificationDeepLink.resolve` understands.

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| No permission prompt | Permission already denied; reset in Settings → Karat Hive → Notifications |
| Token is null / registration fails | Missing capability on the App ID, or the profile wasn't regenerated |
| FCM returns `APNS_AUTH_ERROR` / `THIRD_PARTY_AUTH_ERROR` | APNs key not uploaded, or wrong Key ID / Team ID |
| Works in debug, not TestFlight | `aps-environment` mismatch or an old provisioning profile |
| Foreground message shows nothing | Message has no `notification` title/body (data-only); the banner needs both |
| Tap does nothing | `deepLink` missing from `data`, or it doesn't resolve for the user's role |
