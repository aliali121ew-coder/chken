/// Domain entity mirroring a row of the `wallet_transactions` table.
class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.balanceAfter,
    required this.createdAt,
  });

  final String id;
  final double amount;

  /// Either `credit` or `debit`.
  final String type;
  final String? description;
  final double? balanceAfter;
  final DateTime createdAt;

  bool get isCredit => type == 'credit';
}

/// Domain entity mirroring a row of the `loyalty_transactions` table.
class LoyaltyTransaction {
  const LoyaltyTransaction({
    required this.id,
    required this.pointsEarned,
    required this.pointsSpent,
    required this.balanceAfter,
    required this.description,
    required this.createdAt,
  });

  final String id;
  final int pointsEarned;
  final int pointsSpent;
  final int balanceAfter;
  final String? description;
  final DateTime createdAt;

  /// Net point change for this entry (positive = earned, negative = spent).
  int get netPoints => pointsEarned - pointsSpent;
}
