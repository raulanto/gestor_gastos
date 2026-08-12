import 'package:flutter/material.dart';

class TransactionTypeSelector extends StatelessWidget {
  final String transactionType;
  final ValueChanged<String> onChanged;

  const TransactionTypeSelector({
    super.key,
    required this.transactionType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'expense', label: Text('Gasto')),
        ButtonSegment(value: 'income', label: Text('Ingreso')),
        ButtonSegment(value: 'transfer', label: Text('Transferencia')),
      ],
      selected: {transactionType},
      onSelectionChanged: (Set<String> newSelection) {
        onChanged(newSelection.first);
      },
    );
  }
}
