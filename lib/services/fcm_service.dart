import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/widgets.dart';

import '../controller/const/base_url.dart';
import '../controller/ads/data_layer.dart' show ourSecret;
import '../view/screens/notifications/notifications.dart';
import 'local_notification_service.dart' show handleTapAndOpenNotifications;

/// نفس القناة المستخدمة في تطبيق الأندرويد (GeneralChannel).
/// السيرفر بيبعت data-only messages بالمفاتيح: dTitle / dBody / dChannel_ID / dLanguage
const String kGeneralChannelId = 'GeneralChannel';
const String kGeneralChannelName = 'General Notifications';

/// Background handler — لازم تكون top-level function مش جوه class،
/// وبتتسجل في main.dart قبل runApp.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await FCMService.showLocalNotification(message);
}

class FCMService extends GetxService {
  static FCMService get to => Get.find();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _fcmTokenKey = 'firebase_Token';

  // Stream to handle incoming messages
  final _messageStreamController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onMessageReceived => _messageStreamController.stream;

  Future<void> initialize() async {
    try {
      await _initializeLocalNotifications();

      // Request permissions (بيغطي Android 13+ POST_NOTIFICATIONS و iOS)
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print('Notification settings: ${settings.authorizationStatus}');
      }

      // Get FCM token and sync it with the server
      await sendTokenToServer();

      // لو Firebase جدد الـ token نبعت الجديد للسيرفر (زي onNewToken في الأندرويد)
      _fcm.onTokenRefresh.listen((newToken) {
        sendTokenToServer(freshToken: newToken);
      });

      // Listen for messages
      _setupMessageHandlers();

      // الاشتراك في topic اللغة الحالية (Only_Arabic / Only_English)
      final prefs = await SharedPreferences.getInstance();
      await subscribeToLanguageTopic(prefs.getString('language') ?? 'en');
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing FCM: $e');
      }
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(
        // الـ permission بيتطلب من FirebaseMessaging.requestPermission
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        // Default foreground-presentation options — same rationale as
        // LocalNotificationService: without these, iOS may swallow the
        // banner even when per-notification `presentBanner:true` is set.
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
        defaultPresentBanner: true,
        defaultPresentList: true,
      ),
    );
    // Shared tap handler — MUST match the one in LocalNotificationService
    // and the one below in `showLocalNotification`. The plugin only holds
    // one global tap callback; the last `initialize` wins, so all three
    // sites must pass the same handler or notifications stop navigating.
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: handleTapAndOpenNotifications,
    );

    // إنشاء القناة على أندرويد بنفس الاسم والأهمية بتوع تطبيق الأندرويد
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            kGeneralChannelId,
            kGeneralChannelName,
            importance: Importance.high,
          ),
        );
  }

  void _setupMessageHandlers() {
    // Handle when app is in foreground:
    // زي الأندرويد — مفيش إشعار في الـ system tray، بنبلغ الـ controller بس
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Message received in foreground: ${message.messageId}');
      }
      _messageStreamController.add(message);
    });

    // Handle when app is opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleMessage(message);
      }
    });

    // Handle when app is in background but opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Handling message: ${message.messageId}');
      print('Message data: ${message.data}');
    }

    // Route the user into the in-app notifications screen so they see
    // their full history. Deferred to the next frame in case this is a
    // cold-start (terminated state → tapped push) and the navigator
    // isn't ready yet. Duplicates are prevented by `Get.to` default.
    void tryNavigate() {
      try {
        Get.to<void>(() => NotificationsPage());
      } catch (e) {
        if (kDebugMode) {
          print('FCMService: navigation on tap failed: $e');
        }
      }
    }

    if (Get.context == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => tryNavigate());
    } else {
      tryNavigate();
    }
  }

  /// عرض إشعار محلي لرسائل الـ data-only (بيتنده من الـ background handler).
  /// نفس منطق sendNotification في الأندرويد: GeneralChannel فقط.
  static Future<void> showLocalNotification(RemoteMessage message) async {
    // لو الرسالة فيها notification block النظام بيعرضها لوحده — منكررش
    if (message.notification != null) return;

    final data = message.data;
    final channelId = data['dChannel_ID'] ?? kGeneralChannelId;
    if (channelId != kGeneralChannelId) return;

    final title = data['dTitle'];
    final body = data['dBody'];
    if (title == null && body == null) return;

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    // Shared tap handler — see the note in _initializeLocalNotifications.
    // Background-handler path: this runs when a data-only FCM lands while
    // the app is backgrounded/terminated, so if we omit the callback here
    // the plugin's global slot ends up null and taps stop navigating.
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: handleTapAndOpenNotifications,
    );

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        kGeneralChannelId,
        kGeneralChannelName,
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(body ?? ''),
      ),
      // iOS presentation options — REQUIRED for the notification to
      // appear as a banner when the app is in the foreground. Without
      // these, iOS silently delivers the notification (no visual UI)
      // even though the local plugin fires it. `interruptionLevel:
      // active` explicitly marks the notification as prominent so
      // iOS doesn't demote it to passive.
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
    await _localNotifications.show(id, title, body, details);
  }

  /// إرسال الـ token للسيرفر — نفس UpdateUserTokenV2 في الأندرويد.
  /// بيتنده: عند الإقلاع، عند تجديد الـ token، بعد اللوجين، وعند تغيير اللغة.
  Future<void> sendTokenToServer({String? freshToken, String? language}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('username') ?? '0';
      final lang = language ?? prefs.getString('language') ?? 'en';
      final oldToken = prefs.getString(_fcmTokenKey) ?? 'NA';

      final newToken = freshToken ?? await _fcm.getToken();
      if (newToken == null) return;

      await prefs.setString(_fcmTokenKey, newToken);

      final url = Uri.parse('$base_url/UserRelatedApi.asmx/UpdateUserTokenV2');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'UserName': userName.isEmpty ? '0' : userName,
          'Old_Token': oldToken,
          'New_Token': newToken,
          'Prefered_Language': lang,
          'Our_Secret': ourSecret,
        },
      );

      if (kDebugMode) {
        print('UpdateUserTokenV2 (${response.statusCode}) for $userName');
        print('FCM Token: $newToken');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending FCM token to server: $e');
      }
    }
  }

  /// الاشتراك في topic حسب اللغة — نفس منطق الأندرويد بالظبط
  /// (Only_Arabic / Only_English) عشان إشعارات السيرفر الجماعية توصل صح.
  Future<void> subscribeToLanguageTopic(String langCode) async {
    try {
      final subscribeTo = langCode == 'ar' ? 'Only_Arabic' : 'Only_English';
      final unsubscribeFrom = langCode == 'ar' ? 'Only_English' : 'Only_Arabic';

      await _fcm.subscribeToTopic(subscribeTo);
      await _fcm.unsubscribeFromTopic(unsubscribeFrom);

      if (kDebugMode) {
        print('Subscribed to topic: $subscribeTo, unsubscribed from: $unsubscribeFrom');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating topic subscription: $e');
      }
    }
  }

  // Call this when user logs in or language changes
  Future<void> updateFCMToken({String? newToken, String? language}) async {
    await sendTokenToServer(freshToken: newToken, language: language);
  }

  // Get current FCM token
  Future<String?> getCurrentToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current FCM token: $e');
      }
      return null;
    }
  }

  @override
  void onClose() {
    _messageStreamController.close();
    super.onClose();
  }
}
