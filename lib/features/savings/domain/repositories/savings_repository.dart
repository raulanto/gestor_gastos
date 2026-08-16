import '../entities/savings_goal.dart';
import '../entities/savings_transaction.dart';
import '../entities/savings_rule.dart';

abstract class SavingsRepository {
  // Goals
  Future<List<SavingsGoalEntity>> getSavingsGoals();
  Future<SavingsGoalEntity> createGoal(SavingsGoalEntity goal);
  Future<void> updateGoal(SavingsGoalEntity goal);
  Future<void> deleteGoal(int id);

  // Transactions
  Future<List<SavingsTransactionEntity>> getTransactionsByGoal(int goalId);
  Future<SavingsTransactionEntity> createTransaction(
    SavingsTransactionEntity tx,
  );

  // Rules
  Future<List<SavingsRuleEntity>> getRules();
  Future<List<SavingsRuleEntity>> getRulesByGoal(int goalId);
  Future<SavingsRuleEntity> createRule(SavingsRuleEntity rule);
  Future<void> updateRule(SavingsRuleEntity rule);
  Future<void> deleteRule(int id);
}
