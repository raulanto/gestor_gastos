import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/loan.dart';

class LoanCard extends StatelessWidget {
  final LoanEntity loan;
  final bool isActive;

  const LoanCard({super.key, required this.loan, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final photoPath = loan.person?.photoPath;
    final hasPhoto = photoPath != null;
    
    return Card(
      color: isActive ? null : theme.colorScheme.surfaceContainerHighest,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive 
              ? theme.colorScheme.primaryContainer 
              : Colors.grey.shade300,
          backgroundImage: hasPhoto ? FileImage(File(photoPath)) : null,
          child: !hasPhoto 
              ? Icon(
                  isActive ? Icons.person : Icons.check, 
                  color: isActive ? theme.colorScheme.onPrimaryContainer : Colors.green
                )
              : null,
        ),
        title: Text(
          loan.personName ?? 'Desconocido',
          style: TextStyle(
            decoration: isActive ? TextDecoration.none : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(
          isActive 
              ? 'Vence: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(loan.dueDate))}'
              : 'Liquidado'
        ),
        trailing: Text(
          '\$${loan.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 16,
            color: isActive ? null : Colors.grey,
          ),
        ),
        onTap: () => context.push('/loan_details/${loan.id}'),
      ),
    );
  }
}
