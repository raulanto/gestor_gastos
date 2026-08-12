import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../../accounts/presentation/providers/account_provider.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_provider.dart';
import '../widgets/custom_numeric_keyboard.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  final String? transactionId;
  final String? initialType;

  const AddTransactionPage({super.key, this.transactionId, this.initialType});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  String _expression = '0';
  int? _selectedAccountId;
  int? _selectedCategoryId;
  String _note = '';
  File? _receiptImage;
  String _transactionType = 'expense';
  DateTime _selectedDate = DateTime.now();
  
  bool _isSplitMode = false;
  List<TransactionSplit> _splits = [];
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      _transactionType = widget.initialType!;
    }
    if (widget.transactionId != null) {
      final t = ref.read(transactionByIdProvider(widget.transactionId!));
      if (t != null) {
        _expression = t.amount.toStringAsFixed(2);
        if (_expression.endsWith('.00')) {
          _expression = _expression.substring(0, _expression.length - 3);
        }
        _selectedAccountId = t.accountId;
        _selectedCategoryId = t.categoryId;
        _note = t.note ?? '';
        _noteController.text = _note;
        _selectedDate = DateTime.parse(t.date);
        if (t.receiptImagePath != null) {
          _receiptImage = File(t.receiptImagePath!);
        }
        _transactionType = t.type;
        if (t.splits.length > 1) {
          _isSplitMode = true;
          _splits = List.from(t.splits);
        }
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onKeyPressed(String value) {
    setState(() {
      if (value == '⌫') {
        if (_expression.length > 1) {
          _expression = _expression.substring(0, _expression.length - 1);
        } else {
          _expression = '0';
        }
      } else if (value == '✓') {
        _saveTransaction();
      } else if (value == '=') {
        _evaluateExpression();
      } else {
        if (_expression == '0' && value != '.') {
          _expression = value;
        } else {
          final lastChar = _expression.characters.last;
          if ((value == '+' || value == '-' || value == '.') && 
              (lastChar == '+' || lastChar == '-' || lastChar == '.')) {
            return; 
          }
          _expression += value;
        }
      }
    });
  }

  void _evaluateExpression() {
    try {
      String exp = _expression.replaceAll(' ', '');
      List<String> numbers = exp.split(RegExp(r'[+-]'));
      List<String> operators = exp.split(RegExp(r'[0-9.]+')).where((e) => e.isNotEmpty).toList();

      if (numbers.isNotEmpty && numbers[0].isEmpty) {
         numbers.removeAt(0);
         numbers[0] = '-${numbers[0]}';
         operators.removeAt(0);
      }

      double result = double.parse(numbers[0]);
      for (int i = 0; i < operators.length; i++) {
        double nextNum = double.parse(numbers[i + 1]);
        if (operators[i] == '+') {
          result += nextNum;
        } else if (operators[i] == '-') {
          result -= nextNum;
        }
      }
      
      _expression = result.toStringAsFixed(2);
      if (_expression.endsWith('.00')) {
        _expression = _expression.substring(0, _expression.length - 3);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error en la expresión matemática')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedFile.path);
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
      
      setState(() {
        _receiptImage = savedImage;
      });
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
                    _splits.add(TransactionSplit(categoryId: selectedCat!.id, amount: amount));
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

  Future<void> _saveTransaction() async {
    _evaluateExpression(); 
    final amount = double.tryParse(_expression);
    
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

    final newTransaction = TransactionEntity(
      id: widget.transactionId != null ? int.tryParse(widget.transactionId!) : null,
      accountId: _selectedAccountId!,
      categoryId: _isSplitMode ? null : _selectedCategoryId!,
      amount: amount,
      date: _selectedDate.toIso8601String(),
      note: _note,
      receiptImagePath: _receiptImage?.path,
      type: _transactionType,
      splits: _isSplitMode ? _splits : [],
    );

    if (widget.transactionId == null) {
      await ref.read(transactionsProvider.notifier).addTransaction(newTransaction);
    } else {
      await ref.read(transactionsProvider.notifier).updateTransaction(newTransaction);
    }
    
    ref.invalidate(accountsProvider);
    
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsState = ref.watch(accountsProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

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
      appBar: AppBar(
        title: Text(widget.transactionId == null ? 'Añadir Gasto' : 'Editar Gasto'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'expense', label: Text('Gasto')),
                      ButtonSegment(value: 'income', label: Text('Ingreso')),
                      ButtonSegment(value: 'transfer', label: Text('Transferencia')),
                    ],
                    selected: {_transactionType},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _transactionType = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  Center(
                    child: Text(
                      '\$$_expression',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: _transactionType == 'expense' ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  accountsState.when(
                    data: (accounts) => DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Cuenta', border: OutlineInputBorder()),
                      // ignore: deprecated_member_use
                      value: _selectedAccountId,
                      items: accounts.map((a) => DropdownMenuItem(
                        value: a.id,
                        child: Row(
                          children: [
                            // ignore: non_const_argument_for_const_parameter
                            Icon(IconData(a.iconCode, fontFamily: 'MaterialIcons'), color: Color(a.colorCode)),
                            const SizedBox(width: 8),
                            Text(a.name),
                          ],
                        ),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedAccountId = val),
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (e, st) => Text('Error: \$e'),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dividir Gasto (Splits)'),
                      Switch(
                        value: _isSplitMode,
                        onChanged: (val) {
                          setState(() {
                            _isSplitMode = val;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

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
                              Icon(IconData(selectedCategory.iconCode, fontFamily: 'MaterialIcons'), color: Color(selectedCategory.colorCode)),
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
                              leading: cat != null ? Icon(IconData(cat.iconCode, fontFamily: 'MaterialIcons'), color: Color(cat.colorCode)) : const Icon(Icons.category),
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
                  
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Fecha', border: OutlineInputBorder()),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Text("${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}"),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _noteController,
                          decoration: const InputDecoration(
                            labelText: 'Nota (opcional)',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) => _note = val,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        icon: Icon(_receiptImage != null ? Icons.image : Icons.camera_alt),
                        onPressed: _pickImage,
                      ),
                      if (_receiptImage != null)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _receiptImage = null;
                            });
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          CustomNumericKeyboard(
            onKeyPressed: _onKeyPressed,
          ),
        ],
      ),
    );
  }
}
