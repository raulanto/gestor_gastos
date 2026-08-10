import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/entities/savings_transaction.dart';
import '../providers/savings_provider.dart';

class SavingsGoalDetailsPage extends ConsumerWidget {
  final SavingsGoalEntity goal;

  const SavingsGoalDetailsPage({super.key, required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txsAsync = ref.watch(savingsGoalTransactionsProvider(goal.id!));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(goal.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/savings_rules', extra: goal);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'delete') {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Eliminar Meta'),
                    content: const Text('¿Estás seguro de que deseas eliminar esta meta de ahorro? Se eliminará todo su historial.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                      TextButton(
                        onPressed: () {
                          ref.read(savingsGoalsProvider.notifier).deleteGoal(goal.id!);
                          Navigator.pop(ctx); // Close dialog
                          context.pop(); // Go back
                        },
                        child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'delete', child: Text('Eliminar Meta', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      body: txsAsync.when(
        data: (txs) {
          final savedAmount = txs.fold<double>(0, (sum, tx) => tx.type == 'deposit' ? sum + tx.amount : sum - tx.amount);
          final progress = savedAmount / goal.targetAmount;
          
          return Column(
            children: [
              // Cabecera con progreso
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text('Total Ahorrado', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('\$${savedAmount.toStringAsFixed(2)}', style: Theme.of(context).textTheme.displaySmall),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
                    const SizedBox(height: 8),
                    Text('Meta: \$${goal.targetAmount.toStringAsFixed(2)} (${(progress * 100).toStringAsFixed(1)}%)'),
                  ],
                ),
              ),
              const Divider(),
              // Historial
              Expanded(
                child: ListView.builder(
                  itemCount: txs.length,
                  itemBuilder: (context, index) {
                    final tx = txs[index];
                    final isDeposit = tx.type == 'deposit';
                    return ListTile(
                      leading: Icon(isDeposit ? Icons.arrow_downward : Icons.arrow_upward, color: isDeposit ? Colors.green : Colors.red),
                      title: Text(tx.reason ?? 'Transacción'),
                      subtitle: Text(tx.date.substring(0, 10)),
                      trailing: Text('${isDeposit ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}', style: TextStyle(color: isDeposit ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: goal.status == 'completed' ? null : FloatingActionButton.extended(
        onPressed: () {
          final txs = txsAsync.value ?? [];
          final savedAmount = txs.fold<double>(0, (sum, tx) => tx.type == 'deposit' ? sum + tx.amount : sum - tx.amount);
          _showTransactionModal(context, ref, true, savedAmount);
        },
        label: const Text('Aportar'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showTransactionModal(BuildContext context, WidgetRef ref, bool isDeposit, double savedAmount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, top: 16, left: 16, right: 16),
          child: _TransactionForm(goal: goal, savedAmount: savedAmount, isDeposit: isDeposit),
        );
      }
    );
  }
}

class _TransactionForm extends ConsumerStatefulWidget {
  final SavingsGoalEntity goal;
  final double savedAmount;
  final bool isDeposit;
  const _TransactionForm({required this.goal, required this.savedAmount, required this.isDeposit});

  @override
  ConsumerState<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<_TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  double _amount = 0.0;
  String _reason = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.isDeposit ? 'Nueva Aportación' : 'Retiro de Ahorro', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Monto'),
            keyboardType: TextInputType.number,
            validator: (v) => v == null || double.tryParse(v) == null ? 'Monto inválido' : null,
            onSaved: (v) => _amount = double.parse(v!),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(labelText: widget.isDeposit ? 'Motivo (opcional)' : 'Motivo del retiro (obligatorio)'),
            validator: (v) {
              if (!widget.isDeposit && (v == null || v.length < 5)) return 'Debe justificar el retiro (>5 caracteres)';
              return null;
            },
            onSaved: (v) => _reason = v ?? '',
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                final tx = SavingsTransactionEntity(
                  goalId: widget.goal.id!,
                  accountId: 1, // FIX: Need real account selection in UI
                  amount: _amount,
                  date: DateTime.now().toIso8601String(),
                  type: widget.isDeposit ? 'deposit' : 'withdrawal',
                  reason: _reason,
                );
                
                final repo = ref.read(savingsRepositoryProvider);
                await repo.createTransaction(tx);
                
                // Check for completion
                if (widget.isDeposit) {
                  final newTotal = widget.savedAmount + _amount;
                  if (newTotal >= widget.goal.targetAmount && widget.goal.status != 'completed') {
                    await ref.read(savingsGoalsProvider.notifier).updateGoal(
                      widget.goal.copyWith(status: 'completed')
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Meta de ahorro cumplida!')));
                    }
                  }
                }
                
                // Refresh list
                ref.invalidate(savingsGoalTransactionsProvider(widget.goal.id!));
                
                if (!context.mounted) return;
                Navigator.of(context).pop();
              }
            },
            child: Text(widget.isDeposit ? 'Aportar' : 'Retirar'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
