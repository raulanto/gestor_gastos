import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/budgets_provider.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../savings/presentation/providers/savings_provider.dart';

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
    final budgetsAsync = ref.watch(monthlyBudgetsProvider(_monthYearKey));
    final globalAsync = ref.watch(globalBudgetProvider(_monthYearKey));
    final categoriesState = ref.watch(categoriesProvider);
    final savingsState = ref.watch(savingsGoalsProvider);

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
          // Month Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: _prevMonth),
                Text(_displayMonth, style: theme.textTheme.titleLarge),
                IconButton(icon: const Icon(Icons.chevron_right), onPressed: _nextMonth),
              ],
            ),
          ),
          
          // Global Budget
          globalAsync.when(
            data: (global) {
              final budgeted = global['budgeted'] ?? 0.0;
              final spent = global['spent'] ?? 0.0;
              final progress = budgeted > 0 ? (spent / budgeted).clamp(0.0, 1.0) : 0.0;
              
              Color progressColor = Colors.green;
              if (progress >= 1.0) progressColor = Colors.red;
              else if (progress >= 0.8) progressColor = Colors.orange;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Presupuesto Global (Gastos)', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          color: progressColor,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          minHeight: 8,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Gastado: \$${spent.toStringAsFixed(2)}'),
                            Text('Límite: \$${budgeted.toStringAsFixed(2)}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          
          // Budget List
          Expanded(
            child: budgetsAsync.when(
              data: (progressList) {
                if (progressList.isEmpty) {
                  return const Center(child: Text('No hay presupuestos para este mes.'));
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: progressList.length,
                  itemBuilder: (context, index) {
                    final item = progressList[index];
                    final b = item.budget;
                    
                    String title = 'Desconocido';
                    IconData iconData = Icons.category;
                    Color color = Colors.grey;
                    
                    if (b.categoryId != null && categoriesState.value != null) {
                      final cat = categoriesState.value!.firstWhere(
                        (c) => c.id == b.categoryId,
                        orElse: () => categoriesState.value!.first
                      );
                      title = cat.name;
                      iconData = IconData(cat.iconCode, fontFamily: 'MaterialIcons');
                      color = Color(cat.colorCode);
                    } else if (b.savingsGoalId != null && savingsState.value != null) {
                      final goal = savingsState.value!.firstWhere(
                        (g) => g.id == b.savingsGoalId,
                        orElse: () => savingsState.value!.first
                      );
                      title = 'Ahorro: \${goal.name}';
                      iconData = IconData(goal.iconCode, fontFamily: 'MaterialIcons');
                      color = Color(goal.colorCode);
                    }
                    
                    double prog = item.progressPercentage;
                    Color barColor = Colors.green;
                    if (prog >= 1.0) barColor = Colors.red;
                    else if (prog >= 0.8) barColor = Colors.orange;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color,
                          child: Icon(iconData, color: Colors.white),
                        ),
                        title: Text(title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: prog.clamp(0.0, 1.0),
                              color: barColor,
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            ),
                            const SizedBox(height: 4),
                            Text('\$${item.actualAmount.toStringAsFixed(2)} de \$${b.amount.toStringAsFixed(2)}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            ref.read(budgetRepositoryProvider).deleteBudget(b.id!);
                            ref.invalidate(monthlyBudgetsProvider(_monthYearKey));
                            ref.invalidate(globalBudgetProvider(_monthYearKey));
                          },
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          )
        ],
      ),
    );
  }
}
