import 'dart:developer';

import 'package:get_storage/get_storage.dart';

import '../model/notification_model.dart';

/// Persistent store for locally-generated notifications (i.e. notifications
/// fired via `LocalNotificationService` — payment confirmations, ad-created
/// summaries, etc.).
///
/// Complements the API-fetched notifications loaded by `NotificationsController`
/// — this store handles the ones the client generates on-device. The two lists
/// are merged for display but kept separate for storage/lifecycle purposes.
///
/// Uses `get_storage` (already initialised in `main.dart`) so no schema or
/// migration is required. Bounded to [_maxRetained] entries to avoid unbounded
/// growth on long-lived installs.
class NotificationsStore {
  NotificationsStore._();

  static final NotificationsStore instance = NotificationsStore._();

  static const String _storageKey = 'local_notifications_v1';
  static const int _maxRetained = 200;

  final GetStorage _box = GetStorage();

  /// Returns all locally-persisted notifications, newest first.
  List<NotificationModel> getAll() {
    try {
      final dynamic raw = _box.read(_storageKey);
      if (raw is! List) return <NotificationModel>[];
      return raw
          .whereType<Map>()
          .map(
            (m) => NotificationModel.fromMap(Map<String, dynamic>.from(m)),
          )
          .toList();
    } catch (e) {
      log('NotificationsStore.getAll failed: $e');
      return <NotificationModel>[];
    }
  }

  /// Number of stored notifications that are still marked unread.
  int unreadCount() {
    try {
      return getAll().where((n) => !n.isRead).length;
    } catch (_) {
      return 0;
    }
  }

  /// Prepend a new notification to the store. Trims the tail so we never
  /// exceed [_maxRetained] persisted entries.
  Future<void> add(NotificationModel notification) async {
    try {
      final List<NotificationModel> list = getAll();
      list.insert(0, notification);
      if (list.length > _maxRetained) {
        list.removeRange(_maxRetained, list.length);
      }
      final List<Map<String, dynamic>> raw =
          list.map((n) => n.toMap()).toList();
      await _box.write(_storageKey, raw);
    } catch (e) {
      log('NotificationsStore.add failed: $e');
    }
  }

  /// Mark every persisted notification as read. Used when the user opens the
  /// notifications page — clears the local contribution to the unread badge.
  Future<void> markAllAsRead() async {
    try {
      final List<NotificationModel> list =
          getAll().map((n) => n.copyWith(isRead: true)).toList();
      if (list.isEmpty) return;
      final List<Map<String, dynamic>> raw =
          list.map((n) => n.toMap()).toList();
      await _box.write(_storageKey, raw);
    } catch (e) {
      log('NotificationsStore.markAllAsRead failed: $e');
    }
  }

  /// Delete a single persisted notification, identified by its `date`.
  /// Locally-fired notifications carry a `DateTime.now()` timestamp at their
  /// millisecond precision, which is unique in practice and is what the UI
  /// uses as the dismiss target.
  Future<void> removeByDate(DateTime date) async {
    try {
      final int key = date.millisecondsSinceEpoch;
      final List<NotificationModel> list = getAll();
      final int before = list.length;
      list.removeWhere((n) => n.date.millisecondsSinceEpoch == key);
      if (list.length == before) return;
      final List<Map<String, dynamic>> raw =
          list.map((n) => n.toMap()).toList();
      await _box.write(_storageKey, raw);
    } catch (e) {
      log('NotificationsStore.removeByDate failed: $e');
    }
  }

  /// Delete all locally-persisted notifications. Intended for account
  /// switches / sign-out where local state must not leak between users.
  Future<void> clear() async {
    try {
      await _box.remove(_storageKey);
    } catch (e) {
      log('NotificationsStore.clear failed: $e');
    }
  }
}
