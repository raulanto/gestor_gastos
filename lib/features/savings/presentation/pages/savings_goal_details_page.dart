import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../../domain/entities/savings_goal.dart';
import '../providers/savings_provider.dart';
import '../widgets/edit_savings_goal_dialog.dart';
import '../widgets/savings_goal_header.dart';
import '../widgets/savings_transaction_form.dart';
import '../widgets/savings_transaction_list.dart';

class SavingsGoalDetailsPage extends ConsumerStatefulWidget {
  final SavingsGoalEntity goal;

  const SavingsGoalDetailsPage({super.key, required this.goal});

  @override
  ConsumerState<SavingsGoalDetailsPage> createState() => _SavingsGoalDetailsPageState();
}

class _SavingsGoalDetailsPageState extends ConsumerState<SavingsGoalDetailsPage> {
  late SavingsGoalEntity _currentGoal;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _currentGoal = widget.goal;
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txsAsync = ref.watch(savingsGoalTransactionsProvider(_currentGoal.id!));
    
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
        title: Text(_currentGoal.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Reglas de Ahorro',
            onPressed: () {
              context.push('/savings_rules', extra: _currentGoal);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (val) async {
              if (val == 'edit') {
                final updatedGoal = await showDialog<SavingsGoalEntity>(
                  context: context,
                  builder: (ctx) => EditSavingsGoalDialog(goal: _currentGoal),
                );
                if (updatedGoal != null) {
                  setState(() {
                    _currentGoal = updatedGoal;
                  });
                }
              } else if (val == 'delete') {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Eliminar Meta'),
                    content: const Text('¿Estás seguro de que deseas eliminar esta meta de ahorro? Se eliminará todo su historial.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                      TextButton(
                        onPressed: () {
                          ref.read(savingsGoalsProvider.notifier).deleteGoal(_currentGoal.id!);
                          Navigator.pop(ctx);
                          context.pop();
                        },
                        child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Editar Meta')),
              const PopupMenuItem(value: 'delete', child: Text('Eliminar Meta', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      body: txsAsync.when(
        data: (txs) {
          final savedAmount = txs.fold<double>(0, (sum, tx) => tx.type == 'deposit' ? sum + tx.amount : sum - tx.amount);
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SavingsGoalHeader(goal: _currentGoal, savedAmount: savedAmount),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Text('Historial', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              Expanded(
                child: SavingsTransactionList(transactions: txs),
              )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: _currentGoal.status == 'completed' ? null : FloatingActionButton.extended(
        onPressed: () {
          final txs = txsAsync.value ?? [];
          final savedAmount = txs.fold<double>(0, (sum, tx) => tx.type == 'deposit' ? sum + tx.amount : sum - tx.amount);
          _showTransactionModal(context, ref, true, savedAmount);
        },
        label: const Text('Aportar'),
        icon: const Icon(Icons.add),
      ),
    ),
    Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: pi / 2, // shoot downwards
        maxBlastForce: 5,
        minBlastForce: 2,
        emissionFrequency: 0.05,
        numberOfParticles: 50,
        gravity: 0.1,
      ),
    ),
  ],
);
  }

  void _showTransactionModal(BuildContext context, WidgetRef ref, bool isDeposit, double savedAmount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, top: 16, left: 16, right: 16),
          child: SavingsTransactionForm(goal: _currentGoal, savedAmount: savedAmount, isDeposit: isDeposit),
        );
      }
    ).then((_) {
      // Re-fetch to check if the goal completed status updated
      final goalsState = ref.read(savingsGoalsProvider);
      final updatedDbGoal = goalsState.value?.where((g) => g.id == _currentGoal.id).firstOrNull;
      if (updatedDbGoal != null && updatedDbGoal.status != _currentGoal.status) {
        setState(() {
          _currentGoal = updatedDbGoal;
        });
        if (_currentGoal.status == 'completed') {
          _confettiController.play();
        }
      }
    });
  }
}
