import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/loans_provider.dart';

class LoansPage extends ConsumerWidget {
  const LoansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(loansProvider);
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
                      Text('Préstamos', style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.15)),
                        icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
                        onPressed: () => context.push('/add_loan'),
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
                    child: loansAsync.when(
        data: (loans) {
          if (loans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No hay préstamos registrados.'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/add_loan'),
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar Préstamo'),
                  ),
                ],
              ),
            );
          }
          final activeLoans = loans.where((l) => l.status == 'active').toList();
          final paidLoans = loans.where((l) => l.status == 'paid').toList();

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (activeLoans.isNotEmpty) ...[
                const Text('Activos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...activeLoans.map((loan) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: loan.person?.photoPath != null 
                          ? FileImage(File(loan.person!.photoPath!)) 
                          : null,
                      child: loan.person?.photoPath == null 
                          ? Icon(Icons.person, color: theme.colorScheme.onPrimaryContainer)
                          : null,
                    ),
                    title: Text(loan.personName ?? 'Desconocido'),
                    subtitle: Text('Vence: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(loan.dueDate))}'),
                    trailing: Text(
                      '\$${loan.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    onTap: () => context.push('/loan_details/${loan.id}'),
                  ),
                )),
                const SizedBox(height: 16),
              ],
              if (paidLoans.isNotEmpty) ...[
                const Text('Liquidados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...paidLoans.map((loan) => Card(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: loan.person?.photoPath != null 
                          ? FileImage(File(loan.person!.photoPath!)) 
                          : null,
                      child: loan.person?.photoPath == null 
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                    ),
                    title: Text(loan.personName ?? 'Desconocido', style: const TextStyle(decoration: TextDecoration.lineThrough)),
                    subtitle: const Text('Liquidado'),
                    trailing: Text(
                      '\$${loan.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
                    ),
                    onTap: () => context.push('/loan_details/${loan.id}'),
                  ),
                )),
              ]
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
    );
  }
}
