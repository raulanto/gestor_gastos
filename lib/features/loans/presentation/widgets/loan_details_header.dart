import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/loan.dart';
import 'loan_detail_row.dart';

class LoanDetailsHeader extends StatelessWidget {
  final LoanEntity loan;
  final double totalPaid;
  final double remaining;
  final bool isPaid;

  const LoanDetailsHeader({
    super.key,
    required this.loan,
    required this.totalPaid,
    required this.remaining,
    required this.isPaid,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
            backgroundImage: loan.person?.photoPath != null 
                ? FileImage(File(loan.person!.photoPath!)) 
                : null,
            child: loan.person?.photoPath == null 
                ? Icon(Icons.person, size: 36, color: theme.colorScheme.onPrimaryContainer)
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loan.personName ?? 'Desconocido',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                LoanDetailRow(icon: Icons.attach_money, label: 'Monto total', value: '\$${loan.amount.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                LoanDetailRow(icon: Icons.category, label: 'Tipo', value: loan.type),
                const SizedBox(height: 8),
                LoanDetailRow(icon: Icons.calendar_today, label: 'Fecha préstamo', value: DateFormat('dd/MM/yyyy').format(DateTime.parse(loan.date))),
                const SizedBox(height: 8),
                LoanDetailRow(icon: Icons.event_available, label: 'Fecha a pagar', value: DateFormat('dd/MM/yyyy').format(DateTime.parse(loan.dueDate))),
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
    );
  }
}
