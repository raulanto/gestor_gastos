import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/account_provider.dart';

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsState = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Cuentas')),
      body: accountsState.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(child: Text('No hay cuentas configuradas.'));
          }
          return ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(account.colorCode).withValues(alpha: 0.2),
                  child: Icon(
                    // ignore: non_const_argument_for_const_parameter
                    IconData(account.iconCode, fontFamily: 'MaterialIcons'),
                    color: Color(account.colorCode),
                  ),
                ),
                title: Text(account.name),
                subtitle: Text('Saldo: \$${account.balance.toStringAsFixed(2)}'),
                trailing: const Icon(Icons.more_vert),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Añadir cuenta nueva
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
