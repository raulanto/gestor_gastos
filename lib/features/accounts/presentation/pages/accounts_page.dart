import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/account_provider.dart';
import '../widgets/add_edit_account_dialog.dart';

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
                    IconData(account.iconCode, fontFamily: 'MaterialIcons'),
                    color: Color(account.colorCode),
                  ),
                ),
                title: Text(account.name),
                subtitle: Text('Saldo: \$${account.balance.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AddEditAccountDialog(account: account),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        ref.read(accountsProvider.notifier).deleteAccount(account.id);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  context.push('/account_details', extra: account);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddEditAccountDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
