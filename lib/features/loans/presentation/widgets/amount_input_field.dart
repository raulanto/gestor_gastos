import 'package:flutter/material.dart';

class AmountInputField extends StatelessWidget {
  final FormFieldSetter<String> onSaved;

  const AmountInputField({super.key, required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Monto', 
        prefixIcon: Icon(Icons.attach_money), 
        border: OutlineInputBorder()
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
