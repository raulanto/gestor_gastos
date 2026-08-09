import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getTransactions();
  Future<TransactionEntity> createTransaction(TransactionEntity transaction);
  Future<TransactionEntity> updateTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(int id);
}
