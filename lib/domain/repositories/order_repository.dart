import '../entities/order.dart';

/// Thrown by [OrderRepository.placeOrder] when a wallet payment is requested
/// but the user's balance is below the order total.
class InsufficientWalletBalance implements Exception {
  const InsufficientWalletBalance();
}

/// Places orders from the current cart and reads back the customer's
/// order history.
abstract class OrderRepository {
  /// Groups the current cart items by store, creates one order per store
  /// (each with its own `order_items`), then clears the placed cart items.
  ///
  /// Returns the ids of the created orders.
  Future<List<String>> placeOrder({
    required String addressId,
    required String paymentMethod,
    String? notes,
    String? couponId,
    String? couponStoreId,
    double couponDiscount = 0,
    String deliveryType = 'immediate',
    DateTime? scheduledAt,
  });

  Future<List<Order>> getOrders();

  Future<Order> getOrderById(String id);
}
