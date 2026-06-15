import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/gift_card_repository.dart';

/// Supabase-backed implementation of [GiftCardRepository].
///
/// Redemption is delegated to the `redeem_gift_card` SECURITY DEFINER
/// function so the card claim and wallet credit happen atomically and can't
/// be forged from the client.
class GiftCardRepositoryImpl implements GiftCardRepository {
  GiftCardRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<double> redeem(String code) async {
    try {
      final amount = await _client.rpc<dynamic>(
        'redeem_gift_card',
        params: {'p_code': code},
      );
      return (amount as num).toDouble();
    } on PostgrestException catch (e) {
      if (e.message.contains('invalid_gift_card')) {
        throw const InvalidGiftCard();
      }
      rethrow;
    }
  }
}
