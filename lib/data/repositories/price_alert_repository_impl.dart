import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_tables.dart';
import '../../domain/entities/price_alert.dart';
import '../../domain/repositories/price_alert_repository.dart';

/// Supabase-backed implementation of [PriceAlertRepository].
class PriceAlertRepositoryImpl implements PriceAlertRepository {
  PriceAlertRepositoryImpl(this._client);

  final SupabaseClient _client;

  PriceAlert _fromJson(Map<String, dynamic> row) {
    return PriceAlert(
      id: row['id'] as String,
      productId: row['product_id'] as String,
      targetPrice: (row['target_price'] as num?)?.toDouble(),
      alertType: row['alert_type'] as String,
      isTriggered: row['is_triggered'] as bool? ?? false,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  @override
  Future<List<PriceAlert>> getMyAlerts() async {
    final userId = _client.auth.currentUser!.id;
    final rows = await _client
        .from(SupabaseTables.priceAlerts)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return rows.map(_fromJson).toList();
  }

  @override
  Future<PriceAlert?> getAlertForProduct(String productId) async {
    final userId = _client.auth.currentUser!.id;
    final row = await _client
        .from(SupabaseTables.priceAlerts)
        .select()
        .eq('user_id', userId)
        .eq('product_id', productId)
        .maybeSingle();
    if (row == null) return null;
    return _fromJson(row);
  }

  @override
  Future<void> createAlert({
    required String productId,
    required String alertType,
    double? targetPrice,
  }) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from(SupabaseTables.priceAlerts).insert({
      'user_id': userId,
      'product_id': productId,
      'alert_type': alertType,
      'target_price': targetPrice,
    });
  }

  @override
  Future<void> deleteAlert(String id) async {
    await _client.from(SupabaseTables.priceAlerts).delete().eq('id', id);
  }
}
