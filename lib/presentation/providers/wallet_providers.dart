import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/supabase_client_provider.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../../domain/repositories/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepositoryImpl(ref.watch(supabaseClientProvider));
});

final walletTransactionsProvider = FutureProvider<List<WalletTransaction>>((ref) {
  return ref.watch(walletRepositoryProvider).getWalletTransactions();
});

final loyaltyTransactionsProvider = FutureProvider<List<LoyaltyTransaction>>((ref) {
  return ref.watch(walletRepositoryProvider).getLoyaltyTransactions();
});
