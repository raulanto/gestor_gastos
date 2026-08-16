import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoansHeader extends StatelessWidget {
  const LoansHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Préstamos',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.onPrimary.withValues(
                alpha: 0.15,
              ),
            ),
            icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
            onPressed: () => context.push('/add_loan'),
          ),
        ],
      ),
    );
  }
}
