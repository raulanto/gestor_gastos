import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Categorías')),
      body: categoriesState.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('No hay categorías configuradas.'));
          }

          // Agrupar categorías
          final mainCategories = categories.where((c) => c.parentId == null).toList();
          final subCategories = categories.where((c) => c.parentId != null).toList();

          return ListView.builder(
            itemCount: mainCategories.length,
            itemBuilder: (context, index) {
              final mainCategory = mainCategories[index];
              final children = subCategories.where((c) => c.parentId == mainCategory.id).toList();

              if (children.isEmpty) {
                return ListTile(
                  leading: Icon(
                    // ignore: non_const_argument_for_const_parameter
                    IconData(mainCategory.iconCode, fontFamily: 'MaterialIcons'),
                    color: Color(mainCategory.colorCode),
                  ),
                  title: Text(mainCategory.name),
                );
              }

              return ExpansionTile(
                leading: Icon(
                  // ignore: non_const_argument_for_const_parameter
                  IconData(mainCategory.iconCode, fontFamily: 'MaterialIcons'),
                  color: Color(mainCategory.colorCode),
                ),
                title: Text(mainCategory.name),
                children: children.map((child) {
                  return ListTile(
                    contentPadding: const EdgeInsets.only(left: 72.0, right: 16.0),
                    leading: Icon(
                      // ignore: non_const_argument_for_const_parameter
                      IconData(child.iconCode, fontFamily: 'MaterialIcons'),
                      color: Color(child.colorCode),
                    ),
                    title: Text(child.name),
                  );
                }).toList(),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Añadir categoría nueva
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
