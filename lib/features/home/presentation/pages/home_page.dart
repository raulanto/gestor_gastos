import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../features/settings/presentation/pages/settings_page.dart';
import '../../../recurring_transactions/application/recurring_service.dart';
import '../../../recurring_transactions/presentation/pages/recurring_transactions_page.dart';
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
    });
  }

  final List<Widget> _pages = const [
    _TransactionsView(), // Gastos
    _RecurringTransactionsView(), // Recurrentes
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
            icon: Icon(Icons.receipt_long),
            label: 'Gastos',
          ),
          NavigationDestination(
            icon: Icon(Icons.autorenew),
            label: 'Recurrentes',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
      floatingActionButton: _currentIndex < 2 
        ? FloatingActionButton(
            onPressed: () {
              if (_currentIndex == 0) {
                context.push('/add_transaction');
              } else if (_currentIndex == 1) {
                context.push('/add_recurring_transaction');
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
class _TransactionsView extends ConsumerWidget {
  const _TransactionsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsState = ref.watch(transactionsProvider);
    final theme = Theme.of(context);

    return SafeArea(
      child: transactionsState.when(
        data: (transactions) {
          double totalGastado = 0;
          for (var t in transactions) {
            if (t.type == 'expense') {
              totalGastado += t.amount;
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabecera Resumen
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Text('Gastado este mes', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                    const SizedBox(height: 8),
                    Text(
                      '\$${totalGastado.toStringAsFixed(2)}',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
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
                child: transactions.isEmpty
                    ? const Center(child: Text('No hay transacciones aún.'))
                    : ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final t = transactions[index];
                          final isExpense = t.type == 'expense';
                          final isTransfer = t.type == 'transfer';
                          
                          // TODO: Load Category Name and Icon from DB correctly by id.
                          // For now, simple fallback UI:
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
