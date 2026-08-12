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
        final available = global['available'] ?? 0.0;
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Presupuesto Global',
                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$${spent.toStringAsFixed(2)}', style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                  Text('${(progress * 100).toStringAsFixed(0)}%', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  color: progressColor,
                  backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                  minHeight: 12,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.account_balance_wallet, size: 16, color: theme.colorScheme.onPrimary),
                        const SizedBox(width: 6),
                        Text(
                          'Disponible real: \$${available.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Límite: \$${budgeted.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary.withValues(alpha: 0.8)),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}
