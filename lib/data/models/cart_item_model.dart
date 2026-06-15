import '../../domain/entities/cart_item.dart';
import 'product_model.dart';

/// Maps a `cart_items` row embedded with its `products` and `stores`
/// relations (see [CartRepositoryImpl.getItems]) to [CartItem].
class CartItemModel {
  const CartItemModel({
    required this.id,
    required this.product,
    required this.storeId,
    required this.storeName,
    required this.storeNameEn,
    required this.quantity,
    required this.selectedVariant,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final store = json['store'] as Map<String, dynamic>?;
    return CartItemModel(
      id: json['id'] as String,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      storeId: json['store_id'] as String,
      storeName: store?['name'] as String? ?? '',
      storeNameEn: store?['name_en'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      selectedVariant: json['selected_variant'] as Map<String, dynamic>?,
    );
  }

  final String id;
  final ProductModel product;
  final String storeId;
  final String storeName;
  final String? storeNameEn;
  final int quantity;
  final Map<String, dynamic>? selectedVariant;

  CartItem toEntity() {
    return CartItem(
      id: id,
      product: product.toEntity(),
      storeId: storeId,
      storeName: storeName,
      storeNameEn: storeNameEn,
      quantity: quantity,
      selectedVariant: selectedVariant,
    );
  }
}
