import '../../domain/entities/product.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.storeId,
    required this.categoryId,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.basePrice,
    required this.discountPercentage,
    required this.finalPrice,
    required this.stockQuantity,
    required this.images,
    required this.tags,
    required this.isFeatured,
    required this.isActive,
    required this.totalSold,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      categoryId: json['category_id'] as String?,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String?,
      descriptionAr: json['description_ar'] as String?,
      descriptionEn: json['description_en'] as String?,
      basePrice: (json['base_price'] as num).toDouble(),
      discountPercentage: (json['discount_percentage'] as num?)?.toInt() ?? 0,
      finalPrice: (json['final_price'] as num).toDouble(),
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
      images: _parseImages(json['images']),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      isFeatured: json['is_featured'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      totalSold: (json['total_sold'] as num?)?.toInt() ?? 0,
    );
  }

  /// `images` is stored as JSONB: `[{"url": "...", "type": "image"}, ...]`.
  static List<String> _parseImages(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => e['url'] as String?)
        .whereType<String>()
        .toList();
  }

  final String id;
  final String storeId;
  final String? categoryId;
  final String nameAr;
  final String? nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final double basePrice;
  final int discountPercentage;
  final double finalPrice;
  final int stockQuantity;
  final List<String> images;
  final List<String> tags;
  final bool isFeatured;
  final bool isActive;
  final int totalSold;

  Product toEntity() {
    return Product(
      id: id,
      storeId: storeId,
      categoryId: categoryId,
      nameAr: nameAr,
      nameEn: nameEn,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      basePrice: basePrice,
      discountPercentage: discountPercentage,
      finalPrice: finalPrice,
      stockQuantity: stockQuantity,
      images: images,
      tags: tags,
      isFeatured: isFeatured,
      isActive: isActive,
      totalSold: totalSold,
    );
  }
}
