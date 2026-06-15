import '../entities/product.dart';
import '../entities/store.dart';

/// Storefront data for the store detail screen.
abstract class StoreRepository {
  /// Fetches a single approved, active store by [id].
  Future<Store> getStoreById(String id);

  /// Active products belonging to [storeId].
  Future<List<Product>> getStoreProducts(String storeId, {int limit = 50});
}
