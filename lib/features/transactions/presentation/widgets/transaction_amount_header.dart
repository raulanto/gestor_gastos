import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';

class TransactionAmountHeader extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionAmountHeader({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = transaction.type == 'expense';
    final amountColor = isExpense ? Colors.red : Colors.green;
    final typeLabel = isExpense ? 'Gasto' : (transaction.type == 'income' ? 'Ingreso' : 'Transferencia');

    return Center(
      child: Column(
        children: [
          Text(
            typeLabel.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${transaction.amount.toStringAsFixed(2)}',
            style: theme.textTheme.displayMedium?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            transaction.date.substring(0, 10), // Simplificado
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
