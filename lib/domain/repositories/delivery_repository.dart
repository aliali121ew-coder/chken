import '../entities/order.dart';

/// Delivery-agent operations: browsing available orders, managing the
/// agent's active deliveries and order history.
abstract class DeliveryRepository {
  /// Orders that are ready for pickup and not yet assigned to any agent.
  Future<List<Order>> getAvailableOrders();

  /// Orders currently assigned to the signed-in agent and not yet delivered.
  Future<List<Order>> getActiveOrders();

  /// Orders the signed-in agent has delivered (or cancelled while assigned).
  Future<List<Order>> getOrderHistory();

  /// Assigns [orderId] to the signed-in agent and marks it picked up.
  Future<void> acceptOrder(String orderId);

  Future<void> updateOrderStatus(String orderId, String status);
}
