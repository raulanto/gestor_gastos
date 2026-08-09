import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.username ?? 'Usuario'),
            accountEmail: const Text('Gestor de Gastos'),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Mis Cuentas'),
            subtitle: const Text('Administrar cuentas de efectivo, bancos...'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/accounts');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Mis Categorías'),
            subtitle: const Text('Administrar categorías de gastos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/categories');
            },
          ),
        ],
      ),
    );
  }
}
