import '../../../../core/database/app_database.dart';
import '../../domain/entities/person.dart';

class PersonLocalDataSource {
  final AppDatabase _appDatabase;

  PersonLocalDataSource(this._appDatabase);

  Future<List<PersonEntity>> getPersons() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'persons',
      orderBy: 'name ASC',
    );
    return maps.map((map) => PersonEntity.fromMap(map)).toList();
  }

  Future<int> insertPerson(PersonEntity person) async {
    final db = await _appDatabase.database;
    return await db.insert('persons', person.toMap());
  }

  Future<int> updatePerson(PersonEntity person) async {
    final db = await _appDatabase.database;
    return await db.update(
      'persons',
      person.toMap(),
      where: 'id = ?',
      whereArgs: [person.id],
    );
  }

  Future<int> deletePerson(int id) async {
    final db = await _appDatabase.database;
    return await db.delete('persons', where: 'id = ?', whereArgs: [id]);
  }

  Future<PersonEntity?> getPersonById(int id) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'persons',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return PersonEntity.fromMap(maps.first);
    }
    return null;
  }
}
