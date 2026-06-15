import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/supabase_client_provider.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import 'auth_providers.dart';
import 'cart_providers.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(ref.watch(supabaseClientProvider));
});

final ordersProvider = FutureProvider<List<Order>>((ref) {
  return ref.watch(orderRepositoryProvider).getOrders();
});

final orderByIdProvider = FutureProvider.family<Order, String>((ref, id) {
  return ref.watch(orderRepositoryProvider).getOrderById(id);
});

/// Places an order from the current cart and refreshes dependent providers.
class CheckoutController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<List<String>?> placeOrder({
    required String addressId,
    required String paymentMethod,
    String? notes,
    String? couponId,
    String? couponStoreId,
    double couponDiscount = 0,
    String deliveryType = 'immediate',
    DateTime? scheduledAt,
  }) async {
    state = const AsyncValue.loading();
    List<String>? orderIds;
    state = await AsyncValue.guard(() async {
      orderIds = await ref.read(orderRepositoryProvider).placeOrder(
            addressId: addressId,
            paymentMethod: paymentMethod,
            notes: notes,
            couponId: couponId,
            couponStoreId: couponStoreId,
            couponDiscount: couponDiscount,
            deliveryType: deliveryType,
            scheduledAt: scheduledAt,
          );
    });
    ref.invalidate(cartItemsProvider);
    ref.invalidate(ordersProvider);
    if (paymentMethod == 'wallet' && !state.hasError) {
      ref.invalidate(currentProfileProvider);
    }
    return state.hasError ? null : orderIds;
  }
}

final checkoutControllerProvider = AsyncNotifierProvider<CheckoutController, void>(CheckoutController.new);
