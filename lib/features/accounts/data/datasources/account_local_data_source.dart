import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/account.dart';

class AccountLocalDataSource {
  final AppDatabase _appDatabase;

  AccountLocalDataSource(this._appDatabase);

  Future<List<Account>> getAccounts() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('accounts');
    return List.generate(maps.length, (i) => Account.fromMap(maps[i]));
  }

  Future<Account> createAccount(Account account) async {
    final db = await _appDatabase.database;
    var map = account.toMap();
    map.remove('id'); // SQLite generates the ID if omitted or null

    final id = await db.insert(
      'accounts',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return account.copyWith(id: id);
  }

  Future<void> updateAccount(Account account) async {
    final db = await _appDatabase.database;
    await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<void> deleteAccount(int id) async {
    final db = await _appDatabase.database;
    await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
