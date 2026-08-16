import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../persons/domain/entities/person.dart';

class PersonSelectorField extends StatelessWidget {
  final PersonEntity? selectedPerson;
  final ValueChanged<PersonEntity?> onChanged;

  const PersonSelectorField({
    super.key,
    required this.selectedPerson,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final person = await context.push<PersonEntity?>(
          '/persons?select=true',
        );
        if (person != null) {
          onChanged(person);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Persona (Requerido)',
          border: OutlineInputBorder(),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_outline),
            const SizedBox(width: 8),
            Text(selectedPerson?.name ?? 'Seleccionar persona'),
          ],
        ),
      ),
    );
  }
}
