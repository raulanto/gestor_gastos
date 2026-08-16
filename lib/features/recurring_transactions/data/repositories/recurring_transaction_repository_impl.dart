import '../../domain/entities/recurring_transaction.dart';
import '../../domain/repositories/recurring_transaction_repository.dart';
import '../datasources/recurring_transaction_local_data_source.dart';

class RecurringTransactionRepositoryImpl
    implements RecurringTransactionRepository {
  final RecurringTransactionLocalDataSource _dataSource;

  RecurringTransactionRepositoryImpl(this._dataSource);

  @override
  Future<List<RecurringTransactionEntity>> getRecurringTransactions() async {
    return await _dataSource.getRecurringTransactions();
  }

  @override
  Future<RecurringTransactionEntity> create(
    RecurringTransactionEntity rt,
  ) async {
    return await _dataSource.create(rt);
  }

  @override
  Future<RecurringTransactionEntity> update(
    RecurringTransactionEntity rt,
  ) async {
    return await _dataSource.update(rt);
  }

  @override
  Future<void> updateNextExecutionDate(int id, String nextDate) async {
    return await _dataSource.updateNextExecutionDate(id, nextDate);
  }

  @override
  Future<void> updateStatus(int id, String status) async {
    return await _dataSource.updateStatus(id, status);
  }

  @override
  Future<void> delete(int id) async {
    return await _dataSource.delete(id);
  }
}
