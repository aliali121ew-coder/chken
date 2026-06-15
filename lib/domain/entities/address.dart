/// Domain entity mirroring a row of the `addresses` table.
class Address {
  const Address({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.city,
    required this.isDefault,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String label;
  final String fullAddress;
  final String? city;
  final bool isDefault;
  final double? latitude;
  final double? longitude;
}
