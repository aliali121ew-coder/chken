import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_tables.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../models/address_model.dart';

/// Supabase-backed implementation of [AddressRepository].
class AddressRepositoryImpl implements AddressRepository {
  AddressRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Address>> getAddresses() async {
    final userId = _client.auth.currentUser!.id;
    final rows = await _client
        .from(SupabaseTables.addresses)
        .select()
        .eq('user_id', userId)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);
    return rows.map((row) => AddressModel.fromJson(row).toEntity()).toList();
  }

  @override
  Future<Address> addAddress({
    required String label,
    required String fullAddress,
    String? city,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final row = await _client
        .from(SupabaseTables.addresses)
        .insert({
          'user_id': userId,
          'label': label,
          'full_address': fullAddress,
          'city': city,
          'latitude': latitude,
          'longitude': longitude,
          'is_default': isDefault,
        })
        .select()
        .single();
    return AddressModel.fromJson(row).toEntity();
  }

  @override
  Future<void> deleteAddress(String id) async {
    await _client.from(SupabaseTables.addresses).delete().eq('id', id);
  }

  @override
  Future<void> setDefaultAddress(String id) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from(SupabaseTables.addresses).update({'is_default': false}).eq('user_id', userId);
    await _client.from(SupabaseTables.addresses).update({'is_default': true}).eq('id', id);
  }
}
