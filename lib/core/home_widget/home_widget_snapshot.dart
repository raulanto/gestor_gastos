import 'package:flutter/material.dart';

import '../utils/currency_utils.dart';

/// Los widgets de Android se pueden redimensionar libremente, así que en vez
/// de estirar una única imagen a cualquier tamaño (lo que deforma el texto),
/// se generan variantes con distinta cantidad de información según el
/// espacio disponible. El lado nativo elige la variante más cercana al
/// tamaño real del widget (ver `BalanceGeneralWidgetProvider.kt`).
enum HomeWidgetTier {
  /// Widgets pequeños: solo el balance (típicamente 4x2 celdas).
  compact(4, 2),

  /// Widgets medianos: balance + resumen en texto (típicamente 4x3 celdas).
  medium(4, 3),

  /// Widgets grandes: diseño completo con tarjetas KPI (típicamente 4x4 celdas).
  expanded(4, 4);

  final int columns;
  final int rows;

  const HomeWidgetTier(this.columns, this.rows);

  Size get size => Size((70.0 * columns) - 30.0, (70.0 * rows) - 30.0);
}

/// Réplica en miniatura del encabezado "Balance General" de la pantalla de
/// inicio, usada para generar la imagen que se muestra en el home widget de
/// Android/iOS (ver [HomeWidgetService]).
class HomeWidgetSnapshot extends StatelessWidget {
  final HomeWidgetTier tier;
  final String backgroundAsset;
  final Color primaryColor;
  final double balance;
  final double income;
  final double expense;
  final String periodLabel;

  const HomeWidgetSnapshot({
    super.key,
    required this.tier,
    required this.backgroundAsset,
    required this.primaryColor,
    required this.balance,
    required this.income,
    required this.expense,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    final size = tier.size;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: DefaultTextStyle(
          style: const TextStyle(fontFamily: 'SFProRounded'),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                backgroundAsset,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primaryColor.withValues(alpha: 0.35),
                      primaryColor.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: switch (tier) {
                  HomeWidgetTier.compact => _CompactContent(
                    balance: balance,
                    periodLabel: periodLabel,
                  ),
                  HomeWidgetTier.medium => _MediumContent(
                    balance: balance,
                    income: income,
                    expense: expense,
                    periodLabel: periodLabel,
                  ),
                  HomeWidgetTier.expanded => _ExpandedContent(
                    balance: balance,
                    income: income,
                    expense: expense,
                    periodLabel: periodLabel,
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactContent extends StatelessWidget {
  final double balance;
  final String periodLabel;

  const _CompactContent({required this.balance, required this.periodLabel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Balance General',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyUtils.formatAmount(balance),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _MediumContent extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;
  final String periodLabel;

  const _MediumContent({
    required this.balance,
    required this.income,
    required this.expense,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _TitleRow(periodLabel: periodLabel),
        Text(
          CurrencyUtils.formatAmount(balance),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _InlineKpi(
                icon: Icons.arrow_upward_rounded,
                color: const Color(0xFF34D399),
                amount: income,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _InlineKpi(
                icon: Icons.arrow_downward_rounded,
                color: const Color(0xFFF87171),
                amount: expense,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExpandedContent extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;
  final String periodLabel;

  const _ExpandedContent({
    required this.balance,
    required this.income,
    required this.expense,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _TitleRow(periodLabel: periodLabel),
        Text(
          CurrencyUtils.formatAmount(balance),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _Kpi(
                icon: Icons.arrow_upward_rounded,
                color: const Color(0xFF34D399),
                label: 'Ingresos',
                amount: income,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Kpi(
                icon: Icons.arrow_downward_rounded,
                color: const Color(0xFFF87171),
                label: 'Gastos',
                amount: expense,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TitleRow extends StatelessWidget {
  final String periodLabel;

  const _TitleRow({required this.periodLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: Text(
            'Balance General',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            periodLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/// Fila compacta de ingresos/gastos sin tarjeta, usada en [HomeWidgetTier.medium].
class _InlineKpi extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double amount;

  const _InlineKpi({required this.icon, required this.color, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            CurrencyUtils.formatAmount(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/// Tarjeta KPI completa con etiqueta, usada en [HomeWidgetTier.expanded].
class _Kpi extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final double amount;

  const _Kpi({
    required this.icon,
    required this.color,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 13, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  CurrencyUtils.formatAmount(amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
