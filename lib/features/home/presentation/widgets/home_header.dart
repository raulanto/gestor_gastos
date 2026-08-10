import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final double totalBalance;

  const HomeHeader({super.key, required this.totalBalance});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                    child: Icon(Icons.person, size: 16, color: theme.colorScheme.onPrimary),
                  ),
                  const SizedBox(width: 8),
                  Text('Gestor de Gastos', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                ],
              ),
              Icon(Icons.search, color: theme.colorScheme.onPrimary),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Balance General',
            style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onPrimary.withValues(alpha: 0.8)),
          ),
          Text(
            '\$${totalBalance.toStringAsFixed(2)}',
            style: theme.textTheme.displayLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
