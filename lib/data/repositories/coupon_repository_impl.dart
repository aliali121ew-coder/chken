import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_tables.dart';
import '../../domain/entities/coupon.dart';
import '../../domain/repositories/coupon_repository.dart';

/// Supabase-backed implementation of [CouponRepository].
class CouponRepositoryImpl implements CouponRepository {
  CouponRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Coupon?> findByCode(String code) async {
    final row = await _client
        .from(SupabaseTables.coupons)
        .select()
        .eq('code', code.trim())
        .maybeSingle();
    if (row == null) return null;
    return Coupon(
      id: row['id'] as String,
      storeId: row['store_id'] as String?,
      code: row['code'] as String,
      type: row['type'] as String,
      value: (row['value'] as num).toDouble(),
      minOrderAmount: (row['min_order_amount'] as num?)?.toDouble() ?? 0,
    );
  }
}
