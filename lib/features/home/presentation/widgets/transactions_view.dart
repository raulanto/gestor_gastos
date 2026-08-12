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
import 'home_category_chart.dart';
import 'transaction_list.dart';

class TransactionsView extends ConsumerStatefulWidget {
  const TransactionsView({super.key});

  @override
  ConsumerState<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends ConsumerState<TransactionsView> {
  int _chartType = 0; // 0 = Flujo, 1 = Categorías

  @override
  Widget build(BuildContext context) {
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
            // Filtrar aportaciones/retiros de metas de ahorro (no tienen categoría ni splits)
            if (t.categoryId == null && t.splits.isEmpty) {
              continue;
            }

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

          return Stack(
            children: [
              // Imagen de fondo con degradado
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 350,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/home_bg.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.4),
                          theme.colorScheme.primary,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Contenido principal
              Container(
                color: Colors.transparent,
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Análisis', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                    SegmentedButton<int>(
                                      segments: const [
                                        ButtonSegment(value: 0, label: Text('Flujo'), icon: Icon(Icons.bar_chart, size: 18)),
                                        ButtonSegment(value: 1, label: Text('Categorías'), icon: Icon(Icons.pie_chart, size: 18)),
                                      ],
                                      selected: {_chartType},
                                      onSelectionChanged: (Set<int> newSelection) {
                                        setState(() {
                                          _chartType = newSelection.first;
                                        });
                                      },
                                      style: SegmentedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        textStyle: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 200,
                                  child: _chartType == 0 
                                      ? HomeChart(chartData: summary.chartData)
                                      : HomeCategoryChart(categoryData: summary.categoryExpenses),
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
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: theme.colorScheme.onPrimary)),
        error: (e, st) => Center(child: Text('Error: $e', style: TextStyle(color: theme.colorScheme.onPrimary))),
      ),
    );
  }
}
