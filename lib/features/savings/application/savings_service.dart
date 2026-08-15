import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/domain/entities/transaction.dart';
import '../../transactions/domain/repositories/transaction_repository.dart';
import '../../transactions/presentation/providers/transaction_provider.dart';
import '../domain/entities/savings_transaction.dart';
import '../domain/repositories/savings_repository.dart';
import '../presentation/providers/savings_provider.dart';
import 'savings_notification_watcher.dart';

final savingsServiceProvider = Provider<SavingsService>((ref) {
  final savingsRepo = ref.watch(savingsRepositoryProvider);
  final txRepo = ref.watch(transactionRepositoryProvider);
  return SavingsService(savingsRepo, txRepo, ref);
});

class SavingsService {
  final SavingsRepository _savingsRepository;
  final TransactionRepository _transactionRepository;
  final Ref ref;

  SavingsService(this._savingsRepository, this._transactionRepository, this.ref);

  /// Processes active savings rules against a new transaction.
  Future<void> processTransactionRules(TransactionEntity tx) async {
    final allRules = await _savingsRepository.getRules();
    if (allRules.isEmpty) return;
    
    // Fetch all active goals to get their priorities and configurations
    final allGoals = await _savingsRepository.getSavingsGoals();
    final goalMap = { for (var g in allGoals) g.id! : g };

    // Filter active rules and map them to their goals
    final activeRules = allRules.where((r) => r.status == 'active' && goalMap.containsKey(r.goalId)).toList();
    
    // Sort rules based on their goal's priority (lowest number = highest priority)
    activeRules.sort((a, b) {
      final pA = goalMap[a.goalId]!.priority;
      final pB = goalMap[b.goalId]!.priority;
      return pA.compareTo(pB);
    });

    double remainingIncome = tx.amount;

    for (var rule in activeRules) {
      final goal = goalMap[rule.goalId]!;
      
      if (tx.type == 'expense' && rule.ruleType == 'round_up') {
        // Redondeo configurable
        final roundingTarget = rule.value > 0 ? rule.value : 10.0;
        final rounded = (tx.amount / roundingTarget).ceil() * roundingTarget;
        final difference = rounded - tx.amount;

        if (difference > 0) {
          await _executeAutomaticSaving(
            goalId: rule.goalId,
            accountId: tx.accountId,
            amount: difference,
            reason: 'Redondeo automático',
            deductFromBalance: goal.deductFromBalance,
          );
        }
      } else if (tx.type == 'income' && rule.ruleType == 'fixed_percentage' && remainingIncome > 0) {
        // Porcentaje sobre el ingreso
        final percentage = rule.value;
        double amountToSave = tx.amount * (percentage / 100);
        
        // Limitar la cantidad a ahorrar al ingreso restante
        if (amountToSave > remainingIncome) {
          amountToSave = remainingIncome;
        }

        if (amountToSave > 0) {
          await _executeAutomaticSaving(
            goalId: rule.goalId,
            accountId: tx.accountId,
            amount: amountToSave,
            reason: 'Ahorro automático ($percentage%)',
            deductFromBalance: goal.deductFromBalance,
          );
          remainingIncome -= amountToSave;
        }
      }
    }
  }

  Future<void> _executeAutomaticSaving({
    required int goalId,
    required int accountId,
    required double amount,
    required String reason,
    required bool deductFromBalance,
  }) async {
    // 1. Create a Savings Transaction (deposit)
    final savingsTx = SavingsTransactionEntity(
      goalId: goalId,
      accountId: accountId,
      amount: amount,
      date: DateTime.now().toIso8601String(),
      type: 'deposit',
      reason: reason,
    );
    await _savingsRepository.createTransaction(savingsTx);

    // Trigger notification watcher
    ref.read(savingsNotificationWatcherProvider).checkSavingsProgress(goalId, amount).catchError((e) {
      debugPrint('Error in savings watcher: $e');
    });

    // 2. Create a normal expense transaction to reflect the real money leaving the account, if configured
    if (deductFromBalance) {
      final realTx = TransactionEntity(
        accountId: accountId,
        amount: amount,
        date: DateTime.now().toIso8601String(),
        note: reason,
        type: 'expense',
      );
      await _transactionRepository.createTransaction(realTx);
    }
  }
}
