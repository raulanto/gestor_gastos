import 'package:flutter/material.dart';

class AmountInputField extends StatelessWidget {
  final FormFieldSetter<String> onSaved;
  final String? initialValue;

  const AmountInputField({super.key, required this.onSaved, this.initialValue});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: const InputDecoration(
        labelText: 'Monto',
        prefixIcon: Icon(Icons.attach_money),
        border: OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Requerido';
        if (double.tryParse(v) == null) return 'Monto inválido';
        return null;
      },
      onSaved: onSaved,
    );
  }
}
