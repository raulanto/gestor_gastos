import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/presentation/providers/account_provider.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_provider.dart';
import '../widgets/custom_numeric_keyboard.dart';

import '../widgets/transaction_type_selector.dart';
import '../widgets/transaction_account_selector.dart';
import '../widgets/transaction_category_selector.dart';
import '../widgets/transaction_split_list.dart';
import '../widgets/transaction_date_selector.dart';
import '../widgets/transaction_note_image_input.dart';
import '../widgets/category_picker_sheet.dart';

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

  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      _transactionType = widget.initialType!;
    }
  }

  void _hydrateFromTransaction(TransactionEntity t) {
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
    _hydrated = true;
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
          final lastChar = _expression[_expression.length - 1];
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
    if (pickedFile == null || !mounted) return;

    final appDir = await getApplicationDocumentsDirectory();
    if (!mounted) return;

    final fileName = path.basename(pickedFile.path);
    final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
    if (!mounted) return;

    final previousImage = _receiptImage;

    setState(() => _receiptImage = savedImage);

    if (previousImage != null && previousImage.path != savedImage.path) {
      previousImage.delete().catchError((_) => previousImage);
    }
  }

  Future<void> _addSplitDialog() async {
    double amount = 0;
    Category? selectedCat;
    final categoriesState = ref.read(categoriesProvider);
    
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
                  if (categoriesState.value != null) {
                    showCategoryPickerSheet(
                      context: context,
                      categories: categoriesState.value!,
                      onSelected: (cat) {
                        setStateSB(() => selectedCat = cat);
                      },
                    );
                  }
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
      final totalSplits = _splits.fold<double>(0, (sum, item) => sum + item.amount);
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

    int? parsedId;
    if (widget.transactionId != null) {
      parsedId = int.tryParse(widget.transactionId!);
      if (parsedId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID de transacción inválido, no se puede guardar')),
        );
        return;
      }
    }

    final newTransaction = TransactionEntity(
      id: parsedId,
      accountId: _selectedAccountId!,
      categoryId: _isSplitMode ? null : _selectedCategoryId!,
      amount: amount,
      date: _selectedDate.toIso8601String(),
      note: _note,
      receiptImagePath: _receiptImage?.path,
      type: _transactionType,
      splits: _isSplitMode ? _splits : [],
    );

    if (parsedId == null) {
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

    if (widget.transactionId != null && !_hydrated) {
      final t = ref.watch(transactionByIdProvider(widget.transactionId!));
      if (t == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Editar Gasto')),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _hydrateFromTransaction(t));
      });
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Gasto')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    ref.listen<AsyncValue<List<Account>>>(accountsProvider, (previous, next) {
      next.whenData((accounts) {
        if (accounts.isNotEmpty && _selectedAccountId == null) {
          setState(() => _selectedAccountId = accounts.first.id);
        }
      });
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
                  TransactionTypeSelector(
                    transactionType: _transactionType,
                    onChanged: (val) => setState(() => _transactionType = val),
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
                    data: (accounts) => TransactionAccountSelector(
                      selectedAccountId: _selectedAccountId,
                      accounts: accounts,
                      onChanged: (val) => setState(() => _selectedAccountId = val),
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (e, st) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dividir Gasto (Splits)'),
                      Switch(
                        value: _isSplitMode,
                        onChanged: (val) => setState(() {
                          _isSplitMode = val;
                          if (!val) _splits.clear();
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (!_isSplitMode)
                    TransactionCategorySelector(
                      selectedCategory: selectedCategory,
                      categories: categoriesState.value,
                      onSelected: (cat) => setState(() => _selectedCategoryId = cat.id),
                    )
                  else
                    TransactionSplitList(
                      splits: _splits,
                      categories: categoriesState.value,
                      onAddSplit: _addSplitDialog,
                      onRemoveSplit: (s) => setState(() => _splits.remove(s)),
                    ),

                  const SizedBox(height: 16),
                  
                  TransactionDateSelector(
                    selectedDate: _selectedDate,
                    onChanged: (date) => setState(() => _selectedDate = date),
                  ),

                  const SizedBox(height: 16),

                  TransactionNoteImageInput(
                    noteController: _noteController,
                    onNoteChanged: (val) => _note = val,
                    receiptImage: _receiptImage,
                    onPickImage: _pickImage,
                    onClearImage: () {
                      final old = _receiptImage;
                      setState(() => _receiptImage = null);
                      old?.delete().catchError((_) => old);
                    },
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
