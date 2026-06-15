/// Thrown when a gift-card code is missing, already redeemed, or expired.
class InvalidGiftCard implements Exception {
  const InvalidGiftCard();
}

/// Gift-card redemption: claiming a card by code and crediting its value to
/// the user's wallet.
abstract class GiftCardRepository {
  /// Redeems [code] for the signed-in user, crediting their wallet by the
  /// card's amount. Returns the credited amount.
  ///
  /// Throws [InvalidGiftCard] when the code is unknown, already redeemed,
  /// or expired.
  Future<double> redeem(String code);
}
