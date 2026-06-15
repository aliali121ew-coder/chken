/// Domain entity mirroring a row of the `price_alerts` table.
class PriceAlert {
  const PriceAlert({
    required this.id,
    required this.productId,
    required this.targetPrice,
    required this.alertType,
    required this.isTriggered,
    required this.createdAt,
  });

  final String id;
  final String productId;
  final double? targetPrice;

  /// Either `price_drop` or `back_in_stock`.
  final String alertType;
  final bool isTriggered;
  final DateTime createdAt;
}
