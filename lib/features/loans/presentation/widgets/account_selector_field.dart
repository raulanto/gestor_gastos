import 'package:flutter/material.dart';
import 'package:gestor_gastos/features/accounts/domain/entities/account.dart';
import 'package:gestor_gastos/core/utils/icon_utils.dart';

class AccountSelectorField extends StatelessWidget {
  final int? selectedAccountId;
  final List<Account> accounts;
  final ValueChanged<int?> onChanged;

  const AccountSelectorField({
    super.key,
    required this.selectedAccountId,
    required this.accounts,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(
        labelText: 'Cuenta origen', 
        prefixIcon: Icon(Icons.account_balance_wallet),
        border: OutlineInputBorder()
      ),
      initialValue: selectedAccountId,
      items: accounts.map((a) => DropdownMenuItem(
        value: a.id,
        child: Row(
          children: [
            Icon(IconUtils.getIcon(a.iconCode), color: Color(a.colorCode)),
            const SizedBox(width: 8),
            Text(a.name),
          ],
        ),
      )).toList(),
      onChanged: onChanged,
    );
  }
}
