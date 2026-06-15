import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/supabase_client_provider.dart';
import '../../data/repositories/referral_repository_impl.dart';
import '../../domain/entities/referral.dart';
import '../../domain/repositories/referral_repository.dart';

final referralRepositoryProvider = Provider<ReferralRepository>((ref) {
  return ReferralRepositoryImpl(ref.watch(supabaseClientProvider));
});

final myReferralsProvider = FutureProvider<List<Referral>>((ref) {
  return ref.watch(referralRepositoryProvider).getMyReferrals();
});
