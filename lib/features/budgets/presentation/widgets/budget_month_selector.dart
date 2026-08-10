import 'package:flutter/material.dart';

class BudgetMonthSelector extends StatelessWidget {
  final String displayMonth;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  const BudgetMonthSelector({
    super.key,
    required this.displayMonth,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevMonth,
          ),
          Text(displayMonth, style: theme.textTheme.titleLarge),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNextMonth,
          ),
        ],
      ),
    );
  }
}
