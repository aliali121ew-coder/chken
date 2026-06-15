import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/supabase_client_provider.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepositoryImpl(ref.watch(supabaseClientProvider));
});

final productReviewsProvider = FutureProvider.family<List<Review>, String>((ref, productId) {
  return ref.watch(reviewRepositoryProvider).getProductReviews(productId);
});

final hasReviewedProvider = FutureProvider.family<bool, String>((ref, productId) {
  return ref.watch(reviewRepositoryProvider).hasReviewed(productId);
});

/// Drives review submission.
class ReviewController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> submit({
    required String productId,
    required String storeId,
    required int rating,
    String? comment,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(reviewRepositoryProvider).submitReview(
            productId: productId,
            storeId: storeId,
            rating: rating,
            comment: comment,
          );
    });
    ref.invalidate(productReviewsProvider(productId));
    ref.invalidate(hasReviewedProvider(productId));
    return !state.hasError;
  }
}

final reviewControllerProvider = AsyncNotifierProvider<ReviewController, void>(ReviewController.new);
