import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/supabase_client_provider.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(ref.watch(supabaseClientProvider));
});

/// The current user's cart, joined with product and store details.
final cartItemsProvider = FutureProvider<List<CartItem>>((ref) {
  return ref.watch(cartRepositoryProvider).getItems();
});

/// Drives cart mutations (add/update quantity/remove), exposing
/// loading/error state to the UI and refreshing [cartItemsProvider] on
/// success.
class CartController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> addItem({
    required String productId,
    required String storeId,
    required int quantity,
    Map<String, dynamic>? selectedVariant,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(cartRepositoryProvider).addItem(
            productId: productId,
            storeId: storeId,
            quantity: quantity,
            selectedVariant: selectedVariant,
          );
    });
    ref.invalidate(cartItemsProvider);
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(cartRepositoryProvider).updateQuantity(cartItemId, quantity);
    });
    ref.invalidate(cartItemsProvider);
  }

  Future<void> removeItem(String cartItemId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(cartRepositoryProvider).removeItem(cartItemId);
    });
    ref.invalidate(cartItemsProvider);
  }
}

final cartControllerProvider = AsyncNotifierProvider<CartController, void>(CartController.new);
