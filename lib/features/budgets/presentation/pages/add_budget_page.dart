import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/budget.dart';
import '../providers/budgets_provider.dart';
import '../../../categories/domain/entities/category.dart';
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

  Future<void> _selectCategory(BuildContext context, Function(Category) onSelected) async {
    final categoriesState = ref.read(categoriesProvider);
    if (categoriesState.value == null) return;
    
    final categories = categoriesState.value!;
    final mainCategories = categories.where((c) => c.parentId == null).toList();
    final subCategories = categories.where((c) => c.parentId != null).toList();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Seleccionar Categoría', style: Theme.of(context).textTheme.titleLarge),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: mainCategories.length,
                    itemBuilder: (context, index) {
                      final main = mainCategories[index];
                      final children = subCategories.where((c) => c.parentId == main.id).toList();

                      if (children.isEmpty) {
                        return ListTile(
                          // ignore: non_const_argument_for_const_parameter
                          leading: Icon(IconData(main.iconCode, fontFamily: 'MaterialIcons'), color: Color(main.colorCode)),
                          title: Text(main.name),
                          onTap: () {
                            onSelected(main);
                            Navigator.pop(context);
                          },
                        );
                      }
                      return ExpansionTile(
                        // ignore: non_const_argument_for_const_parameter
                        leading: Icon(IconData(main.iconCode, fontFamily: 'MaterialIcons'), color: Color(main.colorCode)),
                        title: Text(main.name),
                        children: children.map((child) => ListTile(
                          contentPadding: const EdgeInsets.only(left: 72.0, right: 16.0),
                          // ignore: non_const_argument_for_const_parameter
                          leading: Icon(IconData(child.iconCode, fontFamily: 'MaterialIcons'), color: Color(child.colorCode)),
                          title: Text(child.name),
                          onTap: () {
                            onSelected(child);
                            Navigator.pop(context);
                          },
                        )).toList(),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesProvider);
    final savingsState = ref.watch(savingsGoalsProvider);

    Category? selectedCategory;
    if (_selectedCategoryId != null && categoriesState.value != null) {
      selectedCategory = categoriesState.value!.where((c) => c.id == _selectedCategoryId).firstOrNull;
    }

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
              InkWell(
                onTap: () {
                  _selectCategory(context, (cat) {
                    setState(() => _selectedCategoryId = cat.id);
                  });
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                  child: Row(
                    children: [
                      if (selectedCategory != null)
                        // ignore: non_const_argument_for_const_parameter
                        Icon(IconData(selectedCategory.iconCode, fontFamily: 'MaterialIcons'), color: Color(selectedCategory.colorCode)),
                      const SizedBox(width: 8),
                      Text(selectedCategory != null ? selectedCategory.name : 'Seleccionar Categoría'),
                    ],
                  ),
                ),
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
