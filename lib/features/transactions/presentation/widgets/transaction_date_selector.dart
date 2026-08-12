import 'package:flutter/material.dart';

class TransactionDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;

  const TransactionDateSelector({
    super.key,
    required this.selectedDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Fecha', border: OutlineInputBorder()),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 8),
            Text("${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}"),
          ],
        ),
      ),
    );
  }
}
