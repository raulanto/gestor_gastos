import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/budgets_provider.dart';

class BudgetGlobalCard extends ConsumerWidget {
  final String monthYearKey;

  const BudgetGlobalCard({super.key, required this.monthYearKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final globalAsync = ref.watch(globalBudgetProvider(monthYearKey));

    return globalAsync.when(
      data: (global) {
        final budgeted = global['budgeted'] ?? 0.0;
        final spent = global['spent'] ?? 0.0;
        final progress = budgeted > 0
            ? (spent / budgeted).clamp(0.0, 1.0)
            : 0.0;

        Color progressColor = Colors.green;
        if (progress >= 1.0) {
          progressColor = Colors.red;
        } else if (progress >= 0.8) {
          progressColor = Colors.orange;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Presupuesto Global (Gastos)',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    color: progressColor,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Gastado: \$${spent.toStringAsFixed(2)}'),
                      Text('Límite: \$${budgeted.toStringAsFixed(2)}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}
