import '../entities/address.dart';

/// Manages the current user's saved delivery addresses.
abstract class AddressRepository {
  Future<List<Address>> getAddresses();

  Future<Address> addAddress({
    required String label,
    required String fullAddress,
    String? city,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  });

  Future<void> deleteAddress(String id);

  /// Marks [id] as the default address, unsetting any previous default.
  Future<void> setDefaultAddress(String id);
}
