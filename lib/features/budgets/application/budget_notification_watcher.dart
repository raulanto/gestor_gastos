import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestor_gastos/core/utils/currency_utils.dart';
import 'package:flutter/material.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/theme/theme_provider.dart';
import '../../settings/presentation/providers/notification_preferences_provider.dart';
import '../presentation/providers/budgets_provider.dart';
import '../../categories/presentation/providers/category_provider.dart';
import 'package:gestor_gastos/core/utils/currency_utils.dart';

final budgetNotificationWatcherProvider = Provider<BudgetNotificationWatcher>((
  ref,
) {
  return BudgetNotificationWatcher(ref);
});

class BudgetNotificationWatcher {
  final Ref ref;

  BudgetNotificationWatcher(this.ref);

  // Niveles de alerta ya notificados para no repetir el mismo aviso
  // en cada transacción mientras el presupuesto siga en el mismo tramo.
  static const _levelNone = 0;
  static const _levelWarning = 1;
  static const _levelExceeded = 2;

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
    final categoryBudget = budgets
        .where((b) => b.categoryId == categoryId)
        .firstOrNull;

    if (categoryBudget == null)
      return; // No hay presupuesto configurado para esta categoría

    // 3. Calcular lo gastado
    final spent = await budgetRepo.getActualSpendForCategory(
      categoryId,
      monthYear,
    );
    final percentage = spent / categoryBudget.amount;

    // 4. Determinar el nivel de alerta alcanzado y evitar repetir el mismo
    // aviso mientras el presupuesto siga en el mismo tramo (o uno inferior).
    final level = percentage >= 1.0
        ? _levelExceeded
        : percentage >= categoryBudget.warningThreshold
        ? _levelWarning
        : _levelNone;

    final prefs = ref.read(sharedPreferencesProvider);
    final levelKey = 'budget_notif_level_${categoryId}_$monthYear';
    final notifiedLevel = prefs.getInt(levelKey) ?? _levelNone;

    if (level <= notifiedLevel) {
      // No subió de tramo: si bajó, actualizamos el nivel guardado para
      // poder volver a avisar si vuelve a subir, pero sin notificar ahora.
      if (level < notifiedLevel) await prefs.setInt(levelKey, level);
      return;
    }

    // Subió de tramo respecto al último aviso: notificar y persistir.
    await prefs.setInt(levelKey, level);

    final notificationService = ref.read(notificationServiceProvider);

    // Obtener el nombre de la categoría
    final cats = ref.read(categoriesProvider).value ?? [];
    final categoryName = cats
        .firstWhere(
          (c) => c.id == categoryId,
          orElse: () => throw Exception('Categoría no encontrada'),
        )
        .name;

    if (level == _levelExceeded) {
      await notificationService.showBudgetAlert(
        id: categoryId * 1000 + 1, // ID único por categoría y tipo de alerta
        title: 'Presupuesto Excedido',
        body:
            'Has gastado ${CurrencyUtils.formatAmount(spent)} en $categoryName, superando tu límite de ${CurrencyUtils.formatAmount(categoryBudget.amount)}.',
        payload: '/budgets',
      );
    } else {
      await notificationService.showBudgetAlert(
        id: categoryId * 1000 + 2,
        title: 'Atención: Presupuesto al ${(percentage * 100).toInt()}%',
        body:
            'Has gastado ${CurrencyUtils.formatAmount(spent)} de ${CurrencyUtils.formatAmount(categoryBudget.amount)} en $categoryName.',
        payload: '/budgets',
      );
    }
  }
}
