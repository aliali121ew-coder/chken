import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/supabase_client_provider.dart';
import '../../data/repositories/delivery_repository_impl.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/delivery_repository.dart';

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryRepositoryImpl(ref.watch(supabaseClientProvider));
});

final availableOrdersProvider = FutureProvider<List<Order>>((ref) {
  return ref.watch(deliveryRepositoryProvider).getAvailableOrders();
});

final activeOrdersProvider = FutureProvider<List<Order>>((ref) {
  return ref.watch(deliveryRepositoryProvider).getActiveOrders();
});

final deliveryHistoryProvider = FutureProvider<List<Order>>((ref) {
  return ref.watch(deliveryRepositoryProvider).getOrderHistory();
});

/// Drives delivery-agent mutations: accepting orders and advancing their
/// delivery status.
class DeliveryController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> acceptOrder(String orderId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(deliveryRepositoryProvider).acceptOrder(orderId);
    });
    ref.invalidate(availableOrdersProvider);
    ref.invalidate(activeOrdersProvider);
    return !state.hasError;
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(deliveryRepositoryProvider).updateOrderStatus(orderId, status);
    });
    ref.invalidate(activeOrdersProvider);
    ref.invalidate(deliveryHistoryProvider);
    return !state.hasError;
  }
}

final deliveryControllerProvider = AsyncNotifierProvider<DeliveryController, void>(DeliveryController.new);
