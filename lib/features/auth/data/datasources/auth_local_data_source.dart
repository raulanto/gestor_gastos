import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/user.dart';

class AuthLocalDataSource {
  final AppDatabase _appDatabase;

  AuthLocalDataSource(this._appDatabase);

  Future<User?> getUser() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('users', limit: 1);

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User> saveUser(String username) async {
    final db = await _appDatabase.database;
    
    // Validar si ya existe el usuario o insertar
    final existingUsers = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (existingUsers.isNotEmpty) {
      return User.fromMap(existingUsers.first);
    }

    final id = await db.insert(
      'users',
      {'username': username},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return User(id: id, username: username);
  }
  Future<User> updateProfile(int id, String username, String? photoPath) async {
    final db = await _appDatabase.database;
    await db.update(
      'users',
      {
        'username': username,
        'photo_path': photoPath,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    return User(id: id, username: username, photoPath: photoPath);
  }
}
