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

  @override
  void initState() {
    super.initState();
    _name = widget.goal.name;
    _targetAmount = widget.goal.targetAmount;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Meta'),
      content: Form(
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
          ],
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
