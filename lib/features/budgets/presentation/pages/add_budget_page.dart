import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/budget.dart';
import '../providers/budgets_provider.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../savings/presentation/providers/savings_provider.dart';

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
    final avg = await repo.getAverageSpendForCategory(_selectedCategoryId!, months: 3);
    
    if (mounted) {
      setState(() {
        _amountController.text = avg.toStringAsFixed(2);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sugerencia basada en promedio de últimos 3 meses: \$${avg.toStringAsFixed(2)}')));
    }
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingrese un monto válido')));
      return;
    }
    
    if (!_isSavings && _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione una categoría')));
      return;
    }
    
    if (_isSavings && _selectedSavingsGoalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione una meta de ahorro')));
      return;
    }
    
    final repo = ref.read(budgetRepositoryProvider);
    await repo.createBudget(BudgetEntity(
      categoryId: _isSavings ? null : _selectedCategoryId,
      savingsGoalId: _isSavings ? _selectedSavingsGoalId : null,
      amount: amount,
      monthYear: widget.monthYear,
    ));
    
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

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Presupuesto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Gasto (Categoría)')),
                ButtonSegment(value: true, label: Text('Ahorro (Meta)')),
              ],
              selected: {_isSavings},
              onSelectionChanged: (set) {
                setState(() {
                  _isSavings = set.first;
                });
              },
            ),
            const SizedBox(height: 24),
            
            if (!_isSavings)
              categoriesState.when(
                data: (cats) => DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                  value: _selectedCategoryId,
                  items: cats.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, st) => Text('Error: $e'),
              )
            else
              savingsState.when(
                data: (goals) => DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Meta de Ahorro', border: OutlineInputBorder()),
                  value: _selectedSavingsGoalId,
                  items: goals.map((g) => DropdownMenuItem(
                    value: g.id,
                    child: Text(g.name),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedSavingsGoalId = val),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, st) => Text('Error: $e'),
              ),
              
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Monto Límite', border: OutlineInputBorder()),
                  ),
                ),
                if (!_isSavings) ...[
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _suggestAmount,
                    icon: const Icon(Icons.lightbulb_outline),
                    tooltip: 'Sugerir basado en histórico',
                  )
                ]
              ],
            ),
            
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Guardar Presupuesto'),
            )
          ],
        ),
      ),
    );
  }
}
