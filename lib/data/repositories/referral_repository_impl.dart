import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_tables.dart';
import '../../domain/entities/referral.dart';
import '../../domain/repositories/referral_repository.dart';

/// Supabase-backed implementation of [ReferralRepository].
class ReferralRepositoryImpl implements ReferralRepository {
  ReferralRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Referral>> getMyReferrals() async {
    final userId = _client.auth.currentUser!.id;
    final rows = await _client
        .from(SupabaseTables.referrals)
        .select('id, reward_given, created_at, referred:profiles!referrals_referred_id_fkey(full_name)')
        .eq('referrer_id', userId)
        .order('created_at', ascending: false);

    return rows.map((row) {
      final referred = row['referred'] as Map<String, dynamic>?;
      return Referral(
        id: row['id'] as String,
        referredName: referred?['full_name'] as String?,
        rewardGiven: row['reward_given'] as bool? ?? false,
        createdAt: DateTime.parse(row['created_at'] as String),
      );
    }).toList();
  }
}
