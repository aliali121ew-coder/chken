import '../entities/product.dart';

/// Product catalog lookups used by the product detail and categories
/// screens.
abstract class CatalogRepository {
  /// Fetches a single active product by [id].
  Future<Product> getProductById(String id);

  /// Active products belonging to [categoryId].
  Future<List<Product>> getProductsByCategory(String categoryId, {int limit = 30});

  /// Active products whose Arabic or English name matches [query].
  Future<List<Product>> searchProducts(String query, {int limit = 30});
}
