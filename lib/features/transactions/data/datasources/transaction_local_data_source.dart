import '../../../../core/database/app_database.dart';
import '../../domain/entities/transaction.dart';

class TransactionLocalDataSource {
  final AppDatabase appDb;

  TransactionLocalDataSource(this.appDb);

  Future<List<TransactionEntity>> getTransactions() async {
    final db = await appDb.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC, id DESC',
    );

    List<TransactionEntity> transactions = [];
    for (var map in maps) {
      final transactionId = map['id'];

      // Obtener splits si los hay
      final List<Map<String, dynamic>> splitMaps = await db.query(
        'transaction_splits',
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
      );

      final splits = splitMaps.map((s) => TransactionSplit.fromMap(s)).toList();

      transactions.add(TransactionEntity.fromMap(map, splits: splits));
    }

    return transactions;
  }

  Future<TransactionEntity> createTransaction(
    TransactionEntity transaction,
  ) async {
    final db = await appDb.database;
    int id = await db.transaction((txn) async {
      final tId = await txn.insert('transactions', transaction.toMap());

      if (transaction.categoryId != null && transaction.splits.isEmpty) {
        await txn.insert('transaction_splits', {
          'transaction_id': tId,
          'category_id': transaction.categoryId,
          'amount': transaction.amount,
        });
      } else {
        for (var split in transaction.splits) {
          final splitMap = split.toMap();
          splitMap['transaction_id'] = tId;
          splitMap.remove('id'); // SQLite lo autogenerará
          await txn.insert('transaction_splits', splitMap);
        }
      }

      // Actualizar saldo de la cuenta si es un gasto
      if (transaction.type == 'expense') {
        await txn.rawUpdate(
          'UPDATE accounts SET balance = balance - ? WHERE id = ?',
          [transaction.amount, transaction.accountId],
        );
      } else if (transaction.type == 'income') {
        await txn.rawUpdate(
          'UPDATE accounts SET balance = balance + ? WHERE id = ?',
          [transaction.amount, transaction.accountId],
        );
      }

      return tId;
    });

    return TransactionEntity(
      id: id,
      accountId: transaction.accountId,
      categoryId: transaction.categoryId,
      amount: transaction.amount,
      date: transaction.date,
      note: transaction.note,
      receiptImagePath: transaction.receiptImagePath,
      type: transaction.type,
      splits: transaction.splits,
    );
  }

  Future<void> deleteTransaction(int id) async {
    final db = await appDb.database;
    // Primero, obtener la transacción para revertir el balance
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      final t = TransactionEntity.fromMap(maps.first);

      await db.transaction((txn) async {
        if (t.type == 'expense') {
          await txn.rawUpdate(
            'UPDATE accounts SET balance = balance + ? WHERE id = ?',
            [t.amount, t.accountId],
          );
        } else if (t.type == 'income') {
          await txn.rawUpdate(
            'UPDATE accounts SET balance = balance - ? WHERE id = ?',
            [t.amount, t.accountId],
          );
        }

        await txn.delete('transactions', where: 'id = ?', whereArgs: [id]);
        // Los splits se eliminan por CASCADE en SQLite
      });
    }
  }

  Future<TransactionEntity> updateTransaction(
    TransactionEntity transaction,
  ) async {
    final db = await appDb.database;
    await db.transaction((txn) async {
      // Revertir el balance anterior de la cuenta para recalcular
      final oldMaps = await txn.query(
        'transactions',
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
      if (oldMaps.isNotEmpty) {
        final oldT = TransactionEntity.fromMap(oldMaps.first);
        if (oldT.type == 'expense') {
          await txn.rawUpdate(
            'UPDATE accounts SET balance = balance + ? WHERE id = ?',
            [oldT.amount, oldT.accountId],
          );
        } else if (oldT.type == 'income') {
          await txn.rawUpdate(
            'UPDATE accounts SET balance = balance - ? WHERE id = ?',
            [oldT.amount, oldT.accountId],
          );
        }
      }

      await txn.update(
        'transactions',
        transaction.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );

      // Eliminar splits anteriores
      await txn.delete(
        'transaction_splits',
        where: 'transaction_id = ?',
        whereArgs: [transaction.id],
      );

      // Insertar nuevos splits
      if (transaction.categoryId != null && transaction.splits.isEmpty) {
        await txn.insert('transaction_splits', {
          'transaction_id': transaction.id,
          'category_id': transaction.categoryId,
          'amount': transaction.amount,
        });
      } else {
        for (var split in transaction.splits) {
          final splitMap = split.toMap();
          splitMap['transaction_id'] = transaction.id;
          splitMap.remove('id');
          await txn.insert('transaction_splits', splitMap);
        }
      }

      // Aplicar nuevo balance
      if (transaction.type == 'expense') {
        await txn.rawUpdate(
          'UPDATE accounts SET balance = balance - ? WHERE id = ?',
          [transaction.amount, transaction.accountId],
        );
      } else if (transaction.type == 'income') {
        await txn.rawUpdate(
          'UPDATE accounts SET balance = balance + ? WHERE id = ?',
          [transaction.amount, transaction.accountId],
        );
      }
    });

    return transaction;
  }
}
