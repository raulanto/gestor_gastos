import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../widgets/budget_month_selector.dart';
import '../widgets/budget_global_card.dart';
import '../widgets/budget_list_view.dart';

class BudgetsPage extends ConsumerStatefulWidget {
  const BudgetsPage({super.key});

  @override
  ConsumerState<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends ConsumerState<BudgetsPage> {
  DateTime _currentMonth = DateTime.now();

  String get _monthYearKey => DateFormat('yyyy-MM').format(_currentMonth);
  String get _displayMonth => DateFormat.yMMMM().format(_currentMonth);

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presupuestos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/add_budget', extra: _monthYearKey);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          BudgetMonthSelector(
            displayMonth: _displayMonth,
            onPrevMonth: _prevMonth,
            onNextMonth: _nextMonth,
          ),
          BudgetGlobalCard(monthYearKey: _monthYearKey),
          const SizedBox(height: 16),
          Expanded(
            child: BudgetListView(monthYearKey: _monthYearKey),
          ),
        ],
      ),
    );
  }
}
