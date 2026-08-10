import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/account.dart';
import '../providers/account_transactions_provider.dart';

class AccountDetailsPage extends ConsumerWidget {
  final Account account;

  const AccountDetailsPage({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filterMap = ref.watch(accountDateFilterProvider);
    final filter = filterMap[account.id] ?? DateRangeFilter.monthly;
    final summaryAsync = ref.watch(accountTransactionsSummaryProvider(account.id));

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          account.name,
          style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Color(account.colorCode).withValues(alpha: 0.8),
              child: Icon(IconData(account.iconCode, fontFamily: 'MaterialIcons'), color: Colors.white, size: 20),
            ),
          )
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Balance
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  Text('Balance Actual', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary.withValues(alpha: 0.8))),
                  const SizedBox(height: 8),
                  Text(
                    '\$${account.balance.toStringAsFixed(2)}',
                    style: theme.textTheme.displaySmall?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            // Filtros
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: SegmentedButton<DateRangeFilter>(
                segments: const [
                  ButtonSegment(value: DateRangeFilter.days7, label: Text('7 Días')),
                  ButtonSegment(value: DateRangeFilter.monthly, label: Text('Mes')),
                  ButtonSegment(value: DateRangeFilter.trimester, label: Text('Trimestre')),
                ],
                selected: {filter},
                onSelectionChanged: (Set<DateRangeFilter> newSelection) {
                  ref.read(accountDateFilterProvider.notifier).updateFilter(account.id, newSelection.first);
                },
                style: SegmentedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  selectedBackgroundColor: theme.colorScheme.onPrimary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  selectedForegroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.onPrimary.withValues(alpha: 0.3)),
                ),
              ),
            ),

            // Contenedor principal blanco
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: summaryAsync.when(
                  data: (summary) {
                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Resumen Numérico
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildSummaryCard(context, 'Ingresos', summary.totalIncome, Colors.green),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildSummaryCard(context, 'Gastos', summary.totalExpense, Colors.red),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                // Chart
                                Text('Resumen de Flujo', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 220,
                                  child: _buildChart(summary.chartData, theme),
                                ),
                                const SizedBox(height: 32),
                                Text('Historial de Transacciones', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        if (summary.transactions.isEmpty)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Center(child: Text('No hay transacciones en este periodo.')),
                            ),
                          )
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final tx = summary.transactions[index];
                                final isIncome = tx.type == 'income';
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                  leading: CircleAvatar(
                                    backgroundColor: isIncome ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                                    child: Icon(
                                      isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                      color: isIncome ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  title: Text(tx.note?.isNotEmpty == true ? tx.note! : (isIncome ? 'Ingreso' : 'Gasto'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(DateFormat('dd MMM yyyy').format(DateTime.parse(tx.date))),
                                  trailing: Text(
                                    '${isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: isIncome ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  onTap: () {
                                    context.push('/transaction_details', extra: tx);
                                  },
                                );
                              },
                              childCount: summary.transactions.length,
                            ),
                          ),
                        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, double amount, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(title == 'Ingresos' ? Icons.arrow_upward : Icons.arrow_downward, color: color, size: 16),
              const SizedBox(width: 4),
              Text(title, style: theme.textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text('\$${amount.toStringAsFixed(2)}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildChart(Map<String, Map<String, double>> chartData, ThemeData theme) {
    if (chartData.isEmpty) {
      return const Center(child: Text('No hay datos para mostrar gráficas'));
    }

    final entries = chartData.entries.toList();
    entries.sort((a, b) => a.value['timestamp']!.compareTo(b.value['timestamp']!));

    double maxY = 0;
    for (var entry in entries) {
      if (entry.value['income']! > maxY) maxY = entry.value['income']!;
      if (entry.value['expense']! > maxY) maxY = entry.value['expense']!;
    }
    
    // Add 20% padding to maxY
    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 && value.toInt() < entries.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      entries[value.toInt()].key,
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4 == 0 ? 1 : maxY / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.surfaceContainerHighest,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(entries.length, (index) {
          final entry = entries[index];
          final income = entry.value['income']!;
          final expense = entry.value['expense']!;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: income,
                color: Colors.green,
                width: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              BarChartRodData(
                toY: expense,
                color: Colors.red,
                width: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }
}
