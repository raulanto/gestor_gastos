import '../../domain/entities/savings_goal.dart';
import '../../domain/entities/savings_rule.dart';
import '../../domain/entities/savings_transaction.dart';
import '../../domain/repositories/savings_repository.dart';
import '../datasources/savings_local_data_source.dart';

class SavingsRepositoryImpl implements SavingsRepository {
  final SavingsLocalDataSource _dataSource;

  SavingsRepositoryImpl(this._dataSource);

  @override
  Future<List<SavingsGoalEntity>> getSavingsGoals() => _dataSource.getGoals();

  @override
  Future<SavingsGoalEntity> createGoal(SavingsGoalEntity goal) => _dataSource.createGoal(goal);

  @override
  Future<void> updateGoal(SavingsGoalEntity goal) => _dataSource.updateGoal(goal);

  @override
  Future<void> deleteGoal(int id) => _dataSource.deleteGoal(id);

  @override
  Future<List<SavingsTransactionEntity>> getTransactionsByGoal(int goalId) => _dataSource.getTransactionsByGoal(goalId);

  @override
  Future<SavingsTransactionEntity> createTransaction(SavingsTransactionEntity tx) => _dataSource.createTransaction(tx);

  @override
  Future<List<SavingsRuleEntity>> getRules() => _dataSource.getRules();

  @override
  Future<List<SavingsRuleEntity>> getRulesByGoal(int goalId) => _dataSource.getRulesByGoal(goalId);

  @override
  Future<SavingsRuleEntity> createRule(SavingsRuleEntity rule) => _dataSource.createRule(rule);

  @override
  Future<void> updateRule(SavingsRuleEntity rule) => _dataSource.updateRule(rule);

  @override
  Future<void> deleteRule(int id) => _dataSource.deleteRule(id);
}
