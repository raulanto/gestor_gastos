import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../transactions/domain/entities/transaction.dart';

class TransactionList extends StatelessWidget {
  final Map<String, List<TransactionEntity>> groupedTransactions;

  const TransactionList({super.key, required this.groupedTransactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (groupedTransactions.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: Text('No hay transacciones.')),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final dateKey = groupedTransactions.keys.elementAt(index);
          final dailyTxs = groupedTransactions[dateKey]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Text(
                  dateKey,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              ...dailyTxs.map((t) {
                final isExpense = t.type == 'expense';
                final isTransfer = t.type == 'transfer';
                
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                  onTap: () {
                    context.push('/transaction_details', extra: t);
                  },
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      isExpense ? Icons.shopping_bag_outlined : (isTransfer ? Icons.swap_horiz : Icons.account_balance_wallet_outlined),
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  title: Text(t.note?.isNotEmpty == true ? t.note! : 'Transacción', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(isExpense ? 'Gasto' : (isTransfer ? 'Transferencia' : 'Ingreso')),
                  trailing: Text(
                    "${isExpense ? '-' : (isTransfer ? '' : '+')}\$${t.amount.toStringAsFixed(2)}",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isExpense ? theme.colorScheme.onSurface : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          );
        },
        childCount: groupedTransactions.length,
      ),
    );
  }
}
