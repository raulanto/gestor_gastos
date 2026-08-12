import 'package:flutter/material.dart';

class BudgetTypeSelector extends StatelessWidget {
  final bool isSavings;
  final ValueChanged<bool> onChanged;

  const BudgetTypeSelector({
    super.key,
    required this.isSavings,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(value: false, label: Text('Gasto (Categoría)')),
        ButtonSegment(value: true, label: Text('Ahorro (Meta)')),
      ],
      selected: {isSavings},
      onSelectionChanged: (set) => onChanged(set.first),
    );
  }
}
