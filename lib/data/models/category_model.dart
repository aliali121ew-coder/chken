import '../../domain/entities/category.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.iconUrl,
    required this.parentId,
    required this.sortOrder,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String?,
      iconUrl: json['icon_url'] as String?,
      parentId: json['parent_id'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String nameAr;
  final String? nameEn;
  final String? iconUrl;
  final String? parentId;
  final int sortOrder;

  Category toEntity() {
    return Category(
      id: id,
      nameAr: nameAr,
      nameEn: nameEn,
      iconUrl: iconUrl,
      parentId: parentId,
      sortOrder: sortOrder,
    );
  }
}
