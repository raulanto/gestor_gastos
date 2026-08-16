class PersonEntity {
  final int? id;
  final String name;
  final String? phone;
  final String? photoPath;

  PersonEntity({this.id, required this.name, this.phone, this.photoPath});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'phone': phone, 'photo_path': photoPath};
  }

  factory PersonEntity.fromMap(Map<String, dynamic> map) {
    return PersonEntity(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      photoPath: map['photo_path'],
    );
  }

  PersonEntity copyWith({
    int? id,
    String? name,
    String? phone,
    String? photoPath,
  }) {
    return PersonEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}
