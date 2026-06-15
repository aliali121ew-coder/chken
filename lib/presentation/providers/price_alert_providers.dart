import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/supabase_client_provider.dart';
import '../../data/repositories/price_alert_repository_impl.dart';
import '../../domain/entities/price_alert.dart';
import '../../domain/repositories/price_alert_repository.dart';

final priceAlertRepositoryProvider = Provider<PriceAlertRepository>((ref) {
  return PriceAlertRepositoryImpl(ref.watch(supabaseClientProvider));
});

final productAlertProvider = FutureProvider.family<PriceAlert?, String>((ref, productId) {
  return ref.watch(priceAlertRepositoryProvider).getAlertForProduct(productId);
});

/// Drives creating/removing a product alert and refreshes the per-product
/// alert lookup.
class PriceAlertController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> toggleAlert({
    required String productId,
    required String alertType,
    double? targetPrice,
    PriceAlert? existing,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(priceAlertRepositoryProvider);
      if (existing != null) {
        await repo.deleteAlert(existing.id);
      } else {
        await repo.createAlert(productId: productId, alertType: alertType, targetPrice: targetPrice);
      }
    });
    ref.invalidate(productAlertProvider(productId));
    return !state.hasError;
  }
}

final priceAlertControllerProvider = AsyncNotifierProvider<PriceAlertController, void>(PriceAlertController.new);
