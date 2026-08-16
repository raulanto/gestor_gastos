class User {
  final int id;
  final String username;
  final String? photoPath;

  const User({required this.id, required this.username, this.photoPath});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      username: map['username'] as String,
      photoPath: map['photo_path'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'username': username, 'photo_path': photoPath};
  }
}
