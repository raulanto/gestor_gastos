import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/domain/entities/transaction.dart';
import '../../transactions/domain/repositories/transaction_repository.dart';
import '../../transactions/presentation/providers/transaction_provider.dart';
import '../domain/entities/savings_transaction.dart';
import '../domain/repositories/savings_repository.dart';
import '../presentation/providers/savings_provider.dart';

final savingsServiceProvider = Provider<SavingsService>((ref) {
  final savingsRepo = ref.watch(savingsRepositoryProvider);
  final txRepo = ref.watch(transactionRepositoryProvider);
  return SavingsService(savingsRepo, txRepo);
});

class SavingsService {
  final SavingsRepository _savingsRepository;
  final TransactionRepository _transactionRepository;

  SavingsService(this._savingsRepository, this._transactionRepository);

  /// Processes active savings rules against a new transaction.
  Future<void> processTransactionRules(TransactionEntity tx) async {
    final allRules = await _savingsRepository.getRules();
    if (allRules.isEmpty) return;

    for (var rule in allRules) {
      if (rule.status != 'active') continue;

      if (tx.type == 'expense' && rule.ruleType == 'round_up') {
        // Redondeo al siguiente entero o decena? Asumamos redondeo al entero superior
        final rounded = tx.amount.ceilToDouble();
        final difference = rounded - tx.amount;

        if (difference > 0) {
          await _executeAutomaticSaving(
            goalId: rule.goalId,
            accountId: tx.accountId,
            amount: difference,
            reason: 'Redondeo automático',
          );
        }
      } else if (tx.type == 'income' && rule.ruleType == 'fixed_percentage') {
        // Porcentaje sobre el ingreso
        final percentage = rule.value;
        final amountToSave = tx.amount * (percentage / 100);

        if (amountToSave > 0) {
          await _executeAutomaticSaving(
            goalId: rule.goalId,
            accountId: tx.accountId,
            amount: amountToSave,
            reason: 'Ahorro programado ($percentage%)',
          );
        }
      }
    }
  }

  Future<void> _executeAutomaticSaving({
    required int goalId,
    required int accountId,
    required double amount,
    required String reason,
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

    // 2. Create a normal expense transaction to reflect the real money leaving the account
    final realTx = TransactionEntity(
      accountId: accountId,
      amount: amount,
      date: DateTime.now().toIso8601String(),
      note: reason,
      type: 'expense', // It's an expense from the normal account's perspective
      // Optionally link to a special "Savings" category
    );
    await _transactionRepository.createTransaction(realTx);
  }
}
