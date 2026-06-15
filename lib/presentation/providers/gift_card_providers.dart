import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/supabase_client_provider.dart';
import '../../data/repositories/gift_card_repository_impl.dart';
import '../../domain/repositories/gift_card_repository.dart';
import 'auth_providers.dart';
import 'wallet_providers.dart';

final giftCardRepositoryProvider = Provider<GiftCardRepository>((ref) {
  return GiftCardRepositoryImpl(ref.watch(supabaseClientProvider));
});

/// Drives gift-card redemption and refreshes wallet-dependent providers.
class GiftCardController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Returns the credited amount on success, or `null` on failure.
  Future<double?> redeem(String code) async {
    state = const AsyncLoading();
    double? amount;
    state = await AsyncValue.guard(() async {
      amount = await ref.read(giftCardRepositoryProvider).redeem(code);
    });
    if (!state.hasError) {
      ref.invalidate(currentProfileProvider);
      ref.invalidate(walletTransactionsProvider);
    }
    return state.hasError ? null : amount;
  }
}

final giftCardControllerProvider = AsyncNotifierProvider<GiftCardController, void>(GiftCardController.new);
