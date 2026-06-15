/// A single line item snapshot of a product within an [Order].
class OrderItem {
  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  final String id;
  final String? productId;
  final String productName;
  final String? productImageUrl;
  final int quantity;
  final double unitPrice;
  final double subtotal;
}

/// Domain entity mirroring a row of the `orders` table.
class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.storeId,
    required this.storeName,
    required this.storeNameEn,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.subtotal,
    required this.deliveryFee,
    required this.discountAmount,
    required this.totalAmount,
    required this.createdAt,
    required this.items,
  });

  final String id;
  final String orderNumber;
  final String storeId;
  final String storeName;
  final String? storeNameEn;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final double subtotal;
  final double deliveryFee;
  final double discountAmount;
  final double totalAmount;
  final DateTime createdAt;
  final List<OrderItem> items;

  /// Returns the localized store name for [languageCode] (`ar`/`en`),
  /// falling back to Arabic when no English translation is set.
  String storeDisplayName(String languageCode) {
    if (languageCode == 'en' && storeNameEn != null && storeNameEn!.isNotEmpty) {
      return storeNameEn!;
    }
    return storeName;
  }
}
