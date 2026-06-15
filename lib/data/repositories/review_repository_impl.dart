import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_tables.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';

/// Supabase-backed implementation of [ReviewRepository].
class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _select = '*, customer:profiles(full_name)';

  @override
  Future<List<Review>> getProductReviews(String productId) async {
    final rows = await _client
        .from(SupabaseTables.reviews)
        .select(_select)
        .eq('product_id', productId)
        .isFilter('deleted_at', null)
        .eq('is_approved', true)
        .order('created_at', ascending: false);

    return rows.map((row) {
      final customer = row['customer'] as Map<String, dynamic>?;
      return Review(
        id: row['id'] as String,
        customerId: row['customer_id'] as String?,
        customerName: customer?['full_name'] as String?,
        productRating: (row['product_rating'] as num?)?.toInt() ?? 0,
        comment: row['comment'] as String?,
        createdAt: DateTime.parse(row['created_at'] as String),
      );
    }).toList();
  }

  @override
  Future<bool> hasReviewed(String productId) async {
    final userId = _client.auth.currentUser!.id;
    final row = await _client
        .from(SupabaseTables.reviews)
        .select('id')
        .eq('product_id', productId)
        .eq('customer_id', userId)
        .maybeSingle();
    return row != null;
  }

  @override
  Future<void> submitReview({
    required String productId,
    required String storeId,
    required int rating,
    String? comment,
  }) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from(SupabaseTables.reviews).insert({
      'customer_id': userId,
      'product_id': productId,
      'store_id': storeId,
      'product_rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    });
  }
}
