import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/savings_notification_watcher.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/entities/savings_transaction.dart';
import '../providers/savings_provider.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../accounts/presentation/providers/account_provider.dart';

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
  ConsumerState<SavingsTransactionForm> createState() =>
      _SavingsTransactionFormState();
}

class _SavingsTransactionFormState
    extends ConsumerState<SavingsTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  double _amount = 0.0;
  String _reason = '';
  int? _selectedAccountId;

  @override
  Widget build(BuildContext context) {
    final accountsState = ref.watch(accountsProvider);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.isDeposit ? 'Nueva Aportación' : 'Retiro de Ahorro',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
              if (!widget.isDeposit && val > widget.savedAmount)
                return 'Saldo insuficiente';
              return null;
            },
            onSaved: (v) => _amount = double.parse(v!),
          ),
          const SizedBox(height: 16),
          accountsState.when(
            data: (accounts) {
              if (accounts.isEmpty)
                return const Text('No hay cuentas disponibles.');
              // Si solo hay una cuenta, seleccionarla por defecto
              if (_selectedAccountId == null && accounts.isNotEmpty) {
                _selectedAccountId = accounts.first.id;
              }
              return DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Cuenta',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_wallet),
                ),
                initialValue: _selectedAccountId,
                items: accounts.map((acc) {
                  return DropdownMenuItem<int>(
                    value: acc.id,
                    child: Text(acc.name),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedAccountId = val;
                  });
                },
                validator: (val) {
                  if (val == null) return 'Seleccione una cuenta';
                  return null;
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Text('Error al cargar cuentas: $err'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: widget.isDeposit
                  ? 'Motivo (opcional)'
                  : 'Motivo del retiro (obligatorio)',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.notes),
            ),
            validator: (v) {
              if (!widget.isDeposit && (v == null || v.length < 5))
                return 'Debe justificar el retiro (>5 caracteres)';
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

                if (_selectedAccountId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, seleccione una cuenta.'),
                    ),
                  );
                  return;
                }

                if (!widget.isDeposit && widget.goal.isProtected) {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Meta Protegida'),
                      content: const Text(
                        'Esta meta está protegida. ¿Estás seguro de que deseas retirar fondos de ella?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            'Sí, retirar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm != true) return;
                }

                final tx = SavingsTransactionEntity(
                  goalId: widget.goal.id!,
                  accountId: _selectedAccountId!,
                  amount: _amount,
                  date: DateTime.now().toIso8601String(),
                  type: widget.isDeposit ? 'deposit' : 'withdrawal',
                  reason: _reason.isEmpty && widget.isDeposit
                      ? 'Aportación manual'
                      : _reason,
                );

                final repo = ref.read(savingsRepositoryProvider);
                await repo.createTransaction(tx);

                // Trigger notification watcher
                final amountDelta = widget.isDeposit ? _amount : -_amount;
                ref
                    .read(savingsNotificationWatcherProvider)
                    .checkSavingsProgress(widget.goal.id!, amountDelta)
                    .catchError((e) {
                      debugPrint('Error in savings watcher: $e');
                    });

                // Si la meta está vinculada al saldo real, reflejar la transacción manual
                if (widget.goal.deductFromBalance) {
                  final realTx = TransactionEntity(
                    accountId: _selectedAccountId!,
                    amount: _amount,
                    date: DateTime.now().toIso8601String(),
                    note: widget.isDeposit
                        ? 'Aportación a ${widget.goal.name}'
                        : 'Retiro de ${widget.goal.name}',
                    type: widget.isDeposit
                        ? 'expense'
                        : 'income', // Un depósito al ahorro es un gasto en la cuenta principal
                  );
                  await ref
                      .read(transactionRepositoryProvider)
                      .createTransaction(realTx);
                  // Opcional: Invalidar proveedores de transacciones para que el Home se actualice
                  ref.invalidate(transactionsProvider);
                  // Invalidar también accountsProvider para que el saldo se actualice si es necesario
                  ref.invalidate(accountsProvider);
                }

                // Evaluar completitud
                if (widget.isDeposit) {
                  final newTotal = widget.savedAmount + _amount;
                  if (newTotal >= widget.goal.targetAmount &&
                      widget.goal.status != 'completed') {
                    await ref
                        .read(savingsGoalsProvider.notifier)
                        .updateGoal(widget.goal.copyWith(status: 'completed'));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '¡Felicidades! Meta de ahorro cumplida.',
                          ),
                        ),
                      );
                    }
                  }
                }

                ref.invalidate(
                  savingsGoalTransactionsProvider(widget.goal.id!),
                );

                if (context.mounted) {
                  Navigator.of(context).pop(true);
                }
              }
            },
            icon: Icon(
              widget.isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
            ),
            label: Text(widget.isDeposit ? 'Aportar' : 'Retirar'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
