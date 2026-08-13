import 'package:flutter/material.dart';
import '../../../accounts/domain/entities/account.dart';
import 'package:gestor_gastos/core/utils/icon_utils.dart';

class TransactionAccountTile extends StatelessWidget {
  final Account account;

  const TransactionAccountTile({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        IconUtils.getIcon(account.iconCode),
        color: Color(account.colorCode),
        size: 32,
      ),
      title: const Text('Cuenta'),
      subtitle: Text(
        account.name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
