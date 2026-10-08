# Implementation Plan: FCM In-App & Local Notifications Plug-and-Play Package

| Metadata | Details |
| :--- | :--- |
| **Document** | Implementation Plan — Reusable FCM & Local Notifications Package |
| **Location** | `apps/kh_mobile/karat_hive/docs/implementation_plan_fcm_local_notifications.md` |
| **Target Packages** | `packages/kh_notifications` (New), `apps/kh_mobile/karat_hive` (Consumer) |
| **Status** | Proposed |
| **Authors** | Antigravity AI Engineering |

---

## 1. Executive Summary & Architecture Overview

### Core Objectives
1. **Decoupled Architecture**: Create a reusable, self-contained Dart/Flutter package (`packages/kh_notifications`) inside the Melos workspace that abstracts away all FCM and Flutter Local Notifications boilerplate.
2. **Unified Plug-and-Play Facade**: Expose a single `KhNotificationHelper` entry point that handles permissions, Android notification channels, iOS presentation options, background and foreground notification streams, and cold-start detection.
3. **Foreground Heads-Up & In-App Sync**: Display native heads-up system alerts when messages arrive while the app is foregrounded, while dispatching Riverpod data cache invalidation in parallel.
4. **Resilient Deep-Link Navigation**: Bridge tap events from foreground heads-up banners, background system notifications, and cold-start app launches into role-guarded routes via `NotificationDeepLink` and `GoRouter`.
5. **Token Lifecycle**: Provide an automated token retrieval and refresh callback mechanism to register device tokens with the backend (`POST /v1/devices`).

---

## 2. Package Architecture (`packages/kh_notifications`)

```
packages/kh_notifications/
├── pubspec.yaml
├── README.md
└── lib/
    ├── kh_notifications.dart                      # Public barrel exports
    └── src/
        ├── models/
        │   ├── kh_notification_config.dart        # Channel ID, icons, sound/vibration toggles
        │   └── kh_notification_message.dart       # Normalized notification payload model
        ├── local/
        │   └── kh_local_notification_service.dart # FlutterLocalNotificationsPlugin wrapper
        ├── fcm/
        │   └── kh_fcm_service.dart                # FirebaseMessaging wrapper & streams
        └── kh_notification_helper.dart           # Public facade unifying FCM + Local notifications
```

---

## 3. File Change Matrix

| Component / File | Action | Description |
| :--- | :---: | :--- |
| `pubspec.yaml` (root workspace) | `[MODIFY]` | Add `- packages/kh_notifications` to Melos workspace packages list. |
| `packages/kh_notifications/pubspec.yaml` | `[CREATE]` | Define package with `firebase_core`, `firebase_messaging`, and `flutter_local_notifications`. |
| `packages/kh_notifications/lib/kh_notifications.dart` | `[CREATE]` | Main barrel export file. |
| `packages/kh_notifications/lib/src/models/kh_notification_config.dart` | `[CREATE]` | Configuration class for Android channel, notification icons, and sound/vibration flags. |
| `packages/kh_notifications/lib/src/models/kh_notification_message.dart` | `[CREATE]` | Normalized immutable notification data model with JSON/RemoteMessage converters. |
| `packages/kh_notifications/lib/src/local/kh_local_notification_service.dart` | `[CREATE]` | Encapsulated local notification channel setup and presentation logic. |
| `packages/kh_notifications/lib/src/fcm/kh_fcm_service.dart` | `[CREATE]` | Encapsulated Firebase messaging streams and token retrieval. |
| `packages/kh_notifications/lib/src/kh_notification_helper.dart` | `[CREATE]` | High-level facade with `initialize()`, `requestPermission()`, streams, and tap handlers. |
| `apps/kh_mobile/karat_hive/pubspec.yaml` | `[MODIFY]` | Add `kh_notifications` path dependency; remove direct redundant dependencies if needed. |
| `apps/kh_mobile/karat_hive/android/app/src/main/AndroidManifest.xml` | `[MODIFY]` | Declare `POST_NOTIFICATIONS`, `VIBRATE`, default channel metadata, and notification icon. |
| `apps/kh_mobile/karat_hive/ios/Runner/Info.plist` | `[MODIFY]` | Declare remote notification background modes if missing. |
| `apps/kh_mobile/karat_hive/lib/bootstrap.dart` | `[MODIFY]` | Initialize `KhNotificationHelper` during application bootstrap. |
| `apps/kh_mobile/karat_hive/lib/app/notifications/push_invalidation_binder.dart` | `[MODIFY]` | Connect Riverpod invalidation and deep-link routing to `KhNotificationHelper` streams. |

---

## 4. Detailed Component Specifications

### 4.1. Models & Configuration

#### `KhNotificationConfig`
```dart
class KhNotificationConfig {
  const KhNotificationConfig({
    this.androidChannelId = 'kh_high_importance_channel',
    this.androidChannelName = 'Karat Hive Alerts',
    this.androidChannelDescription = 'Urgent notifications for requests, offers, and connections.',
    this.defaultAndroidIcon = '@mipmap/ic_launcher',
    this.enableVibration = true,
    this.playSound = true,
  });

  final String androidChannelId;
  final String androidChannelName;
  final String androidChannelDescription;
  final String defaultAndroidIcon;
  final bool enableVibration;
  final bool playSound;
}
```

#### `KhNotificationMessage`
```dart
class KhNotificationMessage {
  const KhNotificationMessage({
    required this.id,
    required this.data,
    this.title,
    this.body,
    this.deepLink,
  });

  final String id;
  final String? title;
  final String? body;
  final Map<String, dynamic> data;
  final String? deepLink;

  factory KhNotificationMessage.fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    return KhNotificationMessage(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? data['title']?.toString(),
      body: message.notification?.body ?? data['body']?.toString(),
      data: data,
      deepLink: data['deep_link']?.toString() ?? data['deepLink']?.toString(),
    );
  }
}
```

---

### 4.2. Helper Facade API (`KhNotificationHelper`)

The helper will implement the following contract:
- `Future<void> initialize({KhNotificationConfig config, bool showForegroundLocalAlerts, BackgroundMessageHandler? onBackgroundMessage})`
- `Future<bool> requestPermission()`
- `Future<String?> getToken()`
- `Stream<String> get onTokenRefresh`
- `Stream<KhNotificationMessage> get onForegroundMessage`
- `Stream<KhNotificationMessage> get onNotificationTapped`
- `Future<KhNotificationMessage?> getInitialMessage()`
- `Future<void> showLocalNotification({required int id, required String title, required String body, String? payload})`

---

### 4.3. Mobile App Integration in `karat_hive`

#### A. Bootstrap Lifecycle (`lib/bootstrap.dart`)
1. Call `await notificationHelper.initialize(onBackgroundMessage: firebaseMessagingBackgroundHandler)`.
2. Retrieve `initialMessage = await notificationHelper.getInitialMessage()`.
3. If an initial message exists with `deepLink`, store it in a pending navigation provider to route after router mount.

#### B. Stream Wiring (`lib/app/notifications/push_invalidation_binder.dart`)
1. Listen to `notificationHelper.onForegroundMessage`:
   - Execute `PushInvalidationPlan.fromData(msg.data).apply(ref)`.
2. Listen to `notificationHelper.onNotificationTapped`:
   - Parse `msg.deepLink`.
   - Invoke `NotificationDeepLink.open(context, msg.deepLink, isVendor: session.isVendor)`.
3. Listen to `notificationHelper.onTokenRefresh`:
   - Sync new device token with backend device registration endpoint (`/v1/devices`).

---

## 5. Native Platform Configuration Checklist

### Android
- [ ] Add `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` in `AndroidManifest.xml`.
- [ ] Add `<uses-permission android:name="android.permission.VIBRATE"/>`.
- [ ] Set default FCM channel metadata (`com.google.firebase.messaging.default_notification_channel_id`).
- [ ] Verify `launchMode="singleTop"` on `MainActivity`.

### iOS
- [ ] Add `remote-notification` and `fetch` under `UIBackgroundModes` in `ios/Runner/Info.plist`.
- [ ] Ensure APNs certificates or auth keys are properly provisioned in Firebase Console.

---

## 6. Implementation Steps & Milestones

1. **Phase 1: Workspace Package Setup**
   - Create `packages/kh_notifications` directory and structure.
   - Author `pubspec.yaml` and run `dart pub get` / `melos bootstrap`.
   - Implement models, FCM wrapper, Local Notification service, and `KhNotificationHelper`.

2. **Phase 2: App Dependency & Native Configuration**
   - Link `kh_notifications` in `apps/kh_mobile/karat_hive/pubspec.yaml`.
   - Update Android manifest and iOS plist settings.

3. **Phase 3: Service Integration**
   - Refactor `bootstrap.dart` to initialize the helper.
   - Refactor `push_invalidation_binder.dart` to consume unified foreground and tap streams.
   - Wire cold-start `getInitialMessage()` handling into the router launch flow.

4. **Phase 4: Unit Testing & Verification**
   - Write tests for `KhNotificationMessage` serialization and mapping.
   - Mock notification helper streams to verify Riverpod invalidation and deep-link routing.
   - Validate static analysis with `melos run analyze`.

---

## 7. Verification & Testing Matrix

| Scenario | Trigger / Action | Expected Behavior |
| :--- | :--- | :--- |
| **Foreground Push** | Send FCM while viewing Request Details screen. | Native heads-up alert shows at top of screen; Riverpod cache refreshes in-place. |
| **Foreground Tap** | Tap the heads-up notification. | App routes to the linked screen via `NotificationDeepLink`. |
| **Background Tap** | App in background; tap notification in system tray. | App resumes to foreground and opens target route. |
| **Cold Start Tap** | App killed; tap notification in system tray. | App launches, authenticates session, runs route guards, and lands on target screen. |
| **Token Refresh** | Invalidate or rotate FCM token. | `onTokenRefresh` stream emits and updates backend records. |
