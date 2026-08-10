import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../data/datasources/budget_local_data_source.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';

final budgetLocalDataSourceProvider = Provider<BudgetLocalDataSource>((ref) {
  return BudgetLocalDataSource(ref.watch(appDatabaseProvider));
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryImpl(ref.watch(budgetLocalDataSourceProvider));
});

class BudgetProgress {
  final BudgetEntity budget;
  final double actualAmount;

  BudgetProgress({required this.budget, required this.actualAmount});

  double get progressPercentage => budget.amount > 0 ? actualAmount / budget.amount : 0.0;
}

final monthlyBudgetsProvider = FutureProvider.family<List<BudgetProgress>, String>((ref, monthYear) async {
  ref.watch(transactionsProvider);
  final repo = ref.watch(budgetRepositoryProvider);
  final budgets = await repo.getBudgetsByMonth(monthYear);
  
  List<BudgetProgress> progressList = [];
  for (var b in budgets) {
    double actual = 0.0;
    if (b.categoryId != null) {
      actual = await repo.getActualSpendForCategory(b.categoryId!, monthYear);
    } else if (b.savingsGoalId != null) {
      actual = await repo.getActualSavingsForGoal(b.savingsGoalId!, monthYear);
    }
    progressList.add(BudgetProgress(budget: b, actualAmount: actual));
  }
  
  return progressList;
});

final globalBudgetProvider = FutureProvider.family<Map<String, double>, String>((ref, monthYear) async {
  ref.watch(transactionsProvider);
  final repo = ref.watch(budgetRepositoryProvider);
  final budgets = await repo.getBudgetsByMonth(monthYear);
  
  double totalBudgeted = 0.0;
  double totalSpent = 0.0;
  
  for (var b in budgets) {
    // Solo sumamos los de gastos para el presupuesto global de gastos, no los de ahorro
    if (b.categoryId != null) {
      totalBudgeted += b.amount;
      totalSpent += await repo.getActualSpendForCategory(b.categoryId!, monthYear);
    }
  }
  
  return {
    'budgeted': totalBudgeted,
    'spent': totalSpent,
  };
});
