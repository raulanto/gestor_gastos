import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/entities/savings_transaction.dart';
import '../providers/savings_provider.dart';

class SavingsTransactionForm extends ConsumerStatefulWidget {
  final SavingsGoalEntity goal;
  final double savedAmount;
  final bool isDeposit;
  
  const SavingsTransactionForm({
    super.key,
    required this.goal,
    required this.savedAmount,
    required this.isDeposit,
  });

  @override
  ConsumerState<SavingsTransactionForm> createState() => _SavingsTransactionFormState();
}

class _SavingsTransactionFormState extends ConsumerState<SavingsTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  double _amount = 0.0;
  String _reason = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.isDeposit ? 'Nueva Aportación' : 'Retiro de Ahorro',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Monto',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Requerido';
              final val = double.tryParse(v);
              if (val == null || val <= 0) return 'Monto inválido';
              if (!widget.isDeposit && val > widget.savedAmount) return 'Saldo insuficiente';
              return null;
            },
            onSaved: (v) => _amount = double.parse(v!),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: widget.isDeposit ? 'Motivo (opcional)' : 'Motivo del retiro (obligatorio)',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.notes),
            ),
            validator: (v) {
              if (!widget.isDeposit && (v == null || v.length < 5)) return 'Debe justificar el retiro (>5 caracteres)';
              return null;
            },
            onSaved: (v) => _reason = v ?? '',
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: widget.isDeposit ? Colors.green : Colors.red,
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                final tx = SavingsTransactionEntity(
                  goalId: widget.goal.id!,
                  accountId: 1, // TODO: Permitir selección de cuenta
                  amount: _amount,
                  date: DateTime.now().toIso8601String(),
                  type: widget.isDeposit ? 'deposit' : 'withdrawal',
                  reason: _reason.isEmpty && widget.isDeposit ? 'Aportación manual' : _reason,
                );
                
                final repo = ref.read(savingsRepositoryProvider);
                await repo.createTransaction(tx);
                
                // Evaluar completitud
                if (widget.isDeposit) {
                  final newTotal = widget.savedAmount + _amount;
                  if (newTotal >= widget.goal.targetAmount && widget.goal.status != 'completed') {
                    await ref.read(savingsGoalsProvider.notifier).updateGoal(
                      widget.goal.copyWith(status: 'completed')
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Felicidades! Meta de ahorro cumplida.')));
                    }
                  }
                }
                
                ref.invalidate(savingsGoalTransactionsProvider(widget.goal.id!));
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
            icon: Icon(widget.isDeposit ? Icons.arrow_downward : Icons.arrow_upward),
            label: Text(widget.isDeposit ? 'Aportar' : 'Retirar'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
