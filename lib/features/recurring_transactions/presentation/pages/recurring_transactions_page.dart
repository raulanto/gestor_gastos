import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      bottom: false,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/home_bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.4),
                      theme.colorScheme.primary,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recurrentes', style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.15)),
                        icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
                        onPressed: () => context.push('/add_recurring_transaction'),
                      ),
                    ],
                  ),
                ),
                Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: recurringState.when(
                  data: (rts) {
                    if (rts.isEmpty) {
                      return const Center(child: Text('No hay gastos recurrentes configurados.'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 24, bottom: 100),
                      itemCount: rts.length,
                      itemBuilder: (context, index) {
                        final rt = rts[index];
                        final isExpense = rt.type == 'expense';
                        final isActive = rt.status == 'active';
                        final nextDate = DateFormat('dd MMM yyyy').format(DateTime.parse(rt.nextExecutionDate));

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: isActive 
                                  ? (isExpense ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1))
                                  : Colors.grey.withValues(alpha: 0.1),
                              child: Icon(
                                isExpense ? Icons.autorenew : Icons.savings,
                                color: isActive ? (isExpense ? Colors.red : Colors.green) : Colors.grey,
                              ),
                            ),
                            title: Text(rt.note ?? 'Recurrente', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${periodicityMap[rt.periodicity] ?? rt.periodicity} • Próx: $nextDate'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${rt.amount.toStringAsFixed(2)}',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isActive ? (isExpense ? theme.colorScheme.onSurface : Colors.green) : Colors.grey,
                                      ),
                                    ),
                                    Text(isActive ? 'Activo' : 'Pausado', style: theme.textTheme.bodySmall?.copyWith(color: isActive ? Colors.green : Colors.grey)),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Switch(
                                  value: isActive,
                                  activeColor: theme.colorScheme.primary,
                                  onChanged: (val) {
                                    ref.read(recurringTransactionsProvider.notifier).toggleStatus(rt.id!);
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              context.push('/edit_recurring_transaction/${rt.id}');
                            },
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Eliminar Gasto Recurrente'),
                                  content: const Text('¿Estás seguro de que deseas eliminar este gasto recurrente? No se eliminarán los cobros ya generados.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                                    TextButton(
                                      onPressed: () {
                                        ref.read(recurringTransactionsProvider.notifier).remove(rt.id!);
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                )
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Error: $e')),
                ),
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
