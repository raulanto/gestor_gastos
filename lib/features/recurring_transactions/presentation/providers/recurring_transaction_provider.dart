import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../data/datasources/recurring_transaction_local_data_source.dart';
import '../../data/repositories/recurring_transaction_repository_impl.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/repositories/recurring_transaction_repository.dart';

final recurringTransactionRepositoryProvider = Provider<RecurringTransactionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final dataSource = RecurringTransactionLocalDataSource(db);
  return RecurringTransactionRepositoryImpl(dataSource);
});

final recurringTransactionsProvider = AsyncNotifierProvider<RecurringTransactionNotifier, List<RecurringTransactionEntity>>(() {
  return RecurringTransactionNotifier();
});

class RecurringTransactionNotifier extends AsyncNotifier<List<RecurringTransactionEntity>> {
  @override
  Future<List<RecurringTransactionEntity>> build() async {
    return await ref.read(recurringTransactionRepositoryProvider).getRecurringTransactions();
  }

  Future<void> add(RecurringTransactionEntity rt) async {
    final repo = ref.read(recurringTransactionRepositoryProvider);
    final newRt = await repo.create(rt);
    state = AsyncValue.data([...state.value ?? [], newRt]);
  }

  Future<void> updateRecurringTransaction(RecurringTransactionEntity rt) async {
    final repo = ref.read(recurringTransactionRepositoryProvider);
    await repo.update(rt);
    final list = state.value ?? [];
    state = AsyncValue.data(list.map((e) => e.id == rt.id ? rt : e).toList());
  }

  Future<void> toggleStatus(int id) async {
    final list = state.value ?? [];
    final current = list.firstWhere((e) => e.id == id);
    final newStatus = current.status == 'active' ? 'paused' : 'active';
    
    final repo = ref.read(recurringTransactionRepositoryProvider);
    await repo.updateStatus(id, newStatus);
    
    state = AsyncValue.data(list.map((e) {
      if (e.id == id) {
        return RecurringTransactionEntity(
          id: e.id,
          amount: e.amount,
          accountId: e.accountId,
          categoryId: e.categoryId,
          note: e.note,
          type: e.type,
          periodicity: e.periodicity,
          nextExecutionDate: e.nextExecutionDate,
          status: newStatus,
          splits: e.splits,
        );
      }
      return e;
    }).toList());
  }

  Future<void> remove(int id) async {
    final repo = ref.read(recurringTransactionRepositoryProvider);
    await repo.delete(id);
    state = AsyncValue.data((state.value ?? []).where((e) => e.id != id).toList());
  }
}

final recurringTransactionByIdProvider = Provider.family<RecurringTransactionEntity?, String>((ref, id) {
  final transactions = ref.watch(recurringTransactionsProvider);
  final parsedId = int.tryParse(id);
  if (parsedId == null) return null;
  return transactions.maybeWhen(
    data: (list) => list.where((rt) => rt.id == parsedId).firstOrNull,
    orElse: () => null,
  );
});
