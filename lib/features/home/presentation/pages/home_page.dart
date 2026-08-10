import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/settings/presentation/pages/settings_page.dart';
import '../../../budgets/presentation/pages/budgets_page.dart';
import '../../../recurring_transactions/application/recurring_service.dart';
import '../../../recurring_transactions/presentation/pages/recurring_transactions_page.dart';
import '../../../savings/application/savings_schedule_service.dart';
import '../../../savings/presentation/pages/savings_page.dart';

import '../widgets/transactions_view.dart';

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
    TransactionsView(), // Gastos
    RecurringTransactionsPage(), // Recurrentes
    SavingsPage(), // Ahorro
    BudgetsPage(), // Presupuesto
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

