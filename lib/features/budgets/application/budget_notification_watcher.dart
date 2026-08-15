import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/notifications/notification_service.dart';
import '../../settings/presentation/providers/notification_preferences_provider.dart';
import '../presentation/providers/budgets_provider.dart';
import '../../categories/presentation/providers/category_provider.dart';

final budgetNotificationWatcherProvider = Provider<BudgetNotificationWatcher>((ref) {
  return BudgetNotificationWatcher(ref);
});

class BudgetNotificationWatcher {
  final Ref ref;

  BudgetNotificationWatcher(this.ref);

  Future<void> checkBudgetForCategory(int categoryId, DateTime date) async {
    // 1. Verificar preferencia global
    final prefsRepo = ref.read(notificationPreferenceRepositoryProvider);
    final budgetPref = await prefsRepo.getPreference('budget');
    if (budgetPref != null && !budgetPref.isEnabled) {
      return; // El usuario desactivó las notificaciones de presupuesto
    }

    final monthYear = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    
    // 2. Obtener el presupuesto
    final budgetRepo = ref.read(budgetRepositoryProvider);
    final budgets = await budgetRepo.getBudgetsByMonth(monthYear);
    final categoryBudget = budgets.where((b) => b.categoryId == categoryId).firstOrNull;
    
    if (categoryBudget == null) return; // No hay presupuesto configurado para esta categoría

    // 3. Calcular lo gastado
    final spent = await budgetRepo.getActualSpendForCategory(categoryId, monthYear);
    final percentage = spent / categoryBudget.amount;

    // 4. Evaluar umbrales y notificar
    final notificationService = ref.read(notificationServiceProvider);
    
    // Obtener el nombre de la categoría
    final cats = ref.read(categoriesProvider).value ?? [];
    final categoryName = cats.firstWhere((c) => c.id == categoryId, orElse: () => throw Exception('Categoría no encontrada')).name;

    if (percentage >= 1.0) {
      await notificationService.showBudgetAlert(
        id: categoryId * 1000 + 1, // ID único por categoría y tipo de alerta
        title: 'Presupuesto Excedido',
        body: 'Has gastado \$${spent.toStringAsFixed(2)} en $categoryName, superando tu límite de \$${categoryBudget.amount.toStringAsFixed(2)}.',
        payload: '/budgets',
      );
    } else if (percentage >= categoryBudget.warningThreshold) {
      await notificationService.showBudgetAlert(
        id: categoryId * 1000 + 2,
        title: 'Atención: Presupuesto al ${(percentage * 100).toInt()}%',
        body: 'Has gastado \$${spent.toStringAsFixed(2)} de \$${categoryBudget.amount.toStringAsFixed(2)} en $categoryName.',
        payload: '/budgets',
      );
    }
  }
}
