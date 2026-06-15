import '../entities/category.dart';
import '../entities/product.dart';
import '../entities/store.dart';

/// Read-only data needed to render the customer Home screen.
abstract class HomeRepository {
  /// Active top-level categories, ordered by `sort_order`.
  Future<List<Category>> getCategories();

  /// Active products flagged as `is_featured`.
  Future<List<Product>> getFeaturedProducts({int limit = 10});

  /// Active products ordered by `total_sold` descending.
  Future<List<Product>> getBestSellers({int limit = 10});

  /// Approved, active stores ordered by rating descending.
  Future<List<Store>> getNearbyStores({int limit = 10});
}
