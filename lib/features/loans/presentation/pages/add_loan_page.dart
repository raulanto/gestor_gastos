import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../accounts/presentation/providers/account_provider.dart';
import '../../../persons/domain/entities/person.dart';
import '../../domain/entities/loan.dart';
import '../providers/loans_provider.dart';
import '../widgets/person_selector_field.dart';
import '../widgets/amount_input_field.dart';
import '../widgets/account_selector_field.dart';
import '../widgets/loan_type_selector_field.dart';
import '../widgets/due_date_selector_field.dart';

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
                PersonSelectorField(
                  selectedPerson: _selectedPerson,
                  onChanged: (person) => setState(() => _selectedPerson = person),
                ),
                const SizedBox(height: 16),
                AmountInputField(
                  onSaved: (v) => _amount = double.parse(v!),
                ),
                const SizedBox(height: 16),
                AccountSelectorField(
                  selectedAccountId: _selectedAccountId,
                  accounts: accounts,
                  onChanged: (v) => setState(() => _selectedAccountId = v),
                ),
                const SizedBox(height: 16),
                LoanTypeSelectorField(
                  type: _type,
                  onChanged: (v) => setState(() => _type = v!),
                ),
                const SizedBox(height: 16),
                DueDateSelectorField(
                  dueDate: _dueDate,
                  onChanged: (date) => setState(() => _dueDate = date),
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
