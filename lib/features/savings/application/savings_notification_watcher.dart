import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/notifications/notification_service.dart';
import '../../settings/presentation/providers/notification_preferences_provider.dart';
import '../presentation/providers/savings_provider.dart';

final savingsNotificationWatcherProvider = Provider<SavingsNotificationWatcher>((ref) {
  return SavingsNotificationWatcher(ref);
});

class SavingsNotificationWatcher {
  final Ref ref;

  SavingsNotificationWatcher(this.ref);

  Future<void> checkSavingsProgress(int goalId, double newTransactionAmount) async {
    // 1. Verify global preference for savings notifications
    final prefsRepo = ref.read(notificationPreferenceRepositoryProvider);
    final savingsPref = await prefsRepo.getPreference('savings');
    if (savingsPref != null && !savingsPref.isEnabled) {
      return; // The user disabled savings notifications
    }

    // 2. Obtain the specific goal
    final repo = ref.read(savingsRepositoryProvider);
    final goals = await repo.getSavingsGoals();
    final goal = goals.where((g) => g.id == goalId).firstOrNull;

    if (goal == null) return;

    final target = goal.targetAmount;
    if (target <= 0) return;

    // 3. Calculate current and previous amounts
    final transactions = await repo.getTransactionsByGoal(goalId);
    final currentAmount = transactions.fold(0.0, (sum, tx) => sum + (tx.type == 'deposit' ? tx.amount : -tx.amount));
    // Assuming the new transaction was just added to the DB, so it's already in currentAmount
    // Wait, the new transaction amount could be negative if it's a withdrawal. Let's just use it directly.
    final previousAmount = currentAmount - newTransactionAmount;

    final prevPercentage = previousAmount / target;
    final currPercentage = currentAmount / target;

    // Check thresholds: 25%, 50%, 75%, 100%
    final thresholds = [1.0, 0.75, 0.50, 0.25];
    final notificationService = ref.read(notificationServiceProvider);

    for (final threshold in thresholds) {
      if (prevPercentage < threshold && currPercentage >= threshold) {
        if (threshold == 1.0) {
          // Meta cumplida
          await notificationService.showSavingsProgressAlert(
            id: goalId * 1000 + 4,
            title: '¡Meta Cumplida!',
            body: '¡Felicidades! Has completado tu meta de ahorro "${goal.name}".',
            payload: '/savings',
          );
        } else {
          // Progreso
          await notificationService.showSavingsProgressAlert(
            id: goalId * 1000 + (threshold * 100).toInt(),
            title: 'Progreso de Ahorro: ${(threshold * 100).toInt()}%',
            body: 'Has alcanzado el ${(threshold * 100).toInt()}% de tu meta "${goal.name}". ¡Sigue así!',
            payload: '/savings',
          );
        }
        break; // Only trigger the highest threshold they crossed
      }
    }
  }
}
