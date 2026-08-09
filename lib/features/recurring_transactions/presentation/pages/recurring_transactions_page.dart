import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/recurring_transaction_provider.dart';

const periodicityMap = {
  'daily': 'Diario',
  'weekly': 'Semanal',
  'biweekly': 'Quincenal',
  'monthly': 'Mensual',
  'yearly': 'Anual',
};

class RecurringTransactionsPage extends ConsumerWidget {
  const RecurringTransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringState = ref.watch(recurringTransactionsProvider);
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Gastos Recurrentes', style: theme.textTheme.headlineMedium),
          ),
          Expanded(
            child: recurringState.when(
              data: (rts) {
                if (rts.isEmpty) {
                  return const Center(child: Text('No hay gastos recurrentes configurados.'));
                }

                return ListView.builder(
                  itemCount: rts.length,
                  itemBuilder: (context, index) {
                    final rt = rts[index];
                    final isExpense = rt.type == 'expense';
                    final isActive = rt.status == 'active';
                    final nextDate = DateFormat.yMMMd().format(DateTime.parse(rt.nextExecutionDate));

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isActive 
                            ? (isExpense ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1))
                            : Colors.grey.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.autorenew,
                          color: isActive 
                            ? (isExpense ? Colors.red : Colors.green)
                            : Colors.grey,
                        ),
                      ),
                      title: Text(rt.note ?? 'Recurrente'),
                      subtitle: Text('Frecuencia: ${periodicityMap[rt.periodicity] ?? rt.periodicity}\nPróximo: $nextDate'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$${rt.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isActive 
                                ? (isExpense ? Colors.red : Colors.green)
                                : Colors.grey,
                            ),
                          ),
                          Switch(
                            value: isActive,
                            onChanged: (val) {
                              ref.read(recurringTransactionsProvider.notifier).toggleStatus(rt.id!);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
