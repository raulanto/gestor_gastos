import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/domain/entities/transaction.dart';
import '../../transactions/domain/repositories/transaction_repository.dart';
import '../domain/entities/savings_transaction.dart';
import '../domain/repositories/savings_repository.dart';
import '../presentation/providers/savings_provider.dart';
import '../../transactions/presentation/providers/transaction_provider.dart';
import 'savings_notification_watcher.dart';

final savingsScheduleServiceProvider = Provider<SavingsScheduleService>((ref) {
  final savingsRepo = ref.watch(savingsRepositoryProvider);
  final txRepo = ref.watch(
    transactionRepositoryProvider,
  ); // Asumiendo que se exporta o importando el provider
  return SavingsScheduleService(savingsRepo, txRepo, ref);
});

class SavingsScheduleService {
  final SavingsRepository _savingsRepository;
  final TransactionRepository _transactionRepository;
  final Ref ref;

  SavingsScheduleService(
    this._savingsRepository,
    this._transactionRepository,
    this.ref,
  );

  /// Called on app startup to process 'scheduled' savings rules that might be due.
  /// For simplicity, we assume 'scheduled' rules execute once a month on the 1st day.
  /// A complete implementation would require `next_execution_date` on the rule entity.
  Future<void> checkAndExecuteScheduledSavings() async {
    final rules = await _savingsRepository.getRules();

    // Filtramos solo las programadas activas
    final scheduledRules = rules
        .where((r) => r.ruleType == 'scheduled' && r.status == 'active')
        .toList();
    if (scheduledRules.isEmpty) return;

    final now = DateTime.now();

    for (var rule in scheduledRules) {
      // Simplificación: verificamos si ya se cobró este mes revisando las transacciones de esta meta.
      // Lo ideal sería tener `next_execution_date` como en gastos recurrentes.
      final txs = await _savingsRepository.getTransactionsByGoal(rule.goalId);
      final hasRunThisMonth = txs.any((tx) {
        if (tx.reason != 'Ahorro programado automático') return false;
        final d = DateTime.parse(tx.date);
        return d.year == now.year && d.month == now.month;
      });

      if (!hasRunThisMonth) {
        // Ejecutar cobro
        await _executeAutomaticSaving(
          goalId: rule.goalId,
          accountId:
              1, // FIX: In a real app we need to specify WHICH account this rule uses. Using 1 (Efectivo) as fallback.
          amount: rule.value,
          reason: 'Ahorro programado automático',
        );
      }
    }
  }

  Future<void> _executeAutomaticSaving({
    required int goalId,
    required int accountId,
    required double amount,
    required String reason,
  }) async {
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
    ref
        .read(savingsNotificationWatcherProvider)
        .checkSavingsProgress(goalId, amount)
        .catchError((e) {
          debugPrint('Error in savings watcher: $e');
        });

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
