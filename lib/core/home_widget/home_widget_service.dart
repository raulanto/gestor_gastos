import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import 'home_widget_snapshot.dart';

/// Genera y publica las imágenes que muestra el home widget "Balance
/// general", replicando el estilo (fondo, degradado y KPIs) de la pantalla
/// de inicio.
///
/// Como el widget de Android se puede redimensionar libremente, se renderiza
/// una variante por cada [HomeWidgetTier] en cada actualización; el lado
/// nativo elige la que mejor se ajusta al tamaño real del widget en vez de
/// estirar una sola imagen (lo que deformaba el texto).
class HomeWidgetService {
  HomeWidgetService._();

  static const String androidWidgetName = 'BalanceGeneralWidgetProvider';
  static const String iOSWidgetName = 'BalanceGeneralWidget';

  static String snapshotKeyFor(HomeWidgetTier tier) =>
      'balance_general_snapshot_${tier.name}';

  static Future<void> updateSnapshot({
    required String backgroundAsset,
    required Color primaryColor,
    required double balance,
    required double income,
    required double expense,
    String periodLabel = 'Mes',
  }) async {
    for (final tier in HomeWidgetTier.values) {
      await HomeWidget.renderFlutterWidget(
        HomeWidgetSnapshot(
          tier: tier,
          backgroundAsset: backgroundAsset,
          primaryColor: primaryColor,
          balance: balance,
          income: income,
          expense: expense,
          periodLabel: periodLabel,
        ),
        key: snapshotKeyFor(tier),
        logicalSize: tier.size,
        pixelRatio: 3.0,
      );
    }

    await HomeWidget.updateWidget(
      androidName: androidWidgetName,
      iOSName: iOSWidgetName,
    );
  }
}
