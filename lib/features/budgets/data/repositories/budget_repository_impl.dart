import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_data_source.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource _dataSource;

  BudgetRepositoryImpl(this._dataSource);

  @override
  Future<List<BudgetEntity>> getBudgetsByMonth(String monthYear) {
    return _dataSource.getBudgetsByMonth(monthYear);
  }

  @override
  Future<BudgetEntity> createBudget(BudgetEntity budget) {
    return _dataSource.createBudget(budget);
  }

  @override
  Future<BudgetEntity> updateBudget(BudgetEntity budget) {
    return _dataSource.updateBudget(budget);
  }

  @override
  Future<void> deleteBudget(int id) {
    return _dataSource.deleteBudget(id);
  }

  @override
  Future<double> getAverageSpendForCategory(int categoryId, {int months = 3}) {
    return _dataSource.getAverageSpendForCategory(categoryId, months: months);
  }

  @override
  Future<double> getActualSpendForCategory(int categoryId, String monthYear) {
    return _dataSource.getActualSpendForCategory(categoryId, monthYear);
  }

  @override
  Future<double> getActualSavingsForGoal(int savingsGoalId, String monthYear) {
    return _dataSource.getActualSavingsForGoal(savingsGoalId, monthYear);
  }
}
