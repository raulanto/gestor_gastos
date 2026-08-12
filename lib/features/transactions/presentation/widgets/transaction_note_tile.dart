import 'package:flutter/material.dart';

class TransactionNoteTile extends StatelessWidget {
  final String note;

  const TransactionNoteTile({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    if (note.isEmpty) return const SizedBox.shrink();
    return ListTile(
      leading: const Icon(Icons.notes, size: 32),
      title: const Text('Nota'),
      subtitle: Text(note, style: const TextStyle(fontSize: 16)),
    );
  }
}
