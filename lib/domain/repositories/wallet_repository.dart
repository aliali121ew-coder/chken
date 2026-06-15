import '../entities/wallet_transaction.dart';

/// Read access to the signed-in user's wallet and loyalty ledgers.
abstract class WalletRepository {
  Future<List<WalletTransaction>> getWalletTransactions();

  Future<List<LoyaltyTransaction>> getLoyaltyTransactions();
}
