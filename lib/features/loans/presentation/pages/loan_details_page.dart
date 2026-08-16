import 'package:gestor_gastos/core/utils/currency_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme_provider.dart';
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
    final theme = Theme.of(context);
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
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
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
                      theme.colorScheme.primary.withValues(alpha: 0.9),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Detalles del Préstamo',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (val) {
                          if (val == 'edit') {
                            context.push('/edit_loan/${loan.id}');
                          } else if (val == 'delete') {
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                bool keepHistory = true;
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      title: const Text('Eliminar Préstamo'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            '¿Estás seguro de que deseas eliminar este préstamo?',
                                          ),
                                          const SizedBox(height: 16),
                                          CheckboxListTile(
                                            title: const Text(
                                              'Mantener transacciones de cobros y abonos en el balance general',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            value: keepHistory,
                                            onChanged: (val) {
                                              if (val != null) {
                                                setState(() => keepHistory = val);
                                              }
                                            },
                                            controlAffinity: ListTileControlAffinity.leading,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            ref
                                                .read(loansProvider.notifier)
                                                .deleteLoan(loan.id!, keepHistory: keepHistory);
                                            Navigator.pop(ctx);
                                            context.pop();
                                          },
                                          child: const Text(
                                            'Eliminar',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Editar Préstamo'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Eliminar Préstamo',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: paymentsAsync.when(
                      data: (payments) {
                        final totalPaid = payments.fold(0.0, (sum, p) => sum + p.amount);
                        final remaining = loan.amount - totalPaid;
                        final isPaid = loan.status == 'paid' || remaining <= 0;

                        return ListView(
                          padding: const EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0, bottom: 100),
                          children: [
                            LoanDetailsHeader(
                              loan: loan,
                              totalPaid: totalPaid,
                              remaining: remaining,
                              isPaid: isPaid,
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Historial de Abonos',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (payments.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Text('Aún no hay abonos registrados.'),
                              ),
                            for (final p in payments)
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green.withValues(alpha: 0.2),
                                    child: const Icon(Icons.payment, color: Colors.green),
                                  ),
                                  title: Text(
                                    CurrencyUtils.formatAmount(p.amount),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.parse(p.date)),
                                  ),
                                ),
                              ),
                          ],
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
      floatingActionButton: paymentsAsync.maybeWhen(
        data: (payments) {
          final totalPaid = payments.fold(0.0, (sum, p) => sum + p.amount);
          final remaining = loan.amount - totalPaid;
          final isPaid = loan.status == 'paid' || remaining <= 0;
          if (isPaid) return null;
          return FloatingActionButton.extended(
            elevation: 0,
            highlightElevation: 0,
            onPressed: () => _showAddPaymentDialog(remaining, loan),
            label: const Text('Abonar'),
            icon: const Icon(Icons.add),
          );
        },
        orElse: () => null,
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
