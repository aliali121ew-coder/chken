import '../../domain/entities/store.dart';

class StoreModel {
  const StoreModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.description,
    required this.descriptionEn,
    required this.logoUrl,
    required this.bannerUrl,
    required this.gradientStart,
    required this.gradientEnd,
    required this.primaryColor,
    required this.secondaryColor,
    required this.category,
    required this.rating,
    required this.totalReviews,
    required this.deliveryFee,
    required this.minOrderAmount,
    required this.isActive,
    required this.isApproved,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      description: json['description'] as String?,
      descriptionEn: json['description_en'] as String?,
      logoUrl: json['logo_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      gradientStart: json['gradient_start'] as String? ?? '#4CAF50',
      gradientEnd: json['gradient_end'] as String? ?? '#2E7D32',
      primaryColor: json['primary_color'] as String? ?? '#4CAF50',
      secondaryColor: json['secondary_color'] as String? ?? '#2E7D32',
      category: json['category'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      isApproved: json['is_approved'] as bool? ?? false,
    );
  }

  final String id;
  final String name;
  final String? nameEn;
  final String? description;
  final String? descriptionEn;
  final String? logoUrl;
  final String? bannerUrl;
  final String gradientStart;
  final String gradientEnd;
  final String primaryColor;
  final String secondaryColor;
  final String? category;
  final double rating;
  final int totalReviews;
  final double deliveryFee;
  final double minOrderAmount;
  final bool isActive;
  final bool isApproved;

  Store toEntity() {
    return Store(
      id: id,
      name: name,
      nameEn: nameEn,
      description: description,
      descriptionEn: descriptionEn,
      logoUrl: logoUrl,
      bannerUrl: bannerUrl,
      gradientStart: gradientStart,
      gradientEnd: gradientEnd,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      category: category,
      rating: rating,
      totalReviews: totalReviews,
      deliveryFee: deliveryFee,
      minOrderAmount: minOrderAmount,
      isActive: isActive,
      isApproved: isApproved,
    );
  }
}
