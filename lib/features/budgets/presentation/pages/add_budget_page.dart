import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestor_gastos/features/categories/domain/entities/category.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/budget.dart';
import '../providers/budgets_provider.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../savings/presentation/providers/savings_provider.dart';

import '../widgets/budget_type_selector.dart';
import '../widgets/budget_category_selector.dart';
import '../widgets/budget_savings_goal_selector.dart';
import '../widgets/budget_amount_input.dart';

class AddBudgetPage extends ConsumerStatefulWidget {
  final String monthYear; // YYYY-MM
  const AddBudgetPage({super.key, required this.monthYear});

  @override
  ConsumerState<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends ConsumerState<AddBudgetPage> {
  final _amountController = TextEditingController();

  bool _isSavings = false;
  int? _selectedCategoryId;
  int? _selectedSavingsGoalId;

  Future<void> _suggestAmount() async {
    if (_isSavings) return;
    if (_selectedCategoryId == null) return;

    final repo = ref.read(budgetRepositoryProvider);
    final avg = await repo.getAverageSpendForCategory(
      _selectedCategoryId!,
      months: 3,
    );

    if (mounted) {
      setState(() {
        _amountController.text = avg.toStringAsFixed(2);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sugerencia basada en promedio de últimos 3 meses: \$${avg.toStringAsFixed(2)}',
          ),
        ),
      );
    }
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingrese un monto válido')));
      return;
    }

    if (!_isSavings && _selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleccione una categoría')));
      return;
    }

    if (_isSavings && _selectedSavingsGoalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione una meta de ahorro')),
      );
      return;
    }

    final repo = ref.read(budgetRepositoryProvider);
    await repo.createBudget(
      BudgetEntity(
        categoryId: _isSavings ? null : _selectedCategoryId,
        savingsGoalId: _isSavings ? _selectedSavingsGoalId : null,
        amount: amount,
        monthYear: widget.monthYear,
      ),
    );

    ref.invalidate(monthlyBudgetsProvider(widget.monthYear));
    ref.invalidate(globalBudgetProvider(widget.monthYear));

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesProvider);
    final savingsState = ref.watch(savingsGoalsProvider);

    Category? selectedCategory;
    if (_selectedCategoryId != null && categoriesState.value != null) {
      selectedCategory = categoriesState.value!
          .where((c) => c.id == _selectedCategoryId)
          .firstOrNull;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Presupuesto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BudgetTypeSelector(
              isSavings: _isSavings,
              onChanged: (val) => setState(() => _isSavings = val),
            ),
            const SizedBox(height: 24),

            if (!_isSavings)
              BudgetCategorySelector(
                selectedCategory: selectedCategory,
                categories: categoriesState.value,
                onSelected: (cat) =>
                    setState(() => _selectedCategoryId = cat.id),
              )
            else
              savingsState.when(
                data: (goals) => BudgetSavingsGoalSelector(
                  selectedGoalId: _selectedSavingsGoalId,
                  goals: goals,
                  onChanged: (val) =>
                      setState(() => _selectedSavingsGoalId = val),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, st) => Text('Error: $e'),
              ),

            const SizedBox(height: 16),

            BudgetAmountInput(
              controller: _amountController,
              isSavings: _isSavings,
              onSuggestAmount: _suggestAmount,
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Guardar Presupuesto'),
            ),
          ],
        ),
      ),
    );
  }
}
