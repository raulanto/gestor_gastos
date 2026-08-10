import 'package:flutter/material.dart';

class KpiCards extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;

  const KpiCards({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(context, 'Ingresos', totalIncome, Colors.green),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(context, 'Gastos', totalExpense, Colors.red),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, double amount, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(title == 'Ingresos' ? Icons.arrow_upward : Icons.arrow_downward, color: color, size: 16),
              const SizedBox(width: 4),
              Text(title, style: theme.textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text('\$${amount.toStringAsFixed(2)}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
