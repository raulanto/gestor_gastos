import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../accounts/presentation/providers/account_provider.dart';
import '../../../persons/domain/entities/person.dart';
import '../../domain/entities/loan.dart';
import '../providers/loans_provider.dart';

class AddLoanPage extends ConsumerStatefulWidget {
  const AddLoanPage({super.key});

  @override
  ConsumerState<AddLoanPage> createState() => _AddLoanPageState();
}

class _AddLoanPageState extends ConsumerState<AddLoanPage> {
  final _formKey = GlobalKey<FormState>();
  PersonEntity? _selectedPerson;
  double _amount = 0.0;
  int? _selectedAccountId;
  String _type = 'efectivo';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Préstamo')),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(child: Text('Crea una cuenta primero.'));
          }
          _selectedAccountId ??= accounts.first.id;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                InkWell(
                  onTap: () async {
                    final person = await context.push<PersonEntity?>('/persons?select=true');
                    if (person != null) {
                      setState(() {
                        _selectedPerson = person;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Persona (Requerido)',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline),
                        const SizedBox(width: 8),
                        Text(_selectedPerson?.name ?? 'Seleccionar persona'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Monto', 
                    prefixIcon: Icon(Icons.attach_money), 
                    border: OutlineInputBorder()
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (double.tryParse(v) == null) return 'Monto inválido';
                    return null;
                  },
                  onSaved: (v) => _amount = double.parse(v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Cuenta origen', 
                    prefixIcon: Icon(Icons.account_balance_wallet),
                    border: OutlineInputBorder()
                  ),
                  value: _selectedAccountId,
                  items: accounts.map((a) => DropdownMenuItem(
                    value: a.id,
                    child: Row(
                      children: [
                        Icon(IconData(a.iconCode, fontFamily: 'MaterialIcons'), color: Color(a.colorCode)),
                        const SizedBox(width: 8),
                        Text(a.name),
                      ],
                    ),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedAccountId = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Tipo', 
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder()
                  ),
                  value: _type,
                  items: const [
                    DropdownMenuItem(
                      value: 'efectivo', 
                      child: Row(
                        children: [
                          Icon(Icons.money, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Efectivo'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'tarjeta', 
                      child: Row(
                        children: [
                          Icon(Icons.credit_card, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Tarjeta'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _type = v!),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      setState(() => _dueDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de pago',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(DateFormat('dd/MM/yyyy').format(_dueDate)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Guardar Préstamo'),
                )
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedPerson != null) {
      _formKey.currentState!.save();
      final loan = LoanEntity(
        personId: _selectedPerson!.id,
        personName: _selectedPerson!.name,
        type: _type,
        amount: _amount,
        accountId: _selectedAccountId!,
        date: DateTime.now().toIso8601String(),
        dueDate: _dueDate.toIso8601String(),
      );
      ref.read(loansProvider.notifier).createLoan(loan);
      context.pop();
    }
  }
}
