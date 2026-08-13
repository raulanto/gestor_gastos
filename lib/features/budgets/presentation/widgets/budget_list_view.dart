import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/budget.dart';
import '../providers/budgets_provider.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../savings/presentation/providers/savings_provider.dart';
import 'package:gestor_gastos/core/utils/icon_utils.dart';

class BudgetListView extends ConsumerWidget {
  final String monthYearKey;

  const BudgetListView({super.key, required this.monthYearKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final budgetsAsync = ref.watch(monthlyBudgetsProvider(monthYearKey));
    final categoriesState = ref.watch(categoriesProvider);
    final savingsState = ref.watch(savingsGoalsProvider);

    return budgetsAsync.when(
      data: (progressList) {
        if (progressList.isEmpty) {
          return const Center(
            child: Text('No hay presupuestos para este mes.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: progressList.length,
          itemBuilder: (context, index) {
            final item = progressList[index];
            final b = item.budget;

            String title = 'Desconocido';
            IconData iconData = Icons.category;
            Color color = Colors.grey;

            if (b.categoryId != null && categoriesState.value != null) {
              final cat = categoriesState.value!.firstWhere(
                (c) => c.id == b.categoryId,
                orElse: () => categoriesState.value!.first,
              );
              title = cat.name;
              iconData = IconUtils.getIcon(cat.iconCode);
              color = Color(cat.colorCode);
            } else if (b.savingsGoalId != null && savingsState.value != null) {
              final goal = savingsState.value!.firstWhere(
                (g) => g.id == b.savingsGoalId,
                orElse: () => savingsState.value!.first,
              );
              title = 'Ahorro: ${goal.name}';
              iconData = IconUtils.getIcon(goal.iconCode);
              color = Color(goal.colorCode);
            }

            double prog = item.progressPercentage;
            Color barColor = Colors.green;
            if (prog >= 1.0) {
              barColor = Colors.red;
            } else if (prog >= 0.8) {
              barColor = Colors.orange;
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.2),
                          child: Icon(iconData, color: color),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              Text('\$${item.actualAmount.toStringAsFixed(2)} / \$${b.amount.toStringAsFixed(2)}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurfaceVariant),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditBudgetDialog(context, ref, b, monthYearKey);
                            } else if (value == 'delete') {
                              ref.read(budgetRepositoryProvider).deleteBudget(b.id!);
                              ref.invalidate(monthlyBudgetsProvider(monthYearKey));
                              ref.invalidate(globalBudgetProvider(monthYearKey));
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Editar Límite'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Consumido', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        Text('${(prog * 100).toStringAsFixed(0)}%', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: barColor)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: prog.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: barColor.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  void _showEditBudgetDialog(BuildContext context, WidgetRef ref, BudgetEntity budget, String monthYearKey) {
    final controller = TextEditingController(text: budget.amount.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Presupuesto'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Monto Límite', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newAmount = double.tryParse(controller.text);
                if (newAmount != null && newAmount > 0) {
                  final updatedBudget = budget.copyWith(amount: newAmount);
                  await ref.read(budgetRepositoryProvider).updateBudget(updatedBudget);
                  ref.invalidate(monthlyBudgetsProvider(monthYearKey));
                  ref.invalidate(globalBudgetProvider(monthYearKey));
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
