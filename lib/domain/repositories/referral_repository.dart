import '../entities/referral.dart';

/// The signed-in user's referral activity.
abstract class ReferralRepository {
  /// Users who signed up with the current user's referral code.
  Future<List<Referral>> getMyReferrals();
}
