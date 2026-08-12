import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/persons_provider.dart';

class PersonsCatalogPage extends ConsumerWidget {
  final bool isSelectionMode;
  
  const PersonsCatalogPage({
    super.key,
    this.isSelectionMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personsAsync = ref.watch(personsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactos'),
        centerTitle: true,
      ),
      body: personsAsync.when(
        data: (persons) {
          if (persons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No hay personas registradas.'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/add_person'),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Añadir Persona'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: persons.length,
            itemBuilder: (context, index) {
              final person = persons[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: person.photoPath != null 
                        ? FileImage(File(person.photoPath!)) 
                        : null,
                    child: person.photoPath == null 
                        ? Text(person.name[0].toUpperCase())
                        : null,
                  ),
                  title: Text(person.name),
                  subtitle: person.phone != null && person.phone!.isNotEmpty 
                      ? Text(person.phone!) 
                      : null,
                  trailing: isSelectionMode ? null : IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => context.push('/edit_person/${person.id}'),
                  ),
                  onTap: () {
                    if (isSelectionMode) {
                      context.pop(person);
                    } else {
                      context.push('/edit_person/${person.id}');
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: personsAsync.maybeWhen(
        data: (persons) => persons.isNotEmpty ? FloatingActionButton(
          onPressed: () => context.push('/add_person'),
          child: const Icon(Icons.person_add),
        ) : null,
        orElse: () => null,
      ),
    );
  }
}
