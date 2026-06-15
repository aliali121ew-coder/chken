/// Domain entity mirroring a row of the `referrals` table, joined with the
/// referred user's name.
class Referral {
  const Referral({
    required this.id,
    required this.referredName,
    required this.rewardGiven,
    required this.createdAt,
  });

  final String id;
  final String? referredName;
  final bool rewardGiven;
  final DateTime createdAt;
}
