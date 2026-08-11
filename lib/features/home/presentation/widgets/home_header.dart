import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/date_filter_provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class HomeHeader extends ConsumerWidget {
  final double totalBalance;

  const HomeHeader({super.key, required this.totalBalance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final user = ref.watch(authNotifierProvider).value;

    String monthStr = DateFormat('MMMM yyyy').format(selectedMonth);
    monthStr = monthStr[0].toUpperCase() + monthStr.substring(1);

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.onPrimary, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.person,
                        size: 24,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenido de vuelta,',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                      Text(
                        user?.username ?? 'Usuario',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: theme.colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      ref
                          .read(selectedMonthProvider.notifier)
                          .updateMonth(
                            DateTime(
                              selectedMonth.year,
                              selectedMonth.month - 1,
                            ),
                          );
                    },
                  ),
                  Text(
                    monthStr,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      ref
                          .read(selectedMonthProvider.notifier)
                          .updateMonth(
                            DateTime(
                              selectedMonth.year,
                              selectedMonth.month + 1,
                            ),
                          );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Balance General',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
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
