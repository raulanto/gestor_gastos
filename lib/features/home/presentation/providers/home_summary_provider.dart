import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import 'period_view_provider.dart';

class HomeSummary {
  final List<TransactionEntity> transactions;
  final double totalIncome;
  final double totalExpense;
  final double totalBalance;
  final Map<String, Map<String, double>> chartData;

  HomeSummary({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalBalance,
    required this.chartData,
  });
}

final homeSummaryProvider = Provider<AsyncValue<HomeSummary>>((ref) {
  final transactionsAsync = ref.watch(transactionsProvider);
  final periodView = ref.watch(periodViewProvider);

  return transactionsAsync.whenData((allTransactions) {
    final now = DateTime.now();
    List<TransactionEntity> txs = [];
    
    for (var t in allTransactions) {
      final date = DateTime.parse(t.date);
      bool include = false;
      if (periodView == PeriodView.day) {
        include = date.year == now.year && date.month == now.month && date.day == now.day;
      } else if (periodView == PeriodView.week) {
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        include = date.isAfter(weekStart.subtract(const Duration(days: 1)));
      } else if (periodView == PeriodView.month) {
        include = date.year == now.year && date.month == now.month;
      } else if (periodView == PeriodView.year) {
        include = date.year == now.year;
      }
      if (include) txs.add(t);
    }

    txs.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

    double totalIncome = 0;
    double totalExpense = 0;
    for (var t in txs) {
      if (t.type == 'income') {
        totalIncome += t.amount;
      } else if (t.type == 'expense') {
        totalExpense += t.amount;
      }
    }
    
    // Grouping for chart
    Map<String, Map<String, double>> chartData = {};

    for (var tx in txs) {
      final date = DateTime.parse(tx.date);
      String key;
      
      if (periodView == PeriodView.year) {
        key = DateFormat('MMM yy').format(date); // Ej. Ene 26
      } else if (periodView == PeriodView.month) {
        final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
        key = DateFormat('MMM dd').format(startOfWeek); // Ej. Ene 01
      } else if (periodView == PeriodView.week) {
        key = DateFormat('EEE dd').format(date); // Ej. Lun 01
      } else { // day
        key = DateFormat('HH:00').format(date); // Ej. 14:00
      }

      if (!chartData.containsKey(key)) {
        chartData[key] = {'income': 0.0, 'expense': 0.0, 'timestamp': date.millisecondsSinceEpoch.toDouble()};
      }
      if (tx.type == 'income') {
        chartData[key]!['income'] = chartData[key]!['income']! + tx.amount;
      } else if (tx.type == 'expense') {
        chartData[key]!['expense'] = chartData[key]!['expense']! + tx.amount;
      }
    }

    return HomeSummary(
      transactions: txs,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      totalBalance: totalIncome - totalExpense,
      chartData: chartData,
    );
  });
});
