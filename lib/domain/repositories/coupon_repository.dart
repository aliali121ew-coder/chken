import '../entities/coupon.dart';

/// Coupon code validation used at checkout.
abstract class CouponRepository {
  /// Looks up an active, unexpired coupon by its [code]. Returns `null`
  /// when no matching coupon exists.
  Future<Coupon?> findByCode(String code);
}
