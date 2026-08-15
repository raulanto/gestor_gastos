import 'package:flutter/material.dart';
import '../../domain/entities/savings_goal.dart';

class SavingsGoalHeader extends StatelessWidget {
  final SavingsGoalEntity goal;
  final double savedAmount;

  const SavingsGoalHeader({
    super.key,
    required this.goal,
    required this.savedAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (savedAmount / goal.targetAmount).clamp(0.0, 1.0);
    final isCompleted = goal.status == 'completed';

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Ahorrado', style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                )),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('¡Meta Cumplida!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '\$${savedAmount.toStringAsFixed(2)}',
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? Colors.green : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(progress * 100).toStringAsFixed(1)}%', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text('Meta: \$${goal.targetAmount.toStringAsFixed(2)}', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
