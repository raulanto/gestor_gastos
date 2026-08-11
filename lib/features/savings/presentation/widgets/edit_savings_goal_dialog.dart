import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/savings_goal.dart';
import '../providers/savings_provider.dart';

class EditSavingsGoalDialog extends ConsumerStatefulWidget {
  final SavingsGoalEntity goal;

  const EditSavingsGoalDialog({super.key, required this.goal});

  @override
  ConsumerState<EditSavingsGoalDialog> createState() => _EditSavingsGoalDialogState();
}

class _EditSavingsGoalDialogState extends ConsumerState<EditSavingsGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late double _targetAmount;
  late bool _isProtected;
  late bool _deductFromBalance;
  late int _priority;

  @override
  void initState() {
    super.initState();
    _name = widget.goal.name;
    _targetAmount = widget.goal.targetAmount;
    _isProtected = widget.goal.isProtected;
    _deductFromBalance = widget.goal.deductFromBalance;
    _priority = widget.goal.priority;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Meta'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nombre de la Meta'),
                validator: (v) => v == null || v.isEmpty ? 'El nombre es obligatorio' : null,
                onSaved: (v) => _name = v ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _targetAmount.toStringAsFixed(2),
                decoration: const InputDecoration(labelText: 'Monto Objetivo'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || double.tryParse(v) == null ? 'Monto inválido' : null,
                onSaved: (v) => _targetAmount = double.parse(v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _priority.toString(),
                decoration: const InputDecoration(
                  labelText: 'Prioridad',
                  helperText: 'Menor número = mayor prioridad',
                ),
                keyboardType: TextInputType.number,
                onSaved: (v) => _priority = int.tryParse(v ?? '0') ?? 0,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Proteger Meta'),
                value: _isProtected,
                onChanged: (val) => setState(() => _isProtected = val),
              ),
              SwitchListTile(
                title: const Text('Vincular Saldo'),
                value: _deductFromBalance,
                onChanged: (val) => setState(() => _deductFromBalance = val),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final updatedGoal = widget.goal.copyWith(
                name: _name,
                targetAmount: _targetAmount,
                isProtected: _isProtected,
                deductFromBalance: _deductFromBalance,
                priority: _priority,
              );
              
              await ref.read(savingsGoalsProvider.notifier).updateGoal(updatedGoal);
              if (context.mounted) {
                Navigator.pop(context, updatedGoal);
              }
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
