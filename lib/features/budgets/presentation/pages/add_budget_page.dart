import 'package:gestor_gastos/core/utils/currency_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';
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
  double _warningThreshold = 0.8;

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
            'Sugerencia basada en promedio de últimos 3 meses: ${CurrencyUtils.formatAmount(avg)}',
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
        warningThreshold: _warningThreshold,
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
    final theme = Theme.of(context);
    final categoriesState = ref.watch(categoriesProvider);
    final savingsState = ref.watch(savingsGoalsProvider);

    Category? selectedCategory;
    if (_selectedCategoryId != null && categoriesState.value != null) {
      selectedCategory = categoriesState.value!
          .where((c) => c.id == _selectedCategoryId)
          .firstOrNull;
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
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
                      theme.colorScheme.primary.withValues(alpha: 1.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nuevo Presupuesto',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          BudgetTypeSelector(
                            isSavings: _isSavings,
                            onChanged: (val) =>
                                setState(() => _isSavings = val),
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
                                onChanged: (val) => setState(
                                  () => _selectedSavingsGoalId = val,
                                ),
                              ),
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (e, st) => Text('Error: $e'),
                            ),

                          const SizedBox(height: 16),

                          BudgetAmountInput(
                            controller: _amountController,
                            isSavings: _isSavings,
                            onSuggestAmount: _suggestAmount,
                          ),

                          const SizedBox(height: 24),
                          Text(
                            'Avisarme al llegar al ${(_warningThreshold * 100).toInt()}%',
                            style: theme.textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          Slider(
                            value: _warningThreshold,
                            min: 0.1,
                            max: 1.0,
                            divisions: 9,
                            label: '${(_warningThreshold * 100).toInt()}%',
                            activeColor: theme.colorScheme.primary,
                            onChanged: (val) {
                              setState(() => _warningThreshold = val);
                            },
                          ),

                          const SizedBox(height: 32),
                          FilledButton(
                            onPressed: _save,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Guardar Presupuesto',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
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
