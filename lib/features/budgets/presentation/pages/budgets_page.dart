import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';
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
    final theme = Theme.of(context);
    
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 370,
            child: AnimatedContainer(
  duration: const Duration(milliseconds: 500),
  
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(ref.watch(appBackgroundProvider)),
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
          Container(
            color: Colors.transparent,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Presupuestos', style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.15)),
                        icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
                        onPressed: () {
                          context.push('/add_budget/$_monthYearKey');
                        },
                      ),
                    ],
                  ),
                ),
            BudgetMonthSelector(
              displayMonth: _displayMonth,
              onPrevMonth: _prevMonth,
              onNextMonth: _nextMonth,
            ),
            BudgetGlobalCard(monthYearKey: _monthYearKey),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: BudgetListView(monthYearKey: _monthYearKey),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);
  }
}
