import 'package:flutter/material.dart';

class LoanTypeSelectorField extends StatelessWidget {
  final String type;
  final ValueChanged<String?> onChanged;

  const LoanTypeSelectorField({
    super.key,
    required this.type,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Tipo', 
        prefixIcon: Icon(Icons.category),
        border: OutlineInputBorder()
      ),
      value: type,
      items: const [
        DropdownMenuItem(
          value: 'efectivo', 
          child: Row(
            children: [
              Icon(Icons.money, color: Colors.green),
              SizedBox(width: 8),
              Text('Efectivo'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'tarjeta', 
          child: Row(
            children: [
              Icon(Icons.credit_card, color: Colors.blue),
              SizedBox(width: 8),
              Text('Tarjeta'),
            ],
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
