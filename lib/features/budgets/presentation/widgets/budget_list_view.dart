import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/budget.dart';
import '../providers/budgets_provider.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../savings/presentation/providers/savings_provider.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
              iconData = IconData(cat.iconCode, fontFamily: 'MaterialIcons');
              color = Color(cat.colorCode);
            } else if (b.savingsGoalId != null && savingsState.value != null) {
              final goal = savingsState.value!.firstWhere(
                (g) => g.id == b.savingsGoalId,
                orElse: () => savingsState.value!.first,
              );
              title = 'Ahorro: ${goal.name}';
              iconData = IconData(goal.iconCode, fontFamily: 'MaterialIcons');
              color = Color(goal.colorCode);
            }

            double prog = item.progressPercentage;
            Color barColor = Colors.green;
            if (prog >= 1.0) {
              barColor = Colors.red;
            } else if (prog >= 0.8) {
              barColor = Colors.orange;
            }

            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color,
                  child: Icon(iconData, color: Colors.white),
                ),
                title: Text(title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: prog.clamp(0.0, 1.0),
                      color: barColor,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${item.actualAmount.toStringAsFixed(2)} de \$${b.amount.toStringAsFixed(2)}',
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _showEditBudgetDialog(context, ref, b, monthYearKey);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        ref.read(budgetRepositoryProvider).deleteBudget(b.id!);
                        ref.invalidate(monthlyBudgetsProvider(monthYearKey));
                        ref.invalidate(globalBudgetProvider(monthYearKey));
                      },
                    ),
                  ],
                ),
                isThreeLine: true,
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
