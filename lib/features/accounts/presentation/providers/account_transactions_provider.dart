import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import 'package:intl/intl.dart';

enum DateRangeFilter { days7, monthly, trimester }

class AccountDateFilterNotifier extends Notifier<Map<int, DateRangeFilter>> {
  @override
  Map<int, DateRangeFilter> build() => {};

  void updateFilter(int accountId, DateRangeFilter filter) {
    state = {...state, accountId: filter};
  }
}

final accountDateFilterProvider = NotifierProvider<AccountDateFilterNotifier, Map<int, DateRangeFilter>>(() {
  return AccountDateFilterNotifier();
});

class AccountTransactionsSummary {
  final List<TransactionEntity> transactions;
  final double totalIncome;
  final double totalExpense;
  final Map<String, Map<String, double>> chartData;

  AccountTransactionsSummary({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.chartData,
  });
}

final accountTransactionsSummaryProvider = Provider.family<AsyncValue<AccountTransactionsSummary>, int>((ref, accountId) {
  final transactionsAsync = ref.watch(transactionsProvider);
  final filterMap = ref.watch(accountDateFilterProvider);
  final filter = filterMap[accountId] ?? DateRangeFilter.monthly;

  return transactionsAsync.whenData((allTransactions) {
    var accountTxs = allTransactions.where((t) => t.accountId == accountId).toList();

    final now = DateTime.now();
    DateTime startDate;
    if (filter == DateRangeFilter.days7) {
      startDate = now.subtract(const Duration(days: 6));
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
    } else if (filter == DateRangeFilter.monthly) {
      startDate = DateTime(now.year, now.month, 1);
    } else { // trimester
      startDate = DateTime(now.year, now.month - 2, 1);
    }

    accountTxs = accountTxs.where((t) {
      final date = DateTime.parse(t.date);
      return date.isAfter(startDate.subtract(const Duration(seconds: 1)));
    }).toList();
    
    accountTxs.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

    double totalIncome = 0;
    double totalExpense = 0;
    
    // Grouping for chart
    Map<String, Map<String, double>> chartData = {};

    for (var tx in accountTxs) {
      if (tx.type == 'income') {
        totalIncome += tx.amount;
      } else if (tx.type == 'expense') {
        totalExpense += tx.amount;
      }
      
      final date = DateTime.parse(tx.date);
      String key;
      if (filter == DateRangeFilter.trimester) {
        // Group by week for trimester to avoid too many bars
        final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
        key = DateFormat('MMM dd').format(startOfWeek);
      } else {
        // Group by day for 7 days or monthly
        key = DateFormat('MMM dd').format(date);
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

    return AccountTransactionsSummary(
      transactions: accountTxs,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      chartData: chartData,
    );
  });
});
