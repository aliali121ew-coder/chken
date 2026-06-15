import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/supabase_client_provider.dart';
import '../../data/repositories/vendor_repository_impl.dart';
import '../../domain/entities/inventory_log.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/store.dart';
import '../../domain/repositories/vendor_repository.dart';

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  return VendorRepositoryImpl(ref.watch(supabaseClientProvider));
});

final myStoreProvider = FutureProvider<Store?>((ref) {
  return ref.watch(vendorRepositoryProvider).getMyStore();
});

final vendorStatsProvider = FutureProvider.family<VendorStats, String>((ref, storeId) {
  return ref.watch(vendorRepositoryProvider).getDashboardStats(storeId);
});

final vendorOrdersProvider = FutureProvider.family<List<Order>, String>((ref, storeId) {
  return ref.watch(vendorRepositoryProvider).getStoreOrders(storeId);
});

final vendorProductsProvider = FutureProvider.family<List<Product>, String>((ref, storeId) {
  return ref.watch(vendorRepositoryProvider).getMyProducts(storeId);
});

final inventoryLogsProvider = FutureProvider.family<List<InventoryLog>, String>((ref, storeId) {
  return ref.watch(vendorRepositoryProvider).getInventoryLogs(storeId);
});

/// Drives vendor mutations: order status updates, product CRUD and store
/// settings updates.
class VendorController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> updateOrderStatus(String storeId, String orderId, String status) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(vendorRepositoryProvider).updateOrderStatus(orderId, status);
    });
    ref.invalidate(vendorOrdersProvider(storeId));
    ref.invalidate(vendorStatsProvider(storeId));
    return !state.hasError;
  }

  Future<bool> createProduct({
    required String storeId,
    required String nameAr,
    String? nameEn,
    String? descriptionAr,
    required double basePrice,
    required int discountPercentage,
    required int stockQuantity,
    String? categoryId,
    required bool isActive,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(vendorRepositoryProvider).createProduct(
            storeId: storeId,
            nameAr: nameAr,
            nameEn: nameEn,
            descriptionAr: descriptionAr,
            basePrice: basePrice,
            discountPercentage: discountPercentage,
            stockQuantity: stockQuantity,
            categoryId: categoryId,
            isActive: isActive,
          );
    });
    ref.invalidate(vendorProductsProvider(storeId));
    ref.invalidate(inventoryLogsProvider(storeId));
    return !state.hasError;
  }

  Future<bool> updateProduct({
    required String storeId,
    required String productId,
    required String nameAr,
    String? nameEn,
    String? descriptionAr,
    required double basePrice,
    required int discountPercentage,
    required int stockQuantity,
    String? categoryId,
    required bool isActive,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(vendorRepositoryProvider).updateProduct(
            productId: productId,
            nameAr: nameAr,
            nameEn: nameEn,
            descriptionAr: descriptionAr,
            basePrice: basePrice,
            discountPercentage: discountPercentage,
            stockQuantity: stockQuantity,
            categoryId: categoryId,
            isActive: isActive,
          );
    });
    ref.invalidate(vendorProductsProvider(storeId));
    ref.invalidate(inventoryLogsProvider(storeId));
    return !state.hasError;
  }

  Future<bool> deleteProduct(String storeId, String productId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(vendorRepositoryProvider).deleteProduct(productId);
    });
    ref.invalidate(vendorProductsProvider(storeId));
    return !state.hasError;
  }

  Future<bool> updateStoreSettings({
    required String storeId,
    required String name,
    String? nameEn,
    String? description,
    required double deliveryFee,
    required double minOrderAmount,
    required bool isActive,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(vendorRepositoryProvider).updateStoreSettings(
            storeId: storeId,
            name: name,
            nameEn: nameEn,
            description: description,
            deliveryFee: deliveryFee,
            minOrderAmount: minOrderAmount,
            isActive: isActive,
          );
    });
    ref.invalidate(myStoreProvider);
    return !state.hasError;
  }
}

final vendorControllerProvider = AsyncNotifierProvider<VendorController, void>(VendorController.new);
