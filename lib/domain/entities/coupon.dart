/// Domain entity mirroring a row of the `coupons` table.
class Coupon {
  const Coupon({
    required this.id,
    required this.storeId,
    required this.code,
    required this.type,
    required this.value,
    required this.minOrderAmount,
  });

  final String id;
  final String? storeId;
  final String code;

  /// Either `percentage` or `fixed`.
  final String type;
  final double value;
  final double minOrderAmount;

  /// Computes the discount this coupon yields for a given [subtotal],
  /// clamped so it never exceeds the subtotal.
  double discountFor(double subtotal) {
    if (subtotal < minOrderAmount) return 0;
    final raw = type == 'percentage' ? subtotal * value / 100 : value;
    return raw > subtotal ? subtotal : raw;
  }
}
