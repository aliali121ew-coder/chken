import '../../domain/entities/order.dart';

class OrderItemModel {
  const OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      productId: json['product_id'] as String?,
      productName: json['product_name'] as String,
      productImageUrl: json['product_image_url'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  final String id;
  final String? productId;
  final String productName;
  final String? productImageUrl;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  OrderItem toEntity() {
    return OrderItem(
      id: id,
      productId: productId,
      productName: productName,
      productImageUrl: productImageUrl,
      quantity: quantity,
      unitPrice: unitPrice,
      subtotal: subtotal,
    );
  }
}

class OrderModel {
  const OrderModel({
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

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final store = json['store'] as Map<String, dynamic>?;
    final items = (json['order_items'] as List<dynamic>?) ?? const [];
    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      storeId: json['store_id'] as String,
      storeName: store?['name'] as String? ?? '',
      storeNameEn: store?['name_en'] as String?,
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['total_amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      items: items
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList(),
    );
  }

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

  Order toEntity() {
    return Order(
      id: id,
      orderNumber: orderNumber,
      storeId: storeId,
      storeName: storeName,
      storeNameEn: storeNameEn,
      status: status,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
      createdAt: createdAt,
      items: items,
    );
  }
}
