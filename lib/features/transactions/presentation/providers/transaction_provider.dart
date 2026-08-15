import 'dart:async';
import '../../../../core/providers/date_filter_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../savings/application/savings_service.dart';
import '../../../budgets/application/budget_notification_watcher.dart';
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

      // Check budget thresholds in the background
      final watcher = ref.read(budgetNotificationWatcherProvider);
      final txDate = DateTime.tryParse(newT.date) ?? DateTime.now();
      for (final split in newT.splits) {
        watcher.checkBudgetForCategory(split.categoryId, txDate).catchError((e) {
           debugPrint('Error checking budget notifications: $e');
        });
      }
      
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
      final updatedT = await _repository.updateTransaction(transaction);
      
      // Check budget thresholds in the background
      final watcher = ref.read(budgetNotificationWatcherProvider);
      final txDate = DateTime.tryParse(updatedT.date) ?? DateTime.now();
      for (final split in updatedT.splits) {
        watcher.checkBudgetForCategory(split.categoryId, txDate).catchError((e) {
           debugPrint('Error checking budget notifications: $e');
        });
      }

      return await _repository.getTransactions();
    });
  }
}

final filteredTransactionsProvider = Provider<AsyncValue<List<TransactionEntity>>>((ref) {
  final transactionsState = ref.watch(transactionsProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);

  return transactionsState.whenData((transactions) {
    return transactions.where((t) {
      final tDate = DateTime.parse(t.date);
      return tDate.year == selectedMonth.year && tDate.month == selectedMonth.month;
    }).toList();
  });
});

final transactionByIdProvider = Provider.family<TransactionEntity?, String>((ref, id) {
  final transactions = ref.watch(transactionsProvider);
  final parsedId = int.tryParse(id);
  if (parsedId == null) return null;
  return transactions.maybeWhen(
    data: (list) => list.where((t) => t.id == parsedId).firstOrNull,
    orElse: () => null,
  );
});
