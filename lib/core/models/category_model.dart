enum CategoryType { expense, income, transfer }

class CategoryModel {
  final String id;
  final String name;
  final CategoryType type;
  final String? iconPath;
  final List<String> subcategories;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    this.iconPath,
    this.subcategories = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'],
    name: json['name'],
    type: CategoryType.values.byName(json['type']),
    iconPath: json['iconPath'],
    subcategories: List<String>.from(json['subcategories'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'iconPath': iconPath,
    'subcategories': subcategories,
  };
}
