import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../savings/application/savings_service.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../data/datasources/transaction_local_data_source.dart';
import '../../data/repositories/transaction_repository_impl.dart';

final transactionLocalDataSourceProvider = Provider<TransactionLocalDataSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TransactionLocalDataSource(db);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final localDataSource = ref.watch(transactionLocalDataSourceProvider);
  return TransactionRepositoryImpl(localDataSource);
});

final transactionsProvider = AsyncNotifierProvider<TransactionNotifier, List<TransactionEntity>>(() {
  return TransactionNotifier();
});

class TransactionNotifier extends AsyncNotifier<List<TransactionEntity>> {
  late TransactionRepository _repository;

  @override
  FutureOr<List<TransactionEntity>> build() async {
    _repository = ref.watch(transactionRepositoryProvider);
    return await _repository.getTransactions();
  }

  Future<void> addTransaction(TransactionEntity transaction) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final newT = await _repository.createTransaction(transaction);
      
      // Process savings rules in the background
      ref.read(savingsServiceProvider).processTransactionRules(newT).catchError((e) {
        debugPrint('Error processing savings rules: $e');
      });
      
      return await _repository.getTransactions();
    });
  }

  Future<void> removeTransaction(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteTransaction(id);
      return await _repository.getTransactions();
    });
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.updateTransaction(transaction);
      return await _repository.getTransactions();
    });
  }
}
