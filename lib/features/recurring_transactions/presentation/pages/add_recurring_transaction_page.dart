import 'package:gestor_gastos/core/utils/currency_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../features/accounts/presentation/providers/account_provider.dart';
import '../../../../features/categories/domain/entities/category.dart';
import '../../../../features/categories/presentation/providers/category_provider.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../providers/recurring_transaction_provider.dart';
import 'package:gestor_gastos/core/utils/icon_utils.dart';

import '../../../../features/transactions/presentation/widgets/custom_numeric_keyboard.dart';
import '../../../../features/transactions/presentation/widgets/transaction_type_selector.dart';
import '../../../../features/transactions/presentation/widgets/transaction_account_selector.dart';
import '../../../../features/transactions/presentation/widgets/transaction_category_selector.dart';
import '../../../../features/transactions/presentation/widgets/category_picker_sheet.dart';

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
  ConsumerState<AddRecurringTransactionPage> createState() =>
      _AddRecurringTransactionPageState();
}

class _AddRecurringTransactionPageState
    extends ConsumerState<AddRecurringTransactionPage> {
  String _expression = '0';
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();

  int? _selectedAccountId;
  int? _selectedCategoryId;
  String _transactionType = 'expense';
  String _periodicity = 'monthly';
  DateTime _nextExecutionDate = DateTime.now();

  bool _isSplitMode = false;
  final List<RecurringTransactionSplit> _splits = [];

  final List<String> _periodicities = [
    'daily',
    'weekly',
    'biweekly',
    'monthly',
    'yearly',
  ];

  bool _hydrated = false;
  bool _showKeyboard = false;

  @override
  void initState() {
    super.initState();
    _showKeyboard = widget.transactionId == null;
  }

  void _hydrateFromTransaction(RecurringTransactionEntity t) {
    _expression = t.amount.toStringAsFixed(2);
    if (_expression.endsWith('.00')) {
      _expression = _expression.substring(0, _expression.length - 3);
    }
    _nameController.text = t.name ?? '';
    _noteController.text = t.note ?? '';
    _selectedAccountId = t.accountId;
    _selectedCategoryId = t.categoryId;
    _transactionType = t.type;
    _periodicity = t.periodicity;
    _nextExecutionDate = DateTime.parse(t.nextExecutionDate);
    if (t.splits.isNotEmpty) {
      bool isSingle =
          t.categoryId != null &&
          t.splits.length == 1 &&
          t.splits.first.amount == t.amount;

      if (!isSingle) {
        _isSplitMode = true;
        _splits.addAll(t.splits);
      }
    }
    _hydrated = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
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
        _save();
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
      List<String> operators = exp
          .split(RegExp(r'[0-9.]+'))
          .where((e) => e.isNotEmpty)
          .toList();

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

  Future<void> _addSplitDialog() async {
    double amount = 0;
    Category? selectedCat;
    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: const Text('Añadir División'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Monto'),
                    onChanged: (val) => amount = double.tryParse(val) ?? 0,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () async {
                      await showCategoryPickerSheet(
                        context: context,
                        categories: ref.read(categoriesProvider).value ?? [],
                        onSelected: (cat) {
                          setStateSB(() => selectedCat = cat);
                        },
                      );
                    },
                    child: Text(
                      selectedCat == null
                          ? 'Seleccionar Categoría'
                          : selectedCat!.name,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedCat != null && amount > 0) {
                      setState(() {
                        _splits.add(
                          RecurringTransactionSplit(
                            categoryId: selectedCat!.id,
                            amount: amount,
                          ),
                        );
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Añadir'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _save() async {
    _evaluateExpression();
    final amount = double.tryParse(_expression);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingrese un monto válido')));
      return;
    }

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleccione una cuenta')));
      return;
    }

    if (_isSplitMode) {
      if (_splits.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Añada al menos una división')),
        );
        return;
      }
      double totalSplits = _splits.fold(0, (sum, item) => sum + item.amount);
      if ((totalSplits - amount).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'La suma de las divisiones (${CurrencyUtils.formatAmount(totalSplits)}) no coincide con el total (${CurrencyUtils.formatAmount(amount)})',
            ),
          ),
        );
        return;
      }
    } else {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione una categoría')),
        );
        return;
      }
    }

    if (widget.transactionId != null) {
      final t = ref.read(
        recurringTransactionByIdProvider(widget.transactionId!),
      );
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
      await ref
          .read(recurringTransactionsProvider.notifier)
          .updateRecurringTransaction(updatedRt);
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
    final theme = Theme.of(context);

    if (widget.transactionId != null && !_hydrated) {
      final t = ref.watch(
        recurringTransactionByIdProvider(widget.transactionId!),
      );
      if (t == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Editar Recurrente')),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _hydrateFromTransaction(t));
      });
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Recurrente')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
            height: 350,
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
                        widget.transactionId == null
                            ? 'Nuevo Recurrente'
                            : 'Editar Recurrente',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: MediaQuery.of(context).viewInsets.bottom == 0
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 16.0,
                          ),
                          child: Column(
                            children: [
                              TransactionTypeSelector(
                                transactionType: _transactionType,
                                onChanged: (val) =>
                                    setState(() => _transactionType = val),
                              ),
                              const SizedBox(height: 24),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _showKeyboard = true),
                                child: Text(
                                  '\$$_expression',
                                  style: theme.textTheme.displayLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_showKeyboard) {
                                setState(() => _showKeyboard = false);
                              }
                            },
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText:
                                          'Nombre del Gasto (Ej: Netflix)',
                                      prefixIcon: Icon(Icons.title),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  DropdownButtonFormField<String>(
                                    initialValue: _periodicity,
                                    decoration: const InputDecoration(
                                      labelText: 'Frecuencia',
                                      prefixIcon: Icon(Icons.repeat),
                                    ),
                                    items: _periodicities
                                        .map(
                                          (p) => DropdownMenuItem(
                                            value: p,
                                            child: Text(periodicityMap[p] ?? p),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) =>
                                        setState(() => _periodicity = val!),
                                  ),
                                  const SizedBox(height: 16),

                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text(
                                      'Fecha de Próximo Cobro',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      DateFormat.yMMMd().format(
                                        _nextExecutionDate,
                                      ),
                                    ),
                                    trailing: const Icon(Icons.calendar_today),
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: _nextExecutionDate,
                                        firstDate: DateTime.now().subtract(
                                          const Duration(days: 365),
                                        ),
                                        lastDate: DateTime.now().add(
                                          const Duration(days: 365 * 10),
                                        ),
                                      );
                                      if (date != null) {
                                        setState(
                                          () => _nextExecutionDate = date,
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  accountsState.when(
                                    data: (accounts) =>
                                        TransactionAccountSelector(
                                          selectedAccountId: _selectedAccountId,
                                          accounts: accounts,
                                          onChanged: (val) => setState(
                                            () => _selectedAccountId = val,
                                          ),
                                        ),
                                    loading: () =>
                                        const CircularProgressIndicator(),
                                    error: (e, st) => Text('Error: $e'),
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Dividir Gasto (Splits)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
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
                                      onSelected: (cat) => setState(
                                        () => _selectedCategoryId = cat.id,
                                      ),
                                    )
                                  else
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        if (_splits.isNotEmpty)
                                          ..._splits.map((s) {
                                            final cat = categoriesState.value
                                                ?.where(
                                                  (c) => c.id == s.categoryId,
                                                )
                                                .firstOrNull;
                                            return ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: cat != null
                                                  ? Icon(
                                                      IconUtils.getIcon(
                                                        cat.iconCode,
                                                      ),
                                                      color: Color(
                                                        cat.colorCode,
                                                      ),
                                                    )
                                                  : const Icon(Icons.category),
                                              title: Text(
                                                cat?.name ?? 'Desconocida',
                                              ),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    CurrencyUtils.formatAmount(
                                                      s.amount,
                                                    ),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _splits.remove(s);
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        OutlinedButton.icon(
                                          onPressed: _addSplitDialog,
                                          icon: const Icon(Icons.add),
                                          label: const Text('Añadir División'),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 16),

                                  TextField(
                                    controller: _noteController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nota (Opcional)',
                                      prefixIcon: Icon(Icons.note),
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  FilledButton(
                                    onPressed: _save,
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'Guardar',
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
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child:
                              (_showKeyboard &&
                                  MediaQuery.of(context).viewInsets.bottom == 0)
                              ? CustomNumericKeyboard(
                                  onKeyPressed: _onKeyPressed,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
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
