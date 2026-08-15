import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';
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
            child: AnimatedContainer(
  duration: const Duration(milliseconds: 500),
  
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(ref.watch(appBackgroundProvider)),
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
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
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
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isActive 
                                              ? (isExpense ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1))
                                              : Colors.grey.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Icon(
                                          isExpense ? Icons.autorenew : Icons.savings,
                                          color: isActive ? (isExpense ? Colors.red : Colors.green) : Colors.grey,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              rt.name ?? rt.note ?? 'Recurrente', 
                                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${periodicityMap[rt.periodicity] ?? rt.periodicity} • Próx: $nextDate',
                                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isActive 
                                                    ? theme.colorScheme.primary.withValues(alpha: 0.1) 
                                                    : Colors.grey.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                isActive ? 'Activo' : 'Pausado', 
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  color: isActive ? theme.colorScheme.primary : Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '\$${rt.amount.toStringAsFixed(2)}',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: isActive ? (isExpense ? theme.colorScheme.onSurface : Colors.green) : Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Transform.scale(
                                            scale: 0.8,
                                            alignment: Alignment.centerRight,
                                            child: Switch(
                                              value: isActive,
                                              activeThumbColor: theme.colorScheme.primary,
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              onChanged: (val) {
                                                ref.read(recurringTransactionsProvider.notifier).toggleStatus(rt.id!);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
