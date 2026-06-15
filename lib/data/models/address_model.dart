import '../../domain/entities/address.dart';

class AddressModel {
  const AddressModel({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.city,
    required this.isDefault,
    required this.latitude,
    required this.longitude,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      label: json['label'] as String? ?? 'Home',
      fullAddress: json['full_address'] as String,
      city: json['city'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String label;
  final String fullAddress;
  final String? city;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  Address toEntity() {
    return Address(
      id: id,
      label: label,
      fullAddress: fullAddress,
      city: city,
      isDefault: isDefault,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
