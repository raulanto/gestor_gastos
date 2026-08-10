import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeChart extends StatelessWidget {
  final Map<String, Map<String, double>> chartData;

  const HomeChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (chartData.isEmpty) {
      return const Center(child: Text('No hay suficientes datos.'));
    }

    final entries = chartData.entries.toList();
    entries.sort((a, b) => a.value['timestamp']!.compareTo(b.value['timestamp']!));

    double maxY = 0;
    for (var entry in entries) {
      if (entry.value['income']! > maxY) maxY = entry.value['income']!;
      if (entry.value['expense']! > maxY) maxY = entry.value['expense']!;
    }
    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 && value.toInt() < entries.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      entries[value.toInt()].key,
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4 == 0 ? 1 : maxY / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.surfaceContainerHighest,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(entries.length, (index) {
          final entry = entries[index];
          final income = entry.value['income']!;
          final expense = entry.value['expense']!;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: income,
                color: Colors.green,
                width: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              BarChartRodData(
                toY: expense,
                color: Colors.red,
                width: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }
}
