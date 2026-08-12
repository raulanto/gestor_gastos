import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../accounts/presentation/providers/account_provider.dart';
import '../../../categories/presentation/providers/category_provider.dart';

class TransactionList extends ConsumerWidget {
  final Map<String, List<TransactionEntity>> groupedTransactions;

  const TransactionList({super.key, required this.groupedTransactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    final accountsState = ref.watch(accountsProvider);
    final categoriesState = ref.watch(categoriesProvider);
    
    final accounts = accountsState.value ?? [];
    final categories = categoriesState.value ?? [];

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
                
                final account = accounts.where((a) => a.id == t.accountId).firstOrNull;
                final category = categories.where((c) => c.id == t.categoryId).firstOrNull;

                final categoryColor = category != null ? Color(category.colorCode) : theme.colorScheme.primary;
                final categoryIcon = category != null ? IconData(category.iconCode, fontFamily: 'MaterialIcons') : (isExpense ? Icons.shopping_bag_outlined : (isTransfer ? Icons.swap_horiz : Icons.account_balance_wallet_outlined));

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                  onTap: () {
                    context.push('/transaction_details/${t.id}');
                  },
                  leading: CircleAvatar(
                    backgroundColor: categoryColor.withValues(alpha: 0.2),
                    child: Icon(
                      categoryIcon,
                      color: categoryColor,
                    ),
                  ),
                  title: Text(t.note?.isNotEmpty == true ? t.note! : (category?.name ?? 'Transacción'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (account != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            account.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(isExpense ? 'Gasto' : (isTransfer ? 'Transferencia' : 'Ingreso')),
                    ],
                  ),
                  trailing: Text(
                    "${isExpense ? '-' : (isTransfer ? '' : '+')}\$${t.amount.toStringAsFixed(2)}",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isExpense ? Colors.red.shade700 : (isTransfer ? theme.colorScheme.onSurface : Colors.green.shade700),
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
