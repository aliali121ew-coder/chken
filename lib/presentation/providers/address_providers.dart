import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/supabase_client_provider.dart';
import '../../data/repositories/address_repository_impl.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepositoryImpl(ref.watch(supabaseClientProvider));
});

final addressesProvider = FutureProvider<List<Address>>((ref) {
  return ref.watch(addressRepositoryProvider).getAddresses();
});

/// Adds a new address and refreshes [addressesProvider].
class AddressController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Address?> addAddress({
    required String label,
    required String fullAddress,
    String? city,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    state = const AsyncValue.loading();
    Address? created;
    state = await AsyncValue.guard(() async {
      created = await ref.read(addressRepositoryProvider).addAddress(
            label: label,
            fullAddress: fullAddress,
            city: city,
            latitude: latitude,
            longitude: longitude,
            isDefault: isDefault,
          );
    });
    ref.invalidate(addressesProvider);
    return created;
  }

  Future<void> deleteAddress(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(addressRepositoryProvider).deleteAddress(id);
    });
    ref.invalidate(addressesProvider);
  }

  Future<void> setDefaultAddress(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(addressRepositoryProvider).setDefaultAddress(id);
    });
    ref.invalidate(addressesProvider);
  }
}

final addressControllerProvider = AsyncNotifierProvider<AddressController, void>(AddressController.new);
