import '../../domain/entities/recurring_transaction.dart';

abstract class RecurringTransactionRepository {
  Future<List<RecurringTransactionEntity>> getRecurringTransactions();
  Future<RecurringTransactionEntity> create(RecurringTransactionEntity rt);
  Future<RecurringTransactionEntity> update(RecurringTransactionEntity rt);
  Future<void> updateNextExecutionDate(int id, String nextDate);
  Future<void> updateStatus(int id, String status);
  Future<void> delete(int id);
}
