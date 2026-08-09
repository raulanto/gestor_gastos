import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_data_source.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource _localDataSource;

  TransactionRepositoryImpl(this._localDataSource);

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    return await _localDataSource.getTransactions();
  }

  @override
  Future<TransactionEntity> createTransaction(TransactionEntity transaction) async {
    return await _localDataSource.createTransaction(transaction);
  }

  @override
  Future<void> deleteTransaction(int id) async {
    return await _localDataSource.deleteTransaction(id);
  }

  @override
  Future<TransactionEntity> updateTransaction(TransactionEntity transaction) async {
    return await _localDataSource.updateTransaction(transaction);
  }
}
