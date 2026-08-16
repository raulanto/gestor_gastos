import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import 'package:intl/intl.dart';
import '../../../home/presentation/providers/period_view_provider.dart';
import '../../../home/presentation/providers/home_summary_provider.dart' show CategoryExpenseData;
import '../../../../core/providers/date_filter_provider.dart';

class AccountDateFilterNotifier extends Notifier<Map<int, PeriodView>> {
  @override
  Map<int, PeriodView> build() => {};

  void updateFilter(int accountId, PeriodView filter) {
    state = {...state, accountId: filter};
  }
}

final accountDateFilterProvider =
    NotifierProvider<AccountDateFilterNotifier, Map<int, PeriodView>>(() {
      return AccountDateFilterNotifier();
    });

class AccountTransactionsSummary {
  final List<TransactionEntity> transactions;
  final double totalIncome;
  final double totalExpense;
  final Map<String, Map<String, double>> chartData;
  final List<CategoryExpenseData> categoryExpenses;

  AccountTransactionsSummary({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.chartData,
    required this.categoryExpenses,
  });
}

final accountTransactionsSummaryProvider =
    Provider.family<AsyncValue<AccountTransactionsSummary>, int>((
      ref,
      accountId,
    ) {
      final transactionsAsync = ref.watch(transactionsProvider);
      final categoriesAsync = ref.watch(categoriesProvider);
      final filterMap = ref.watch(accountDateFilterProvider);
      final filter = filterMap[accountId] ?? PeriodView.month;
      final selectedMonth = ref.watch(selectedMonthProvider);

      if (transactionsAsync is AsyncLoading || categoriesAsync is AsyncLoading) {
        return const AsyncValue.loading();
      }

      final categories = categoriesAsync.value ?? [];

      return transactionsAsync.whenData((allTransactions) {
        var accountTxs = allTransactions
            .where((t) => t.accountId == accountId)
            .toList();

        List<TransactionEntity> filteredTxs = [];
        for (var t in accountTxs) {
          final date = DateTime.parse(t.date);
          bool include = false;
          if (filter == PeriodView.day) {
            final referenceDate =
                (selectedMonth.year == DateTime.now().year &&
                    selectedMonth.month == DateTime.now().month)
                ? DateTime.now()
                : DateTime(selectedMonth.year, selectedMonth.month, 1);
            include =
                date.year == referenceDate.year &&
                date.month == referenceDate.month &&
                date.day == referenceDate.day;
          } else if (filter == PeriodView.week) {
            final referenceDate =
                (selectedMonth.year == DateTime.now().year &&
                    selectedMonth.month == DateTime.now().month)
                ? DateTime.now()
                : DateTime(selectedMonth.year, selectedMonth.month, 1);
            final weekStart = referenceDate.subtract(
              Duration(days: referenceDate.weekday - 1),
            );
            include =
                date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                date.isBefore(weekStart.add(const Duration(days: 7)));
          } else if (filter == PeriodView.month) {
            include =
                date.year == selectedMonth.year &&
                date.month == selectedMonth.month;
          } else if (filter == PeriodView.year) {
            include = date.year == selectedMonth.year;
          }
          if (include) filteredTxs.add(t);
        }

        filteredTxs.sort(
          (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)),
        );

        double totalIncome = 0;
        double totalExpense = 0;
        Map<int, double> catExpMap = {};

        // Grouping for chart
        Map<String, Map<String, double>> chartData = {};

        for (var tx in filteredTxs) {
          if (tx.type == 'income') {
            totalIncome += tx.amount;
          } else if (tx.type == 'expense') {
            totalExpense += tx.amount;
            if (tx.categoryId != null) {
              catExpMap[tx.categoryId!] = (catExpMap[tx.categoryId!] ?? 0) + tx.amount;
            }
          }

          final date = DateTime.parse(tx.date);
          String key;
          if (filter == PeriodView.year) {
            key = DateFormat('MMM yyyy').format(date);
          } else if (filter == PeriodView.month) {
            key = DateFormat('MMM dd').format(date);
          } else {
            key = DateFormat('EEE dd').format(date);
          }

          if (!chartData.containsKey(key)) {
            chartData[key] = {
              'income': 0.0,
              'expense': 0.0,
              'timestamp': date.millisecondsSinceEpoch.toDouble(),
            };
          }
          if (tx.type == 'income') {
            chartData[key]!['income'] = chartData[key]!['income']! + tx.amount;
          } else if (tx.type == 'expense') {
            chartData[key]!['expense'] =
                chartData[key]!['expense']! + tx.amount;
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

        return AccountTransactionsSummary(
          transactions: filteredTxs,
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          chartData: chartData,
          categoryExpenses: categoryExpenses,
        );
      });
    });
