import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/savings_provider.dart';
import 'savings_page.dart'; // To reuse SavingsGoalCard

class SavingsCompletedPage extends ConsumerWidget {
  const SavingsCompletedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsState = ref.watch(savingsGoalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas Cumplidas'),
      ),
      body: savingsState.when(
        data: (goals) {
          final completedGoals = goals.where((g) => g.status == 'completed').toList();
          if (completedGoals.isEmpty) {
            return const Center(child: Text('Aún no tienes metas de ahorro cumplidas.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: completedGoals.length,
            itemBuilder: (context, index) {
              final goal = completedGoals[index];
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
