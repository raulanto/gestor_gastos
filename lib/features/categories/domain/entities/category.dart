class Category {
  final int id;
  final String name;
  final int iconCode;
  final int colorCode;
  final int?
  parentId; // null si es categoría principal, ID del padre si es subcategoría

  const Category({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorCode,
    this.parentId,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      iconCode: map['icon_code'] as int,
      colorCode: map['color_code'] as int,
      parentId: map['parent_id'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_code': iconCode,
      'color_code': colorCode,
      'parent_id': parentId,
    };
  }

  Category copyWith({
    int? id,
    String? name,
    int? iconCode,
    int? colorCode,
    int? parentId,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorCode: colorCode ?? this.colorCode,
      parentId: parentId ?? this.parentId,
    );
  }
}
