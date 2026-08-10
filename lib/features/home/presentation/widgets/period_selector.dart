import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/period_view_provider.dart';

class PeriodSelector extends ConsumerWidget {
  const PeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodView = ref.watch(periodViewProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: SegmentedButton<PeriodView>(
        segments: const [
          ButtonSegment(value: PeriodView.day, label: Text('Hoy')),
          ButtonSegment(value: PeriodView.week, label: Text('Sem.')),
          ButtonSegment(value: PeriodView.month, label: Text('Mes')),
          ButtonSegment(value: PeriodView.year, label: Text('Año')),
        ],
        selected: {periodView},
        onSelectionChanged: (Set<PeriodView> newSelection) {
          ref.read(periodViewProvider.notifier).updateView(newSelection.first);
        },
        style: SegmentedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          selectedBackgroundColor: theme.colorScheme.onPrimary,
          foregroundColor: theme.colorScheme.onPrimary,
          selectedForegroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.onPrimary.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}
