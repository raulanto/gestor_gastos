import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/savings_provider.dart';
import '../../domain/entities/savings_goal.dart';

class SavingsPage extends ConsumerWidget {
  const SavingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsState = ref.watch(savingsGoalsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caja de Ahorros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Metas Cumplidas',
            onPressed: () {
              context.push('/savings_completed');
            },
          ),
        ],
      ),
      body: savingsState.when(
        data: (goals) {
          final activeGoals = goals.where((g) => g.status == 'active').toList();
          if (activeGoals.isEmpty) {
            return const Center(child: Text('No tienes metas de ahorro activas.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          context.push('/savings_goal_details', extra: goal);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(goal.colorCode),
                    child: Icon(IconData(goal.iconCode, fontFamily: 'MaterialIcons'), color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(goal.name, style: theme.textTheme.titleMedium),
                        Text('Meta: \$${goal.targetAmount.toStringAsFixed(2)}', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              txsAsync.when(
                data: (txs) {
                  final savedAmount = txs.fold<double>(0, (sum, tx) => tx.type == 'deposit' ? sum + tx.amount : sum - tx.amount);
                  final progress = (savedAmount / goal.targetAmount).clamp(0.0, 1.0);
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      ),
                      const SizedBox(height: 8),
                      Text('Progreso: \$${savedAmount.toStringAsFixed(2)} (${(progress * 100).toStringAsFixed(1)}%)', style: theme.textTheme.bodySmall),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, st) => Text('Error al cargar progreso', style: theme.textTheme.bodySmall?.copyWith(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
