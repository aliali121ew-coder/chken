import '../entities/store.dart';
import '../entities/user_profile.dart';

/// Platform-wide aggregate stats shown on the admin dashboard.
class AdminStats {
  const AdminStats({
    required this.totalUsers,
    required this.totalStores,
    required this.totalOrders,
    required this.totalRevenue,
  });

  final int totalUsers;
  final int totalStores;
  final int totalOrders;
  final double totalRevenue;
}

/// A CMS banner row.
class BannerItem {
  const BannerItem({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.imageUrl,
    required this.isActive,
    required this.sortOrder,
  });

  final String id;
  final String? titleAr;
  final String? titleEn;
  final String imageUrl;
  final bool isActive;
  final int sortOrder;
}

/// An audit log entry.
class AuditLogEntry {
  const AuditLogEntry({
    required this.id,
    required this.action,
    required this.tableName,
    required this.createdAt,
  });

  final String id;
  final String action;
  final String? tableName;
  final DateTime createdAt;
}

/// Admin operations: platform stats, store approvals, user management,
/// CMS banners and audit log access.
abstract class AdminRepository {
  Future<AdminStats> getDashboardStats();

  Future<List<Store>> getPendingStores();

  Future<List<Store>> getAllStores();

  Future<void> setStoreApproval(String storeId, bool isApproved);

  Future<void> setStoreActive(String storeId, bool isActive);

  Future<List<UserProfile>> getUsers();

  Future<void> setUserActive(String userId, bool isActive);

  Future<List<BannerItem>> getBanners();

  Future<void> createBanner({
    required String imageUrl,
    String? titleAr,
    String? titleEn,
  });

  Future<void> setBannerActive(String bannerId, bool isActive);

  Future<void> deleteBanner(String bannerId);

  Future<List<AuditLogEntry>> getAuditLogs();
}
