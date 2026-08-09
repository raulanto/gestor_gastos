import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
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
    final previousState = state.value;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final newT = await _repository.createTransaction(transaction);
      return [newT, ...?previousState];
    });
  }

  Future<void> removeTransaction(int id) async {
    final previousState = state.value;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteTransaction(id);
      return previousState?.where((t) => t.id != id).toList() ?? [];
    });
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    final previousState = state.value;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updatedT = await _repository.updateTransaction(transaction);
      if (previousState == null) return [updatedT];
      return previousState.map((t) => t.id == updatedT.id ? updatedT : t).toList();
    });
  }
}
