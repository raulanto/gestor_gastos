import 'dart:io';
import 'package:gestor_gastos/core/utils/currency_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/date_filter_provider.dart';
import '../providers/period_view_provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class HomeHeader extends ConsumerWidget {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final bool isMinimized;
  final VoidCallback onToggleMinimize;

  const HomeHeader({
    super.key,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.isMinimized,
    required this.onToggleMinimize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final periodView = ref.watch(periodViewProvider);
    final user = ref.watch(authNotifierProvider).value;

    // "Hoy" y "Semana" siempre apuntan al día/semana real, así que navegar
    // de mes no tiene efecto en esas vistas.
    final monthNavEnabled =
        periodView == PeriodView.month || periodView == PeriodView.year;

    String monthStr = DateFormat('MMMM yyyy').format(selectedMonth);
    monthStr = monthStr[0].toUpperCase() + monthStr.substring(1);

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 16),
      child: Column(
        children: [
          // Sección superior animada (se oculta al minimizar)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isMinimized
                ? const SizedBox.shrink()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.go('/settings');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.onPrimary,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: theme.colorScheme.onPrimary
                                    .withValues(alpha: 0.2),
                                backgroundImage: user?.photoPath != null
                                    ? FileImage(File(user!.photoPath!))
                                    : null,
                                child: user?.photoPath == null
                                    ? Icon(
                                        Icons.person,
                                        size: 24,
                                        color: theme.colorScheme.onPrimary,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bienvenido,',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimary.withValues(
                                    alpha: 0.8,
                                  ),
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
                              color: theme.colorScheme.onPrimary.withValues(
                                alpha: monthNavEnabled ? 1.0 : 0.3,
                              ),
                            ),
                            onPressed: !monthNavEnabled
                                ? null
                                : () {
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
                              color: theme.colorScheme.onPrimary.withValues(
                                alpha: monthNavEnabled ? 1.0 : 0.3,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.chevron_right,
                              color: theme.colorScheme.onPrimary.withValues(
                                alpha: monthNavEnabled ? 1.0 : 0.3,
                              ),
                            ),
                            onPressed: !monthNavEnabled
                                ? null
                                : () {
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
          ),
          SizedBox(height: isMinimized ? 0 : 24),
          // Sección de balance
          GestureDetector(
            onTap: onToggleMinimize,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.center,
              padding: isMinimized
                  ? const EdgeInsets.all(16.0)
                  : EdgeInsets.zero,
              child: Column(
                children: [
                  Text(
                    'Balance General',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyUtils.formatAmount(totalBalance),
                    style:
                        (isMinimized
                                ? theme.textTheme.displayLarge
                                : theme.textTheme.displayLarge)
                            ?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: isMinimized ? 48 : null,
                            ),
                  ),
                  // Indicadores minimalistas (solo visibles al minimizar)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: isMinimized
                        ? Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildMinimalistIndicator(
                                  context,
                                  Icons.arrow_upward_rounded,
                                  theme.colorScheme.tertiary,
                                  totalIncome,
                                ),
                                const SizedBox(width: 32),
                                _buildMinimalistIndicator(
                                  context,
                                  Icons.arrow_downward_rounded,
                                  theme.colorScheme.error,
                                  totalExpense,
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalistIndicator(
    BuildContext context,
    IconData icon,
    Color color,
    double amount,
  ) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          CurrencyUtils.formatAmount(amount),
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
