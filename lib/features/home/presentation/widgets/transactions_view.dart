import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../providers/period_view_provider.dart';
class TransactionsView extends ConsumerWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodView = ref.watch(periodViewProvider);
    final transactionsState = ref.watch(transactionsProvider);
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: transactionsState.when(
        data: (allTransactions) {
          final now = DateTime.now();
          List<TransactionEntity> txs = [];
          
          for (var t in allTransactions) {
            final date = DateTime.parse(t.date);
            bool include = false;
            if (periodView == PeriodView.day) {
              include = date.year == now.year && date.month == now.month && date.day == now.day;
            } else if (periodView == PeriodView.week) {
              final weekStart = now.subtract(Duration(days: now.weekday - 1));
              include = date.isAfter(weekStart.subtract(const Duration(days: 1)));
            } else if (periodView == PeriodView.month) {
              include = date.year == now.year && date.month == now.month;
            } else if (periodView == PeriodView.year) {
              include = date.year == now.year;
            }
            if (include) txs.add(t);
          }

          txs.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

          double totalIncome = 0;
          double totalExpense = 0;
          for (var t in txs) {
            if (t.type == 'income') {
              totalIncome += t.amount;
            } else if (t.type == 'expense') {
              totalExpense += t.amount;
            }
          }
          final totalBalance = totalIncome - totalExpense;


          Map<String, List<TransactionEntity>> groupedTransactions = {};
          
          for (var t in txs) {
            final date = DateTime.parse(t.date);
            final diff = DateTime(now.year, now.month, now.day).difference(DateTime(date.year, date.month, date.day)).inDays;
            
            String key;
            if (diff == 0) {
              key = 'HOY';
            } else if (diff == 1) {
              key = 'AYER';
            } else {
              key = DateFormat('dd MMM').format(date).toUpperCase();
            }
            
            if (!groupedTransactions.containsKey(key)) {
              groupedTransactions[key] = [];
            }
            groupedTransactions[key]!.add(t);
          }

          return Container(
            color: theme.colorScheme.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 32),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                                child: Icon(Icons.person, size: 16, color: theme.colorScheme.onPrimary),
                              ),
                              const SizedBox(width: 8),
                              Text('Gestor de Gastos', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Icon(Icons.search, color: theme.colorScheme.onPrimary),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        '\$${totalBalance.toStringAsFixed(2)}',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_upward, color: Colors.green, size: 16),
                          const SizedBox(width: 4),
                          Text('\$${totalIncome.toStringAsFixed(2)}', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                          const SizedBox(width: 24),
                          Icon(Icons.arrow_downward, color: Colors.red, size: 16),
                          const SizedBox(width: 4),
                          Text('\$${totalExpense.toStringAsFixed(2)}', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.15),
                              foregroundColor: theme.colorScheme.onPrimary,
                            ),
                            onPressed: () => context.push('/add_transaction?type=income'),
                            icon: const Icon(Icons.add),
                            label: const Text('Ingreso'),
                          ),
                          const SizedBox(width: 16),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.15),
                              foregroundColor: theme.colorScheme.onPrimary,
                            ),
                            onPressed: () => context.push('/add_transaction?type=expense'),
                            icon: const Icon(Icons.call_made),
                            label: const Text('Gasto'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Transacciones', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                              PopupMenuButton<PeriodView>(
                                icon: Icon(Icons.filter_list, color: theme.colorScheme.onSurface),
                                initialValue: periodView,
                                onSelected: (PeriodView newPeriod) {
                                  ref.read(periodViewProvider.notifier).state = newPeriod;
                                },
                                itemBuilder: (BuildContext context) => <PopupMenuEntry<PeriodView>>[
                                  const PopupMenuItem<PeriodView>(
                                    value: PeriodView.day,
                                    child: Text('Diario'),
                                  ),
                                  const PopupMenuItem<PeriodView>(
                                    value: PeriodView.week,
                                    child: Text('Semanal'),
                                  ),
                                  const PopupMenuItem<PeriodView>(
                                    value: PeriodView.month,
                                    child: Text('Mensual'),
                                  ),
                                  const PopupMenuItem<PeriodView>(
                                    value: PeriodView.year,
                                    child: Text('Anual'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: txs.isEmpty
                              ? const Center(child: Text('No hay transacciones.'))
                              : ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 100),
                                  itemCount: groupedTransactions.length,
                                  itemBuilder: (context, index) {
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
                                        }).toList(),
                                        const SizedBox(height: 8),
                                      ],
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: theme.colorScheme.onPrimary)),
        error: (e, st) => Center(child: Text('Error: $e', style: TextStyle(color: theme.colorScheme.onPrimary))),
      ),
    );
  }
}
