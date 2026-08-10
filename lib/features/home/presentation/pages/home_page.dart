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
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(Icons.home, Icons.home_outlined, 0),
                _buildNavItem(Icons.autorenew, Icons.autorenew_outlined, 1),
                _buildNavItem(Icons.savings, Icons.savings_outlined, 2),
                _buildNavItem(Icons.pie_chart, Icons.pie_chart_outline, 3),
                _buildNavItem(Icons.settings, Icons.settings_outlined, 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData selectedIcon, IconData unselectedIcon, int index) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.surface : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? selectedIcon : unselectedIcon,
          color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.surface.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

