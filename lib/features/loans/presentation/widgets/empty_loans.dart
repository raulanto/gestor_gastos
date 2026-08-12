import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmptyLoans extends StatelessWidget {
  const EmptyLoans({super.key});

  @override
  Widget build(BuildContext context) {
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
}
