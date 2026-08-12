import 'package:flutter/material.dart';
import '../../../accounts/domain/entities/account.dart';

class TransactionAccountTile extends StatelessWidget {
  final Account account;

  const TransactionAccountTile({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        IconData(account.iconCode, fontFamily: 'MaterialIcons'),
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
