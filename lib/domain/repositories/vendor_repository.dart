import '../entities/inventory_log.dart';
import '../entities/order.dart';
import '../entities/product.dart';
import '../entities/store.dart';

/// Aggregate stats shown on the vendor dashboard.
class VendorStats {
  const VendorStats({
    required this.totalOrders,
    required this.totalRevenue,
    required this.pendingOrders,
  });

  final int totalOrders;
  final double totalRevenue;
  final int pendingOrders;
}

/// Store-owner operations: managing the vendor's own store, products and
/// incoming orders.
abstract class VendorRepository {
  /// The store owned by the signed-in vendor, or `null` if none exists yet.
  Future<Store?> getMyStore();

  Future<VendorStats> getDashboardStats(String storeId);

  Future<List<Order>> getStoreOrders(String storeId);

  Future<void> updateOrderStatus(String orderId, String status);

  /// All products for [storeId], including inactive ones.
  Future<List<Product>> getMyProducts(String storeId);

  /// Stock-change history for [storeId], newest first.
  Future<List<InventoryLog>> getInventoryLogs(String storeId);

  Future<void> createProduct({
    required String storeId,
    required String nameAr,
    String? nameEn,
    String? descriptionAr,
    required double basePrice,
    required int discountPercentage,
    required int stockQuantity,
    String? categoryId,
    required bool isActive,
  });

  Future<void> updateProduct({
    required String productId,
    required String nameAr,
    String? nameEn,
    String? descriptionAr,
    required double basePrice,
    required int discountPercentage,
    required int stockQuantity,
    String? categoryId,
    required bool isActive,
  });

  Future<void> deleteProduct(String productId);

  Future<void> updateStoreSettings({
    required String storeId,
    required String name,
    String? nameEn,
    String? description,
    required double deliveryFee,
    required double minOrderAmount,
    required bool isActive,
  });
}
