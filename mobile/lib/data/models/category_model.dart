// lib/data/models/category_model.dart

class CategoryModel {
  final int id;
  final String name;
  final String type;
  final String? icon;
  final String? color;
  final bool isDefault;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    required this.isDefault,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
    };
  }
}