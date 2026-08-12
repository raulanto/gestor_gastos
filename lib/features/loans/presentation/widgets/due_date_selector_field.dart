import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DueDateSelectorField extends StatelessWidget {
  final DateTime dueDate;
  final ValueChanged<DateTime> onChanged;

  const DueDateSelectorField({
    super.key,
    required this.dueDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: dueDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha de pago',
          border: OutlineInputBorder(),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 8),
            Text(DateFormat('dd/MM/yyyy').format(dueDate)),
          ],
        ),
      ),
    );
  }
}
