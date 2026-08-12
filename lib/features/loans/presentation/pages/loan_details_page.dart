import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/loan.dart';
import '../../domain/entities/loan_payment.dart';
import '../providers/loans_provider.dart';

class LoanDetailsPage extends ConsumerStatefulWidget {
  final LoanEntity loan;
  const LoanDetailsPage({super.key, required this.loan});

  @override
  ConsumerState<LoanDetailsPage> createState() => _LoanDetailsPageState();
}

class _LoanDetailsPageState extends ConsumerState<LoanDetailsPage> {
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(loanPaymentsProvider(widget.loan.id!));
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Detalles del Préstamo')),
      body: paymentsAsync.when(
        data: (payments) {
          final totalPaid = payments.fold(0.0, (sum, p) => sum + p.amount);
          final remaining = widget.loan.amount - totalPaid;
          final isPaid = widget.loan.status == 'paid' || remaining <= 0;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: widget.loan.person?.photoPath != null 
                          ? FileImage(File(widget.loan.person!.photoPath!)) 
                          : null,
                      child: widget.loan.person?.photoPath == null 
                          ? Icon(Icons.person, size: 36, color: theme.colorScheme.onPrimaryContainer)
                          : null,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.loan.personName ?? 'Desconocido',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(Icons.attach_money, 'Monto total', '\$${widget.loan.amount.toStringAsFixed(2)}', theme),
                          const SizedBox(height: 8),
                          _buildDetailRow(Icons.category, 'Tipo', widget.loan.type, theme),
                          const SizedBox(height: 8),
                          _buildDetailRow(Icons.calendar_today, 'Fecha préstamo', DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.loan.date)), theme),
                          const SizedBox(height: 8),
                          _buildDetailRow(Icons.event_available, 'Fecha a pagar', DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.loan.dueDate)), theme),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Abonado', style: theme.textTheme.bodySmall),
                                  Text('\$${totalPaid.toStringAsFixed(2)}', style: theme.textTheme.titleMedium?.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Restante', style: theme.textTheme.bodySmall),
                                  Text('\$${remaining > 0 ? remaining.toStringAsFixed(2) : '0.00'}', style: theme.textTheme.titleMedium?.copyWith(color: isPaid ? Colors.grey : Colors.red, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Historial de Abonos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (payments.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Aún no hay abonos registrados.'),
                ),
              for (final p in payments)
                ListTile(
                  leading: const Icon(Icons.payment, color: Colors.green),
                  title: Text('\$${p.amount.toStringAsFixed(2)}'),
                  subtitle: Text(DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.parse(p.date))),
                ),
              const SizedBox(height: 24),
              if (!isPaid)
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar Abono'),
                  onPressed: () => _showAddPaymentDialog(remaining),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showAddPaymentDialog(double remaining) {
    _amountController.text = remaining.toStringAsFixed(2);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Registrar Abono', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Monto a abonar', 
                prefixText: '\$',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    final val = double.tryParse(_amountController.text);
                    if (val != null && val > 0) {
                      final payment = LoanPaymentEntity(
                        loanId: widget.loan.id!,
                        amount: val,
                        date: DateTime.now().toIso8601String(),
                      );
                      ref.read(loansProvider.notifier).addPayment(payment, widget.loan);
                      ref.invalidate(loanPaymentsProvider(widget.loan.id!));
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text('$label: ', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
      ],
    );
  }
}
