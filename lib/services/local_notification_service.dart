import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../controller/notifications_controller.dart';
import '../model/notification_model.dart';
import '../view/screens/notifications/notifications.dart';
import 'fcm_service.dart' show kGeneralChannelId, kGeneralChannelName;
import 'notifications_store.dart';

/// Lightweight wrapper around `flutter_local_notifications` for firing local
/// (device-side) notifications outside the FCM remote pipeline.
///
/// Reuses the same `GeneralChannel` that `FCMService` uses for its remote-push
/// notifications, so a single Android channel controls both. Idempotent
/// initialization: the plugin and the channel are only registered once per
/// process, regardless of how many times [showLocalNotification] is called.
///
/// This service intentionally does NOT touch the existing remote-notification
/// flow in `FCMService`. It only *adds* a code path for local notifications.
class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Keys we have already notified about in this app session. Prevents
  /// double-firing if a widget rebuild or navigation re-enters a success
  /// branch with the same identifier. Keys are namespaced with a short prefix
  /// so payment IDs and post IDs cannot collide.
  final Set<String> _notifiedKeys = <String>{};

  /// Public entry point so `main.dart` can trigger initialization at app
  /// startup — before any notification can arrive — so the plugin's global
  /// tap-callback slot is set from t=0 in the main isolate.
  Future<void> initialize() => _ensureInitialized();

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(
        // Request permission from flutter_local_notifications ITSELF
        // (in addition to FirebaseMessaging.requestPermission which
        // FCMService already calls). Two reasons:
        //   1. Ensures the flutter_local_notifications plugin's iOS
        //      side sets up its UNUserNotificationCenter delegate.
        //   2. When Firebase's app-delegate proxy swizzling wins, our
        //      delegate can be silently dropped — explicitly asking
        //      here forces the plugin to re-register.
        // The prompt is idempotent — iOS won't re-ask the user if
        // permission is already granted.
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        // Default foreground-presentation options — in
        // flutter_local_notifications v18+ these seed the plugin's
        // internal UNUserNotificationCenter delegate.
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
        defaultPresentBanner: true,
        defaultPresentList: true,
      ),
    );
    await _plugin.initialize(
      initSettings,
      // Fires when the user taps a local notification we posted (from any
      // app state: foreground / background / terminated). Routes into the
      // in-app notifications screen so the user sees their history.
      //
      // The plugin's tap handler is a single global slot — every
      // `FlutterLocalNotificationsPlugin.initialize(...)` call anywhere in
      // the app overwrites it. So all `initialize` sites (this one and the
      // two in FCMService) MUST pass the same callback, otherwise the last
      // one to run wins and strips the handler. `handleTapAndOpenNotifications`
      // is the shared entry point used by all three.
      onDidReceiveNotificationResponse: handleTapAndOpenNotifications,
    );

    // Recreate the same channel FCMService uses — idempotent on Android.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
      const AndroidNotificationChannel(
        kGeneralChannelId,
        kGeneralChannelName,
        importance: Importance.high,
      ),
    );

    _initialized = true;

    // Terminated-state tap handling. When the app is fully killed and the
    // user taps a local notification, the OS launches the app but
    // `onDidReceiveNotificationResponse` does NOT fire — the tap is
    // instead reported here, ONCE, via `getNotificationAppLaunchDetails`.
    // Route to the notifications page after the first frame so the
    // navigator is mounted.
    try {
      final NotificationAppLaunchDetails? launch =
          await _plugin.getNotificationAppLaunchDetails();
      final bool launchedByTap =
          launch?.didNotificationLaunchApp ?? false;
      if (launchedByTap) {
        if (kDebugMode) {
          print('🔔 App was launched via a local notification tap.');
        }
        _openNotificationsPage();
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔔 getNotificationAppLaunchDetails failed: $e');
      }
    }
  }

  /// Push the in-app notifications screen. Uses the root navigator key
  /// (not `Get.to`) so:
  ///   • The push happens regardless of `preventDuplicates` — even when
  ///     NotificationsPage is already somewhere in the stack, the tap
  ///     brings the user to a fresh instance.
  ///   • No dependency on `Get.context`, which is unreliable when the
  ///     tap fires while the app is transitioning between states.
  ///
  /// Falls back to `Get.to` in the (very unlikely) event the navigator
  /// key is not yet attached. Guarded by a post-frame deferral for
  /// cold-start-from-tap.
  void _openNotificationsPage() {
    void tryNavigate() {
      try {
        final NavigatorState? nav = Get.key.currentState;
        if (kDebugMode) {
          print('🔔 Attempting to push NotificationsPage. '
              'navState=${nav != null}, ctx=${Get.context != null}');
        }
        if (nav != null) {
          nav.push(
            MaterialPageRoute<void>(builder: (_) => NotificationsPage()),
          );
          return;
        }
        // Fallback for the odd case where the navigator key isn't attached.
        Get.to<void>(() => NotificationsPage(), preventDuplicates: false);
      } catch (e, s) {
        if (kDebugMode) {
          print('🔔 Navigation to NotificationsPage failed: $e\n$s');
        }
      }
    }

    // Defer to the next frame if the navigator isn't ready yet
    // (cold-start-from-tap path).
    if (Get.key.currentState == null) {
      if (kDebugMode) {
        print('🔔 Navigator not ready — deferring to post-frame.');
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => tryNavigate());
    } else {
      tryNavigate();
    }
  }

  /// Fire a local notification.
  ///
  /// [title] and [body] are the visible content. [payload] is an optional
  /// string carried through to the tap handler (currently the tap handler is
  /// a no-op — future navigation logic can consume the payload here).
  ///
  /// This method is safe to call multiple times: any failure is caught and
  /// logged in debug builds so a missed notification never breaks the caller
  /// (e.g. a payment success flow).
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    String? carId,
    String? carImageUrl,
  }) async {
    // 1) Fire the OS-level notification (visible on the device).
    try {
      await _ensureInitialized();

      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          kGeneralChannelId,
          kGeneralChannelName,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
        // iOS presentation options — REQUIRED for the notification to
        // appear as a banner when the app is in the foreground. Without
        // these, the notification is silently delivered (no visual UI)
        // even though it's stored in the app's local list. Android
        // handles foreground presentation via the channel importance
        // above and doesn't need this.
        //
        // `interruptionLevel: active` (the iOS 15+ default) explicitly
        // marks the notification as "prominent" — otherwise iOS can
        // classify it as passive and drop the banner even in the
        // Notification Center. Firebase's UNUserNotificationCenter
        // proxy swizzling has been observed to demote unmarked
        // notifications to passive, so being explicit here is
        // belt-and-suspenders.
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          presentBanner: true,
          presentList: true,
          interruptionLevel: InterruptionLevel.active,
        ),
      );

      final id = DateTime.now().millisecondsSinceEpoch.remainder(0x7FFFFFFF);
      if (kDebugMode) {
        debugPrint('🔔 Firing OS notification id=$id title="$title"');
      }
      await _plugin.show(id, title, body, details, payload: payload);
      if (kDebugMode) {
        debugPrint('🔔 OS notification .show() completed for id=$id');
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('🔔 LocalNotificationService.showLocalNotification failed: $e\n$st');
      }
    }

    // 2) Persist to the local store so it shows up on the notifications page
    //    even after a restart, and mirror it into the in-memory list of the
    //    NotificationsController if that controller is currently registered.
    //    Both operations are independent of step 1 — a failure to display the
    //    OS notification must not prevent the user's on-screen list from
    //    picking it up.
    //
    // Car-specific extras:
    //   • [carId] is stored on `postCode` — semantically the same "identifier
    //     for the linked post" field the API notifications already use, so the
    //     rendering card can treat both sources uniformly.
    //   • [carImageUrl] is carried inside `data` and consumed by the notification
    //     card to render a thumbnail on the trailing edge.
    final NotificationModel model = NotificationModel(
      title: title,
      reason: body,
      postCode: carId,
      date: DateTime.now().toUtc(),
      isRead: false,
      data: <String, dynamic>{
        'source': 'local',
        if (payload != null) 'payload': payload,
        if (carId != null) 'carId': carId,
        if (carImageUrl != null && carImageUrl.trim().isNotEmpty)
          'carImageUrl': carImageUrl.trim(),
      },
    );

    try {
      await NotificationsStore.instance.add(model);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('LocalNotificationService: persist failed: $e');
      }
    }

    try {
      if (Get.isRegistered<NotificationsController>()) {
        Get.find<NotificationsController>().addLocalNotification(model);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('LocalNotificationService: controller refresh failed: $e');
      }
    }
  }

  /// Fire a payment-success notification at most once per unique [paymentId].
  ///
  /// Guarantees exactly-once delivery within a single app session for a given
  /// backend-signed payment ID. Empty payment IDs are ignored (a missing
  /// paymentId already signals "not really successful" in the payment flow).
  Future<void> notifyPaymentSuccessOnce({
    required String paymentId,
    required String title,
    required String body,
    String? payload,
    String? carId,
    String? carImageUrl,
  }) async {
    await _notifyOnce(
      key: 'payment:$paymentId',
      rawId: paymentId,
      title: title,
      body: body,
      payload: payload ?? paymentId,
      carId: carId,
      carImageUrl: carImageUrl,
    );
  }

  /// Fire an ad-creation notification at most once per unique [postId].
  ///
  /// Used at the tail end of the create-ad flow to inform the user that their
  /// post landed successfully, along with its resulting status (Draft or
  /// Pending Approval) and any confirmed paid services from the same session.
  Future<void> notifyAdCreatedOnce({
    required String postId,
    required String title,
    required String body,
    String? payload,
    String? carImageUrl,
  }) async {
    await _notifyOnce(
      key: 'post_created:$postId',
      rawId: postId,
      title: title,
      body: body,
      payload: payload ?? postId,
      // The ad-created notification always relates to the just-created post,
      // so use its ID as the car identifier for the card thumbnail linkage.
      carId: postId,
      carImageUrl: carImageUrl,
    );
  }

  Future<void> _notifyOnce({
    required String key,
    required String rawId,
    required String title,
    required String body,
    String? payload,
    String? carId,
    String? carImageUrl,
  }) async {
    if (rawId.isEmpty) return;
    if (_notifiedKeys.contains(key)) return;
    _notifiedKeys.add(key);

    await showLocalNotification(
      title: title,
      body: body,
      payload: payload,
      carId: carId,
      carImageUrl: carImageUrl,
    );
  }
}

/// Top-level `onDidReceiveNotificationResponse` shared by every
/// `FlutterLocalNotificationsPlugin.initialize(...)` call in the app
/// ([LocalNotificationService], [FCMService.initialize],
/// [FCMService.showLocalNotification]).
///
/// Must stay top-level (not a method) so any future background-isolate
/// wiring can reference the same symbol without an instance capture.
@pragma('vm:entry-point')
void handleTapAndOpenNotifications(NotificationResponse response) {
  if (kDebugMode) {
    print('🔔 handleTapAndOpenNotifications fired. '
        'payload=${response.payload}, type=${response.notificationResponseType}');
  }
  LocalNotificationService.instance._openNotificationsPage();
}
