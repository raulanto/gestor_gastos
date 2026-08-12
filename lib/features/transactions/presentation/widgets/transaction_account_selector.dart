import 'package:flutter/material.dart';
import '../../../accounts/domain/entities/account.dart';

class TransactionAccountSelector extends StatelessWidget {
  final int? selectedAccountId;
  final List<Account> accounts;
  final ValueChanged<int?> onChanged;

  const TransactionAccountSelector({
    super.key,
    required this.selectedAccountId,
    required this.accounts,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(labelText: 'Cuenta', border: OutlineInputBorder()),
      value: selectedAccountId,
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
      onChanged: onChanged,
    );
  }
}
