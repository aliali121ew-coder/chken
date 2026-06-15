import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_tables.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/admin_repository.dart';
import '../models/profile_model.dart';
import '../models/store_model.dart';

/// Supabase-backed implementation of [AdminRepository].
class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<AdminStats> getDashboardStats() async {
    final usersCount = await _client.from(SupabaseTables.profiles).count();
    final storesCount = await _client.from(SupabaseTables.stores).count();
    final orderRows = await _client.from(SupabaseTables.orders).select('total_amount');

    var totalRevenue = 0.0;
    for (final row in orderRows) {
      totalRevenue += (row['total_amount'] as num).toDouble();
    }

    return AdminStats(
      totalUsers: usersCount,
      totalStores: storesCount,
      totalOrders: orderRows.length,
      totalRevenue: totalRevenue,
    );
  }

  @override
  Future<List<Store>> getPendingStores() async {
    final rows = await _client
        .from(SupabaseTables.stores)
        .select()
        .eq('is_approved', false)
        .order('created_at', ascending: false);
    return rows.map((row) => StoreModel.fromJson(row).toEntity()).toList();
  }

  @override
  Future<List<Store>> getAllStores() async {
    final rows = await _client
        .from(SupabaseTables.stores)
        .select()
        .order('created_at', ascending: false);
    return rows.map((row) => StoreModel.fromJson(row).toEntity()).toList();
  }

  @override
  Future<void> setStoreApproval(String storeId, bool isApproved) async {
    await _client.from(SupabaseTables.stores).update({
      'is_approved': isApproved,
      if (isApproved) 'approved_at': DateTime.now().toIso8601String(),
    }).eq('id', storeId);
  }

  @override
  Future<void> setStoreActive(String storeId, bool isActive) async {
    await _client.from(SupabaseTables.stores).update({'is_active': isActive}).eq('id', storeId);
  }

  @override
  Future<List<UserProfile>> getUsers() async {
    final rows = await _client
        .from(SupabaseTables.profiles)
        .select()
        .order('created_at', ascending: false);
    return rows.map((row) => ProfileModel.fromJson(row).toEntity()).toList();
  }

  @override
  Future<void> setUserActive(String userId, bool isActive) async {
    await _client.from(SupabaseTables.profiles).update({'is_active': isActive}).eq('id', userId);
  }

  @override
  Future<List<BannerItem>> getBanners() async {
    final rows = await _client
        .from(SupabaseTables.banners)
        .select()
        .order('sort_order', ascending: true);
    return rows
        .map((row) => BannerItem(
              id: row['id'] as String,
              titleAr: row['title_ar'] as String?,
              titleEn: row['title_en'] as String?,
              imageUrl: row['image_url'] as String,
              isActive: row['is_active'] as bool? ?? true,
              sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
            ))
        .toList();
  }

  @override
  Future<void> createBanner({
    required String imageUrl,
    String? titleAr,
    String? titleEn,
  }) async {
    await _client.from(SupabaseTables.banners).insert({
      'image_url': imageUrl,
      'title_ar': titleAr,
      'title_en': titleEn,
    });
  }

  @override
  Future<void> setBannerActive(String bannerId, bool isActive) async {
    await _client.from(SupabaseTables.banners).update({'is_active': isActive}).eq('id', bannerId);
  }

  @override
  Future<void> deleteBanner(String bannerId) async {
    await _client.from(SupabaseTables.banners).delete().eq('id', bannerId);
  }

  @override
  Future<List<AuditLogEntry>> getAuditLogs() async {
    final rows = await _client
        .from(SupabaseTables.auditLogs)
        .select('id, action, table_name, created_at')
        .order('created_at', ascending: false)
        .limit(100);
    return rows
        .map((row) => AuditLogEntry(
              id: row['id'] as String,
              action: row['action'] as String,
              tableName: row['table_name'] as String?,
              createdAt: DateTime.parse(row['created_at'] as String),
            ))
        .toList();
  }
}
