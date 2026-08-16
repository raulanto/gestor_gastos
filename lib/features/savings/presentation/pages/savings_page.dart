import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/savings_provider.dart';
import '../../domain/entities/savings_goal.dart';
import 'package:gestor_gastos/core/utils/icon_utils.dart';

class SavingsPage extends ConsumerWidget {
  const SavingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsState = ref.watch(savingsGoalsProvider);
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350,
            child: AnimatedContainer(
  duration: const Duration(milliseconds: 500),
  
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(ref.watch(appBackgroundProvider)),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.4),
                      theme.colorScheme.primary,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ahorros', style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          IconButton(
                            style: IconButton.styleFrom(backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.15)),
                            icon: Icon(Icons.check_circle_outline, color: theme.colorScheme.onPrimary),
                            onPressed: () => context.push('/savings_completed'),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            style: IconButton.styleFrom(backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.15)),
                            icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
                            onPressed: () => context.push('/add_savings_goal'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Material(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    child: savingsState.when(
                      data: (goals) {
                        final activeGoals = goals.where((g) => g.status == 'active').toList();
                        if (activeGoals.isEmpty) {
                          return const Center(child: Text('No tienes metas de ahorro activas.'));
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 24, bottom: 100),
                          itemCount: activeGoals.length,
                          itemBuilder: (context, index) {
                            final goal = activeGoals[index];
                            return SavingsGoalCard(goal: goal);
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Center(child: Text('Error: $e')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SavingsGoalCard extends ConsumerWidget {
  final SavingsGoalEntity goal;

  const SavingsGoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final txsAsync = ref.watch(savingsGoalTransactionsProvider(goal.id!));

    return InkWell(
      onTap: () {
        context.push('/savings_goal_details/${goal.id}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(goal.colorCode).withValues(alpha: 0.2),
                    child: Icon(IconUtils.getIcon(goal.iconCode), color: Color(goal.colorCode)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(goal.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        Text('Meta: \$${goal.targetAmount.toStringAsFixed(2)}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              txsAsync.when(
                data: (txs) {
                  final savedAmount = txs.fold<double>(0, (sum, tx) => tx.type == 'deposit' ? sum + tx.amount : sum - tx.amount);
                  final progress = (savedAmount / goal.targetAmount).clamp(0.0, 1.0);
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('\$${savedAmount.toStringAsFixed(2)}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                          Text('${(progress * 100).toStringAsFixed(0)}%', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                error: (e, st) => Text('Error al cargar progreso', style: theme.textTheme.bodySmall?.copyWith(color: Colors.red)),
              ),
            ],
          ),
        ),
    );
  }
}
