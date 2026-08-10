import '../entities/budget.dart';

abstract class BudgetRepository {
  Future<List<BudgetEntity>> getBudgetsByMonth(String monthYear);
  Future<BudgetEntity> createBudget(BudgetEntity budget);
  Future<BudgetEntity> updateBudget(BudgetEntity budget);
  Future<void> deleteBudget(int id);
  Future<double> getAverageSpendForCategory(int categoryId, {int months = 3});
  Future<double> getActualSpendForCategory(int categoryId, String monthYear);
  Future<double> getActualSavingsForGoal(int savingsGoalId, String monthYear);
}
