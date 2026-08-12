import 'package:flutter/material.dart';
import '../../../savings/domain/entities/savings_goal.dart';

class BudgetSavingsGoalSelector extends StatelessWidget {
  final int? selectedGoalId;
  final List<SavingsGoalEntity> goals;
  final ValueChanged<int?> onChanged;

  const BudgetSavingsGoalSelector({
    super.key,
    required this.selectedGoalId,
    required this.goals,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(labelText: 'Meta de Ahorro', border: OutlineInputBorder()),
      value: selectedGoalId,
      items: goals.map((g) => DropdownMenuItem(
        value: g.id,
        child: Text(g.name),
      )).toList(),
      onChanged: onChanged,
    );
  }
}
