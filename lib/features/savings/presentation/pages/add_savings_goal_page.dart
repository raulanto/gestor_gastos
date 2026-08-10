import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/savings_goal.dart';
import '../providers/savings_provider.dart';

class AddSavingsGoalPage extends ConsumerStatefulWidget {
  const AddSavingsGoalPage({super.key});

  @override
  ConsumerState<AddSavingsGoalPage> createState() => _AddSavingsGoalPageState();
}

class _AddSavingsGoalPageState extends ConsumerState<AddSavingsGoalPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _targetAmount = 0.0;
  DateTime? _deadline;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Meta de Ahorro')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nombre de la Meta (ej. Viaje)'),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              onSaved: (v) => _name = v!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Monto Objetivo'),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || double.tryParse(v) == null ? 'Monto inválido' : null,
              onSaved: (v) => _targetAmount = double.parse(v!),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final newGoal = SavingsGoalEntity(
                    name: _name,
                    targetAmount: _targetAmount,
                    deadlineDate: _deadline?.toIso8601String(),
                    iconCode: Icons.savings.codePoint, // Default
                    colorCode: Colors.blue.toARGB32(), // Default
                  );
                  ref.read(savingsGoalsProvider.notifier).addGoal(newGoal);
                  context.pop();
                }
              },
              child: const Text('Guardar Meta'),
            )
          ],
        ),
      ),
    );
  }
}
