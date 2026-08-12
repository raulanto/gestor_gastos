import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../accounts/presentation/providers/account_provider.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_provider.dart';

class TransactionDetailsPage extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailsPage({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaction = ref.watch(transactionByIdProvider(transactionId));
    
    if (transaction == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transacción no encontrada')),
        body: const Center(child: Text('La transacción no existe o fue eliminada')),
      );
    }
    final accountsState = ref.watch(accountsProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

    // Encontrar cuenta
    final account = accountsState.value?.where((a) => a.id == transaction.accountId).firstOrNull;

    // Obtener color/signo según tipo
    final isExpense = transaction.type == 'expense';
    final amountColor = isExpense ? Colors.red : Colors.green;
    final typeLabel = isExpense ? 'Gasto' : (transaction.type == 'income' ? 'Ingreso' : 'Transferencia');

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
                  content: const Text('¿Estás seguro de que deseas eliminar esta transacción? Esta acción no se puede deshacer.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );

              if (confirm == true && transaction.id != null) {
                await ref.read(transactionsProvider.notifier).removeTransaction(transaction.id!);
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
            // Cabecera de Monto
            Center(
              child: Column(
                children: [
                  Text(
                    typeLabel.toUpperCase(),
                    style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${transaction.amount.toStringAsFixed(2)}',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    transaction.date.substring(0, 10), // Simplificado
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Cuenta
            if (account != null)
              ListTile(
                // ignore: non_const_argument_for_const_parameter
                leading: Icon(IconData(account.iconCode, fontFamily: 'MaterialIcons'), color: Color(account.colorCode), size: 32),
                title: const Text('Cuenta'),
                subtitle: Text(account.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            const Divider(),

            // Categoría o Splits
            if (transaction.splits.length <= 1 && transaction.categoryId != null) ...[
              Builder(builder: (context) {
                final cat = categoriesState.value?.where((c) => c.id == transaction.categoryId).firstOrNull;
                return ListTile(
                  // ignore: non_const_argument_for_const_parameter
                  leading: Icon(cat != null ? IconData(cat.iconCode, fontFamily: 'MaterialIcons') : Icons.category, color: cat != null ? Color(cat.colorCode) : Colors.grey, size: 32),
                  title: const Text('Categoría'),
                  subtitle: Text(cat?.name ?? 'Desconocida', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                );
              }),
            ] else if (transaction.splits.length > 1) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text('Divisiones (Splits)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              ...transaction.splits.map((s) {
                final cat = categoriesState.value?.where((c) => c.id == s.categoryId).firstOrNull;
                return ListTile(
                  dense: true,
                  // ignore: non_const_argument_for_const_parameter
                  leading: Icon(cat != null ? IconData(cat.iconCode, fontFamily: 'MaterialIcons') : Icons.category, color: cat != null ? Color(cat.colorCode) : Colors.grey),
                  title: Text(cat?.name ?? 'Desconocida'),
                  trailing: Text('\$${s.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                );
              }),
            ],
            const Divider(),

            // Nota
            if (transaction.note != null && transaction.note!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.notes, size: 32),
                title: const Text('Nota'),
                subtitle: Text(transaction.note!, style: const TextStyle(fontSize: 16)),
              ),
              
            // Recibo
            if (transaction.receiptImagePath != null) ...[
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text('Recibo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => Dialog(
                      child: InteractiveViewer(
                        child: Image.file(File(transaction.receiptImagePath!)),
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(File(transaction.receiptImagePath!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
