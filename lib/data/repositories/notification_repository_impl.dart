import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_tables.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

/// Supabase-backed implementation of [NotificationRepository].
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._client);

  final SupabaseClient _client;

  AppNotification _fromJson(Map<String, dynamic> row) {
    return AppNotification(
      id: row['id'] as String,
      titleAr: row['title_ar'] as String,
      titleEn: row['title_en'] as String?,
      bodyAr: row['body_ar'] as String?,
      bodyEn: row['body_en'] as String?,
      type: row['type'] as String?,
      isRead: row['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  @override
  Future<List<AppNotification>> getNotifications() async {
    final userId = _client.auth.currentUser!.id;
    final rows = await _client
        .from(SupabaseTables.notifications)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(100);
    return rows.map(_fromJson).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final userId = _client.auth.currentUser!.id;
    return _client
        .from(SupabaseTables.notifications)
        .count(CountOption.exact)
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  @override
  Future<void> markAsRead(String id) async {
    await _client.from(SupabaseTables.notifications).update({'is_read': true}).eq('id', id);
  }

  @override
  Future<void> markAllAsRead() async {
    final userId = _client.auth.currentUser!.id;
    await _client
        .from(SupabaseTables.notifications)
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }
}
