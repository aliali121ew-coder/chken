import '../entities/review.dart';

/// Product/store reviews: reading approved reviews and submitting new ones.
abstract class ReviewRepository {
  /// Approved reviews for [productId], newest first.
  Future<List<Review>> getProductReviews(String productId);

  /// Whether the signed-in user has already reviewed [productId].
  Future<bool> hasReviewed(String productId);

  Future<void> submitReview({
    required String productId,
    required String storeId,
    required int rating,
    String? comment,
  });
}
