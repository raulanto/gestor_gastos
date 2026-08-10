import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../features/settings/presentation/pages/settings_page.dart';

import '../../../budgets/presentation/pages/budgets_page.dart';
import '../../../recurring_transactions/application/recurring_service.dart';
import '../../../recurring_transactions/presentation/pages/recurring_transactions_page.dart';
import '../../../savings/application/savings_schedule_service.dart';
import '../../../savings/presentation/pages/savings_page.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recurringServiceProvider).checkAndExecuteRecurring();
      ref.read(savingsScheduleServiceProvider).checkAndExecuteScheduledSavings();
    });
  }

  final List<Widget> _pages = const [
    _TransactionsView(), // Gastos
    _RecurringTransactionsView(), // Recurrentes
    _SavingsView(), // Ahorro
    BudgetsPage(),
    SettingsPage(), // Configuración
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.autorenew_outlined),
            selectedIcon: Icon(Icons.autorenew),
            label: 'Recurrentes',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings),
            label: 'Ahorro',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Presupuesto',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
      floatingActionButton: [0, 1, 2].contains(_currentIndex)
        ? FloatingActionButton(
            onPressed: () {
              if (_currentIndex == 0) {
                context.push('/add_transaction');
              } else if (_currentIndex == 1) {
                context.push('/add_recurring_transaction');
              } else if (_currentIndex == 2) {
                context.push('/add_savings_goal');
              }
            },
            child: const Icon(Icons.add),
          )
        : null,
    );
  }
}

class _RecurringTransactionsView extends StatelessWidget {
  const _RecurringTransactionsView();

  @override
  Widget build(BuildContext context) {
    return const RecurringTransactionsPage();
  }
}

class _SavingsView extends StatelessWidget {
  const _SavingsView();

  @override
  Widget build(BuildContext context) {
    return const SavingsPage();
  }
}
enum PeriodView { day, week, month }

class PeriodViewNotifier extends Notifier<PeriodView> {
  @override
  PeriodView build() => PeriodView.month;

  void updateView(PeriodView view) {
    state = view;
  }
}

final periodViewProvider = NotifierProvider<PeriodViewNotifier, PeriodView>(PeriodViewNotifier.new);

class _TransactionsView extends ConsumerWidget {
  const _TransactionsView();

  (DateTime start, DateTime end) _getCurrentPeriodBounds(PeriodView view, DateTime now) {
    switch (view) {
      case PeriodView.day:
        return (DateTime(now.year, now.month, now.day), DateTime(now.year, now.month, now.day, 23, 59, 59, 999));
      case PeriodView.week:
        // Lunes a Domingo
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return (
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
          DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59, 999)
        );
      case PeriodView.month:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
        return (startOfMonth, endOfMonth);
    }
  }

  (DateTime start, DateTime end) _getPreviousPeriodBounds(PeriodView view, DateTime currentStart, DateTime currentEnd) {
    switch (view) {
      case PeriodView.day:
        final prevDay = currentStart.subtract(const Duration(days: 1));
        return (prevDay, DateTime(prevDay.year, prevDay.month, prevDay.day, 23, 59, 59, 999));
      case PeriodView.week:
        final prevWeekStart = currentStart.subtract(const Duration(days: 7));
        final prevWeekEnd = currentEnd.subtract(const Duration(days: 7));
        return (prevWeekStart, prevWeekEnd);
      case PeriodView.month:
        final prevMonthStart = DateTime(currentStart.year, currentStart.month - 1, 1);
        final prevMonthEnd = DateTime(currentStart.year, currentStart.month, 0, 23, 59, 59, 999);
        return (prevMonthStart, prevMonthEnd);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsState = ref.watch(transactionsProvider);
    final periodView = ref.watch(periodViewProvider);
    final theme = Theme.of(context);

    return SafeArea(
      child: transactionsState.when(
        data: (allTransactions) {
          final now = DateTime.now();
          final (curStart, curEnd) = _getCurrentPeriodBounds(periodView, now);
          final (prevStart, prevEnd) = _getPreviousPeriodBounds(periodView, curStart, curEnd);

          double currentTotal = 0;
          double prevTotal = 0;
          final currentPeriodTx = <TransactionEntity>[];

          for (var t in allTransactions) {
            final date = DateTime.parse(t.date);
            
            // Check if in current period
            if (date.isAfter(curStart.subtract(const Duration(milliseconds: 1))) &&
                date.isBefore(curEnd.add(const Duration(milliseconds: 1)))) {
              currentPeriodTx.add(t);
              if (t.type == 'expense') {
                currentTotal += t.amount;
              }
            }
            
            // Check if in previous period
            if (date.isAfter(prevStart.subtract(const Duration(milliseconds: 1))) &&
                date.isBefore(prevEnd.add(const Duration(milliseconds: 1)))) {
              if (t.type == 'expense') {
                prevTotal += t.amount;
              }
            }
          }

          // Sort current period tx by date descending
          currentPeriodTx.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

          // Calculate percentage change
          double percentageChange = 0;
          if (prevTotal > 0) {
            percentageChange = ((currentTotal - prevTotal) / prevTotal) * 100;
          } else if (currentTotal > 0) {
            percentageChange = 100; // Increment from 0 to something is a 100% increase mathematically in this context
          }

          String titleStr = '';
          switch (periodView) {
            case PeriodView.day: titleStr = 'Gastado hoy'; break;
            case PeriodView.week: titleStr = 'Gastado esta semana'; break;
            case PeriodView.month: titleStr = 'Gastado este mes'; break;
          }

          String compStr = '';
          switch (periodView) {
            case PeriodView.day: compStr = 'que ayer'; break;
            case PeriodView.week: compStr = 'que la sem. pasada'; break;
            case PeriodView.month: compStr = 'que el mes pasado'; break;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabecera Resumen
              Container(
                padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    SegmentedButton<PeriodView>(
                      segments: const [
                        ButtonSegment(value: PeriodView.day, label: Text('Día')),
                        ButtonSegment(value: PeriodView.week, label: Text('Semana')),
                        ButtonSegment(value: PeriodView.month, label: Text('Mes')),
                      ],
                      selected: {periodView},
                      onSelectionChanged: (val) {
                        ref.read(periodViewProvider.notifier).updateView(val.first);
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(titleStr, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                    const SizedBox(height: 8),
                    Text(
                      '\$${currentTotal.toStringAsFixed(2)}',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (prevTotal > 0 || currentTotal > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            percentageChange > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                            color: percentageChange > 0 ? Colors.red : Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${percentageChange.abs().toStringAsFixed(1)}% ${percentageChange > 0 ? 'más' : 'menos'} $compStr',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: percentageChange > 0 ? Colors.red : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Lista de Transacciones
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Movimientos recientes', style: theme.textTheme.titleLarge),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: currentPeriodTx.isEmpty
                    ? const Center(child: Text('No hay transacciones en este período.'))
                    : ListView.builder(
                        itemCount: currentPeriodTx.length,
                        itemBuilder: (context, index) {
                          final t = currentPeriodTx[index];
                          final isExpense = t.type == 'expense';
                          final isTransfer = t.type == 'transfer';
                          
                          return ListTile(
                            onTap: () {
                              context.push('/transaction_details', extra: t);
                            },
                            leading: CircleAvatar(
                              backgroundColor: isExpense 
                                ? Colors.red.withValues(alpha: 0.1) 
                                : (isTransfer ? Colors.blue.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1)),
                              child: Icon(
                                isExpense ? Icons.arrow_downward : (isTransfer ? Icons.swap_horiz : Icons.arrow_upward),
                                color: isExpense ? Colors.red : (isTransfer ? Colors.blue : Colors.green),
                              ),
                            ),
                            title: Text(t.note?.isNotEmpty == true ? t.note! : 'Transacción'),
                            subtitle: Text(DateFormat.yMMMd().format(DateTime.parse(t.date))),
                            trailing: Text(
                              '${isExpense ? '-' : (isTransfer ? '' : '+')}\$${t.amount.toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isExpense ? Colors.red : (isTransfer ? theme.colorScheme.onSurface : Colors.green),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
