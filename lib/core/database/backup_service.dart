import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'app_database.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  return BackupService(appDb);
});

class BackupService {
  final AppDatabase _appDatabase;

  BackupService(this._appDatabase);

  final List<String> _tables = [
    'accounts',
    'categories',
    'transactions',
    'transaction_splits',
    'recurring_transactions',
    'recurring_transaction_splits',
    'savings_goals',
    'savings_transactions',
    'savings_rules',
    'notification_preferences',
    'budgets',
    'persons',
    'loans',
    'loan_payments',
  ];

  Future<String> exportData() async {
    final db = await _appDatabase.database;
    final Map<String, List<Map<String, dynamic>>> backupData = {};

    for (final table in _tables) {
      final rows = await db.query(table);
      backupData[table] = rows;
    }

    return jsonEncode(backupData);
  }

  Future<void> importData(String jsonString) async {
    final db = await _appDatabase.database;
    final Map<String, dynamic> backupData = jsonDecode(jsonString);

    await db.transaction((txn) async {
      final reverseTables = _tables.reversed.toList();
      for (final table in reverseTables) {
        await txn.delete(table);
      }

      for (final table in _tables) {
        if (backupData.containsKey(table)) {
          final List<dynamic> rows = backupData[table];
          for (final dynamic row in rows) {
            await txn.insert(table, Map<String, dynamic>.from(row), conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      }
    });
  }
}
