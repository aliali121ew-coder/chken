import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_notification.dart';
import '../../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/notification_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final languageCode = ref.watch(localeProvider).languageCode;
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications_title),
        actions: [
          IconButton(
            tooltip: l10n.notifications_markAllRead,
            icon: const Icon(Icons.done_all),
            onPressed: () => ref.read(notificationControllerProvider.notifier).markAllAsRead(),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.common_error),
              TextButton(
                onPressed: () => ref.invalidate(notificationsProvider),
                child: Text(l10n.common_retry),
              ),
            ],
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(child: Text(l10n.notifications_empty));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(notificationsProvider.future),
            child: ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) => _NotificationTile(
                notification: notifications[index],
                languageCode: languageCode,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification, required this.languageCode});

  final AppNotification notification;
  final String languageCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final body = notification.body(languageCode);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: notification.isRead
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.primaryContainer,
        child: Icon(_iconForType(notification.type), size: 20),
      ),
      title: Text(
        notification.title(languageCode),
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: body != null ? Text(body) : null,
      trailing: notification.isRead
          ? null
          : Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
            ),
      onTap: notification.isRead
          ? null
          : () => ref.read(notificationControllerProvider.notifier).markAsRead(notification.id),
    );
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'order_status':
        return Icons.receipt_long_outlined;
      case 'new_message':
        return Icons.chat_bubble_outline;
      case 'price_alert':
      case 'back_in_stock':
        return Icons.notifications_active_outlined;
      case 'coupon':
      case 'promotion':
        return Icons.local_offer_outlined;
      case 'loyalty':
        return Icons.card_giftcard_outlined;
      case 'referral':
        return Icons.people_outline;
      default:
        return Icons.notifications_outlined;
    }
  }
}
