import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/loan.dart';
import 'empty_loans.dart';
import 'section_title.dart';
import 'loan_card.dart';

class LoansContent extends StatelessWidget {
  final AsyncValue<List<LoanEntity>> loansAsync;

  const LoansContent({super.key, required this.loansAsync});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
      child: loansAsync.when(
        data: (loans) {
          if (loans.isEmpty) return const EmptyLoans();

          final activeLoans = loans.where((l) => l.status == 'active').toList();
          final paidLoans = loans.where((l) => l.status == 'paid').toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            children: [
              if (activeLoans.isNotEmpty) ...[
                const SectionTitle('Activos'),
                ...activeLoans.map((loan) => LoanCard(loan: loan, isActive: true)),
                const SizedBox(height: 16),
              ],
              if (paidLoans.isNotEmpty) ...[
                const SectionTitle('Liquidados'),
                ...paidLoans.map((loan) => LoanCard(loan: loan, isActive: false)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
