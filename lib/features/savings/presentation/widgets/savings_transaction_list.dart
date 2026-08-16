import 'package:gestor_gastos/core/utils/currency_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/savings_transaction.dart';
import '../../../accounts/presentation/providers/account_provider.dart';
import 'package:gestor_gastos/core/utils/icon_utils.dart';

class SavingsTransactionList extends ConsumerWidget {
  final List<SavingsTransactionEntity> transactions;

  const SavingsTransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No hay historial de ahorros para esta meta aún.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final accountsState = ref.watch(accountsProvider);
    final accounts = accountsState.value ?? [];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isDeposit = tx.type == 'deposit';
        final theme = Theme.of(context);

        final account = accounts.where((a) => a.id == tx.accountId).firstOrNull;

        return Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerLowest,
          margin: const EdgeInsets.only(bottom: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            leading: CircleAvatar(
              backgroundColor: isDeposit
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.red.withValues(alpha: 0.2),
              child: Icon(
                isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                color: isDeposit ? Colors.green : Colors.red,
              ),
            ),
            title: Text(
              tx.reason ?? 'Transacción',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.date.substring(0, 10)),
                if (account != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ignore: non_const_argument_for_const_parameter
                        Icon(
                          IconUtils.getIcon(account.iconCode),
                          size: 14,
                          color: Color(account.colorCode),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          account.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(account.colorCode),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            trailing: Text(
              '${isDeposit ? '+' : '-'}${CurrencyUtils.formatAmount(tx.amount)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDeposit ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
