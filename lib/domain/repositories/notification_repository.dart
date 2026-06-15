import '../entities/app_notification.dart';

/// The signed-in user's notification inbox.
abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications();

  Future<int> getUnreadCount();

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();
}
