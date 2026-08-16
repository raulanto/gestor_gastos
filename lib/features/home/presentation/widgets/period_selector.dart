import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/period_view_provider.dart';

class PeriodSelector extends ConsumerWidget {
  final PeriodView? selectedPeriod;
  final ValueChanged<PeriodView>? onPeriodChanged;

  const PeriodSelector({super.key, this.selectedPeriod, this.onPeriodChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PeriodView periodView =
        selectedPeriod ?? ref.watch(periodViewProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildOption(context, ref, PeriodView.day, 'Hoy', periodView),
            _buildOption(context, ref, PeriodView.week, 'Sem', periodView),
            _buildOption(context, ref, PeriodView.month, 'Mes', periodView),
            _buildOption(context, ref, PeriodView.year, 'Año', periodView),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    WidgetRef ref,
    PeriodView value,
    String label,
    PeriodView selectedValue,
  ) {
    final isSelected = value == selectedValue;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        if (onPeriodChanged != null) {
          onPeriodChanged!(value);
        } else {
          ref.read(periodViewProvider.notifier).updateView(value);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.onPrimary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onPrimary.withValues(alpha: 0.5),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
