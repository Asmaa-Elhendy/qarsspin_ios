import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer';

import '../model/notification_model.dart';
import '../services/notification_database.dart';
import '../services/notifications_store.dart';
import '../services/fcm_service.dart';
import 'ads/data_layer.dart';
import 'auth/auth_controller.dart'; // لو فعلاً مستخدمه

class NotificationsController extends GetxController {
  final RxList<NotificationModel> _notifications = <NotificationModel>[].obs;
  final RxBool _isLoading = false.obs;
  // Unread count coming from the backend (API `Count` field), tracked
  // separately from locally-generated unread notifications so the two
  // sources can be summed for the badge without conflict.
  final RxInt _apiUnreadCount = 0.obs;
  final RxInt _localUnreadCount = 0.obs;
  final NotificationDatabase _database = NotificationDatabase();
  final FCMService _fcmService = Get.find<FCMService>();

  // Newest-first: `addLocalNotification` and `_hydrateLocalNotifications`
  // both `insert(0, ...)` so the freshest local entries sit at the head
  // of `_notifications`, followed by API notifications (already sorted
  // newest-first by the backend). Returning as-is keeps that ordering
  // for the UI — no `.reversed`, which was flipping it to oldest-first.
  List<NotificationModel> get notifications => _notifications.toList();
  bool get isLoading => _isLoading.value;
  /// Total unread badge count = backend-unread + locally-generated unread.
  int get notificationCount => _apiUnreadCount.value + _localUnreadCount.value;

  @override
  void onInit() {
    super.onInit();
    _setupFCMListeners();
    getNotifications();

    // لما يفتح التطبيق من إشعار (terminated state)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessage(message);
      }
    });
  }

  /// 🔹 جلب الإشعارات من API
  Future<void> getNotifications() async {
    final authController = Get.find<AuthController>();

    try {
      _isLoading.value = true;
      final userName = authController.userName ?? '';
      log('📡 Fetching notifications for user: $userName');

      // ✅ لو اليوزر فاضي (ده سبب "Missing Parameter")
      if (userName.trim().isEmpty) {
        log('⚠️ userName is empty. API will return Missing Parameter.');
        _notifications.clear();
        _apiUnreadCount.value = 0;
        _hydrateLocalNotifications();
     //   Get.snackbar('Error', 'User name is missing');
        return;
      }

      // Get the response data first
      final responseData = await _database.fetchNotificationsFromAPI(
        userName: userName,
        ourSecret: ourSecret,
      );

      // ✅ لو API رجعت Error
      final code = responseData['Code']?.toString();
      if (code != null && code.toLowerCase() == 'error') {
        final desc = responseData['Desc']?.toString() ?? 'Unknown error';
        log('⚠️ API returned error: $desc');

        _notifications.clear();
        _apiUnreadCount.value = 0;
        _hydrateLocalNotifications();

        Get.snackbar('Error', desc);
        return;
      }

      // ✅ استخراج Data بشكل آمن
      final rawData = responseData['Data'];
      final List<dynamic> notificationsData =
      rawData is List ? rawData : <dynamic>[];

      final List<NotificationModel> apiNotifications =
      notificationsData.map((item) {
        final m = item is Map<String, dynamic> ? item : <String, dynamic>{};

        return NotificationModel(
          id: m['Notification_ID'] is int
              ? m['Notification_ID']
              : int.tryParse(m['Notification_ID']?.toString() ?? '0') ?? 0,
          title: "Qars Spin Update for Post ${m['Notification_ID']}",
          date: DateTime.tryParse(m['Subscription_Date']?.toString() ?? '') ??
              DateTime.now(),

          // Add other fields as needed
          postKind: m['Post_Kind']?.toString() ?? '',
          postCode: m['Post_Code']?.toString() ?? '',
          status: m['Status']?.toString() ?? '',
          reason: m['Remarks']?.toString() ?? '',
          summaryPL: m['Notification_Summary_PL']?.toString() ?? '',
          summarySL: m['Notification_Summary_SL']?.toString() ?? '',
          data: m,
        );
      }).toList();

      log('📩 Notifications received: ${apiNotifications.length}');
      _notifications
        ..clear()
        ..addAll(apiNotifications);

      // Merge locally-generated notifications (payment, ad-created, etc.)
      // so they appear on the same page as the backend notifications.
      _hydrateLocalNotifications();

      // ✅ Update the count from API response
      if (responseData['Count'] != null) {
        _apiUnreadCount.value = responseData['Count'] is int
            ? responseData['Count']
            : int.tryParse(responseData['Count'].toString()) ??
                apiNotifications.length;
        log('📊 Notification count from API: ${_apiUnreadCount.value}');
      } else {
        // Fallback to list length if count is not available
        _apiUnreadCount.value = apiNotifications.length;
      }

      if (_notifications.isEmpty) {
        log('⚠️ No notifications found.');
      } else {
        log('✅ Loaded ${_notifications.length} notifications into controller.');
      }
    } catch (e, s) {
      log('❌ Error loading notifications: $e');
      log('$s');
      Get.snackbar('Error', 'Failed to load notifications');
    } finally {
      _isLoading.value = false;
    }
  }

  /// 🔹 تهيئة مستمعي الـ FCM
  void _setupFCMListeners() {
    _fcmService.onMessageReceived.listen((message) async {
      try {
        final notification = NotificationModel.fromFCM(message);

        // أضف الإشعار الجديد مباشرة للقائمة وحدّث العداد
        _notifications.insert(0, notification);
        _notifications.refresh();
        _apiUnreadCount.value++;

        // عرض Snackbar — السيرفر بيبعت data-only messages
        // فالعنوان والنص في dTitle/dBody (متظبطين جوه الموديل) مش في message.notification
        if (Get.isSnackbarOpen != true) {
          Get.snackbar(
            notification.title,
            notification.reason ?? '',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error handling new FCM notification: $e');
        }
      }
    });
  }

  /// 🔹 التعامل مع إشعار تم النقر عليه
  void _handleMessage(RemoteMessage message) {
    try {
      final notification = NotificationModel.fromFCM(message);
      _navigateBasedOnNotification(notification);
    } catch (e) {
      if (kDebugMode) {
        print('Error handling FCM message: $e');
      }
    }
  }

  /// 🔹 التنقل بناءً على الإشعار
  void _navigateBasedOnNotification(NotificationModel notification) {
    try {
      if (notification.postCode != null) {
        // مثال: فتح صفحة إعلان
        // Get.to(() => PostDetailsScreen(postId: notification.postCode!));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error navigating based on notification: $e');
      }
    }
  }

  /// 🔹 تحديث توكن الـ FCM
  Future<void> updateFCMToken() async {
    try {
      await _fcmService.updateFCMToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating FCM token: $e');
      }
    }
  }

  /// Reload the local-notifications slice of the in-memory list from
  /// [NotificationsStore]. Removes any existing local entries first so the
  /// method is fully idempotent — calling it multiple times cannot create
  /// duplicates.
  ///
  /// Locally-generated entries are identified by `data['source'] == 'local'`,
  /// which is set by [LocalNotificationService] when it persists them.
  /// API-sourced entries are left untouched.
  void _hydrateLocalNotifications() {
    try {
      // Wipe any existing local entries before re-inserting fresh copies
      // from the store. This is the single guarantee against duplicate
      // rendering when this method is invoked repeatedly during a session
      // (page opens, live add via addLocalNotification, etc.).
      _notifications.removeWhere((n) => n.data?['source'] == 'local');

      final List<NotificationModel> local =
          NotificationsStore.instance.getAll();
      if (local.isNotEmpty) {
        // Prepend so they render alongside API results in the existing
        // `reversed` getter (newest first).
        _notifications.insertAll(0, local);
      }
      _notifications.refresh();
      _localUnreadCount.value = local.where((n) => !n.isRead).length;
    } catch (e) {
      if (kDebugMode) {
        print('Error hydrating local notifications: $e');
      }
    }
  }

  /// Called by [LocalNotificationService] right after a new local
  /// notification is persisted. Routes through [_hydrateLocalNotifications]
  /// so the in-memory list is rebuilt from the store — cannot produce a
  /// duplicate even if the caller (or a widget) invokes this multiple times.
  void addLocalNotification(NotificationModel notification) {
    try {
      _hydrateLocalNotifications();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding local notification to controller: $e');
      }
    }
  }

  /// Mark every locally-persisted notification as read and reset the local
  /// unread counter. Called by the notifications page when the user opens it.
  ///
  /// Does not touch the backend (`API`) unread count — the backend is the
  /// source of truth for its own unread state and should be updated by a
  /// separate server call if/when that feature exists.
  Future<void> markAllAsRead() async {
    try {
      await NotificationsStore.instance.markAllAsRead();
      _localUnreadCount.value = 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error marking notifications as read: $e');
      }
    }
  }

  /// Delete a single locally-persisted notification (identified by its
  /// `date`) from disk, then refresh the in-memory list so the deletion
  /// is reflected in the UI immediately.
  ///
  /// A no-op for API-sourced notifications — those must be removed on the
  /// backend and cannot be dismissed client-side without them reappearing
  /// on the next fetch.
  Future<void> deleteLocalNotification(NotificationModel notification) async {
    try {
      final bool isLocal = notification.data?['source'] == 'local';
      if (!isLocal) return;
      await NotificationsStore.instance.removeByDate(notification.date);
      _hydrateLocalNotifications();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting local notification: $e');
      }
    }
  }

  /// Wipe every locally-persisted notification (payment / ad-created /
  /// etc.) and refresh the in-memory list. Backend notifications are
  /// untouched.
  Future<void> clearAllLocalNotifications() async {
    try {
      await NotificationsStore.instance.clear();
      _hydrateLocalNotifications();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing local notifications: $e');
      }
    }
  }
}
