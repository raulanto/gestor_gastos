import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import '../database/app_database.dart';
import '../notifications/notification_service.dart';
import '../../features/settings/data/repositories/notification_preference_repository.dart';
import '../../features/savings/data/datasources/savings_local_data_source.dart';
import '../../features/savings/data/repositories/savings_repository_impl.dart';
import '../../features/recurring_transactions/data/datasources/recurring_transaction_local_data_source.dart';
import '../../features/recurring_transactions/data/repositories/recurring_transaction_repository_impl.dart';
import '../../features/transactions/data/datasources/transaction_local_data_source.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final appDb = AppDatabase();
      final notificationService = NotificationService();
      await notificationService.init();

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(appDb),
          notificationServiceProvider.overrideWithValue(notificationService),
        ],
      );

      if (task == 'dailyTask') {
        await _processRecurringTransactions(container, notificationService);
        await _processStagnantSavings(container, notificationService);
      }

      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}

Future<void> _processRecurringTransactions(ProviderContainer container, NotificationService notificationService) async {
  final appDb = container.read(appDatabaseProvider);
  
  final recurringDataSource = RecurringTransactionLocalDataSource(appDb);
  final recurringRepo = RecurringTransactionRepositoryImpl(recurringDataSource);
  
  final txDataSource = TransactionLocalDataSource(appDb);
  final txRepo = TransactionRepositoryImpl(txDataSource);

  final recurrings = await recurringRepo.getRecurringTransactions();
  final now = DateTime.now();
  int processedCount = 0;

  for (var rt in recurrings) {
    if (rt.status == 'active') {
      var nextExec = DateTime.parse(rt.nextExecutionDate);
      bool executed = false;

      while (nextExec.isBefore(now) || (nextExec.year == now.year && nextExec.month == now.month && nextExec.day == now.day)) {
        final newTx = rt.toTransaction(nextExec.toIso8601String());
        await txRepo.createTransaction(newTx);
        
        switch (rt.periodicity) {
          case 'daily': nextExec = nextExec.add(const Duration(days: 1)); break;
          case 'weekly': nextExec = nextExec.add(const Duration(days: 7)); break;
          case 'biweekly': nextExec = nextExec.add(const Duration(days: 14)); break;
          case 'monthly': nextExec = DateTime(nextExec.year, nextExec.month + 1, nextExec.day); break;
          case 'yearly': nextExec = DateTime(nextExec.year + 1, nextExec.month, nextExec.day); break;
          default: nextExec = nextExec.add(const Duration(days: 30));
        }
        executed = true;
      }

      if (executed) {
        await recurringRepo.updateNextExecutionDate(rt.id!, nextExec.toIso8601String());
        processedCount++;
      }
    }
  }

  if (processedCount > 0) {
    final prefsRepo = NotificationPreferenceRepository(appDb);
    final recurringPref = await prefsRepo.getPreference('recurring');
    
    if (recurringPref == null || recurringPref.isEnabled) {
      await notificationService.showRecurringTransactionsAlert(
        id: 9991,
        title: 'Transacciones Recurrentes',
        body: 'Se han procesado $processedCount transacciones recurrentes automáticamente.',
        payload: '/recurring',
      );
    }
  }
}

Future<void> _processStagnantSavings(ProviderContainer container, NotificationService notificationService) async {
  final appDb = container.read(appDatabaseProvider);
  
  final savingsDataSource = SavingsLocalDataSource(appDb);
  final savingsRepo = SavingsRepositoryImpl(savingsDataSource);

  final prefsRepo = NotificationPreferenceRepository(appDb);
  
  final savingsPref = await prefsRepo.getPreference('savings');
  if (savingsPref != null && !savingsPref.isEnabled) {
    return;
  }

  final goals = await savingsRepo.getSavingsGoals();
  final now = DateTime.now();

  for (var goal in goals) {
    if (goal.status == 'active' && goal.targetAmount > 0) {
      final transactions = await savingsRepo.getTransactionsByGoal(goal.id!);
      
      final currentAmount = transactions.fold(0.0, (sum, tx) => sum + (tx.type == 'deposit' ? tx.amount : -tx.amount));
      
      if (currentAmount < goal.targetAmount) {
        DateTime? lastDepositDate;
        for (var tx in transactions) {
          if (tx.type == 'deposit') {
            final d = DateTime.parse(tx.date);
            if (lastDepositDate == null || d.isAfter(lastDepositDate)) {
              lastDepositDate = d;
            }
          }
        }

        if (lastDepositDate != null) {
          final daysSince = now.difference(lastDepositDate).inDays;
          if (daysSince >= 14) { 
             await notificationService.showSavingsProgressAlert(
              id: goal.id! * 1000 + 5,
              title: '¡No abandones tu meta!',
              body: 'Han pasado $daysSince días desde tu último aporte a "${goal.name}". ¡Sigue ahorrando!',
              payload: '/savings',
            );
          }
        }
      }
    }
  }
}
