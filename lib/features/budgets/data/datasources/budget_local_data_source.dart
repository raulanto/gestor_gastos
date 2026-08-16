import '../../../../core/database/app_database.dart';
import '../../domain/entities/budget.dart';

class BudgetLocalDataSource {
  final AppDatabase appDb;
  final Set<String> _cloningMonths = {};

  BudgetLocalDataSource(this.appDb);

  Future<List<BudgetEntity>> getBudgetsByMonth(String monthYear) async {
    final db = await appDb.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'month_year = ?',
      whereArgs: [monthYear],
    );

    if (maps.isEmpty) {
      if (_cloningMonths.contains(monthYear)) {
        await Future.delayed(const Duration(milliseconds: 500));
        return getBudgetsByMonth(monthYear);
      }
      _cloningMonths.add(monthYear);

      try {
        final checkMaps = await db.query(
          'budgets',
          where: 'month_year = ?',
          whereArgs: [monthYear],
        );
        if (checkMaps.isEmpty) {
          // Intentar copiar del mes anterior
          final prevMonthYear = _getPreviousMonthYear(monthYear);
          final prevMaps = await db.query(
            'budgets',
            where: 'month_year = ?',
            whereArgs: [prevMonthYear],
          );

          if (prevMaps.isNotEmpty) {
            // Clonar para el mes actual
            List<BudgetEntity> cloned = [];
            await db.transaction((txn) async {
              for (var map in prevMaps) {
                final newMap = Map<String, dynamic>.from(map);
                newMap.remove('id');
                newMap['month_year'] = monthYear;
                final id = await txn.insert('budgets', newMap);
                cloned.add(BudgetEntity.fromMap({...newMap, 'id': id}));
              }
            });
            return cloned;
          }
        } else {
          return checkMaps.map((m) => BudgetEntity.fromMap(m)).toList();
        }
      } finally {
        _cloningMonths.remove(monthYear);
      }
    }

    return maps.map((m) => BudgetEntity.fromMap(m)).toList();
  }

  String _getPreviousMonthYear(String current) {
    // Formato: YYYY-MM
    final parts = current.split('-');
    if (parts.length != 2) return current;
    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);

    month -= 1;
    if (month == 0) {
      month = 12;
      year -= 1;
    }
    return '$year-${month.toString().padLeft(2, '0')}';
  }

  Future<BudgetEntity> createBudget(BudgetEntity budget) async {
    final db = await appDb.database;
    final id = await db.insert('budgets', budget.toMap());
    return budget.copyWith(id: id);
  }

  Future<BudgetEntity> updateBudget(BudgetEntity budget) async {
    final db = await appDb.database;
    await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
    return budget;
  }

  Future<void> deleteBudget(int id) async {
    final db = await appDb.database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getAverageSpendForCategory(
    int categoryId, {
    int months = 3,
  }) async {
    final db = await appDb.database;
    // Obtener la fecha de hace X meses
    final now = DateTime.now();
    final past = DateTime(now.year, now.month - months, 1);
    final pastIso = past.toIso8601String();

    final result = await db.rawQuery(
      '''
      SELECT SUM(ts.amount) as total
      FROM transaction_splits ts
      JOIN transactions t ON ts.transaction_id = t.id
      WHERE ts.category_id = ? AND t.type = 'expense' AND t.date >= ?
    ''',
      [categoryId, pastIso],
    );

    final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;
    return total / months;
  }

  Future<double> getActualSpendForCategory(
    int categoryId,
    String monthYear,
  ) async {
    final db = await appDb.database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(ts.amount) as total
      FROM transaction_splits ts
      JOIN transactions t ON ts.transaction_id = t.id
      WHERE ts.category_id = ? AND t.type = 'expense' AND t.date LIKE ?
    ''',
      [categoryId, '$monthYear%'],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getActualSavingsForGoal(
    int savingsGoalId,
    String monthYear,
  ) async {
    final db = await appDb.database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(amount) as total
      FROM savings_transactions
      WHERE goal_id = ? AND type = 'deposit' AND date LIKE ?
    ''',
      [savingsGoalId, '$monthYear%'],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
