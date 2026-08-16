import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import '../widgets/add_edit_category_dialog.dart';
import 'package:gestor_gastos/core/utils/icon_utils.dart';

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

          final mainCategories = categories
              .where((c) => c.parentId == null)
              .toList();
          final subCategories = categories
              .where((c) => c.parentId != null)
              .toList();

          return ListView.builder(
            itemCount: mainCategories.length,
            itemBuilder: (context, index) {
              final mainCategory = mainCategories[index];
              final children = subCategories
                  .where((c) => c.parentId == mainCategory.id)
                  .toList();

              final editButton = IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) =>
                        AddEditCategoryDialog(category: mainCategory),
                  );
                },
              );
              final deleteButton = IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  ref
                      .read(categoriesProvider.notifier)
                      .deleteCategory(mainCategory.id);
                },
              );

              final mainActions = Row(
                mainAxisSize: MainAxisSize.min,
                children: [editButton, deleteButton],
              );

              if (children.isEmpty) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(
                      mainCategory.colorCode,
                    ).withValues(alpha: 0.2),
                    child: Icon(
                      IconUtils.getIcon(mainCategory.iconCode),
                      color: Color(mainCategory.colorCode),
                    ),
                  ),
                  title: Text(mainCategory.name),
                  trailing: mainActions,
                );
              }

              return ExpansionTile(
                controlAffinity: ListTileControlAffinity.leading,
                leading: CircleAvatar(
                  backgroundColor: Color(
                    mainCategory.colorCode,
                  ).withValues(alpha: 0.2),
                  child: Icon(
                    IconUtils.getIcon(mainCategory.iconCode),
                    color: Color(mainCategory.colorCode),
                  ),
                ),
                title: Text(mainCategory.name),
                trailing: mainActions,
                children: children.map((child) {
                  return ListTile(
                    contentPadding: const EdgeInsets.only(
                      left: 72.0,
                      right: 16.0,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Color(
                        child.colorCode,
                      ).withValues(alpha: 0.2),
                      radius: 16,
                      child: Icon(
                        IconUtils.getIcon(child.iconCode),
                        color: Color(child.colorCode),
                        size: 18,
                      ),
                    ),
                    title: Text(child.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) =>
                                  AddEditCategoryDialog(category: child),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            ref
                                .read(categoriesProvider.notifier)
                                .deleteCategory(child.id);
                          },
                        ),
                      ],
                    ),
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
          showDialog(
            context: context,
            builder: (_) => const AddEditCategoryDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
