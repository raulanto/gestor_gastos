import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/transactions/presentation/providers/transaction_provider.dart';
import '../theme/theme_provider.dart';

/// Datos de entrada para el snapshot del home widget: siempre corresponden
/// al mes en curso, independientemente del período que el usuario esté
/// navegando dentro de la app.
class HomeWidgetSnapshotData {
  final double income;
  final double expense;
  final String backgroundAsset;
  final String colorSchemeName;

  const HomeWidgetSnapshotData({
    required this.income,
    required this.expense,
    required this.backgroundAsset,
    required this.colorSchemeName,
  });

  double get balance => income - expense;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HomeWidgetSnapshotData &&
          other.income == income &&
          other.expense == expense &&
          other.backgroundAsset == backgroundAsset &&
          other.colorSchemeName == colorSchemeName);

  @override
  int get hashCode =>
      Object.hash(income, expense, backgroundAsset, colorSchemeName);
}

final homeWidgetSnapshotDataProvider =
    Provider<AsyncValue<HomeWidgetSnapshotData>>((ref) {
      final transactionsAsync = ref.watch(transactionsProvider);
      final backgroundAsset = ref.watch(appBackgroundProvider);
      final colorSchemeName = ref.watch(colorSchemeProvider);

      return transactionsAsync.whenData((transactions) {
        final now = DateTime.now();
        double income = 0;
        double expense = 0;

        for (final t in transactions) {
          final date = DateTime.parse(t.date);
          if (date.year != now.year || date.month != now.month) continue;
          if (t.type == 'income') {
            income += t.amount;
          } else if (t.type == 'expense') {
            expense += t.amount;
          }
        }

        return HomeWidgetSnapshotData(
          income: income,
          expense: expense,
          backgroundAsset: backgroundAsset,
          colorSchemeName: colorSchemeName,
        );
      });
    });
