import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../../core/providers/date_filter_provider.dart';
import 'period_view_provider.dart';

class CategoryExpenseData {
  final int categoryId;
  final String name;
  final int colorCode;
  final double amount;

  CategoryExpenseData({
    required this.categoryId,
    required this.name,
    required this.colorCode,
    required this.amount,
  });
}

class HomeSummary {
  final List<TransactionEntity> transactions;
  final double totalIncome;
  final double totalExpense;
  final double totalBalance;
  final Map<String, Map<String, double>> chartData;
  final List<CategoryExpenseData> categoryExpenses;

  HomeSummary({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalBalance,
    required this.chartData,
    required this.categoryExpenses,
  });
}

final homeSummaryProvider = Provider<AsyncValue<HomeSummary>>((ref) {
  final transactionsAsync = ref.watch(transactionsProvider);
  final categoriesAsync = ref.watch(categoriesProvider);
  final periodView = ref.watch(periodViewProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);

  if (transactionsAsync is AsyncLoading || categoriesAsync is AsyncLoading) {
    return const AsyncValue.loading();
  }

  if (transactionsAsync is AsyncError) {
    return AsyncValue.error(transactionsAsync.error!, transactionsAsync.stackTrace!);
  }

  final allTransactions = transactionsAsync.value ?? [];
  final categories = categoriesAsync.value ?? [];

  List<TransactionEntity> txs = [];
  
  for (var t in allTransactions) {
    final date = DateTime.parse(t.date);
    bool include = false;
    if (periodView == PeriodView.day) {
      final referenceDate = (selectedMonth.year == DateTime.now().year && selectedMonth.month == DateTime.now().month) 
          ? DateTime.now() 
          : DateTime(selectedMonth.year, selectedMonth.month, 1);
      include = date.year == referenceDate.year && date.month == referenceDate.month && date.day == referenceDate.day;
    } else if (periodView == PeriodView.week) {
      final referenceDate = (selectedMonth.year == DateTime.now().year && selectedMonth.month == DateTime.now().month) 
          ? DateTime.now() 
          : DateTime(selectedMonth.year, selectedMonth.month, 1);
      final weekStart = referenceDate.subtract(Duration(days: referenceDate.weekday - 1));
      include = date.isAfter(weekStart.subtract(const Duration(days: 1))) && date.isBefore(weekStart.add(const Duration(days: 7)));
    } else if (periodView == PeriodView.month) {
      include = date.year == selectedMonth.year && date.month == selectedMonth.month;
    } else if (periodView == PeriodView.year) {
      include = date.year == selectedMonth.year;
    }
    if (include) txs.add(t);
  }

  txs.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

  double totalIncome = 0;
  double totalExpense = 0;
  Map<int, double> catExpMap = {};

  for (var t in txs) {
    if (t.type == 'income') {
      totalIncome += t.amount;
    } else if (t.type == 'expense') {
      totalExpense += t.amount;
      if (t.categoryId != null) {
        catExpMap[t.categoryId!] = (catExpMap[t.categoryId!] ?? 0) + t.amount;
      }
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

  List<CategoryExpenseData> categoryExpenses = catExpMap.entries.map((e) {
    final cat = categories.where((c) => c.id == e.key).firstOrNull;
    return CategoryExpenseData(
      categoryId: e.key,
      name: cat?.name ?? 'Desconocida',
      colorCode: cat?.colorCode ?? 0xFF9E9E9E,
      amount: e.value,
    );
  }).toList();
  categoryExpenses.sort((a, b) => b.amount.compareTo(a.amount));

  return AsyncValue.data(HomeSummary(
    transactions: txs,
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    totalBalance: totalIncome - totalExpense,
    chartData: chartData,
    categoryExpenses: categoryExpenses,
  ));
});
