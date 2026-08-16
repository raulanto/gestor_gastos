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
            icon: Icon(Icons.chevron_left, color: theme.colorScheme.onPrimary),
            onPressed: onPrevMonth,
          ),
          Text(
            displayMonth,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: theme.colorScheme.onPrimary),
            onPressed: onNextMonth,
          ),
        ],
      ),
    );
  }
}
