import '../../../../core/database/app_database.dart';
import '../../domain/entities/recurring_transaction.dart';

class RecurringTransactionLocalDataSource {
  final AppDatabase appDb;

  RecurringTransactionLocalDataSource(this.appDb);

  Future<List<RecurringTransactionEntity>> getRecurringTransactions() async {
    final db = await appDb.database;
    final maps = await db.query('recurring_transactions');

    List<RecurringTransactionEntity> rts = [];
    for (var map in maps) {
      final rtId = map['id'];
      
      final splitMaps = await db.query(
        'recurring_transaction_splits',
        where: 'recurring_transaction_id = ?',
        whereArgs: [rtId],
      );
      
      final splits = splitMaps.map((s) => RecurringTransactionSplit.fromMap(s)).toList();
      rts.add(RecurringTransactionEntity.fromMap(map, splits: splits));
    }
    return rts;
  }

  Future<RecurringTransactionEntity> create(RecurringTransactionEntity rt) async {
    final db = await appDb.database;
    int id = await db.transaction((txn) async {
      final map = rt.toMap();
      if (rt.categoryId != null && rt.splits.isEmpty) {
        map['category_id'] = rt.categoryId;
      }
      final newId = await txn.insert('recurring_transactions', map);

      if (rt.categoryId != null && rt.splits.isEmpty) {
        await txn.insert('recurring_transaction_splits', {
          'recurring_transaction_id': newId,
          'category_id': rt.categoryId,
          'amount': rt.amount,
        });
      } else {
        for (var split in rt.splits) {
          final splitMap = split.toMap();
          splitMap['recurring_transaction_id'] = newId;
          splitMap.remove('id');
          await txn.insert('recurring_transaction_splits', splitMap);
        }
      }
      return newId;
    });

    return RecurringTransactionEntity(
      id: id,
      amount: rt.amount,
      accountId: rt.accountId,
      categoryId: rt.categoryId,
      note: rt.note,
      type: rt.type,
      periodicity: rt.periodicity,
      nextExecutionDate: rt.nextExecutionDate,
      status: rt.status,
      splits: rt.splits,
    );
  }

  Future<RecurringTransactionEntity> update(RecurringTransactionEntity rt) async {
    final db = await appDb.database;
    await db.transaction((txn) async {
      final map = rt.toMap();
      if (rt.categoryId != null && rt.splits.isEmpty) {
        map['category_id'] = rt.categoryId;
      }
      await txn.update(
        'recurring_transactions',
        map,
        where: 'id = ?',
        whereArgs: [rt.id],
      );

      await txn.delete('recurring_transaction_splits', where: 'recurring_transaction_id = ?', whereArgs: [rt.id]);

      if (rt.categoryId != null && rt.splits.isEmpty) {
        await txn.insert('recurring_transaction_splits', {
          'recurring_transaction_id': rt.id,
          'category_id': rt.categoryId,
          'amount': rt.amount,
        });
      } else {
        for (var split in rt.splits) {
          final splitMap = split.toMap();
          splitMap['recurring_transaction_id'] = rt.id;
          splitMap.remove('id');
          await txn.insert('recurring_transaction_splits', splitMap);
        }
      }
    });

    return rt;
  }

  Future<void> updateNextExecutionDate(int id, String nextDate) async {
    final db = await appDb.database;
    await db.update('recurring_transactions', {'next_execution_date': nextDate}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateStatus(int id, String status) async {
    final db = await appDb.database;
    await db.update('recurring_transactions', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> delete(int id) async {
    final db = await appDb.database;
    await db.delete('recurring_transactions', where: 'id = ?', whereArgs: [id]);
  }
}
