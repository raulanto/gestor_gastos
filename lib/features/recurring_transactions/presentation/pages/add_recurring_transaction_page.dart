import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../features/accounts/presentation/providers/account_provider.dart';
import '../../../../features/categories/domain/entities/category.dart';
import '../../../../features/categories/presentation/providers/category_provider.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../providers/recurring_transaction_provider.dart';
import 'package:gestor_gastos/core/utils/icon_utils.dart';

const periodicityMap = {
  'daily': 'Diario',
  'weekly': 'Semanal',
  'biweekly': 'Quincenal',
  'monthly': 'Mensual',
  'yearly': 'Anual',
};

class AddRecurringTransactionPage extends ConsumerStatefulWidget {
  final String? transactionId;

  const AddRecurringTransactionPage({super.key, this.transactionId});

  @override
  ConsumerState<AddRecurringTransactionPage> createState() => _AddRecurringTransactionPageState();
}

class _AddRecurringTransactionPageState extends ConsumerState<AddRecurringTransactionPage> {
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  
  int? _selectedAccountId;
  int? _selectedCategoryId;
  String _transactionType = 'expense';
  String _periodicity = 'monthly';
  DateTime _nextExecutionDate = DateTime.now();

  bool _isSplitMode = false;
  final List<RecurringTransactionSplit> _splits = [];

  final List<String> _periodicities = ['daily', 'weekly', 'biweekly', 'monthly', 'yearly'];

  @override
  void initState() {
    super.initState();
    if (widget.transactionId != null) {
      final t = ref.read(recurringTransactionByIdProvider(widget.transactionId!));
      if (t != null) {
        _amountController.text = t.amount.toString();
        _nameController.text = t.name ?? '';
        _noteController.text = t.note ?? '';
        _selectedAccountId = t.accountId;
        _selectedCategoryId = t.categoryId;
        _transactionType = t.type;
        _periodicity = t.periodicity;
        _nextExecutionDate = DateTime.parse(t.nextExecutionDate);
        if (t.splits.isNotEmpty) {
          bool isSingle = t.categoryId != null && 
                          t.splits.length == 1 && 
                          t.splits.first.amount == t.amount;
          
          if (!isSingle) {
            _isSplitMode = true;
            _splits.addAll(t.splits);
          }
        }
      }
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
                          leading: Icon(IconUtils.getIcon(main.iconCode), color: Color(main.colorCode)),
                          title: Text(main.name),
                          onTap: () {
                            onSelected(main);
                            Navigator.pop(context);
                          },
                        );
                      }
                      return ExpansionTile(
                        // ignore: non_const_argument_for_const_parameter
                        leading: Icon(IconUtils.getIcon(main.iconCode), color: Color(main.colorCode)),
                        title: Text(main.name),
                        children: children.map((child) => ListTile(
                          contentPadding: const EdgeInsets.only(left: 72.0, right: 16.0),
                          // ignore: non_const_argument_for_const_parameter
                          leading: Icon(IconUtils.getIcon(child.iconCode), color: Color(child.colorCode)),
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

  Future<void> _addSplitDialog() async {
    double amount = 0;
    Category? selectedCat;
    await showDialog(context: context, builder: (ctx) {
      return StatefulBuilder(builder: (context, setStateSB) {
        return AlertDialog(
          title: const Text('Añadir División'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Monto'),
                onChanged: (val) => amount = double.tryParse(val) ?? 0,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  _selectCategory(context, (cat) {
                    setStateSB(() => selectedCat = cat);
                  });
                },
                child: Text(selectedCat == null ? 'Seleccionar Categoría' : selectedCat!.name),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedCat != null && amount > 0) {
                  setState(() {
                    _splits.add(RecurringTransactionSplit(categoryId: selectedCat!.id, amount: amount));
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Añadir')
            )
          ]
        );
      });
    });
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingrese un monto válido')));
      return;
    }
    
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione una cuenta')));
      return;
    }

    if (_isSplitMode) {
      if (_splits.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Añada al menos una división')));
        return;
      }
      double totalSplits = _splits.fold(0, (sum, item) => sum + item.amount);
      if ((totalSplits - amount).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('La suma de las divisiones (\$${totalSplits.toStringAsFixed(2)}) no coincide con el total (\$${amount.toStringAsFixed(2)})'))
        );
        return;
      }
    } else {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione una categoría')));
        return;
      }
    }

    if (widget.transactionId != null) {
      final t = ref.read(recurringTransactionByIdProvider(widget.transactionId!));
      final updatedRt = RecurringTransactionEntity(
        id: int.tryParse(widget.transactionId!),
        amount: amount,
        accountId: _selectedAccountId!,
        categoryId: _isSplitMode ? null : _selectedCategoryId!,
        name: _nameController.text.isNotEmpty ? _nameController.text : null,
        note: _noteController.text,
        type: _transactionType,
        periodicity: _periodicity,
        nextExecutionDate: _nextExecutionDate.toIso8601String(),
        splits: _isSplitMode ? _splits : [],
        status: t?.status ?? 'active',
      );
      await ref.read(recurringTransactionsProvider.notifier).updateRecurringTransaction(updatedRt);
    } else {
      final rt = RecurringTransactionEntity(
        amount: amount,
        accountId: _selectedAccountId!,
        categoryId: _isSplitMode ? null : _selectedCategoryId!,
        name: _nameController.text.isNotEmpty ? _nameController.text : null,
        note: _noteController.text,
        type: _transactionType,
        periodicity: _periodicity,
        nextExecutionDate: _nextExecutionDate.toIso8601String(),
        splits: _isSplitMode ? _splits : [],
      );
      await ref.read(recurringTransactionsProvider.notifier).add(rt);
    }
    
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsState = ref.watch(accountsProvider);
    final categoriesState = ref.watch(categoriesProvider);

    accountsState.whenData((accounts) {
      if (accounts.isNotEmpty && _selectedAccountId == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _selectedAccountId = accounts.first.id);
        });
      }
    });

    Category? selectedCategory;
    if (_selectedCategoryId != null && categoriesState.value != null) {
      selectedCategory = categoriesState.value!.where((c) => c.id == _selectedCategoryId).firstOrNull;
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.transactionId != null ? 'Editar Gasto Recurrente' : 'Nuevo Gasto Recurrente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Gasto')),
                ButtonSegment(value: 'income', label: Text('Ingreso')),
              ],
              selected: {_transactionType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _transactionType = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre del Gasto (Ej: Netflix, Internet)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Monto Total', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _periodicity,
              decoration: const InputDecoration(labelText: 'Frecuencia', border: OutlineInputBorder()),
              items: _periodicities.map((p) => DropdownMenuItem(value: p, child: Text(periodicityMap[p] ?? p))).toList(),
              onChanged: (val) => setState(() => _periodicity = val!),
            ),
            const SizedBox(height: 16),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha de Próximo Cobro'),
              subtitle: Text(DateFormat.yMMMd().format(_nextExecutionDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _nextExecutionDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                );
                if (date != null) {
                  setState(() => _nextExecutionDate = date);
                }
              },
            ),
            const SizedBox(height: 16),

            accountsState.when(
              data: (accounts) => DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Cuenta', border: OutlineInputBorder()),
                initialValue: _selectedAccountId,
                items: accounts.map((a) => DropdownMenuItem(
                  value: a.id,
                  child: Row(
                    children: [
                      // ignore: non_const_argument_for_const_parameter
                      Icon(IconUtils.getIcon(a.iconCode), color: Color(a.colorCode)),
                      const SizedBox(width: 8),
                      Text(a.name),
                    ],
                  ),
                )).toList(),
                onChanged: (val) => setState(() => _selectedAccountId = val),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Error: $e'),
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dividir (Splits)'),
                Switch(
                  value: _isSplitMode,
                  onChanged: (val) => setState(() => _isSplitMode = val),
                ),
              ],
            ),
            
            if (!_isSplitMode)
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
                        Icon(IconUtils.getIcon(selectedCategory.iconCode), color: Color(selectedCategory.colorCode)),
                      const SizedBox(width: 8),
                      Text(selectedCategory != null ? selectedCategory.name : 'Seleccionar Categoría'),
                    ],
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_splits.isNotEmpty)
                    ..._splits.map((s) {
                      final cat = categoriesState.value?.where((c) => c.id == s.categoryId).firstOrNull;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        // ignore: non_const_argument_for_const_parameter
                        leading: cat != null ? Icon(IconUtils.getIcon(cat.iconCode), color: Color(cat.colorCode)) : const Icon(Icons.category),
                        title: Text(cat?.name ?? 'Desconocida'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('\$${s.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _splits.remove(s);
                                });
                              },
                            )
                          ],
                        ),
                      );
                    }),
                  OutlinedButton.icon(
                    onPressed: _addSplitDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Añadir División'),
                  )
                ],
              ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Nota (Opcional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: _save,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
