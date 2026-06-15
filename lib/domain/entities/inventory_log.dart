/// Domain entity mirroring a row of the `inventory_logs` table, joined with
/// the product name.
class InventoryLog {
  const InventoryLog({
    required this.id,
    required this.productName,
    required this.changeAmount,
    required this.stockAfter,
    required this.reason,
    required this.createdAt,
  });

  final String id;
  final String? productName;
  final int changeAmount;
  final int stockAfter;
  final String? reason;
  final DateTime createdAt;
}
