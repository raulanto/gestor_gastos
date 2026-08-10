import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../data/datasources/savings_local_data_source.dart';
import '../../data/repositories/savings_repository_impl.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/entities/savings_transaction.dart';
import '../../domain/repositories/savings_repository.dart';

// Providers
final savingsLocalDataSourceProvider = Provider<SavingsLocalDataSource>((ref) {
  final appDatabase = ref.watch(appDatabaseProvider);
  return SavingsLocalDataSource(appDatabase);
});

final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  final dataSource = ref.watch(savingsLocalDataSourceProvider);
  return SavingsRepositoryImpl(dataSource);
});

// Notifier
class SavingsGoalsNotifier extends AsyncNotifier<List<SavingsGoalEntity>> {
  @override
  Future<List<SavingsGoalEntity>> build() async {
    final repo = ref.watch(savingsRepositoryProvider);
    return repo.getSavingsGoals();
  }

  Future<void> addGoal(SavingsGoalEntity goal) async {
    final repo = ref.read(savingsRepositoryProvider);
    final newGoal = await repo.createGoal(goal);
    state = AsyncValue.data([...state.value ?? [], newGoal]);
  }

  Future<void> updateGoal(SavingsGoalEntity goal) async {
    final repo = ref.read(savingsRepositoryProvider);
    await repo.updateGoal(goal);
    final list = state.value ?? [];
    state = AsyncValue.data(list.map((e) => e.id == goal.id ? goal : e).toList());
  }

  Future<void> deleteGoal(int id) async {
    final repo = ref.read(savingsRepositoryProvider);
    await repo.deleteGoal(id);
    final list = state.value ?? [];
    state = AsyncValue.data(list.where((e) => e.id != id).toList());
  }
}

final savingsGoalsProvider = AsyncNotifierProvider<SavingsGoalsNotifier, List<SavingsGoalEntity>>(SavingsGoalsNotifier.new);

final savingsGoalTransactionsProvider = FutureProvider.family<List<SavingsTransactionEntity>, int>((ref, goalId) async {
  final repo = ref.watch(savingsRepositoryProvider);
  return repo.getTransactionsByGoal(goalId);
});
