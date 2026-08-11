import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsUserProfile extends ConsumerWidget {
  const SettingsUserProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).value;
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.onPrimary, width: 3),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
              child: Icon(
                Icons.person,
                size: 40,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.username ?? 'Usuario',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          Text(
            'Gestor de Gastos',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
