import 'package:flutter/material.dart';

class BudgetAmountInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isSavings;
  final VoidCallback onSuggestAmount;

  const BudgetAmountInput({
    super.key,
    required this.controller,
    required this.isSavings,
    required this.onSuggestAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Monto Límite',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        if (!isSavings) ...[
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: onSuggestAmount,
            icon: const Icon(Icons.lightbulb_outline),
            tooltip: 'Sugerir basado en histórico',
          ),
        ],
      ],
    );
  }
}
