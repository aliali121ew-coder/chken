import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/supabase_client_provider.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(ref.watch(supabaseClientProvider));
});

final notificationsProvider = FutureProvider<List<AppNotification>>((ref) {
  return ref.watch(notificationRepositoryProvider).getNotifications();
});

final unreadNotificationCountProvider = FutureProvider<int>((ref) {
  return ref.watch(notificationRepositoryProvider).getUnreadCount();
});

/// Drives notification mutations (mark read / mark all read).
class NotificationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> markAsRead(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(notificationRepositoryProvider).markAsRead(id);
    });
    ref.invalidate(notificationsProvider);
    ref.invalidate(unreadNotificationCountProvider);
  }

  Future<void> markAllAsRead() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(notificationRepositoryProvider).markAllAsRead();
    });
    ref.invalidate(notificationsProvider);
    ref.invalidate(unreadNotificationCountProvider);
  }
}

final notificationControllerProvider = AsyncNotifierProvider<NotificationController, void>(NotificationController.new);
