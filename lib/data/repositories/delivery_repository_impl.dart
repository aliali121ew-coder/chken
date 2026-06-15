import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_tables.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../models/order_model.dart';

/// Supabase-backed implementation of [DeliveryRepository].
class DeliveryRepositoryImpl implements DeliveryRepository {
  DeliveryRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _orderSelect = '*, store:stores(name, name_en), order_items(*)';

  @override
  Future<List<Order>> getAvailableOrders() async {
    final rows = await _client
        .from(SupabaseTables.orders)
        .select(_orderSelect)
        .eq('status', 'ready')
        .isFilter('delivery_agent_id', null)
        .order('created_at', ascending: false);
    return rows.map((row) => OrderModel.fromJson(row).toEntity()).toList();
  }

  @override
  Future<List<Order>> getActiveOrders() async {
    final userId = _client.auth.currentUser!.id;
    final rows = await _client
        .from(SupabaseTables.orders)
        .select(_orderSelect)
        .eq('delivery_agent_id', userId)
        .inFilter('status', ['picked_up', 'on_way'])
        .order('created_at', ascending: false);
    return rows.map((row) => OrderModel.fromJson(row).toEntity()).toList();
  }

  @override
  Future<List<Order>> getOrderHistory() async {
    final userId = _client.auth.currentUser!.id;
    final rows = await _client
        .from(SupabaseTables.orders)
        .select(_orderSelect)
        .eq('delivery_agent_id', userId)
        .inFilter('status', ['delivered', 'cancelled', 'refunded'])
        .order('created_at', ascending: false);
    return rows.map((row) => OrderModel.fromJson(row).toEntity()).toList();
  }

  @override
  Future<void> acceptOrder(String orderId) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from(SupabaseTables.orders).update({
      'delivery_agent_id': userId,
      'status': 'picked_up',
    }).eq('id', orderId);
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _client.from(SupabaseTables.orders).update({'status': status}).eq('id', orderId);
  }
}
