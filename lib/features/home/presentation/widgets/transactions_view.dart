import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../transactions/domain/entities/transaction.dart';
import '../providers/home_summary_provider.dart';

import 'home_header.dart';
import 'period_selector.dart';
import 'kpi_cards.dart';
import 'home_chart.dart';
import 'transaction_list.dart';

class TransactionsView extends ConsumerWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryState = ref.watch(homeSummaryProvider);
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: summaryState.when(
        data: (summary) {
          // Grouping for the transaction list
          Map<String, List<TransactionEntity>> groupedTransactions = {};
          final now = DateTime.now();
          for (var t in summary.transactions) {
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
                HomeHeader(totalBalance: summary.totalBalance),
                const PeriodSelector(),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                KpiCards(
                                  totalIncome: summary.totalIncome,
                                  totalExpense: summary.totalExpense,
                                ),
                                const SizedBox(height: 32),
                                Text('Flujo de Dinero', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 200,
                                  child: HomeChart(chartData: summary.chartData),
                                ),
                                const SizedBox(height: 32),
                                Row(
                                  children: [
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () => context.push('/add_transaction?type=income'),
                                        icon: const Icon(Icons.add),
                                        label: const Text('Ingreso'),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                                          foregroundColor: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () => context.push('/add_transaction?type=expense'),
                                        icon: const Icon(Icons.call_made),
                                        label: const Text('Gasto'),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                                          foregroundColor: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text('Historial', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        TransactionList(groupedTransactions: groupedTransactions),
                        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
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
