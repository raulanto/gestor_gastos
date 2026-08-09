import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/category.dart';

class CategoryLocalDataSource {
  final AppDatabase _appDatabase;

  CategoryLocalDataSource(this._appDatabase);

  Future<List<Category>> getCategories() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<Category> createCategory(Category category) async {
    final db = await _appDatabase.database;
    var map = category.toMap();
    map.remove('id'); // ID autogenerado

    final id = await db.insert(
      'categories',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return category.copyWith(id: id);
  }

  Future<void> updateCategory(Category category) async {
    final db = await _appDatabase.database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(int id) async {
    final db = await _appDatabase.database;
    // La DB está configurada con ON DELETE CASCADE, por lo que las
    // subcategorías asociadas también se borrarán automáticamente si es un padre.
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
