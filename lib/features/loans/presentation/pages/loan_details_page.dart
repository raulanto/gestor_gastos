import 'package:gestor_gastos/core/utils/currency_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/loan.dart';
import '../providers/loans_provider.dart';
import '../widgets/loan_details_header.dart';
import '../widgets/add_payment_dialog.dart';

class LoanDetailsPage extends ConsumerStatefulWidget {
  final String loanId;
  const LoanDetailsPage({super.key, required this.loanId});

  @override
  ConsumerState<LoanDetailsPage> createState() => _LoanDetailsPageState();
}

class _LoanDetailsPageState extends ConsumerState<LoanDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final loan = ref.watch(loanByIdProvider(widget.loanId));
    if (loan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Préstamo no encontrado')),
        body: const Center(
          child: Text('El préstamo no existe o fue eliminado'),
        ),
      );
    }

    final paymentsAsync = ref.watch(loanPaymentsProvider(loan.id!));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalles del Préstamo')),
      body: paymentsAsync.when(
        data: (payments) {
          final totalPaid = payments.fold(0.0, (sum, p) => sum + p.amount);
          final remaining = loan.amount - totalPaid;
          final isPaid = loan.status == 'paid' || remaining <= 0;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              LoanDetailsHeader(
                loan: loan,
                totalPaid: totalPaid,
                remaining: remaining,
                isPaid: isPaid,
              ),
              const SizedBox(height: 24),
              const Text(
                'Historial de Abonos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (payments.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Aún no hay abonos registrados.'),
                ),
              for (final p in payments)
                ListTile(
                  leading: const Icon(Icons.payment, color: Colors.green),
                  title: Text(CurrencyUtils.formatAmount(p.amount)),
                  subtitle: Text(
                    DateFormat(
                      'dd/MM/yyyy hh:mm a',
                    ).format(DateTime.parse(p.date)),
                  ),
                ),
              const SizedBox(height: 24),
              if (!isPaid)
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar Abono'),
                  onPressed: () => _showAddPaymentDialog(remaining, loan),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showAddPaymentDialog(double remaining, LoanEntity loan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => AddPaymentDialog(remaining: remaining, loan: loan),
    );
  }
}
