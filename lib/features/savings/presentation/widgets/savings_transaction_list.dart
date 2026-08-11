import 'package:flutter/material.dart';
import '../../domain/entities/savings_transaction.dart';

class SavingsTransactionList extends StatelessWidget {
  final List<SavingsTransactionEntity> transactions;

  const SavingsTransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No hay historial de ahorros para esta meta aún.', textAlign: TextAlign.center),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isDeposit = tx.type == 'deposit';
        final theme = Theme.of(context);
        
        return Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerLowest,
          margin: const EdgeInsets.only(bottom: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            leading: CircleAvatar(
              backgroundColor: isDeposit ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              child: Icon(
                isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                color: isDeposit ? Colors.green : Colors.red,
              ),
            ),
            title: Text(tx.reason ?? 'Transacción', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(tx.date.substring(0, 10)),
            trailing: Text(
              '${isDeposit ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDeposit ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
