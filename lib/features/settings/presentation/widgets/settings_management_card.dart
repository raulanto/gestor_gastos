import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'settings_tile.dart';

class SettingsManagementCard extends StatelessWidget {
  const SettingsManagementCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestión',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              SettingsTile(
                icon: Icons.account_balance_wallet,
                title: 'Mis Cuentas',
                subtitle: 'Administrar cuentas de efectivo, bancos...',
                onTap: () => context.push('/accounts'),
              ),
              SettingsTile(
                icon: Icons.category,
                title: 'Mis Categorías',
                subtitle: 'Administrar categorías de gastos',
                onTap: () => context.push('/categories'),
              ),
              SettingsTile(
                icon: Icons.notifications,
                title: 'Notificaciones',
                subtitle: 'Configurar alertas y recordatorios',
                onTap: () => context.push('/notification_settings'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
