import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/recurring_transactions/application/recurring_service.dart';
import '../../../features/savings/application/savings_schedule_service.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recurringServiceProvider).checkAndExecuteRecurring();
      ref
          .read(savingsScheduleServiceProvider)
          .checkAndExecuteScheduledSavings();
    });
  }

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: widget.navigationShell,
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, Icons.home_outlined, 'Inicio', 0),
              _buildNavItem(Icons.autorenew, Icons.autorenew_outlined, 'Recurrentes', 1),
              _buildNavItem(Icons.handshake, Icons.handshake_outlined, 'Préstamos', 4),
              _buildNavItem(Icons.savings, Icons.savings_outlined, 'Ahorros', 2),
              _buildNavItem(Icons.pie_chart, Icons.pie_chart_outline, 'Presupuestos', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData selectedIcon,
    IconData unselectedIcon,
    String label,
    int index,
  ) {
    final isSelected = widget.navigationShell.currentIndex == index;
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.onSurface;
    final unselectedColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: () => _goBranch(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutQuint,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? selectedColor : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isSelected ? selectedIcon : unselectedIcon,
              size: 26,
              color: isSelected ? theme.colorScheme.surface : unselectedColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isSelected ? selectedColor : unselectedColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
