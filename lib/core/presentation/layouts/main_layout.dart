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
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildNavItem(Icons.home, Icons.home_outlined, 0),
                    const SizedBox(width: 4),
                    _buildNavItem(Icons.autorenew, Icons.autorenew_outlined, 1),
                    const SizedBox(width: 4),
                    _buildNavItem(Icons.handshake, Icons.handshake_outlined, 4),
                    const SizedBox(width: 4),
                    _buildNavItem(Icons.savings, Icons.savings_outlined, 2),
                    const SizedBox(width: 4),
                    _buildNavItem(Icons.pie_chart, Icons.pie_chart_outline, 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData selectedIcon,
    IconData unselectedIcon,
    int index,
  ) {
    final isSelected = widget.navigationShell.currentIndex == index;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _goBranch(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutQuint,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(
          isSelected ? selectedIcon : unselectedIcon,
          size: 24,
          color: isSelected
              ? theme.colorScheme.onSurface
              : theme.colorScheme.surface.withValues(alpha: 0.5),
        ),
      ),
    );
  }

}
