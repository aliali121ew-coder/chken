import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_tables.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../../domain/repositories/wallet_repository.dart';

/// Supabase-backed implementation of [WalletRepository].
class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<WalletTransaction>> getWalletTransactions() async {
    final userId = _client.auth.currentUser!.id;
    final rows = await _client
        .from(SupabaseTables.walletTransactions)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(100);
    return rows
        .map((row) => WalletTransaction(
              id: row['id'] as String,
              amount: (row['amount'] as num).toDouble(),
              type: row['type'] as String,
              description: row['description'] as String?,
              balanceAfter: (row['balance_after'] as num?)?.toDouble(),
              createdAt: DateTime.parse(row['created_at'] as String),
            ))
        .toList();
  }

  @override
  Future<List<LoyaltyTransaction>> getLoyaltyTransactions() async {
    final userId = _client.auth.currentUser!.id;
    final rows = await _client
        .from(SupabaseTables.loyaltyTransactions)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(100);
    return rows
        .map((row) => LoyaltyTransaction(
              id: row['id'] as String,
              pointsEarned: (row['points_earned'] as num?)?.toInt() ?? 0,
              pointsSpent: (row['points_spent'] as num?)?.toInt() ?? 0,
              balanceAfter: (row['balance_after'] as num?)?.toInt() ?? 0,
              description: row['description'] as String?,
              createdAt: DateTime.parse(row['created_at'] as String),
            ))
        .toList();
  }
}
