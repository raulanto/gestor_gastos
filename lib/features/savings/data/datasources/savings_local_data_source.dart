import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/entities/savings_rule.dart';
import '../../domain/entities/savings_transaction.dart';

class SavingsLocalDataSource {
  final AppDatabase _appDatabase;

  SavingsLocalDataSource(this._appDatabase);

  // Goals
  Future<List<SavingsGoalEntity>> getGoals() async {
    final db = await _appDatabase.database;
    final maps = await db.query('savings_goals');
    return maps.map((map) => SavingsGoalEntity.fromMap(map)).toList();
  }

  Future<SavingsGoalEntity> createGoal(SavingsGoalEntity goal) async {
    final db = await _appDatabase.database;
    final id = await db.insert(
      'savings_goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return goal.copyWith(id: id);
  }

  Future<void> updateGoal(SavingsGoalEntity goal) async {
    final db = await _appDatabase.database;
    await db.update(
      'savings_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<void> deleteGoal(int id) async {
    final db = await _appDatabase.database;
    await db.delete('savings_goals', where: 'id = ?', whereArgs: [id]);
  }

  // Transactions
  Future<List<SavingsTransactionEntity>> getTransactionsByGoal(
    int goalId,
  ) async {
    final db = await _appDatabase.database;
    final maps = await db.query(
      'savings_transactions',
      where: 'goal_id = ?',
      whereArgs: [goalId],
    );
    return maps.map((map) => SavingsTransactionEntity.fromMap(map)).toList();
  }

  Future<SavingsTransactionEntity> createTransaction(
    SavingsTransactionEntity tx,
  ) async {
    final db = await _appDatabase.database;

    // We should also update the real account balance if it's connected to an account.
    // Savings deposit means money moves from regular account to savings goal.
    // The transaction service should handle the regular expense/income. The savings_transaction just tracks the goal side.

    final id = await db.insert(
      'savings_transactions',
      tx.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return SavingsTransactionEntity(
      id: id,
      goalId: tx.goalId,
      accountId: tx.accountId,
      amount: tx.amount,
      date: tx.date,
      type: tx.type,
      reason: tx.reason,
    );
  }

  // Rules
  Future<List<SavingsRuleEntity>> getRules() async {
    final db = await _appDatabase.database;
    final maps = await db.query('savings_rules');
    return maps.map((map) => SavingsRuleEntity.fromMap(map)).toList();
  }

  Future<List<SavingsRuleEntity>> getRulesByGoal(int goalId) async {
    final db = await _appDatabase.database;
    final maps = await db.query(
      'savings_rules',
      where: 'goal_id = ?',
      whereArgs: [goalId],
    );
    return maps.map((map) => SavingsRuleEntity.fromMap(map)).toList();
  }

  Future<SavingsRuleEntity> createRule(SavingsRuleEntity rule) async {
    final db = await _appDatabase.database;
    final id = await db.insert(
      'savings_rules',
      rule.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return rule.copyWith(id: id);
  }

  Future<void> updateRule(SavingsRuleEntity rule) async {
    final db = await _appDatabase.database;
    await db.update(
      'savings_rules',
      rule.toMap(),
      where: 'id = ?',
      whereArgs: [rule.id],
    );
  }

  Future<void> deleteRule(int id) async {
    final db = await _appDatabase.database;
    await db.delete('savings_rules', where: 'id = ?', whereArgs: [id]);
  }
}
