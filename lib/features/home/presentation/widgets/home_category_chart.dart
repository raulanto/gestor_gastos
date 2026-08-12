import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/home_summary_provider.dart';

class HomeCategoryChart extends StatefulWidget {
  final List<CategoryExpenseData> categoryData;

  const HomeCategoryChart({super.key, required this.categoryData});

  @override
  State<HomeCategoryChart> createState() => _HomeCategoryChartState();
}

class _HomeCategoryChartState extends State<HomeCategoryChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.categoryData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('No hay gastos registrados en este periodo', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          ],
        ),
      );
    }

    final totalExpense = widget.categoryData.fold(0.0, (sum, item) => sum + item.amount);

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 3,
                  centerSpaceRadius: 50,
                  sections: showingSections(),
                ),
              ),
              // Center text showing total or touched amount
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    touchedIndex == -1 ? 'Total' : widget.categoryData[touchedIndex].name,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    touchedIndex == -1 
                      ? '\$${totalExpense.toStringAsFixed(0)}'
                      : '\$${widget.categoryData[touchedIndex].amount.toStringAsFixed(0)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 5,
          child: ListView.separated(
            itemCount: widget.categoryData.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = widget.categoryData[index];
              final isTouched = index == touchedIndex;
              final percentage = (data.amount / totalExpense) * 100;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    touchedIndex = isTouched ? -1 : index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: isTouched ? Color(data.colorCode).withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isTouched ? Color(data.colorCode).withValues(alpha: 0.3) : Colors.transparent,
                    )
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Color(data.colorCode),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(data.colorCode).withValues(alpha: 0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              data.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: isTouched ? FontWeight.bold : FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${data.amount.toStringAsFixed(0)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isTouched ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(widget.categoryData.length, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 30.0 : 22.0;
      final data = widget.categoryData[i];

      return PieChartSectionData(
        color: Color(data.colorCode),
        value: data.amount,
        title: '',
        radius: radius,
        badgeWidget: isTouched 
            ? Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)
                  ]
                ),
                child: Icon(Icons.circle, size: 10, color: Color(data.colorCode)),
              )
            : null,
        badgePositionPercentageOffset: .98,
      );
    });
  }
}
