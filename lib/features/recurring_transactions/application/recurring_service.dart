import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/recurring_transaction_repository.dart';
import '../../transactions/domain/repositories/transaction_repository.dart';
import '../../transactions/presentation/providers/transaction_provider.dart';
import '../presentation/providers/recurring_transaction_provider.dart';

final recurringServiceProvider = Provider<RecurringService>((ref) {
  return RecurringService(
    ref.watch(recurringTransactionRepositoryProvider),
    ref.watch(transactionRepositoryProvider),
    ref,
  );
});

class RecurringService {
  final RecurringTransactionRepository recurringRepo;
  final TransactionRepository transactionRepo;
  final Ref ref;

  RecurringService(this.recurringRepo, this.transactionRepo, this.ref);

  Future<void> checkAndExecuteRecurring() async {
    final recurrings = await recurringRepo.getRecurringTransactions();
    final now = DateTime.now();

    for (var rt in recurrings) {
      if (rt.status == 'active') {
        var nextExec = DateTime.parse(rt.nextExecutionDate);

        // Si la fecha de ejecución es hoy o en el pasado, generar transacción
        while (nextExec.isBefore(now) || isSameDay(nextExec, now)) {
          // Generar la transacción
          final newTx = rt.toTransaction(nextExec.toIso8601String());
          await transactionRepo.createTransaction(newTx);

          // Calcular la siguiente fecha de ejecución
          nextExec = _calculateNextDate(nextExec, rt.periodicity);
        }

        // Si se actualizaron fechas, guardar en BD
        if (nextExec.toIso8601String() != rt.nextExecutionDate) {
          await recurringRepo.updateNextExecutionDate(
            rt.id!,
            nextExec.toIso8601String(),
          );
        }
      }
    }

    // Invalidar para recargar la UI
    ref.invalidate(recurringTransactionsProvider);
    ref.invalidate(transactionsProvider);
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _calculateNextDate(DateTime current, String periodicity) {
    switch (periodicity) {
      case 'daily':
        return current.add(const Duration(days: 1));
      case 'weekly':
        return current.add(const Duration(days: 7));
      case 'biweekly':
        return current.add(const Duration(days: 14));
      case 'monthly':
        return DateTime(current.year, current.month + 1, current.day);
      case 'yearly':
        return DateTime(current.year + 1, current.month, current.day);
      default:
        return current.add(const Duration(days: 30));
    }
  }
}
