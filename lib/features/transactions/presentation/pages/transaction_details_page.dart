import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../accounts/presentation/providers/account_provider.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../providers/transaction_provider.dart';

import '../widgets/transaction_amount_header.dart';
import '../widgets/transaction_account_tile.dart';
import '../widgets/transaction_category_splits.dart';
import '../widgets/transaction_note_tile.dart';
import '../widgets/transaction_receipt_viewer.dart';

class TransactionDetailsPage extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailsPage({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaction = ref.watch(transactionByIdProvider(transactionId));

    if (transaction == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transacción no encontrada')),
        body: const Center(
          child: Text('La transacción no existe o fue eliminada'),
        ),
      );
    }

    final accountsState = ref.watch(accountsProvider);
    final categoriesState = ref.watch(categoriesProvider);

    final account = accountsState.value
        ?.where((a) => a.id == transaction.accountId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Transacción'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/edit_transaction/${transaction.id}');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Eliminar Transacción'),
                  content: const Text(
                    '¿Estás seguro de que deseas eliminar esta transacción? Esta acción no se puede deshacer.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true && transaction.id != null) {
                await ref
                    .read(transactionsProvider.notifier)
                    .removeTransaction(transaction.id!);
                ref.invalidate(accountsProvider); // Para actualizar balance
                if (context.mounted) {
                  context.pop();
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TransactionAmountHeader(transaction: transaction),
            const SizedBox(height: 32),

            if (account != null) TransactionAccountTile(account: account),
            const Divider(),

            TransactionCategorySplits(
              transaction: transaction,
              categories: categoriesState.value ?? [],
            ),
            const Divider(),

            if (transaction.note != null && transaction.note!.isNotEmpty)
              TransactionNoteTile(note: transaction.note!),

            if (transaction.receiptImagePath != null) ...[
              const Divider(),
              TransactionReceiptViewer(
                receiptImagePath: transaction.receiptImagePath!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
