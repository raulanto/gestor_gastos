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
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildOption(context, 'Gasto', 'expense', theme),
          _buildOption(context, 'Ingreso', 'income', theme),
          _buildOption(context, 'Traspaso', 'transfer', theme),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String title, String value, ThemeData theme) {
    final isSelected = transactionType == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
